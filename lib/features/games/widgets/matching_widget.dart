import 'package:flutter/material.dart';
import 'package:learn_play/models/question.dart';

class MatchingWidget extends StatefulWidget {
  final GameQuestion question;
  final void Function(bool isCorrect) onAnswer;
  const MatchingWidget({
    Key? key,
    required this.question,
    required this.onAnswer,
  }) : super(key: key);

  @override
  State<MatchingWidget> createState() => _MatchingWidgetState();
}

class _MatchingWidgetState extends State<MatchingWidget> {
  String? selectedLeft;

  @override
  Widget build(BuildContext context) {
    final model = widget.question.question;
    if (model is! MatchingQuestion) {
      return const Center(child: Text('Invalid question type'));
    }
    final mq = widget.question.question as MatchingQuestion;
    final pairs = List< MapEntry<String,String> >.generate(
      mq.leftItems.length,
      (i) => MapEntry(mq.leftItems[i], mq.rightItems[mq.correctMatches[i]]),
    );
    final leftItems = pairs.map((e) => e.key).toList()..shuffle();
    final rightItems = pairs.map((e) => e.value).toList()..shuffle();

    return Row(
      children: [
        Expanded(
          child: ListView(
            children: leftItems.map((left) {
              return ListTile(
                title: Text(left),
                selected: selectedLeft == left,
                onTap: () => setState(() => selectedLeft = left),
              );
            }).toList(),
          ),
        ),
        Expanded(
          child: ListView(
            children: rightItems.map((right) {
              return ListTile(
                title: Text(right),
                onTap: () {
                  final correct = selectedLeft != null &&
                      pairs
                          .firstWhere((p) => p.key == selectedLeft!)
                          .value ==
                      right;
                  widget.onAnswer(correct);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(correct ? 'Correct!' : 'Try again'),
                    ),
                  );
                },
              );
            }).toList(),
          ),
        ),
      ],
    );
  }
}