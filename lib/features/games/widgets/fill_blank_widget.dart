import 'package:flutter/material.dart';
import '../../../models/models.dart';
import 'package:learn_play/models/question.dart';  // for GameQuestion and subtypes

class FillBlankWidget extends StatefulWidget {
  final GameQuestion question;
  final Function(bool isCorrect) onAnswer;

  const FillBlankWidget({
    super.key,
    required this.question,
    required this.onAnswer,
  });

  @override
  State<FillBlankWidget> createState() => _FillBlankWidgetState();
}

class _FillBlankWidgetState extends State<FillBlankWidget> {
  final List<TextEditingController> _controllers = [];
  bool _isChecking = false;
  
  @override
  void initState() {
    super.initState();
    _initializeControllers();
  }
  
  @override
  void dispose() {
    for (final controller in _controllers) {
      controller.dispose();
    }
    super.dispose();
  }
  
  void _initializeControllers() {
    final questionData = widget.question.question;
    
    if (questionData is FillBlankQuestion) {
      _controllers.clear();
      for (int i = 0; i < questionData.blanks.length; i++) {
        _controllers.add(TextEditingController());
      }
    }
  }
  
  @override
  Widget build(BuildContext context) {
    // Extract the fill-in-the-blank question data
    final questionData = widget.question.question;
    
    if (questionData is! FillBlankQuestion) {
      return const Center(
        child: Text('Invalid question type'),
      );
    }
    
    // Split the text by blanks
    final parts = questionData.textWithBlanks.split('___');
    
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Instructions
          Text(
            'Fill in the blanks',
            style: Theme.of(context).textTheme.titleLarge,
            textAlign: TextAlign.center,
          ),
          
          const SizedBox(height: 32),
          
          // Sentence with blanks
          Expanded(
            child: SingleChildScrollView(
              child: _buildRichText(parts, questionData.blanks.length),
            ),
          ),
          
          const SizedBox(height: 16),
          
          // Check answer button
          ElevatedButton(
            onPressed: _isChecking ? null : _checkAnswers,
            child: const Text('Check Answers'),
          ),
        ],
      ),
    );
  }
  
  // Build rich text with blanks
  Widget _buildRichText(List<String> parts, int blanksCount) {
    // Ensure we have the right number of controllers
    while (_controllers.length < blanksCount) {
      _controllers.add(TextEditingController());
    }
    
    final textWidgets = <Widget>[];
    
    for (int i = 0; i < parts.length; i++) {
      // Add the text part
      if (parts[i].isNotEmpty) {
        textWidgets.add(
          Text(
            parts[i],
            style: const TextStyle(fontSize: 18),
          ),
        );
      }
      
      // Add a blank if not the last part
      if (i < parts.length - 1 && i < _controllers.length) {
        textWidgets.add(
          SizedBox(
            width: 120,
            child: TextField(
              controller: _controllers[i],
              style: const TextStyle(color: Colors.black),
              decoration: const InputDecoration(
                filled: true,
                fillColor: Colors.white,
                labelStyle: TextStyle(color: Colors.black),
                border: OutlineInputBorder(),
                labelText: 'Your Answer',
              ),
              textAlign: TextAlign.center,
            ),
          ),
        );
      }
    }
    
    return Wrap(
      spacing: 8,
      runSpacing: 16,
      alignment: WrapAlignment.center,
      children: textWidgets,
    );
  }
  
  // Check if the answers are correct
  void _checkAnswers() {
    final questionData = widget.question.question;
    
    if (questionData is! FillBlankQuestion) {
      return;
    }
    
    setState(() {
      _isChecking = true;
    });
    
    // Check if answers match the expected blanks
    bool isCorrect = true;
    for (int i = 0; i < questionData.blanks.length && i < _controllers.length; i++) {
      final userAnswer = _controllers[i].text.trim().toLowerCase();
      final correctAnswer = questionData.blanks[i].trim().toLowerCase();
      
      if (userAnswer != correctAnswer) {
        isCorrect = false;
        break;
      }
    }
    
    // Show feedback
    _showFeedback(isCorrect);
    
    // If incorrect, highlight wrong answers
    if (!isCorrect) {
      // Let user see the feedback and try again
      Future.delayed(const Duration(milliseconds: 1500), () {
        if (mounted) {
          setState(() {
            _isChecking = false;
          });
        }
      });
    } else {
      // If correct, move to next question
      Future.delayed(const Duration(milliseconds: 1500), () {
        if (mounted) {
          widget.onAnswer(true);
          setState(() {
            _isChecking = false;
            for (final controller in _controllers) {
              controller.clear();
            }
          });
        }
      });
    }
  }
  
  // Show feedback for the answer
  void _showFeedback(bool isCorrect) {
    final questionData = widget.question.question;
    
    if (questionData is! FillBlankQuestion) {
      return;
    }
    
    String message;
    if (isCorrect) {
      message = 'Correct!';
    } else {
      // Find the first wrong answer to give a hint
      for (int i = 0; i < questionData.blanks.length && i < _controllers.length; i++) {
        final userAnswer = _controllers[i].text.trim().toLowerCase();
        final correctAnswer = questionData.blanks[i].trim().toLowerCase();
        
        if (userAnswer != correctAnswer) {
          message = 'Try again! Check blank #${i + 1}';
          break;
        }
      }
      message = 'Some answers are incorrect. Try again!';
    }
    
    final snackBar = SnackBar(
      content: Row(
        children: [
          Icon(
            isCorrect ? Icons.check_circle : Icons.cancel,
            color: Colors.white,
          ),
          const SizedBox(width: 16),
          Text(
            message,
            style: const TextStyle(fontSize: 16),
          ),
        ],
      ),
      backgroundColor: isCorrect ? Colors.green : Colors.red,
      duration: const Duration(milliseconds: 1500),
    );
    
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }
} 