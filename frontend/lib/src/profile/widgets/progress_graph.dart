import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:frontend/core/services/api_service.dart';
import 'package:frontend/widgets/app_theme.dart';

class ProgressGraph extends StatefulWidget {
  const ProgressGraph({super.key});

  @override
  State<ProgressGraph> createState() => _ProgressGraphState();
}

class _ProgressGraphState extends State<ProgressGraph> {
  bool _isLoading = true;
  String _weeklyImprovement = '+13%';

  // Dynamic spots matrix mapping
  List<FlSpot> _graphSpots = [];
  final List<String> _days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];

  @override
  void initState() {
    super.initState();
    _fetchLiveGraphData();
  }


  Future<void> _fetchLiveGraphData() async {
    try {
      final response = await ApiService.get('/progress/my-stats');
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['success'] == true && data['data'] != null) {
          final stats = data['data'];


          if (stats['weeklyTrend'] != null || stats['weekly_trend'] != null) {
            _weeklyImprovement = stats['weeklyTrend'] ?? stats['weekly_trend'];
          }

          if (stats['graphData'] != null || stats['graph_data'] != null) {
            final List dynamicList = stats['graphData'] ?? stats['graph_data'];
            List<FlSpot> fetchedSpots = [];

            for (int i = 0; i < dynamicList.length; i++) {
              if (i >= 7) break;
              double score = (dynamicList[i]['score'] ?? 0.0).toDouble();
              fetchedSpots.add(FlSpot(i.toDouble(), score));
            }

            if (fetchedSpots.isNotEmpty) {
              setState(() {
                _graphSpots = fetchedSpots;
                _isLoading = false;
              });
              return;
            }
          }
        }
      }
      _loadOriginalFallbackSpots();
    } catch (e) {
      debugPrint("Graph server retrieval error: ${e.toString()}");
      _loadOriginalFallbackSpots();
    }
  }


  void _loadOriginalFallbackSpots() {
    if (mounted) {
      setState(() {
        _graphSpots = const [
          FlSpot(0, 4),
          FlSpot(1, 5),
          FlSpot(2, 4.5),
          FlSpot(3, 6.2),
          FlSpot(4, 5.8),
          FlSpot(5, 7.5),
          FlSpot(6, 7.0),
        ];
        _weeklyImprovement = '+13%';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 15, 20, 5),
      decoration: BoxDecoration(
        color: AppTheme.cardBg(context),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppTheme.borderColor(context)),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '7-Day Progress',
                style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.primaryText(context)
                ),
              ),
              _isLoading
                  ? const SizedBox(
                  width: 14,
                  height: 14,
                  child: CircularProgressIndicator(strokeWidth: 2, color: Color(0xFF007BFF))
              )
                  : Row(
                children: [
                  const Icon(Icons.trending_up, color: Colors.green, size: 16),
                  const SizedBox(width: 5),
                  Text(
                    '$_weeklyImprovement this week',
                    style: const TextStyle(
                        color: Colors.green,
                        fontWeight: FontWeight.bold,
                        fontSize: 13
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 20),
          SizedBox(
            height: 180,
            child: _isLoading
                ? const Center(child: CircularProgressIndicator(color: Color(0xFF007BFF)))
                : LineChart(
              LineChartData(
                lineTouchData: LineTouchData(
                  enabled: true,
                  touchTooltipData: LineTouchTooltipData(
                    getTooltipColor: (touchedSpot) => const Color(0xFF1E293B),
                    tooltipRoundedRadius: 8,
                    getTooltipItems: (List<LineBarSpot> touchedBarSpots) {
                      return touchedBarSpots.map((barSpot) {
                        int index = barSpot.x.toInt();
                        String dayName = (index >= 0 && index < _days.length) ? _days[index] : '';
                        return LineTooltipItem(
                          '$dayName \nscore : ${barSpot.y}',
                          const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        );
                      }).toList();
                    },
                  ),
                ),
                gridData: FlGridData(
                  show: true,
                  drawHorizontalLine: true,
                  drawVerticalLine: false,
                  horizontalInterval: 1,
                  getDrawingHorizontalLine: (value) => FlLine(
                      color: AppTheme.borderColor(context),
                      strokeWidth: 1
                  ),
                ),
                titlesData: FlTitlesData(
                  show: true,
                  rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      interval: 2,
                      reservedSize: 30,
                      getTitlesWidget: (value, meta) => Text(
                        '${value.toInt()}',
                        style: TextStyle(
                            color: Colors.blueGrey.shade300,
                            fontSize: 11
                        ),
                      ),
                    ),
                  ),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 30,
                      interval: 1,
                      getTitlesWidget: (value, meta) {
                        int index = value.toInt();
                        return (index >= 0 && index < _days.length)
                            ? Text(
                          _days[index],
                          style: TextStyle(
                              color: Colors.blueGrey.shade300,
                              fontSize: 11
                          ),
                        )
                            : const Text('');
                      },
                    ),
                  ),
                ),
                borderData: FlBorderData(show: false),
                minX: 0,
                maxX: 6,
                minY: 0,
                maxY: 9,
                lineBarsData: [
                  LineChartBarData(
                    spots: _graphSpots,
                    isCurved: true,
                    color: const Color(0xFF007BFF),
                    barWidth: 3,
                    isStrokeCapRound: true,
                    dotData: FlDotData(
                      show: true,
                      getDotPainter: (spot, percent, barData, index) =>
                          FlDotCirclePainter(
                            radius: 5,
                            color: AppTheme.cardBg(context),
                            strokeWidth: 2,
                            strokeColor: const Color(0xFF007BFF),
                          ),
                    ),
                    belowBarData: BarAreaData(
                      show: true,
                      gradient: LinearGradient(
                        colors: [
                          const Color(0xFF007BFF).withOpacity(0.2),
                          const Color(0xFF007BFF).withOpacity(0.0),
                        ],
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}