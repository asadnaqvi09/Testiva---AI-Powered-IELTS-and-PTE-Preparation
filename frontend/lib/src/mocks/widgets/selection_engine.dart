import 'package:flutter/material.dart';

class SelectionEngineWidget extends StatelessWidget {
  final List<String> options;
  final dynamic selectedAnswer;
  final ValueChanged<String> onChanged;

  const SelectionEngineWidget({
    super.key,
    required this.options,
    required this.selectedAnswer,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: List.generate(options.length, (index) {
        final currentOptionString = options[index];
        final String prefixLetter = String.fromCharCode(64 + (index + 1));
        final bool isMatchedSelection = selectedAnswer == currentOptionString;

        return Padding(
          padding: const EdgeInsets.only(bottom: 12.0),
          child: InkWell(
            onTap: () => onChanged(currentOptionString),
            borderRadius: BorderRadius.circular(14),
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: isMatchedSelection ? const Color(0xFFEDF5FF) : const Color(0xFFF8FAFC),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: isMatchedSelection ? const Color(0xFF0066F5) : const Color(0xFFE2E8F0),
                  width: isMatchedSelection ? 1.5 : 1.0,
                ),
              ),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 16,
                    backgroundColor: isMatchedSelection ? const Color(0xFF0066F5) : const Color(0xFFE2E8F0),
                    child: Text(
                        prefixLetter,
                        style: TextStyle(
                            color: isMatchedSelection ? Colors.white : Colors.black54, // Fixed black80 error
                            fontSize: 12,
                            fontWeight: FontWeight.bold
                        )
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      currentOptionString,
                      style: TextStyle(
                          fontSize: 14,
                          fontWeight: isMatchedSelection ? FontWeight.bold : FontWeight.w500, // Fixed BondWeight error
                          color: isMatchedSelection ? const Color(0xFF0F172A) : const Color(0xFF334155)
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      }),
    );
  }
}