import 'package:flutter/material.dart';
import 'widgets/header_section.dart';
import 'widgets/progress_card.dart';
import 'widgets/stats_row.dart';
import 'widgets/quick_actions_grid.dart';
import 'widgets/ai_recommendation_card.dart';
import 'widgets/daily_tips_list.dart';

class HomePage extends StatelessWidget {
  final GlobalKey<ScaffoldState> scaffoldKey;
  const HomePage({super.key, required this.scaffoldKey});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 10),
              HeaderSection(scaffoldKey: scaffoldKey),
              const SizedBox(height: 20),
              const ProgressCard(),
              const SizedBox(height: 25),
              const StatsRow(),
              const SizedBox(height: 30),
              Text(
                  'Quick Actions',
                  style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: theme.textTheme.titleLarge?.color
                  )
              ),
              const SizedBox(height: 15),
              const QuickActionsGrid(),
              const SizedBox(height: 25),
              const AIRecommendationCard(),
              const SizedBox(height: 25),
              const DailyTipsList(),
              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }
}