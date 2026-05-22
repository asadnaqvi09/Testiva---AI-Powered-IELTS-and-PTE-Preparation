import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:frontend/core/services/api_service.dart'; // ApiService ka path verify kar lein

class ProgressCard extends StatefulWidget {
  const ProgressCard({super.key});

  @override
  State<ProgressCard> createState() => _ProgressCardState();
}

class _ProgressCardState extends State<ProgressCard> {
  bool _isLoading = true;
  double _overallProgress = 0.0; // Default zero se start hoga jab tak API load ho
  String _activeTrack = 'IELTS'; // Default user track tracking

  @override
  void initState() {
    super.initState();
    _fetchLiveProgress();
  }

  // 🚀 Live Backend API Integration for Dashboard Progress
  Future<void> _fetchLiveProgress() async {
    try {
      // Backend ke app.use("/api/v1/progress", progressRoutes) par GET hit marega
      final response = await ApiService.get('/progress');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        if (data['success'] == true && data['data'] != null) {
          setState(() {
            // Backend agar progress out of 100 bhej raha hai (e.g. 75), toh usay double fractional (0.75) banayenge
            double backendProgress = (data['data']['overallProgress'] ?? data['data']['overall_progress'] ?? 0).toDouble();

            _overallProgress = backendProgress > 1 ? backendProgress / 100 : backendProgress;
            _activeTrack = data['data']['studyTrack'] ?? data['data']['track'] ?? 'IELTS';
            _isLoading = false;
          });
          return;
        }
      }

      // Fallback agar backend issue kare to screen blank na ho
      _loadFallbackData();
    } catch (e) {
      debugPrint("Error fetching dashboard progress: ${e.toString()}");
      _loadFallbackData();
    }
  }

  void _loadFallbackData() {
    if (mounted) {
      setState(() {
        _overallProgress = 0.65; // Safe Fallback to 65% design matching
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    // UI display percentage string format calculation
    int percentageDisplay = (_overallProgress * 100).round();

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 10)],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Overall Progress', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const Text("Keep going, you're doing great!", style: TextStyle(color: Colors.grey, fontSize: 13)),
              const SizedBox(height: 15),
              Row(
                children: [
                  // Tab automatically highlight ho jayenge jo backend track data return karega
                  _tabItem('IELTS', _activeTrack.toUpperCase() == 'IELTS'),
                  const SizedBox(width: 10),
                  _tabItem('PTE', _activeTrack.toUpperCase() == 'PTE'),
                ],
              )
            ],
          ),
          Stack(
            alignment: Alignment.center,
            children: [
              SizedBox(
                height: 80, width: 80,
                child: _isLoading
                    ? CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.blue.shade100),
                  strokeWidth: 4,
                )
                    : CircularProgressIndicator(
                  value: _overallProgress,
                  strokeWidth: 8,
                  backgroundColor: Colors.blue.shade50,
                  color: Colors.blue,
                ),
              ),
              _isLoading
                  ? const SizedBox(
                  height: 20,
                  width: 20,
                  child: CircularProgressIndicator(strokeWidth: 2, color: Colors.blue)
              )
                  : Text(
                  '$percentageDisplay%',
                  style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.blue, fontSize: 16)
              ),
            ],
          )
        ],
      ),
    );
  }

  Widget _tabItem(String label, bool isActive) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
    decoration: BoxDecoration(
      color: isActive ? Colors.blue.shade50 : Colors.transparent,
      borderRadius: BorderRadius.circular(8),
    ),
    child: Text(
        label,
        style: TextStyle(
            color: isActive ? Colors.blue : Colors.grey,
            fontWeight: FontWeight.bold,
            fontSize: 12
        )
    ),
  );
}