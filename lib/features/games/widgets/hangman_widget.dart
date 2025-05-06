import 'package:flutter/material.dart';
import 'package:learn_play/models/question.dart';

class HangmanWidget extends StatefulWidget {
  final GameQuestion question;
  final void Function(bool isCorrect) onAnswer;
  const HangmanWidget({
    Key? key,
    required this.question,
    required this.onAnswer,
  }) : super(key: key);

  @override
  State<HangmanWidget> createState() => _HangmanWidgetState();
}

class _HangmanWidgetState extends State<HangmanWidget> {
  late final String word;
  late final String hint;
  Set<String> guessed = {};
  int wrong = 0;

  @override
  void initState() {
    super.initState();
    final model = widget.question.question;
    if (model is HangmanQuestion) {
      word = model.word;
      hint = model.hint;
    } else {
      word = '';
      hint = '';
    }
  }

  @override
  Widget build(BuildContext context) {
    final display = word
        .split('')
        .map((c) => guessed.contains(c) ? c : '_')
        .join(' ');
    return Column(
      children: [
        Text('Hint: $hint'),
        Text(display, style: const TextStyle(fontSize: 32)),
        Wrap(
          spacing: 4,
          children: 'ABCDEFGHIJKLMNOPQRSTUVWXYZ'
              .split('')
              .map((letter) {
            final used = guessed.contains(letter);
            return ElevatedButton(
              onPressed: used
                  ? null
                  : () {
                      setState(() {
                        guessed.add(letter);
                        final correct = word.contains(letter);
                        if (!correct) wrong++;
                        widget.onAnswer(correct);
                      });
                    },
              child: Text(letter),
            );
          }).toList(),
        ),
        if (wrong >= 6)
          const Text('Game Over!', style: TextStyle(color: Colors.red)),
      ],
    );
  }
}