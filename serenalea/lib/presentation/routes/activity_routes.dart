import 'package:flutter/material.dart';
import '../pages/activities/activity_categories_page.dart';

final Map<String, WidgetBuilder> activityRoutes = {
  '/activities': (context) => const ActivityCategoriesPage(),
  '/activity-categories': (context) => const ActivityCategoriesPage(),
};
