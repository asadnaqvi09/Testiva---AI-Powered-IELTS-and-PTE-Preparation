import 'package:flutter/material.dart';

class SocialLoginBtns extends StatelessWidget {
  const SocialLoginBtns({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _socialBtn(
            label: "Google",
            txtColor: Colors.black,
            bgColor: Colors.white,
          ),
        ),
      ],
    );
  }

  Widget _socialBtn({
    required String label,
    required Color txtColor,
    required Color bgColor,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 15),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFEEEEEE)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Image.asset(
            'assets/icons/google_logo_vibrant.png',
            height: 24,
            width: 24,
            fit: BoxFit.contain,
            // Agar image na miley toh crash na ho
            errorBuilder: (context, error, stackTrace) =>
            const Icon(Icons.g_mobiledata, color: Colors.blue, size: 24),
          ),
          const SizedBox(width: 12),
          // Flexible lagane se overflow khatam ho jayega
          Flexible(
            child: Text(
              label,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: txtColor,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
          ),
        ],
      ),
    );
  }
}