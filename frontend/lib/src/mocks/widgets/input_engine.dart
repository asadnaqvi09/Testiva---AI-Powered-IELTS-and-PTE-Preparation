import 'package:flutter/material.dart';

class InputEngineWidget extends StatefulWidget {
  final String initialValue;
  final ValueChanged<String> onChanged;

  const InputEngineWidget({
    super.key,
    required this.initialValue,
    required this.onChanged
  });

  @override
  State<InputEngineWidget> createState() => _InputEngineWidgetState();
}

class _InputEngineWidgetState extends State<InputEngineWidget> {
  late TextEditingController _textController;

  @override
  void initState() {
    super.initState();

    _textController = TextEditingController(text: widget.initialValue);
  }

  @override
  void didUpdateWidget(covariant InputEngineWidget oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.initialValue != widget.initialValue && _textController.text != widget.initialValue) {
      _textController.text = widget.initialValue;
    }
  }

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          decoration: BoxDecoration(
              color: const Color(0xFFF0FDF4),
              borderRadius: BorderRadius.circular(8)
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: const [
              Icon(Icons.border_color, size: 12, color: Colors.green),
              SizedBox(width: 6),
              Text(
                'Type your response inside the text box below:',
                style: TextStyle(color: Colors.green, fontSize: 11, fontWeight: FontWeight.bold),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        TextFormField(
          controller: _textController,
          onChanged: widget.onChanged,
          style: const TextStyle(fontSize: 15, color: Color(0xFF1E293B)),
          decoration: InputDecoration(
            hintText: 'Type your answer here...',
            hintStyle: const TextStyle(color: Colors.grey, fontSize: 14),
            filled: true,
            fillColor: const Color(0xFFF8FAFC),
            contentPadding: const EdgeInsets.all(16),
            enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: const BorderSide(color: Color(0xFFE2E8F0))
            ),
            focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: const BorderSide(color: Color(0xFF0066F5), width: 1.5)
            ),
          ),
        ),
      ],
    );
  }
}