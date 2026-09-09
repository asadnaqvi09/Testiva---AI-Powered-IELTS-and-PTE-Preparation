import 'package:flutter/material.dart';
import '../../../../data/models/prep_module_model.dart';
import '../reading/reading_details_screen.dart';
import '../writing/writing_details_screen.dart';
import '../listening/listening_details_screen.dart';
import '../speaking/speaking_details_screen.dart';
import '../../../../widgets/app_theme.dart';

class ModuleCard extends StatelessWidget {
  final PrepModule module;
  final bool isRecommended;
  const ModuleCard({super.key, required this.module, this.isRecommended = false});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        final String titleLower = module.title.toLowerCase();

        if (titleLower.contains('read')) {
          Navigator.push(context,
              MaterialPageRoute(builder: (context) => const ReadingDetailsScreen()));
        } else if (titleLower.contains('writ')) {
          Navigator.push(context,
              MaterialPageRoute(builder: (context) => const WritingDetailsScreen()));
        } else if (titleLower.contains('listen')) {
          Navigator.push(context,
              MaterialPageRoute(builder: (context) => const ListeningDetailsScreen()));
        } else if (titleLower.contains('speak')) {
          Navigator.push(context,
              MaterialPageRoute(builder: (context) => const SpeakingDetailsScreen()));
        } else {
          ScaffoldMessenger.of(context).clearSnackBars();
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                  '${module.title} simulation engine module is coming soon! 🚀'),
              behavior: SnackBarBehavior.floating,
              backgroundColor: const Color(0xFF1E293B),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)),
            ),
          );
        }
      },
      child: Container(
        padding: const EdgeInsets.all(15),
        decoration: BoxDecoration(
          color: AppTheme.cardBg(context),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isRecommended ? module.color : AppTheme.borderColor(context),
            width: isRecommended ? 2 : 1,
          ),
          boxShadow: AppTheme.cardShadow(context),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: module.color.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(module.icon, color: module.color, size: 24),
                ),
                if (isRecommended)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: module.color.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      'Focus',
                      style: TextStyle(color: module.color, fontSize: 10, fontWeight: FontWeight.bold),
                    ),
                  )
                else if (module.isCompleted)
                  Icon(Icons.check_circle, color: module.color, size: 20)
                else if (module.pdfCount > 0)
                  Container(
                    width: 20,
                    height: 20,
                    alignment: Alignment.center,
                    decoration: const BoxDecoration(
                      color: Color(0xFFDC2626),
                      shape: BoxShape.circle,
                    ),
                    child: Text(
                      '${module.pdfCount}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
              ],
            ),
            const Spacer(),
            Text(
              module.title,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
                color: AppTheme.primaryText(context),
              ),
            ),
            const SizedBox(height: 2),
            Wrap(
              spacing: 8,
              runSpacing: 2,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                Text(
                  '${module.lessonsCount} lessons',
                  style: const TextStyle(color: Colors.grey, fontSize: 12),
                ),
                if (module.pdfCount > 0)
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.picture_as_pdf, color: Color(0xFFDC2626), size: 14),
                      const SizedBox(width: 4),
                      Text(
                        '${module.pdfCount} PDF${module.pdfCount == 1 ? '' : 's'}',
                        style: const TextStyle(color: Colors.grey, fontSize: 12),
                      ),
                    ],
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}