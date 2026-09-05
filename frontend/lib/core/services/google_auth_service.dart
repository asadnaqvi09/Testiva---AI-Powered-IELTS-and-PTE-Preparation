import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'api_service.dart';
import 'auth_navigation_helper.dart';

class GoogleAuthService {
  static final GoogleSignIn _googleSignIn = GoogleSignIn(
    serverClientId:
        '298829936456-ftno9o41s987ca986oek9hrmjst0odfo.apps.googleusercontent.com',
    scopes: ['email', 'profile'],
  );

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
      // Account picker must run first. Awaiting showDialog blocks forever
      // because that Future only completes when the overlay is dismissed.
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) return;

      if (!context.mounted) return;
      overlayShown = true;
      _showLoadingOverlay(context);

      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;
      final String? idToken = googleAuth.idToken;

      if (idToken == null || idToken.isEmpty) {
        throw Exception('Could not fetch Google ID Token. Please try again.');
      }

      final response = await ApiService.post('/auth/google', {
        'idToken': idToken,
      });

      if (!context.mounted) return;
      if (overlayShown) {
        _hideLoadingOverlay(context);
        overlayShown = false;
      }

      final responseData = jsonDecode(response.body) as Map<String, dynamic>;

      if (response.statusCode == 200 && responseData['success'] == true) {
        await ApiService.persistAuthResponse(responseData);

        if (!context.mounted) return;

        final user = Map<String, dynamic>.from(
          responseData['user'] as Map<String, dynamic>,
        );

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
      if (errorMessage.contains('API_EXCEPTION') || errorMessage.contains('10')) {
        debugMessage =
            'Google Sign-In configuration error: Please check if your SHA-1 matches Google Cloud Console and clear app data.';
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(debugMessage),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 5),
        ),
      );
    }
  }
}
