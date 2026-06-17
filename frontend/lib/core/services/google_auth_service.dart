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

  static Future<void> _showLoadingOverlay(BuildContext context) {
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
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
    try {
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) {
        return;
      }

      if (!context.mounted) return;
      await _showLoadingOverlay(context);

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
      _hideLoadingOverlay(context);

      final responseData = jsonDecode(response.body) as Map<String, dynamic>;

      if (response.statusCode == 200 && responseData['success'] == true) {
        if (responseData['accessToken'] != null) {
          await ApiService.setToken(responseData['accessToken'].toString());
        }

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
      if (context.mounted) {
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
