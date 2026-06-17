import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../../widgets/app_theme.dart';

class MediaTabContent extends StatelessWidget {
  final List<dynamic> mediaItems;

  const MediaTabContent({super.key, required this.mediaItems});

  void _openFile(BuildContext context, String url) async {
    try {
      final uri = Uri.parse(url);
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Could not open file: $e'), backgroundColor: Colors.red),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = AppTheme.isDark(context);

    if (mediaItems.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 40),
          child: Column(
            children: [
              Icon(Icons.folder_open, size: 64, color: isDark ? Colors.grey[700] : Colors.grey[300]),
              const SizedBox(height: 16),
              Text(
                'No Study Materials Available',
                style: TextStyle(color: AppTheme.secondaryText(context), fontSize: 16),
              ),
            ],
          ),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 15, top: 5),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Study Materials (${mediaItems.length})',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.primaryText(context),
                ),
              ),
              Text(
                'Admin uploaded',
                style: TextStyle(
                  fontSize: 12,
                  color: AppTheme.secondaryText(context),
                ),
              ),
            ],
          ),
        ),
        ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: mediaItems.length,
          separatorBuilder: (context, index) => const SizedBox(height: 15),
          itemBuilder: (context, index) {
            final media = mediaItems[index];
            final fileName = media['file_name'] ?? 'Document.pdf';
            final fileUrl = media['file_url'] ?? '';
            // Basic extraction or default values
            final isStrategy = fileName.toLowerCase().contains('strategy') || fileName.toLowerCase().contains('guide');
            final tagText = isStrategy ? 'Strategy' : 'Practice';
            
            // Format file size from backend if available, otherwise mock
            final rawSize = media['file_size'];
            String sizeStr = '2.4 MB'; // default mock
            if (rawSize != null && rawSize is num) {
               // Assuming bytes
               sizeStr = '${(rawSize / (1024 * 1024)).toStringAsFixed(1)} MB';
            } else if (rawSize != null && rawSize is String) {
               sizeStr = rawSize;
            }

            return Container(
              decoration: BoxDecoration(
                color: AppTheme.cardBg(context),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: isDark ? Colors.grey[800]! : Colors.grey[200]!),
              ),
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.red.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Icon(Icons.picture_as_pdf, color: Colors.red, size: 24),
                        ),
                        const SizedBox(width: 15),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                fileName,
                                style: TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.bold,
                                  color: AppTheme.primaryText(context),
                                ),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 8),
                              Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                    decoration: BoxDecoration(
                                      color: Colors.red.withOpacity(0.1),
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                    child: const Text('PDF', style: TextStyle(color: Colors.red, fontSize: 10, fontWeight: FontWeight.bold)),
                                  ),
                                  const SizedBox(width: 8),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                    decoration: BoxDecoration(
                                      color: Colors.grey.withOpacity(0.1),
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                    child: Text(tagText, style: TextStyle(color: isDark ? Colors.grey[300] : Colors.grey[700], fontSize: 10, fontWeight: FontWeight.w600)),
                                  ),
                                  const SizedBox(width: 8),
                                  Text(sizeStr, style: TextStyle(color: AppTheme.secondaryText(context), fontSize: 11)),
                                ],
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'Uploaded by Admin',
                                style: TextStyle(color: AppTheme.secondaryText(context), fontSize: 11),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  Divider(height: 1, color: isDark ? Colors.grey[800] : Colors.grey[200]),
                  Row(
                    children: [
                      Expanded(
                        child: TextButton.icon(
                          onPressed: () => _openFile(context, fileUrl),
                          icon: const Icon(Icons.remove_red_eye_outlined, size: 18, color: Colors.blue),
                          label: const Text('Preview', style: TextStyle(color: Colors.blue, fontWeight: FontWeight.w600)),
                          style: TextButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            shape: const RoundedRectangleBorder(borderRadius: BorderRadius.only(bottomLeft: Radius.circular(16))),
                          ),
                        ),
                      ),
                      Container(width: 1, height: 40, color: isDark ? Colors.grey[800] : Colors.grey[200]),
                      Expanded(
                        child: TextButton.icon(
                          onPressed: () => _openFile(context, fileUrl),
                          icon: const Icon(Icons.file_download_outlined, size: 18, color: Colors.green),
                          label: const Text('Download', style: TextStyle(color: Colors.green, fontWeight: FontWeight.w600)),
                          style: TextButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            shape: const RoundedRectangleBorder(borderRadius: BorderRadius.only(bottomRight: Radius.circular(16))),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            );
          },
        ),
      ],
    );
  }
}
