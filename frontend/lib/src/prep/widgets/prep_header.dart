  import 'package:flutter/material.dart';
  import 'package:frontend/core/constants/app_colors.dart';
  import 'package:frontend/widgets/app_theme.dart';

  class PrepHeader extends StatelessWidget implements PreferredSizeWidget {
    final GlobalKey<ScaffoldState> scaffoldKey;

    const PrepHeader({super.key, required this.scaffoldKey});

    @override
    Widget build(BuildContext context) {
      return Container(
        color: AppTheme.appBarBg(context),

        padding: const EdgeInsets.only(top: 20, left: 20, right: 20, bottom: 10),
        child: SafeArea(
          bottom: false,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              GestureDetector(
                onTap: () => scaffoldKey.currentState?.openDrawer(),
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppTheme.surfaceBg(context),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(Icons.menu, color: AppTheme.iconColor(context), size: 24),
                ),
              ),
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppColors.primary,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(Icons.menu_book_rounded, color: Colors.white, size: 20),
                  ),
                  const SizedBox(width: 10),
                  Text(
                    'Testiva',
                    style: TextStyle(
                      color: AppTheme.primaryText(context),
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                  ),
                ],
              ),
              const CircleAvatar(
                backgroundColor: AppColors.primary,
                child: Text('AK', style: TextStyle(color: Colors.white, fontSize: 12)),
              ),
            ],
          ),
        ),
      );
    }

    @override

    Size get preferredSize => const Size.fromHeight(90);
  }