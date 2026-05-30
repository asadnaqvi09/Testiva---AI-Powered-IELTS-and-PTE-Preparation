import 'package:flutter/material.dart';

class MockTestCard extends StatelessWidget {
  final VoidCallback onTap;

  const MockTestCard({super.key, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        title: const Text('Academic Reading Mock Test'),
        trailing: ElevatedButton(
          onPressed: onTap, // Dashboard se aaya hua navigation flow execute hoga
          child: const Text('Start Test'),
        ),
      ),
    );
  }
}