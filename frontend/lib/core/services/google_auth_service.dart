import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'api_service.dart';
import 'user_notifier.dart';

class GoogleAuthService {
  static final GoogleSignIn _googleSignIn = GoogleSignIn(
    serverClientId: '298829936456-ftno9o41s987ca986oek9hrmjst0odfo.apps.googleusercontent.com',
    scopes: ['email', 'profile'],
  );

  static Future<void> handleGoogleSignIn(BuildContext context) async {
    try {
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) {
        return;
      }

      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
      final String? idToken = googleAuth.idToken;

      if (idToken == null || idToken.isEmpty) {
        throw Exception('Could not fetch Google ID Token. Please try again.');
      }

      final response = await ApiService.post('/auth/google', {
        'idToken': idToken,
      });

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);

        if (responseData['success'] == true) {
          if (responseData['accessToken'] != null) {
            await ApiService.setToken(responseData['accessToken']);
          }

          if (responseData['user'] != null) {
            UserNotifier.notifier.value = responseData['user'];
          }

          if (!context.mounted) return;

          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Successfully authenticated with Google!'),
              backgroundColor: Colors.green,
            ),
          );

          final userPreference = responseData['user']['preference'];
          final userName = responseData['user']['full_name'] ?? 'User';

          if (userPreference == null) {
            Navigator.pushNamedAndRemoveUntil(
              context,
              '/select-preference',
                  (route) => false,
              arguments: userName,
            );
          } else {
            Navigator.pushNamedAndRemoveUntil(
              context,
              '/dashboard',
                  (route) => false,
            );
          }
        } else {
          if (!context.mounted) return;
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(responseData['message'] ?? 'Google Authentication failed on backend.'),
              backgroundColor: Colors.red,
            ),
          );
        }
      } else {
        if (!context.mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Server Error (${response.statusCode}): Google endpoint status mismatch.'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      if (!context.mounted) return;

      final String errorMessage = e.toString();
      String debugMessage = 'Google Sign-In failed: $errorMessage';
      if (errorMessage.contains('API_EXCEPTION') || errorMessage.contains('10')) {
        debugMessage = 'Google Sign-In configuration error: Please check if your SHA-1 matching matches exactly with Google Cloud Console and clear app data.';
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