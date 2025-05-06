import 'package:flutter/material.dart';
import '../../../models/models.dart';
import 'package:learn_play/models/question.dart';  // for GameQuestion and subtypes

class TrueFalseWidget extends StatefulWidget {
  final GameQuestion question;
  final Function(bool isCorrect) onAnswer;

  const TrueFalseWidget({
    super.key,
    required this.question,
    required this.onAnswer,
  });

  @override
  State<TrueFalseWidget> createState() => _TrueFalseWidgetState();
}

class _TrueFalseWidgetState extends State<TrueFalseWidget> {
  bool _answered = false;
  
  @override
  Widget build(BuildContext context) {
    // Extract the true/false question
    final questionData = widget.question.question;
    
    if (questionData is! TrueFalseQuestion) {
      return const Center(
        child: Text('Invalid question type'),
      );
    }
    
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Question text
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.blue.shade50,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Text(
              questionData.text,
              style: Theme.of(context).textTheme.headlineSmall,
              textAlign: TextAlign.center,
            ),
          ),
          
          const SizedBox(height: 48),
          
          // True/False buttons
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildAnswerButton(
                context, 
                'True', 
                Colors.green, 
                () => _checkAnswer(true, questionData.correctAnswer),
              ),
              _buildAnswerButton(
                context, 
                'False', 
                Colors.red, 
                () => _checkAnswer(false, questionData.correctAnswer),
              ),
            ],
          ),
          
          if (questionData.explanation != null && _answered) ...[
            const SizedBox(height: 32),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.amber.shade50,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.amber.shade200),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Explanation:',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(questionData.explanation!),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
  
  // Button for True/False
  Widget _buildAnswerButton(
    BuildContext context, 
    String text, 
    Color color, 
    VoidCallback onPressed,
  ) {
    return ElevatedButton(
      onPressed: _answered ? null : onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(
          horizontal: 48,
          vertical: 16,
        ),
        textStyle: const TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.bold,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      child: Text(text),
    );
  }
  
  // Check if the answer is correct
  void _checkAnswer(bool userAnswer, bool correctAnswer) {
    setState(() {
      _answered = true;
    });
    
    final isCorrect = userAnswer == correctAnswer;
    
    // Show a brief feedback and then call onAnswer
    _showFeedback(isCorrect);
    
    // Delayed to allow the user to see the feedback
    Future.delayed(const Duration(milliseconds: 1500), () {
      if (mounted) {
        widget.onAnswer(isCorrect);
        setState(() {
          _answered = false;
        });
      }
    });
  }
  
  // Show feedback for correct/incorrect answer
  void _showFeedback(bool isCorrect) {
    final snackBar = SnackBar(
      content: Row(
        children: [
          Icon(
            isCorrect ? Icons.check_circle : Icons.cancel,
            color: Colors.white,
          ),
          const SizedBox(width: 16),
          Text(
            isCorrect ? 'Correct!' : 'Incorrect!',
            style: const TextStyle(fontSize: 16),
          ),
        ],
      ),
      backgroundColor: isCorrect ? Colors.green : Colors.red,
      duration: const Duration(milliseconds: 1000),
    );
    
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }
} 