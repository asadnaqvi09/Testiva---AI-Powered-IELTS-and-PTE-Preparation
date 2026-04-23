import 'package:flutter/material.dart';

class ProgressCard extends StatelessWidget {
  const ProgressCard({super.key});

  @override
  Widget build(BuildContext context) {
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
              const Text("Overall Progress", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const Text("Keep going, you're doing great!", style: TextStyle(color: Colors.grey, fontSize: 13)),
              const SizedBox(height: 15),
              Row(
                children: [
                  _tabItem("IELTS", true),
                  const SizedBox(width: 10),
                  _tabItem("PTE", false),
                ],
              )
            ],
          ),
          Stack(
            alignment: Alignment.center,
            children: [
              SizedBox(
                height: 80, width: 80,
                child: CircularProgressIndicator(
                  value: 0.65,
                  strokeWidth: 8,
                  backgroundColor: Colors.blue.shade50,
                  color: Colors.blue,
                ),
              ),
              const Text("65%", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.blue)),
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
    child: Text(label, style: TextStyle(color: isActive ? Colors.blue : Colors.grey, fontWeight: FontWeight.bold, fontSize: 12)),
  );
}