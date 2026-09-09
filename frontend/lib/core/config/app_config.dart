/// Runtime API configuration for the Flutter client.
///
/// Phone and PC must be on the **same Wi‑Fi**. Origin is resolved at startup
/// (dart-define → last successful cache → mDNS → default LAN). Admin-Prototype
/// is unchanged (Vite → localhost:5000).
///
/// Manual override still works:
/// ```bash
/// flutter run --dart-define=API_BASE=http://192.168.18.149:5000/api/v1
/// flutter run --dart-define=API_BASE_URL=http://192.168.18.149:5000/api/v1
/// ```
class AppConfig {
  AppConfig._();

  static const String mdnsServiceType = '_testiva._tcp.local';
  static const String lastApiBasePrefsKey = 'testiva_last_api_base';

  static const String _fromApiBase = String.fromEnvironment('API_BASE');
  static const String _fromApiBaseUrl = String.fromEnvironment('API_BASE_URL');

  /// Last-resort PC LAN IPv4 when discovery cannot run (e.g. campus AP isolation).
  static const String defaultLanApi = 'http://192.168.18.149:5000/api/v1';

  /// Android emulator loopback to the host machine.
  static const String emulatorApi = 'http://10.0.2.2:5000/api/v1';

  static String? _resolvedApiBase;
  static String _resolveSource = 'default';

  static bool get hasDartDefine =>
      _fromApiBase.isNotEmpty || _fromApiBaseUrl.isNotEmpty;

  static String get dartDefineApiBase {
    final raw = _fromApiBase.isNotEmpty ? _fromApiBase : _fromApiBaseUrl;
    return normalizeApiBase(raw);
  }

  /// How the current origin was chosen: `define` / `cache` / `mdns` / `emulator` / `default`.
  static String get resolveSource => _resolveSource;

  static String get apiBaseUrl =>
      _resolvedApiBase ?? (hasDartDefine ? dartDefineApiBase : defaultLanApi);

  /// Origin only (`scheme://host:port`) — used by Socket.IO.
  static String get apiOrigin => originFromApiBase(apiBaseUrl);

  static void applyResolved(String apiBase, String source) {
    _resolvedApiBase = normalizeApiBase(apiBase);
    _resolveSource = source;
  }

  static String normalizeApiBase(String raw) {
    var url = raw.trim();
    while (url.endsWith('/')) {
      url = url.substring(0, url.length - 1);
    }
    if (!url.contains('/api/v1')) {
      url = '$url/api/v1';
    }
    return url;
  }

  static String originFromApiBase(String apiBase) {
    final uri = Uri.parse(apiBase);
    if (uri.hasPort && uri.port != 0) {
      return '${uri.scheme}://${uri.host}:${uri.port}';
    }
    return '${uri.scheme}://${uri.host}';
  }

  static String formatConnectionError(Object error) {
    return 'Connection error: $error\nHost: $apiOrigin';
  }
}
