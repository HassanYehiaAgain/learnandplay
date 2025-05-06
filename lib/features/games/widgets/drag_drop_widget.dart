import 'package:flutter/material.dart';
import '../../../models/models.dart';
import 'package:learn_play/models/question.dart';  // for GameQuestion and subtypes

class DragDropWidget extends StatefulWidget {
  final GameQuestion question;
  final Function(bool isCorrect) onAnswer;

  const DragDropWidget({
    super.key,
    required this.question,
    required this.onAnswer,
  });

  @override
  State<DragDropWidget> createState() => _DragDropWidgetState();
}

class _DragDropWidgetState extends State<DragDropWidget> {
  final Map<int, int> _userAnswers = {};
  bool _isChecking = false;
  
  @override
  Widget build(BuildContext context) {
    // Extract the drag drop question
    final questionData = widget.question.question;
    
    if (questionData is! DragDropQuestion) {
      return const Center(
        child: Text('Invalid question type'),
      );
    }
    
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          // Instruction
          Text(
            'Drag the items to their correct targets',
            style: Theme.of(context).textTheme.titleLarge,
            textAlign: TextAlign.center,
          ),
          
          const SizedBox(height: 32),
          
          // Draggable items
          Expanded(
            flex: 1,
            child: Container(
              decoration: BoxDecoration(
                color: Colors.blue.shade50,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  alignment: WrapAlignment.center,
                  children: List.generate(
                    questionData.items.length,
                    (index) => _buildDraggable(
                      index,
                      questionData.items[index],
                      _userAnswers.containsKey(index),
                    ),
                  ),
                ),
              ),
            ),
          ),
          
          const SizedBox(height: 16),
          
          // Drop targets
          Expanded(
            flex: 2,
            child: GridView.builder(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: 1.5,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
              ),
              itemCount: questionData.targets.length,
              itemBuilder: (context, index) {
                return _buildDropTarget(
                  index,
                  questionData.targets[index],
                );
              },
            ),
          ),
          
          const SizedBox(height: 16),
          
          // Check answer button
          ElevatedButton(
            onPressed: _userAnswers.length == questionData.items.length && !_isChecking
                ? () => _checkAnswers(questionData.correctMapping)
                : null,
            child: const Text('Check Answers'),
          ),
        ],
      ),
    );
  }
  
  // Build a draggable item
  Widget _buildDraggable(int index, String text, bool wasPlaced) {
    return Draggable<int>(
      data: index,
      feedback: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.blue.shade100,
          borderRadius: BorderRadius.circular(8),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
              blurRadius: 6,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Text(
          text,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      childWhenDragging: Opacity(
        opacity: 0.3,
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.grey.shade200,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.grey.shade400),
          ),
          child: Text(
            text,
            style: const TextStyle(
              fontSize: 16,
            ),
          ),
        ),
      ),
      child: wasPlaced 
        ? const SizedBox.shrink()  // Hidden when placed
        : Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.blue.shade100,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.blue.shade300),
            ),
            child: Text(
              text,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
    );
  }
  
  // Build a drop target
  Widget _buildDropTarget(int targetIndex, String targetText) {
    // Find which item is mapped to this target, if any
    final mappedItemIndex = _userAnswers.entries
        .firstWhere(
          (entry) => entry.value == targetIndex,
          orElse: () => const MapEntry(-1, -1),
        )
        .key;
    
    final hasItem = mappedItemIndex != -1;
    
    return DragTarget<int>(
      builder: (context, candidateData, rejectedData) {
        return Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: hasItem ? Colors.green.shade50 : Colors.grey.shade100,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: candidateData.isNotEmpty 
                ? Colors.blue 
                : hasItem 
                  ? Colors.green 
                  : Colors.grey.shade400,
              width: candidateData.isNotEmpty ? 2 : 1,
            ),
            boxShadow: candidateData.isNotEmpty 
                ? [
                    BoxShadow(
                      color: Colors.blue.withOpacity(0.3),
                      blurRadius: 8,
                      spreadRadius: 2,
                    ),
                  ]
                : null,
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                targetText,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: hasItem ? Colors.black : Colors.grey.shade700,
                ),
                textAlign: TextAlign.center,
              ),
              
              if (hasItem) ...[
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.green.shade100,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.green.shade300),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        widget.question.question is DragDropQuestion
                            ? (widget.question.question as DragDropQuestion)
                                .items[mappedItemIndex]
                            : 'Item',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(width:
                      8),
                      InkWell(
                        onTap: () {
                          setState(() {
                            _userAnswers.remove(mappedItemIndex);
                          });
                        },
                        child: const Icon(
                          Icons.clear,
                          size: 16,
                          color: Colors.red,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        );
      },
      onWillAccept: (data) => data != null && !_userAnswers.containsKey(data),
      onAccept: (itemIndex) {
        setState(() {
          _userAnswers[itemIndex] = targetIndex;
        });
      },
    );
  }
  
  // Check if the answers are correct
  void _checkAnswers(List<int> correctMapping) {
    setState(() {
      _isChecking = true;
    });
    
    // Compare user answers with correct answers
    bool isCorrect = true;
    for (int i = 0; i < correctMapping.length; i++) {
      if (_userAnswers[i] != correctMapping[i]) {
        isCorrect = false;
        break;
      }
    }
    
    // Show feedback
    _showFeedback(isCorrect);
    
    // Delay to allow feedback to be seen
    Future.delayed(const Duration(milliseconds: 1500), () {
      if (mounted) {
        widget.onAnswer(isCorrect);
        setState(() {
          _isChecking = false;
          _userAnswers.clear();
        });
      }
    });
  }
  
  // Show feedback toast
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
            isCorrect ? 'Correct!' : 'Try again!',
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