import 'package:flutter/material.dart';
import '../../../core/constants/colors.dart';
import '../../../data/models/activity_category_dto.dart';
import '../../../data/repositories/category_repository.dart';
import 'category_activities_page.dart';

class ActivityCategoriesPage extends StatefulWidget {
  const ActivityCategoriesPage({Key? key}) : super(key: key);

  @override
  State<ActivityCategoriesPage> createState() => _ActivityCategoriesPageState();
}

class _ActivityCategoriesPageState extends State<ActivityCategoriesPage> {
  final CategoryRepository _categoryRepository = CategoryRepository();
  late Future<List<ActivityCategory>> _categoriesFuture;

  @override
  void initState() {
    super.initState();
    _categoriesFuture = _categoryRepository.getAllCategories();
  }

  // Convertir nombre de icono a IconData
  IconData _getIconData(String iconName) {
    switch (iconName.toLowerCase()) {
      case 'self_improvement':
        return Icons.self_improvement;
      case 'directions_walk':
        return Icons.directions_walk;
      case 'brush':
        return Icons.brush;
      case 'visibility':
        return Icons.visibility;
      case 'favorite':
        return Icons.favorite;
      case 'psychology':
        return Icons.psychology;
      default:
        return Icons.category;
    }
  }

  // Convertir hex a Color
  Color _getColor(String hexColor) {
    try {
      return Color(int.parse(hexColor.replaceAll('#', '0xFF')));
    } catch (e) {
      return AppColors.color1;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Categorías de Actividades'),
        backgroundColor: AppColors.color1,
      ),
      backgroundColor: AppColors.background,
      body: FutureBuilder<List<ActivityCategory>>(
        future: _categoriesFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.error_outline, size: 64, color: AppColors.color3),
                  const SizedBox(height: 16),
                  Text('Error: ${snapshot.error}'),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      setState(() {
                        _categoriesFuture = _categoryRepository.getAllCategories();
                      });
                    },
                    child: const Text('Reintentar'),
                  ),
                ],
              ),
            );
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.category_outlined, size: 80, color: AppColors.color3),
                  const SizedBox(height: 16),
                  Text(
                    'No hay categorías disponibles',
                    style: TextStyle(fontSize: 18, color: AppColors.color2),
                  ),
                ],
              ),
            );
          }

          final categories = snapshot.data!;
          
          return GridView.builder(
            padding: const EdgeInsets.all(16),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              childAspectRatio: 0.75, // Cambiado de 0.85 a 0.75 para hacerlas más altas
            ),
            itemCount: categories.length,
            itemBuilder: (context, index) {
              final category = categories[index];
              final color = _getColor(category.colorHex);
              final icon = _getIconData(category.iconName);

              return InkWell(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => CategoryActivitiesPage(
                        category: category,
                      ),
                    ),
                  );
                },
                borderRadius: BorderRadius.circular(20),
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        color,
                        color.withOpacity(0.7),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: color.withOpacity(0.3),
                        blurRadius: 12,
                        offset: const Offset(0, 6),
                      ),
                    ],
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16), // Reducido de 20 a 16
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      mainAxisSize: MainAxisSize.min, // Agregado para evitar overflow
                      children: [
                        Container(
                          padding: const EdgeInsets.all(14), // Reducido de 16 a 14
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.3),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            icon,
                            size: 40, // Reducido de 48 a 40
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 12), // Reducido de 16 a 12
                        Flexible( // Envuelto en Flexible
                          child: Text(
                            category.name,
                            style: const TextStyle(
                              fontSize: 16, // Reducido de 18 a 16
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                            textAlign: TextAlign.center,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(height: 6), // Reducido de 8 a 6
                        Flexible( // Envuelto en Flexible
                          child: Text(
                            category.description,
                            style: TextStyle(
                              fontSize: 11, // Reducido de 12 a 11
                              color: Colors.white.withOpacity(0.9),
                            ),
                            textAlign: TextAlign.center,
                            maxLines: 3,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
