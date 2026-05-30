import 'package:flutter/material.dart';
import '../../../../data/models/prep_module_model.dart';
import '../reading/reading_details_screen.dart';
import '../writing/writing_details_screen.dart';
import '../listening/listening_details_screen.dart';
import '../speaking/speaking_details_screen.dart';

class ModuleCard extends StatelessWidget {
  final PrepModule module;
  const ModuleCard({super.key, required this.module});

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return GestureDetector(
      onTap: () {

        final String titleLower = module.title.toLowerCase();

        if (titleLower.contains('read')) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const ReadingDetailsScreen(),
            ),
          );
        } else if (titleLower.contains('writ')) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const WritingDetailsScreen(),
            ),
          );
        } else if (titleLower.contains('listen')) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const ListeningDetailsScreen(),
            ),
          );
        } else if (titleLower.contains('speak')) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const SpeakingDetailsScreen(),
            ),
          );
        } else {

          ScaffoldMessenger.of(context).clearSnackBars();
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('${module.title} simulation engine module is coming soon! 🚀'),
              behavior: SnackBarBehavior.floating,
              backgroundColor: isDarkMode ? const Color(0xFF1E293B) : const Color(0xFF1E293B),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
          );
        }
      },
      child: Container(
        padding: const EdgeInsets.all(15),
        decoration: BoxDecoration(
          color: isDarkMode ? const Color(0xFF1E1E1E) : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isDarkMode ? Colors.grey[800]! : Colors.grey.shade100,
          ),
          boxShadow: [
            if (!isDarkMode)
              BoxShadow(
                color: Colors.black.withOpacity(0.02),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
          ],
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
                    color: module.color.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(module.icon, color: module.color, size: 24),
                ),
                if (module.isCompleted)
                  const Icon(Icons.check_circle, color: Colors.green, size: 20),
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
                color: isDarkMode ? Colors.white : const Color(0xFF1E293B),
              ),
            ),
            const SizedBox(height: 2),
            Text(
              '${module.lessonsCount} lessons',
              style: const TextStyle(color: Colors.grey, fontSize: 12),
            ),
          ],
        ),
      ),
    );
  }
}