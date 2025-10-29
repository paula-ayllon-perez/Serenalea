import 'package:flutter/material.dart';
import 'package:serenalea/presentation/pages/activities/all_activities.dart';
import '../pages/activities/activity/creative_actovity.dart';
import '../pages/activities/activity/observing_activity.dart';
import '../pages/activities/activity/mindfullness_activity.dart';
import '../pages/activities/activity/walk_activity.dart';

final Map<String, WidgetBuilder> activityRoutes = {
  '/activities': (context) => const AllActivitiesPage(),
  '/all-activities': (context) => const AllActivitiesPage(),
  '/creative': (context) => const CreativeActivityPage(),
  '/observing': (context) => const ObservingActivityPage(),
  '/mindfulness': (context) => const MindfulnessActivityPage(),
  '/walk': (context) => const WalkActivityPage(),
};
