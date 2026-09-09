import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:frontend/core/config/app_config.dart';
import 'package:frontend/core/services/multicast_lock.dart';
import 'package:http/http.dart' as http;
import 'package:multicast_dns/multicast_dns.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Resolves the API origin: dart-define → cache → mDNS → emulator → default.
class ApiOriginResolver {
  ApiOriginResolver._();

  static String? _lastPersistedBase;

  static final _ipv4 = RegExp(
    r'^(?:(?:25[0-5]|2[0-4]\d|1?\d?\d)\.){3}(?:25[0-5]|2[0-4]\d|1?\d?\d)$',
  );

  static Future<void> resolve() async {
    if (AppConfig.hasDartDefine) {
      AppConfig.applyResolved(AppConfig.dartDefineApiBase, 'define');
      return;
    }

    final cached = await _loadCachedBase();
    if (cached != null && await pingHealth(cached)) {
      AppConfig.applyResolved(cached, 'cache');
      await persistCurrentBase();
      return;
    }

    if (kDebugMode && !kIsWeb && Platform.isAndroid) {
      if (await pingHealth(
        AppConfig.emulatorApi,
        timeout: const Duration(milliseconds: 800),
      )) {
        AppConfig.applyResolved(AppConfig.emulatorApi, 'emulator');
        await persistCurrentBase();
        return;
      }
    }

    final mdnsBase = await _lookupMdns();
    if (mdnsBase != null && await pingHealth(mdnsBase)) {
      AppConfig.applyResolved(mdnsBase, 'mdns');
      await persistCurrentBase();
      return;
    }

    if (await pingHealth(AppConfig.defaultLanApi)) {
      AppConfig.applyResolved(AppConfig.defaultLanApi, 'default');
      await persistCurrentBase();
      return;
    }

    AppConfig.applyResolved(AppConfig.defaultLanApi, 'default');
  }

  static Future<String?> _loadCachedBase() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(AppConfig.lastApiBasePrefsKey);
    if (raw == null || raw.isEmpty) return null;
    return AppConfig.normalizeApiBase(raw);
  }

  static Future<void> persistCurrentBase() async {
    final current = AppConfig.apiBaseUrl;
    if (_lastPersistedBase == current) return;
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(AppConfig.lastApiBasePrefsKey, current);
      _lastPersistedBase = current;
    } catch (e) {
      debugPrint('[Testiva] failed to persist API origin: $e');
    }
  }

  static Future<bool> pingHealth(
    String apiBase, {
    Duration timeout = const Duration(milliseconds: 1500),
  }) async {
    try {
      final uri = Uri.parse('${AppConfig.normalizeApiBase(apiBase)}/health');
      final response = await http.get(uri).timeout(timeout);
      if (response.statusCode != 200) return false;
      final decoded = jsonDecode(response.body);
      if (decoded is! Map) return false;
      if (decoded['success'] != true) return false;
      final data = decoded['data'];
      if (data is Map && data['service'] != null) {
        return data['service'].toString() == 'testiva';
      }
      return true;
    } catch (_) {
      return false;
    }
  }

  static Future<String?> _lookupMdns() async {
    await MulticastLock.acquire();
    // Android rejects SO_REUSEPORT; force reusePort: false for bind.
    final client = MDnsClient(
      rawDatagramSocketFactory:
          (
            dynamic host,
            int port, {
            bool reuseAddress = true,
            bool reusePort = false,
            int ttl = 1,
          }) {
            return RawDatagramSocket.bind(
              host,
              port,
              reuseAddress: reuseAddress,
              reusePort: false,
              ttl: ttl,
            );
          },
    );
    try {
      await client.start(
        onError: (Object e, [StackTrace? st]) {
          debugPrint('[Testiva] mDNS socket error: $e');
        },
      );
      await for (final ptr
          in client
              .lookup<PtrResourceRecord>(
                ResourceRecordQuery.serverPointer(AppConfig.mdnsServiceType),
              )
              .timeout(
                const Duration(seconds: 2),
                onTimeout: (sink) => sink.close(),
              )) {
        final base = await _resolveService(client, ptr.domainName);
        if (base != null) return base;
      }
    } catch (e) {
      debugPrint('[Testiva] mDNS lookup failed: $e');
    } finally {
      try {
        client.stop();
      } catch (_) {}
      await MulticastLock.release();
    }
    return null;
  }

  static Future<String?> _resolveService(
    MDnsClient client,
    String domainName,
  ) async {
    String? host;
    var port = 5000;
    String? txtIp;

    await for (final srv
        in client
            .lookup<SrvResourceRecord>(ResourceRecordQuery.service(domainName))
            .timeout(
              const Duration(milliseconds: 800),
              onTimeout: (sink) => sink.close(),
            )) {
      host = srv.target;
      port = srv.port;
      break;
    }

    await for (final txt
        in client
            .lookup<TxtResourceRecord>(ResourceRecordQuery.text(domainName))
            .timeout(
              const Duration(milliseconds: 500),
              onTimeout: (sink) => sink.close(),
            )) {
      txtIp = _ipFromTxt(txt);
      if (txtIp != null) break;
    }

    if (txtIp != null && _isUsableIPv4(txtIp)) {
      return AppConfig.normalizeApiBase('http://$txtIp:$port');
    }

    if (host == null || host.isEmpty) return null;
    final hostBare = host.endsWith('.')
        ? host.substring(0, host.length - 1)
        : host;
    if (_isUsableIPv4(hostBare)) {
      return AppConfig.normalizeApiBase('http://$hostBare:$port');
    }

    await for (final a
        in client
            .lookup<IPAddressResourceRecord>(
              ResourceRecordQuery.addressIPv4(host),
            )
            .timeout(
              const Duration(milliseconds: 800),
              onTimeout: (sink) => sink.close(),
            )) {
      final ip = a.address.address;
      if (_isUsableIPv4(ip)) {
        return AppConfig.normalizeApiBase('http://$ip:$port');
      }
    }
    return null;
  }

  static String? _ipFromTxt(TxtResourceRecord txt) {
    final match = RegExp(r'ip=(\d{1,3}(?:\.\d{1,3}){3})').firstMatch(txt.text);
    final ip = match?.group(1);
    if (ip != null && _isUsableIPv4(ip)) return ip;
    return null;
  }

  static bool _isUsableIPv4(String ip) {
    if (!_ipv4.hasMatch(ip)) return false;
    if (ip.startsWith('127.')) return false;
    if (ip.startsWith('169.254.')) return false;
    return true;
  }
}
