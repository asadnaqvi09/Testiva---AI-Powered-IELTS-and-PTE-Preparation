import 'package:flutter/material.dart';
import '../../../../widgets/app_theme.dart';

class CollapsibleLessonTile extends StatefulWidget {
  final String title;
  final List<LessonItem> items;

  const CollapsibleLessonTile({
    super.key,
    required this.title,
    required this.items,
  });

  @override
  State<CollapsibleLessonTile> createState() => _CollapsibleLessonTileState();
}

class _CollapsibleLessonTileState extends State<CollapsibleLessonTile> {
  bool _isExpanded = false;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 15),
      decoration: BoxDecoration(
        color: AppTheme.cardBg(context),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.borderColor(context)),
      ),
      child: Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          // Yeh default arrow ko hata kar hamara custom button dikhaye ga
          trailing: _buildMediaButton(),
          onExpansionChanged: (expanded) => setState(() => _isExpanded = expanded),
          title: Text(
            widget.title,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
              color: AppTheme.primaryText(context),
            ),
          ),
          children: widget.items.map((item) => _buildItem(context, item)).toList(),
        ),
      ),
    );
  }

  Widget _buildMediaButton() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.blue.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        _isExpanded ? "Collapse" : "Media",
        style: const TextStyle(
          color: Colors.blue,
          fontSize: 12,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildItem(BuildContext context, LessonItem item) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        border: Border(top: BorderSide(color: AppTheme.dividerColor(context))),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: item.bgColor,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(item.icon, size: 20, color: item.iconColor),
          ),
          const SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        item.title,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: AppTheme.primaryText(context),
                        ),
                        overflow: TextOverflow.ellipsis,
                        maxLines: 1,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: item.tagColor.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        item.tag,
                        style: TextStyle(
                          color: item.tagColor,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  item.subtitle,
                  style: TextStyle(
                    color: AppTheme.secondaryText(context),
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class LessonItem {
  final String title;
  final String subtitle;
  final String tag;
  final IconData icon;
  final Color bgColor;
  final Color iconColor;
  final Color tagColor;

  LessonItem({
    required this.title,
    required this.subtitle,
    required this.tag,
    required this.icon,
    required this.bgColor,
    required this.iconColor,
    required this.tagColor,
  });
}