/// Runtime API configuration for showcase devices.
///
/// Override at build/run time:
/// ```bash
/// flutter run --dart-define=API_BASE_URL=http://192.168.1.10:5000/api/v1
/// ```
///
/// Defaults to Android emulator loopback (`10.0.2.2`). For a physical device
/// on the same LAN, always pass `--dart-define=API_BASE_URL=...`.
class AppConfig {
  AppConfig._();

  static const String apiBaseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'http://10.0.2.2:5000/api/v1',
  );
}
