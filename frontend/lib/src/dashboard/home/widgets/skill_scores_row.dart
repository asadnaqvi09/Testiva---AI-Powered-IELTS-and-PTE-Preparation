import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:frontend/core/services/api_service.dart';
import 'package:frontend/widgets/app_theme.dart';

class SkillScore {
  final String label;
  final IconData icon;
  final Color color;
  final double band;
  final String subtitle;
  final bool pending;

  const SkillScore({
    required this.label,
    required this.icon,
    required this.color,
    required this.band,
    this.subtitle = '',
    this.pending = false,
  });
}

class SkillScoresRow extends StatelessWidget {
  final List<SkillScore> skills;

  const SkillScoresRow({super.key, required this.skills});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        for (var i = 0; i < skills.length; i++) ...[
          if (i > 0) const SizedBox(width: 8),
          Expanded(child: _SkillCard(skill: skills[i])),
        ],
      ],
    );
  }
}

class _SkillCard extends StatelessWidget {
  final SkillScore skill;
  const _SkillCard({required this.skill});

  @override
  Widget build(BuildContext context) {
    final value = skill.pending
        ? '…'
        : skill.band > 0
            ? skill.band.toStringAsFixed(skill.band % 1 == 0 ? 0 : 1)
            : '—';
    return Container(
      padding: const EdgeInsets.fromLTRB(8, 12, 8, 10),
      decoration: BoxDecoration(
        color: AppTheme.cardBg(context),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppTheme.borderColor(context)),
      ),
      child: Column(
        children: [
          Icon(skill.icon, size: 18, color: skill.color),
          const SizedBox(height: 6),
          Text(
            value,
            style: TextStyle(
              fontFamily: 'Inter',
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: AppTheme.primaryText(context),
            ),
          ),
          const SizedBox(height: 2),
          Text(
            skill.label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontFamily: 'Inter',
              fontSize: 10,
              fontWeight: FontWeight.w600,
              color: AppTheme.secondaryText(context),
            ),
          ),
          if (skill.subtitle.isNotEmpty) ...[
            const SizedBox(height: 2),
            Text(
              skill.subtitle,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontFamily: 'Inter',
                fontSize: 9,
                color: skill.pending ? Colors.orange : skill.color,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class HomeSkillScores extends StatefulWidget {
  const HomeSkillScores({super.key});

  @override
  State<HomeSkillScores> createState() => _HomeSkillScoresState();
}

class _HomeSkillScoresState extends State<HomeSkillScores> {
  Map<String, dynamic> _skills = const {};

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final response = await ApiService.get('/progress/my-stats');
      if (response.statusCode != 200) return;
      final body = jsonDecode(response.body);
      if (body['success'] == true && body['data'] is Map) {
        final latest = (body['data'] as Map)['latest_skills'];
        if (latest is Map && mounted) {
          setState(() => _skills = Map<String, dynamic>.from(latest));
        }
      }
    } catch (_) {}
  }

  double _band(String key) {
    final v = _skills[key];
    if (v is num) return v.toDouble();
    return double.tryParse(v?.toString() ?? '') ?? 0;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Latest skill bands',
          style: TextStyle(
            fontFamily: 'Inter',
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: AppTheme.primaryText(context),
          ),
        ),
        const SizedBox(height: 10),
        SkillScoresRow(
          skills: [
            SkillScore(
              label: 'Reading',
              icon: Icons.menu_book_outlined,
              color: const Color(0xFF7C3AED),
              band: _band('reading'),
            ),
            SkillScore(
              label: 'Listening',
              icon: Icons.headphones_outlined,
              color: const Color(0xFF16A34A),
              band: _band('listening'),
            ),
            SkillScore(
              label: 'Writing',
              icon: Icons.edit_outlined,
              color: const Color(0xFFEA580C),
              band: _band('writing'),
            ),
            SkillScore(
              label: 'Speaking',
              icon: Icons.mic_none_rounded,
              color: const Color(0xFFDB2777),
              band: _band('speaking'),
            ),
          ],
        ),
      ],
    );
  }
}
