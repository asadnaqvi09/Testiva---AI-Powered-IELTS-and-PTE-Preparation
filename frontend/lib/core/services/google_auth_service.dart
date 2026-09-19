import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:frontend/core/config/app_config.dart';
import 'api_service.dart';
import 'auth_navigation_helper.dart';

class GoogleAuthService {
  /// Must match Backend `GOOGLE_CLIENT_ID` (Web OAuth client / serverClientId).
  /// Override: `flutter run --dart-define=GOOGLE_SERVER_CLIENT_ID=....apps.googleusercontent.com`
  static const String serverClientId = String.fromEnvironment(
    'GOOGLE_SERVER_CLIENT_ID',
    defaultValue:
        '298829936456-ftno9o41s987ca986oek9hrmjst0odfo.apps.googleusercontent.com',
  );

  static final GoogleSignIn _googleSignIn = GoogleSignIn(
    serverClientId: serverClientId,
    scopes: const ['email', 'profile'],
  );

  static Future<void> signOut() async {
    try {
      await _googleSignIn.signOut();
    } catch (_) {}
  }

  static void _showLoadingOverlay(BuildContext context) {
    showDialog<void>(
      context: context,
      barrierDismissible: false,
      useRootNavigator: true,
      builder: (_) => const PopScope(
        canPop: false,
        child: Center(
          child: Card(
            child: Padding(
              padding: EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text('Signing in with Google...'),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  static void _hideLoadingOverlay(BuildContext context) {
    if (Navigator.of(context, rootNavigator: true).canPop()) {
      Navigator.of(context, rootNavigator: true).pop();
    }
  }

  static Future<void> handleGoogleSignIn(BuildContext context) async {
    if (!context.mounted) return;

    var overlayShown = false;

    try {
      // Account picker must run first (overlay dialog would block forever).
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) return;

      if (!context.mounted) return;
      overlayShown = true;
      _showLoadingOverlay(context);

      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;
      final String? idToken = googleAuth.idToken;

      if (idToken == null || idToken.isEmpty) {
        throw Exception(
          'Could not fetch Google ID Token. Ensure GOOGLE_CLIENT_ID on the '
          'backend matches serverClientId ($serverClientId).',
        );
      }

      final response = await ApiService.post('/auth/google', {
        'idToken': idToken,
      });

      if (!context.mounted) return;
      if (overlayShown) {
        _hideLoadingOverlay(context);
        overlayShown = false;
      }

      final responseData = ApiService.parseJsonObject(response.body);
      final payload = ApiService.unwrapAuthPayload(responseData);

      if (response.statusCode == 200 &&
          (responseData['success'] == true || payload['accessToken'] != null)) {
        await ApiService.persistAuthResponse(payload);

        if (!context.mounted) return;

        final user = ApiService.userFromAuthPayload(payload);
        if (user['email'] == null || user['email'].toString().isEmpty) {
          user['email'] = googleUser.email;
        }
        if (user['full_name'] == null || user['full_name'].toString().isEmpty) {
          user['full_name'] = googleUser.displayName ?? googleUser.email;
        }

        await AuthNavigationHelper.navigateAfterAuth(
          context,
          user: user,
          successMessage: 'Successfully authenticated with Google!',
        );
        return;
      }

      if (!context.mounted) return;

      final message = responseData['message']?.toString() ??
          'Google authentication failed. Please try again.';

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 5),
        ),
      );
    } catch (e) {
      if (context.mounted && overlayShown) {
        _hideLoadingOverlay(context);
      }

      if (!context.mounted) return;

      final String errorMessage = e.toString();
      String debugMessage = 'Google Sign-In failed: $errorMessage';
      if (errorMessage.contains('API_EXCEPTION') ||
          errorMessage.contains('ApiException: 10') ||
          errorMessage.contains(': 10')) {
        debugMessage =
            'Google Sign-In config error (code 10). Check SHA-1 in Firebase/'
            'Google Cloud Console, package name, and clear app data. Host: ${AppConfig.apiOrigin}';
      } else if (errorMessage.contains('audience') ||
          errorMessage.contains('GOOGLE_CLIENT_ID')) {
        debugMessage =
            'Google token audience mismatch. Set Backend GOOGLE_CLIENT_ID to the Web client ID used as serverClientId.';
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(debugMessage),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 6),
        ),
      );
    }
  }
}
