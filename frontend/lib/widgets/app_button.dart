import 'package:flutter/material.dart';

class AppButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed; // Maine yahan '?' add kiya hai
  final bool isOutline;

  const AppButton({
    super.key,
    required this.text,
    this.onPressed, // 'required' hata diya taake null aa sake
    this.isOutline = false,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: isOutline
          ? OutlinedButton(
        onPressed: onPressed,
        style: OutlinedButton.styleFrom(
          side: BorderSide(
              color: onPressed == null ? Colors.grey.shade300 : const Color(0xFF007BFF),
              width: 1.5
          ),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
        child: Text(
            text,
            style: TextStyle(
                color: onPressed == null ? Colors.grey : const Color(0xFF007BFF),
                fontWeight: FontWeight.w600
            )
        ),
      )
          : ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF007BFF),
          disabledBackgroundColor: const Color(0xFFB0D4FF), // Disable hone par light blue color
          elevation: 0,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
        child: Text(
            text,
            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600)
        ),
      ),
    );
  }
}