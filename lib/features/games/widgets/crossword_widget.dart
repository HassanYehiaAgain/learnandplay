import 'package:flutter/material.dart';
import 'package:learn_play/models/question.dart';

class CrosswordWidget extends StatefulWidget {
  final GameQuestion question;
  final void Function(bool isCorrect) onAnswer;
  const CrosswordWidget({
    Key? key,
    required this.question,
    required this.onAnswer,
  }) : super(key: key);

  @override
  State<CrosswordWidget> createState() => _CrosswordWidgetState();
}

class _CrosswordWidgetState extends State<CrosswordWidget> {
  late List<List<TextEditingController>> _controllers;

  @override
  void initState() {
    super.initState();
    _initializeControllers();
  }

  @override
  void dispose() {
    for (final row in _controllers) {
      for (final controller in row) {
        controller.dispose();
      }
    }
    super.dispose();
  }

  void _initializeControllers() {
    final model = widget.question.question;
    if (model is! CrosswordQuestion) return;

    final grid = model.grid;
    _controllers = List.generate(
      grid.length,
      (row) => List.generate(
        grid[row].length,
        (col) => TextEditingController(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final model = widget.question.question;
    if (model is! CrosswordQuestion) {
      return const Center(child: Text('Invalid question type'));
    }
    final grid = model.grid;
    final acrossClues = model.acrossClues;
    final downClues = model.downClues;

    return Column(
      children: [
        AspectRatio(
          aspectRatio: grid.first.length / grid.length,
          child: GridView.builder(
            physics: const NeverScrollableScrollPhysics(),
            itemCount: grid.length * grid.first.length,
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: grid.first.length),
            itemBuilder: (_, idx) {
              final row = idx ~/ grid.first.length;
              final col = idx % grid.first.length;
              final letter = grid[row][col];
              return Container(
                margin: const EdgeInsets.all(1),
                color: letter == null ? Colors.black : Colors.white,
                child: letter == null
                    ? null
                    : TextField(
                        controller: _controllers[row][col],
                        style: const TextStyle(color: Colors.black),
                        decoration: const InputDecoration(
                          filled: true,
                          fillColor: Colors.white,
                          labelStyle: TextStyle(color: Colors.black),
                          border: OutlineInputBorder(),
                        ),
                      ),
              );
            },
          ),
        ),
        const SizedBox(height: 8),
        Text('Across', style: Theme.of(context).textTheme.headlineSmall),
        ...acrossClues.entries.map((e) => Text('${e.key}. ${e.value}')),
        const SizedBox(height: 8),
        Text('Down', style: Theme.of(context).textTheme.headlineSmall),
        ...downClues.entries.map((e) => Text('${e.key}. ${e.value}')),
      ],
    );
  }
}