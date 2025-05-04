import 'package:flutter/material.dart';
import 'package:learn_play_level_up_flutter/models/game_template_models.dart';

class GamificationTutorialGameView extends StatefulWidget {
  final GamificationTutorialGame game;

  const GamificationTutorialGameView({
    Key? key,
    required this.game,
  }) : super(key: key);

  @override
  _GamificationTutorialGameViewState createState() => _GamificationTutorialGameViewState();
}

class _GamificationTutorialGameViewState extends State<GamificationTutorialGameView> {
  int _currentStep = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.game.title),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              widget.game.steps[_currentStep],
              style: Theme.of(context).textTheme.headlineSmall,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            if (widget.game.tutorialData != null)
              Expanded(
                child: ListView.builder(
                  itemCount: (widget.game.tutorialData!['steps'] as List).length,
                  itemBuilder: (context, index) {
                    final step = widget.game.tutorialData!['steps'][index];
                    return Card(
                      child: ListTile(
                        title: Text(step['title']),
                        subtitle: Text(step['description']),
                        leading: CircleAvatar(
                          child: Text('${index + 1}'),
                        ),
                      ),
                    );
                  },
                ),
              ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                if (_currentStep > 0)
                  ElevatedButton(
                    onPressed: () {
                      setState(() {
                        _currentStep--;
                      });
                    },
                    child: const Text('Previous'),
                  )
                else
                  const SizedBox(width: 100),
                if (_currentStep < widget.game.steps.length - 1)
                  ElevatedButton(
                    onPressed: () {
                      setState(() {
                        _currentStep++;
                      });
                    },
                    child: const Text('Next'),
                  )
                else
                  ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    child: const Text('Finish'),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
} 