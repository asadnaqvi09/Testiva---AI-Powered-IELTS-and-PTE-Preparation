import 'package:flutter/material.dart';
import 'app_theme.dart';

class CircleIconButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  final double size;
  final Color? iconColor;
  final Widget? badge;

  const CircleIconButton({
    super.key,
    required this.icon,
    required this.onTap,
    this.size = 40,
    this.iconColor,
    this.badge,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: SizedBox(
        width: size,
        height: size,
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            Container(
              width: size,
              height: size,
              decoration: AppTheme.circleIconDecor(context),
              child: Icon(
                icon,
                size: size * 0.5,
                color: iconColor ?? AppTheme.iconColor(context),
              ),
            ),
            if (badge != null)
              Positioned(
                top: -1,
                right: -1,
                child: badge!,
              ),
          ],
        ),
      ),
    );
  }
}
