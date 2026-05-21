  import 'package:flutter/material.dart';
  import 'package:frontend/core/constants/app_colors.dart';

  class PrepHeader extends StatelessWidget implements PreferredSizeWidget {
    final GlobalKey<ScaffoldState> scaffoldKey;

    const PrepHeader({super.key, required this.scaffoldKey});

    @override
    Widget build(BuildContext context) {
      return Container(
        color: Colors.white,

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
                    color: Colors.grey.shade50,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(Icons.menu, color: Colors.grey.shade800, size: 24),
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
                  const Text(
                    'Testiva',
                    style: TextStyle(
                      color: Colors.black,
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