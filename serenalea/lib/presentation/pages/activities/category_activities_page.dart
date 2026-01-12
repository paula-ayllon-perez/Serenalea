import 'package:flutter/material.dart';
import '../../../core/constants/colors.dart';
import '../../../data/models/activity_dto.dart';
import '../../../data/models/activity_category_dto.dart';
import '../../../data/repositories/activity_repository.dart';
import 'activity/generic_activity_page.dart';

class CategoryActivitiesPage extends StatefulWidget {
  final ActivityCategory category;

  const CategoryActivitiesPage({
    Key? key,
    required this.category,
  }) : super(key: key);

  @override
  State<CategoryActivitiesPage> createState() => _CategoryActivitiesPageState();
}

class _CategoryActivitiesPageState extends State<CategoryActivitiesPage> {
  final ActivityRepository _activityRepository = ActivityRepository();
  late Future<List<Activity>> _activitiesFuture;

  @override
  void initState() {
    super.initState();
    _activitiesFuture = _activityRepository.getActivitiesByCategory(widget.category.id);
  }

  Color _getCategoryColor() {
    try {
      return Color(int.parse(widget.category.colorHex.replaceAll('#', '0xFF')));
    } catch (e) {
      return AppColors.color1;
    }
  }

  IconData _getDifficultyIcon(String difficulty) {
    switch (difficulty) {
      case 'easy':
        return Icons.sentiment_satisfied;
      case 'hard':
        return Icons.fitness_center;
      default:
        return Icons.trending_up;
    }
  }

  @override
  Widget build(BuildContext context) {
    final categoryColor = _getCategoryColor();

    return Scaffold(
      backgroundColor: AppColors.background,
      body: CustomScrollView(
        slivers: [
          // AppBar con color de la categoría
          SliverAppBar(
            // Usar la altura estándar de la toolbar para evitar huecos
            expandedHeight: kToolbarHeight,
            toolbarHeight: kToolbarHeight,
            floating: false,
            pinned: true,
            backgroundColor: categoryColor,
            // Título en la barra principal (aparece a la derecha de la flecha de volver)
            title: Text(
              widget.category.name,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.white,
                shadows: [Shadow(color: Colors.black38, blurRadius: 4)],
              ),
            ),
            // Ajustes visuales para alinear con la flecha
            centerTitle: false,
            titleSpacing: 0,
            iconTheme: const IconThemeData(color: Colors.white),
            // Fondo con degradado pequeño que no altera la altura
            flexibleSpace: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    categoryColor,
                    categoryColor.withOpacity(0.7),
                  ],
                ),
              ),
            ),
          ),

          // Lista de actividades
          SliverPadding(
            padding: const EdgeInsets.all(16),
            sliver: FutureBuilder<List<Activity>>(
              future: _activitiesFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const SliverFillRemaining(
                    child: Center(child: CircularProgressIndicator()),
                  );
                } else if (snapshot.hasError) {
                  return SliverFillRemaining(
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.error_outline, size: 64, color: AppColors.color3),
                          const SizedBox(height: 16),
                          Text('Error: ${snapshot.error}'),
                        ],
                      ),
                    ),
                  );
                } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return SliverFillRemaining(
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.inbox_outlined, size: 80, color: AppColors.color3),
                          const SizedBox(height: 16),
                          Text(
                            'No hay actividades en esta categoría',
                            style: TextStyle(fontSize: 18, color: AppColors.color2),
                          ),
                        ],
                      ),
                    ),
                  );
                }

                final activities = snapshot.data!;

                return SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      final activity = activities[index];

                      return Padding(
                        padding: const EdgeInsets.only(bottom: 16),
                        child: InkWell(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => GenericActivityPage(
                                  activity: activity,
                                  categoryName: widget.category.name,
                                  categoryColor: categoryColor,
                                ),
                              ),
                            );
                          },
                          borderRadius: BorderRadius.circular(16),
                          child: Container(
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(16),
                              boxShadow: [
                                BoxShadow(
                                  color: categoryColor.withOpacity(0.2),
                                  blurRadius: 8,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Encabezado con imagen opcional
                                if (activity.imageUrl != null)
                                  ClipRRect(
                                    borderRadius: const BorderRadius.only(
                                      topLeft: Radius.circular(16),
                                      topRight: Radius.circular(16),
                                    ),
                                    child: Image.network(
                                      activity.imageUrl!,
                                      height: 150,
                                      width: double.infinity,
                                      fit: BoxFit.cover,
                                      errorBuilder: (context, error, stackTrace) {
                                        return Container(
                                          height: 150,
                                          color: categoryColor.withOpacity(0.2),
                                          child: Icon(
                                            Icons.image_not_supported,
                                            size: 64,
                                            color: categoryColor.withOpacity(0.5),
                                          ),
                                        );
                                      },
                                    ),
                                  ),

                                Padding(
                                  padding: const EdgeInsets.all(16),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          Expanded(
                                            child: Text(
                                              activity.title,
                                              style: TextStyle(
                                                fontSize: 20,
                                                fontWeight: FontWeight.bold,
                                                color: categoryColor,
                                              ),
                                            ),
                                          ),
                                          Container(
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 12,
                                              vertical: 6,
                                            ),
                                            decoration: BoxDecoration(
                                              color: categoryColor.withOpacity(0.1),
                                              borderRadius: BorderRadius.circular(20),
                                            ),
                                            child: Row(
                                              children: [
                                                Icon(
                                                  _getDifficultyIcon(activity.difficulty),
                                                  size: 16,
                                                  color: categoryColor,
                                                ),
                                                const SizedBox(width: 4),
                                                Text(
                                                  activity.difficultyLabel,
                                                  style: TextStyle(
                                                    fontSize: 12,
                                                    fontWeight: FontWeight.bold,
                                                    color: categoryColor,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 12),
                                      Text(
                                        activity.description,
                                        style: TextStyle(
                                          fontSize: 14,
                                          color: AppColors.color2,
                                          height: 1.4,
                                        ),
                                      ),
                                      const SizedBox(height: 16),
                                      Row(
                                        children: [
                                          _buildInfoChip(
                                            Icons.access_time,
                                            '${activity.duration} min',
                                            categoryColor,
                                          ),
                                          const SizedBox(width: 12),
                                          _buildInfoChip(
                                            Icons.star,
                                            '${activity.score} pts',
                                            categoryColor,
                                          ),
                                        ],
                                      ),
                                      if (activity.suitableProfiles.isNotEmpty) ...[
                                        const SizedBox(height: 12),
                                        Wrap(
                                          spacing: 8,
                                          runSpacing: 8,
                                          children: activity.suitableProfiles.map((profile) {
                                            return Container(
                                              padding: const EdgeInsets.symmetric(
                                                horizontal: 10,
                                                vertical: 4,
                                              ),
                                              decoration: BoxDecoration(
                                                color: AppColors.softBlue,
                                                borderRadius: BorderRadius.circular(12),
                                                border: Border.all(
                                                  color: categoryColor.withOpacity(0.3),
                                                ),
                                              ),
                                              child: Text(
                                                profile,
                                                style: TextStyle(
                                                  fontSize: 11,
                                                  color: categoryColor,
                                                  fontWeight: FontWeight.w500,
                                                ),
                                              ),
                                            );
                                          }).toList(),
                                        ),
                                      ],
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                    childCount: activities.length,
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoChip(IconData icon, String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: color),
          const SizedBox(width: 6),
          Text(
            label,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}
