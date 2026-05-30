import 'package:flutter/material.dart';

class MatchingEngineWidget extends StatelessWidget {
  final List<String> questionsToMatch;
  final List<String> availableOptions;
  final Map<String, String> selectedAnswers;
  final Function(String question, String selectedOption) onOptionChanged;

  const MatchingEngineWidget({
    super.key,
    required this.questionsToMatch,
    required this.availableOptions,
    required this.selectedAnswers,
    required this.onOptionChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: List.generate(questionsToMatch.length, (index) {
        final targetQuestion = questionsToMatch[index];
        final currentSelection = selectedAnswers[targetQuestion];

        return Padding(
          padding: const EdgeInsets.only(bottom: 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  CircleAvatar(
                    radius: 11,
                    backgroundColor: const Color(0xFFF59E0B),
                    child: Text(
                      '${index + 1}',
                      style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      targetQuestion,
                      style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: Color(0xFF1E293B)),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(horizontal: 14),
                decoration: BoxDecoration(
                  color: currentSelection != null ? const Color(0xFFE0F2FE) : const Color(0xFFF8FAFC),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: currentSelection != null ? const Color(0xFF38BDF8) : const Color(0xFFE2E8F0),
                    width: 1,
                  ),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: currentSelection,
                    hint: const Text(
                      '— Select answer —',
                      style: TextStyle(color: Colors.grey, fontSize: 14), // Fixed slateGrey error
                    ),
                    isExpanded: true,
                    icon: const Icon(Icons.keyboard_arrow_down, color: Colors.grey), // Fixed slateGrey error
                    style: const TextStyle(fontSize: 14, color: Color(0xFF334155), fontWeight: FontWeight.w500),
                    dropdownColor: const Color(0xFFEDF5FF),
                    borderRadius: BorderRadius.circular(12),
                    items: availableOptions.map((String option) {
                      return DropdownMenuItem<String>(
                        value: option,
                        child: Text(option, overflow: TextOverflow.ellipsis, maxLines: 2),
                      );
                    }).toList(),
                    onChanged: (newValue) {
                      if (newValue != null) {
                        onOptionChanged(targetQuestion, newValue);
                      }
                    },
                  ),
                ),
              ),
            ],
          ),
        );
      }),
    );
  }
}