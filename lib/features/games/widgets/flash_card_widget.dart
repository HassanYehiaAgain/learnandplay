import 'package:flutter/material.dart';
import '../../../models/models.dart';
import 'package:learn_play/models/question.dart';  // for GameQuestion and subtypes

class FlashCardWidget extends StatefulWidget {
  final GameQuestion question;
  final Function(bool isCorrect) onAnswer;

  const FlashCardWidget({
    super.key,
    required this.question,
    required this.onAnswer,
  });

  @override
  State<FlashCardWidget> createState() => _FlashCardWidgetState();
}

class _FlashCardWidgetState extends State<FlashCardWidget> {
  int _currentCardIndex = 0;
  bool _showingFront = true;
  final PageController _pageController = PageController();
  
  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }
  
  @override
  Widget build(BuildContext context) {
    // Extract the flash card data
    final questionData = widget.question.question;
    
    if (questionData is! FlashCardQuestion) {
      return const Center(
        child: Text('Invalid question type'),
      );
    }
    
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Instructions
          Text(
            'Tap card to flip, swipe for next card',
            style: Theme.of(context).textTheme.titleMedium,
            textAlign: TextAlign.center,
          ),
          
          const SizedBox(height: 24),
          
          // Flash card
          Expanded(
            child: GestureDetector(
              onTap: () {
                setState(() {
                  _showingFront = !_showingFront;
                });
              },
              child: _buildCard(
                _showingFront ? questionData.front : questionData.back,
                _showingFront,
              ),
            ),
          ),
          
          const SizedBox(height: 24),
          
          // Self-assessment buttons
          _showingFront 
              ? const SizedBox.shrink()
              : Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    ElevatedButton.icon(
                      onPressed: () => widget.onAnswer(false),
                      icon: const Icon(Icons.close),
                      label: const Text('Didn\'t Know'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red.shade200,
                        foregroundColor: Colors.red.shade900,
                      ),
                    ),
                    ElevatedButton.icon(
                      onPressed: () => widget.onAnswer(true),
                      icon: const Icon(Icons.check),
                      label: const Text('Got It!'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green.shade200,
                        foregroundColor: Colors.green.shade900,
                      ),
                    ),
                  ],
                ),
        ],
      ),
    );
  }
  
  Widget _buildCard(String text, bool isFront) {
    return Card(
      elevation: 8,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      color: isFront ? Colors.blue.shade50 : Colors.amber.shade50,
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(32.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Card type indicator
              Text(
                isFront ? 'QUESTION' : 'ANSWER',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: isFront ? Colors.blue.shade700 : Colors.amber.shade700,
                ),
              ),
              
              const SizedBox(height: 24),
              
              // Card content
              Text(
                text,
                style: Theme.of(context).textTheme.headlineSmall,
                textAlign: TextAlign.center,
              ),
              
              const SizedBox(height: 24),
              
              // Flip icon
              Icon(
                Icons.flip,
                color: isFront ? Colors.blue.shade300 : Colors.amber.shade300,
              ),
            ],
          ),
        ),
      ),
    );
  }
} 