import 'dart:io' show Platform;
import 'package:flutter/foundation.dart' show kIsWeb;

class ApiConstants {
  // Dynamically determines the base URL based on the platform.
  // - kIsWeb: Uses localhost
  // - Platform.isAndroid: Uses 10.0.2.2 for emulator
  // - Platform.isIOS: Uses 127.0.0.1 for simulator
  // 
  // NOTE: If you are testing on a real physical device, change 'fallbackIp'
  // to your computer's local Wi-Fi IP address (e.g., 192.168.1.x)
  static String get baseUrl {
    const String port = '5000';
    const String apiVersion = '/api/v1';
    
    if (kIsWeb) {
      return 'http://localhost:$port$apiVersion';
    }

    try {
      if (Platform.isAndroid) {
        return 'http://10.0.2.2:$port$apiVersion';
      } else if (Platform.isIOS) {
        return 'http://127.0.0.1:$port$apiVersion';
      }
    } catch (e) {
      // Platform check might fail on the web or some unsupported targets.
      // We gracefully fallback below.
    }

    // Default for Physical Devices. Replace this with your actual IPv4 address
    // obtained from `ipconfig` (Windows) or `ifconfig` (macOS).
    const String fallbackIp = '192.168.1.100'; 
    return 'http://$fallbackIp:$port$apiVersion';
  }

  // Common endpoints
  static const String login = '/auth/login';
  static const String register = '/auth/register';
  static const String aiResponseFeedback = '/ai/response-feedback';
}
