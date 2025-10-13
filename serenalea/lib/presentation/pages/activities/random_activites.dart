import 'package:flutter/material.dart';
import 'activity/mindfullness_activity.dart';
import 'activity/walk_activity.dart';
import 'activity/creative_actovity.dart';
import 'activity/observing_activity.dart';
import 'dart:math';

class RandomActivitiesPage extends StatefulWidget {
  const RandomActivitiesPage({Key? key}) : super(key: key);

  @override
  State<RandomActivitiesPage> createState() => _RandomActivitiesPageState();
}

class _RandomActivitiesPageState extends State<RandomActivitiesPage> {
  final List<Widget> activityPages = [
    const MindfulnessActivityPage(),
    const WalkActivityPage(),
    const CreativeActivityPage(),
    const ObservingActivityPage(),
  ];

  int? currentIndex;
  final Random _random = Random();

  void _showNextActivity() {
    setState(() {
      int nextIndex;
      do {
        nextIndex = _random.nextInt(activityPages.length);
      } while (nextIndex == currentIndex && activityPages.length > 1);
      currentIndex = nextIndex;
    });
  }

  @override
  void initState() {
    super.initState();
    _showNextActivity();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Actividad Random'),
      ),
      body: currentIndex == null
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                Expanded(child: activityPages[currentIndex!]),
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  child: ElevatedButton.icon(
                    icon: const Icon(Icons.shuffle_rounded),
                    label: const Text('Siguiente'),
                    onPressed: _showNextActivity,
                  ),
                ),
              ],
            ),
    );
  }
}
