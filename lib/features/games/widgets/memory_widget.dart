import 'package:flutter/material.dart';
import 'package:learn_play/models/question.dart';

class MemoryWidget extends StatefulWidget {
  final GameQuestion question;
  final void Function(bool isCorrect) onAnswer;
  const MemoryWidget({
    Key? key,
    required this.question,
    required this.onAnswer,
  }) : super(key: key);

  @override
  State<MemoryWidget> createState() => _MemoryWidgetState();
}

class _MemoryWidgetState extends State<MemoryWidget> {
  late final List<String> items;
  late List<bool> revealed;
  int? firstIndex;

  @override
  void initState() {
    super.initState();
    final model = widget.question.question;
    if (model is MemoryQuestion) {
      items = [model.front, model.back, model.front, model.back]..shuffle();
    } else {
      items = [];
    }
    revealed = List<bool>.filled(items.length, false);
  }

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      itemCount: items.length,
      gridDelegate:
          const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 4),
      itemBuilder: (_, i) {
        return GestureDetector(
          onTap: () {
            setState(() {
              if (firstIndex == null) {
                firstIndex = i;
                revealed[i] = true;
              } else {
                final match = items[firstIndex!] == items[i];
                widget.onAnswer(match);
                if (!match) {
                  revealed[firstIndex!] = false;
                } else {
                  revealed[i] = true;
                }
                firstIndex = null;
              }
            });
          },
          child: Card(
            child: Center(child: Text(revealed[i] ? items[i] : '?')),
          ),
        );
      },
    );
  }
}