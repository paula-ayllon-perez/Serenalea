import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';
import 'package:serenalea/core/theme/app_theme.dart';
import 'package:serenalea/presentation/widgets/main_drawer.dart';

class StatisticsPage extends StatefulWidget {
  const StatisticsPage({Key? key}) : super(key: key);

  @override
  State<StatisticsPage> createState() => _StatisticsPageState();
}

class _StatisticsPageState extends State<StatisticsPage> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String userId = FirebaseAuth.instance.currentUser!.uid;
  
  Map<String, dynamic> stats = {
    'completedActivities': 0,
    'totalMinutes': 0,
    'diaryEntries': 0,
    'currentStreak': 0,
    'longestStreak': 0,
    'activitiesByCategory': <String, int>{},
    'activitiesByType': <String, int>{},
    'last7Days': <String, int>{},
    'last30Days': <String, int>{},
  };
  
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadStatistics();
  }

  Future<void> _loadStatistics() async {
    setState(() => _isLoading = true);
    
    try {
      // Cargar actividades completadas
      final completedActivitiesSnapshot = await _firestore
          .collection('completedActivities')
          .where('userId', isEqualTo: userId)
          .get();

      // Cargar entradas del diario
      final diaryEntriesSnapshot = await _firestore
          .collection('diaryEntries')
          .where('userId', isEqualTo: userId)
          .get();

      // Calcular estadísticas
      int totalMinutes = 0;
      Map<String, int> activitiesByCategory = {};
      Map<String, int> activitiesByType = {};
      Map<String, int> last7Days = {};
      Map<String, int> last30Days = {};
      
      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);
      
      // Inicializar últimos 7 días
      for (int i = 6; i >= 0; i--) {
        final date = today.subtract(Duration(days: i));
        final key = DateFormat('dd/MM').format(date);
        last7Days[key] = 0;
      }
      
      // Inicializar últimos 30 días (agrupados por semana)
      for (int i = 4; i >= 0; i--) {
        final weekStart = today.subtract(Duration(days: 7 * i + 6));
        final weekEnd = today.subtract(Duration(days: 7 * i));
        final key = '${DateFormat('dd/MM').format(weekStart)}-${DateFormat('dd/MM').format(weekEnd)}';
        last30Days[key] = 0;
      }

      for (var doc in completedActivitiesSnapshot.docs) {
        final data = doc.data();
        
        // Sumar duración (minutos invertidos)
        totalMinutes += (data['duration'] as int? ?? 5); // 5 minutos por defecto si no hay duración
        
        // Contar por categoría
        final category = data['categoryName'] as String? ?? 'Sin categoría';
        activitiesByCategory[category] = (activitiesByCategory[category] ?? 0) + 1;
        
        // Contar por tipo
        final type = data['activityType'] as String? ?? 'simple';
        final typeName = _getTypeDisplayName(type);
        activitiesByType[typeName] = (activitiesByType[typeName] ?? 0) + 1;
        
        // Contar por día (últimos 7 días)
        if (data['completedAt'] != null) {
          final completedDate = (data['completedAt'] as Timestamp).toDate();
          final dayDiff = today.difference(DateTime(completedDate.year, completedDate.month, completedDate.day)).inDays;
          
          if (dayDiff >= 0 && dayDiff < 7) {
            final key = DateFormat('dd/MM').format(completedDate);
            if (last7Days.containsKey(key)) {
              last7Days[key] = last7Days[key]! + 1;
            }
          }
          
          // Contar por semana (últimos 30 días)
          if (dayDiff >= 0 && dayDiff < 30) {
            for (var entry in last30Days.entries.toList()) {
              final parts = entry.key.split('-');
              final weekStart = DateFormat('dd/MM').parse(parts[0]);
              final weekEnd = DateFormat('dd/MM').parse(parts[1]);
              
              if (completedDate.isAfter(weekStart.subtract(const Duration(days: 1))) &&
                  completedDate.isBefore(weekEnd.add(const Duration(days: 1)))) {
                last30Days[entry.key] = entry.value + 1;
                break;
              }
            }
          }
        }
      }

      // Calcular rachas
      final streakInfo = await _calculateStreaks(completedActivitiesSnapshot.docs);

      setState(() {
        stats = {
          'completedActivities': completedActivitiesSnapshot.docs.length,
          'totalMinutes': totalMinutes,
          'diaryEntries': diaryEntriesSnapshot.docs.length,
          'currentStreak': streakInfo['current'],
          'longestStreak': streakInfo['longest'],
          'activitiesByCategory': activitiesByCategory,
          'activitiesByType': activitiesByType,
          'last7Days': last7Days,
          'last30Days': last30Days,
        };
        _isLoading = false;
      });
    } catch (e) {
      debugPrint('Error cargando estadísticas: $e');
      setState(() => _isLoading = false);
    }
  }

  String _getTypeDisplayName(String type) {
    switch (type) {
      case 'photo':
        return 'Fotografía';
      case 'text':
        return 'Texto';
      case 'meditation':
        return 'Meditación';
      case 'simple':
        return 'Simple';
      default:
        return 'Otro';
    }
  }

  Future<Map<String, int>> _calculateStreaks(List<QueryDocumentSnapshot> docs) async {
    if (docs.isEmpty) return {'current': 0, 'longest': 0};

    // Obtener todas las fechas únicas (solo día, sin hora)
    final Set<DateTime> completedDates = {};
    for (var doc in docs) {
      final data = doc.data() as Map<String, dynamic>;
      if (data['completedAt'] != null) {
        final date = (data['completedAt'] as Timestamp).toDate();
        completedDates.add(DateTime(date.year, date.month, date.day));
      }
    }

    if (completedDates.isEmpty) return {'current': 0, 'longest': 0};

    final sortedDates = completedDates.toList()..sort();
    final today = DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day);

    // Calcular racha actual
    int currentStreak = 0;
    DateTime checkDate = today;
    
    while (sortedDates.contains(checkDate)) {
      currentStreak++;
      checkDate = checkDate.subtract(const Duration(days: 1));
    }

    // Calcular racha más larga
    int longestStreak = 0;
    int tempStreak = 1;
    
    for (int i = 1; i < sortedDates.length; i++) {
      final diff = sortedDates[i].difference(sortedDates[i - 1]).inDays;
      
      if (diff == 1) {
        tempStreak++;
      } else {
        if (tempStreak > longestStreak) {
          longestStreak = tempStreak;
        }
        tempStreak = 1;
      }
    }
    
    if (tempStreak > longestStreak) {
      longestStreak = tempStreak;
    }

    return {'current': currentStreak, 'longest': longestStreak};
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Estadísticas'),
        backgroundColor: AppTheme.lightTheme.primaryColor,
        foregroundColor: Colors.white,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _loadStatistics,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Resumen de métricas principales
                    _buildMetricsSummary(),
                    const SizedBox(height: 24),
                    
                    // Rachas
                    _buildStreakSection(),
                    const SizedBox(height: 24),
                    
                    // Tiempo recuperado
                    _buildTimeRecoveredSection(),
                    const SizedBox(height: 24),
                    
                    // Actividad de los últimos 7 días
                    _buildActivityChart7Days(),
                    const SizedBox(height: 24),
                    
                    // Actividad del último mes
                    _buildActivityChart30Days(),
                    const SizedBox(height: 24),
                    
                    // Actividades por categoría
                    _buildCategoryDistribution(),
                    const SizedBox(height: 24),
                    
                    // Actividades por tipo
                    _buildTypeDistribution(),
                  ],
                ),
              ),
            ),
      bottomNavigationBar: const MainBottomBar(),
    );
  }

  Widget _buildMetricsSummary() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Resumen General',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: _buildMetricCard(
                icon: Icons.check_circle,
                color: Colors.green,
                value: stats['completedActivities'].toString(),
                label: 'Actividades\nCompletadas',
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildTimeMetricCard(
                icon: Icons.schedule,
                color: Colors.amber,
                minutes: stats['totalMinutes'] as int,
                label: 'Tiempo\nInvertido',
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _buildMetricCard(
                icon: Icons.book,
                color: Colors.blue,
                value: stats['diaryEntries'].toString(),
                label: 'Entradas de\nDiario',
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildMetricCard(
                icon: Icons.category,
                color: Colors.purple,
                value: (stats['activitiesByCategory'] as Map).length.toString(),
                label: 'Categorías\nExploradas',
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildMetricCard({
    required IconData icon,
    required Color color,
    required String value,
    required String label,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 32),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[700],
              height: 1.2,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTimeMetricCard({
    required IconData icon,
    required Color color,
    required int minutes,
    required String label,
  }) {
    final hours = minutes ~/ 60;
    final remainingMinutes = minutes % 60;
    
    String timeDisplay;
    if (hours > 0) {
      timeDisplay = '${hours}h ${remainingMinutes}m';
    } else {
      timeDisplay = '${minutes}m';
    }
    
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 32),
          const SizedBox(height: 8),
          Text(
            timeDisplay,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[700],
              height: 1.2,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStreakSection() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.orange.shade400, Colors.deepOrange.shade600],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.orange.withOpacity(0.3),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          const Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.local_fire_department, color: Colors.white, size: 28),
              SizedBox(width: 8),
              Text(
                'Rachas de Actividad',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: Column(
                  children: [
                    Text(
                      stats['currentStreak'].toString(),
                      style: const TextStyle(
                        fontSize: 36,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const Text(
                      'Racha Actual',
                      style: TextStyle(color: Colors.white70, fontSize: 14),
                    ),
                    const Text(
                      'días consecutivos',
                      style: TextStyle(color: Colors.white70, fontSize: 12),
                    ),
                  ],
                ),
              ),
              Container(
                width: 1,
                height: 60,
                color: Colors.white.withOpacity(0.3),
              ),
              Expanded(
                child: Column(
                  children: [
                    Text(
                      stats['longestStreak'].toString(),
                      style: const TextStyle(
                        fontSize: 36,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const Text(
                      'Mejor Racha',
                      style: TextStyle(color: Colors.white70, fontSize: 14),
                    ),
                    const Text(
                      'récord personal',
                      style: TextStyle(color: Colors.white70, fontSize: 12),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTimeRecoveredSection() {
    final totalMinutes = stats['totalMinutes'] as int;
    final hours = totalMinutes ~/ 60;
    final minutes = totalMinutes % 60;
    
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.green.shade400, Colors.teal.shade600],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.green.withOpacity(0.3),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.auto_awesome, color: Colors.white, size: 24),
              SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Tiempo Invertido en tu Bienestar',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      hours > 0 ? '${hours}h ${minutes}m' : '${minutes}m',
                      style: const TextStyle(
                        fontSize: 40,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                const Text(
                  'dedicados a mejorar tu vida',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 14,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.15),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                const Icon(Icons.phone_android_outlined, color: Colors.white70, size: 20),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    totalMinutes >= 60
                        ? '💡 Has invertido este tiempo en ti en lugar de en redes sociales'
                        : '💡 Cada minuto cuenta. ¡Sigue así!',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),
          ),
          if (totalMinutes >= 120) ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.15),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  const Icon(Icons.self_improvement, color: Colors.white70, size: 20),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      _getMotivationalMessage(totalMinutes),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  String _getMotivationalMessage(int totalMinutes) {
    final hours = totalMinutes ~/ 60;
    
    if (hours >= 50) {
      return '🌟 ¡Increíble! Has dedicado más de 50 horas a tu crecimiento personal';
    } else if (hours >= 20) {
      return '🎯 ¡Excelente! Ese tiempo invertido ya está generando cambios positivos';
    } else if (hours >= 10) {
      return '✨ ¡Vas muy bien! Ya llevas ${hours} horas invirtiendo en tu bienestar';
    } else if (hours >= 5) {
      return '🌱 Cada sesión suma. Ya llevas ${hours} horas de progreso';
    } else {
      return '💪 ¡Buen comienzo! Cada minuto cuenta para tu transformación';
    }
  }

  Widget _buildActivityChart7Days() {
    final data = stats['last7Days'] as Map<String, int>;
    final maxValue = data.values.isEmpty ? 1 : data.values.reduce((a, b) => a > b ? a : b);
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Actividad de los Últimos 7 Días',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.grey[100],
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: data.entries.map((entry) {
                  final height = maxValue > 0 ? (entry.value / maxValue) * 100 : 0.0;
                  return Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 4),
                      child: Column(
                        children: [
                          Text(
                            entry.value.toString(),
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Container(
                            height: height.clamp(10, 100),
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  AppTheme.lightTheme.primaryColor,
                                  AppTheme.lightTheme.primaryColor.withOpacity(0.6),
                                ],
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                              ),
                              borderRadius: BorderRadius.circular(4),
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            entry.key,
                            style: TextStyle(
                              fontSize: 10,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }).toList(),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildActivityChart30Days() {
    final data = stats['last30Days'] as Map<String, int>;
    final maxValue = data.values.isEmpty ? 1 : data.values.reduce((a, b) => a > b ? a : b);
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Actividad del Último Mes (por semana)',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.grey[100],
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            children: data.entries.map((entry) {
              final percentage = maxValue > 0 ? (entry.value / maxValue) : 0.0;
              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          entry.key,
                          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
                        ),
                        Text(
                          '${entry.value} actividades',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[600],
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: LinearProgressIndicator(
                        value: percentage,
                        minHeight: 8,
                        backgroundColor: Colors.grey[300],
                        valueColor: AlwaysStoppedAnimation<Color>(
                          AppTheme.lightTheme.primaryColor,
                        ),
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }

  Widget _buildCategoryDistribution() {
    final data = stats['activitiesByCategory'] as Map<String, int>;
    
    if (data.isEmpty) {
      return const SizedBox.shrink();
    }
    
    final total = data.values.reduce((a, b) => a + b);
    final sortedEntries = data.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Distribución por Categoría',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.grey[100],
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            children: sortedEntries.map((entry) {
              final percentage = (entry.value / total * 100).round();
              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Row(
                  children: [
                    Expanded(
                      flex: 3,
                      child: Text(
                        entry.key,
                        style: const TextStyle(fontSize: 14),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      flex: 5,
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(4),
                        child: LinearProgressIndicator(
                          value: entry.value / total,
                          minHeight: 8,
                          backgroundColor: Colors.grey[300],
                          valueColor: AlwaysStoppedAnimation<Color>(
                            Colors.purple.shade400,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    SizedBox(
                      width: 60,
                      child: Text(
                        '$percentage% (${entry.value})',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[700],
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.right,
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }

  Widget _buildTypeDistribution() {
    final data = stats['activitiesByType'] as Map<String, int>;
    
    if (data.isEmpty) {
      return const SizedBox.shrink();
    }
    
    final colors = [
      Colors.blue.shade400,
      Colors.green.shade400,
      Colors.orange.shade400,
      Colors.pink.shade400,
    ];
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Distribución por Tipo de Actividad',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),
        Wrap(
          spacing: 12,
          runSpacing: 12,
          children: data.entries.toList().asMap().entries.map((mapEntry) {
            final index = mapEntry.key;
            final entry = mapEntry.value;
            final color = colors[index % colors.length];
            
            return Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: color.withOpacity(0.3)),
              ),
              child: Column(
                children: [
                  Text(
                    entry.value.toString(),
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: color,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    entry.key,
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[700],
                    ),
                  ),
                ],
              ),
            );
          }).toList(),
        ),
      ],
    );
  }
}
