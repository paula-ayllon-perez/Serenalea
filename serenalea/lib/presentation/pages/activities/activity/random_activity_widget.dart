import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../../core/constants/colors.dart';
import '../../../../data/models/activity_dto.dart';
import '../../../../data/repositories/photo_repository.dart';

enum ActivityType {
  photo,      // Requiere foto
  text,       // Requiere escribir texto
  meditation, // Meditación/respiración con temporizador
  simple,     // Solo completar sin requisitos
}

class RandomActivityWidget extends StatefulWidget {
  final Activity activity;
  final VoidCallback onCompleted;

  const RandomActivityWidget({
    Key? key,
    required this.activity,
    required this.onCompleted,
  }) : super(key: key);

  @override
  State<RandomActivityWidget> createState() => _RandomActivityWidgetState();
}

class _RandomActivityWidgetState extends State<RandomActivityWidget> with TickerProviderStateMixin {
  File? _imageFile;
  final TextEditingController _textController = TextEditingController();
  final PhotoRepository _photoRepository = PhotoRepository();
  bool _isCompleted = false;
  bool _isLoading = false;
  
  // Para meditación
  bool _isMeditating = false;
  int _currentCycle = 0;
  int _totalCycles = 0;
  String _breathPhase = '';
  AnimationController? _breathController;
  Animation<double>? _breathAnimation;

  Color get _categoryColor => AppColors.color2;

  ActivityType get _activityType {
    switch (widget.activity.activityType.toLowerCase()) {
      case 'photo':
        return ActivityType.photo;
      case 'text':
        return ActivityType.text;
      case 'meditation':
        return ActivityType.meditation;
      case 'simple':
        return ActivityType.simple;
      default:
        return ActivityType.simple;
    }
  }

  @override
  void dispose() {
    _textController.dispose();
    _breathController?.dispose();
    super.dispose();
  }

  Future<void> _pickImage(ImageSource source) async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(
      source: source,
      maxWidth: 1200,
      maxHeight: 1200,
      imageQuality: 85,
    );
    
    if (pickedFile != null) {
      setState(() {
        _imageFile = File(pickedFile.path);
      });
    }
  }

  Future<void> _completeActivity() async {
    setState(() => _isLoading = true);

    try {
      final userId = FirebaseAuth.instance.currentUser?.uid;
      if (userId == null) {
        throw Exception('Usuario no autenticado');
      }

      // Guardar en completedActivities para estadísticas
      await FirebaseFirestore.instance.collection('completedActivities').add({
        'userId': userId,
        'activityId': widget.activity.id,
        'activityName': widget.activity.title,
        'categoryName': 'Aleatoria',
        'activityType': widget.activity.activityType,
        'score': widget.activity.score,
        'duration': widget.activity.duration, // Duración en minutos
        'completedAt': FieldValue.serverTimestamp(),
      });

      // Guardar en el álbum según el tipo de actividad
      if (_activityType == ActivityType.photo && _imageFile != null) {
        await _photoRepository.savePhoto(
          imagePath: _imageFile!.path,
          activityName: widget.activity.title,
          activityCategory: 'Aleatoria',
          description: widget.activity.description,
        );
      } else if (_activityType == ActivityType.text && _textController.text.trim().isNotEmpty) {
        await _photoRepository.savePhoto(
          imagePath: 'icon:text',
          activityName: widget.activity.title,
          activityCategory: 'Aleatoria',
          description: _textController.text.trim(),
        );
      } else if (_activityType == ActivityType.meditation) {
        await _photoRepository.savePhoto(
          imagePath: 'icon:meditation',
          activityName: widget.activity.title,
          activityCategory: 'Aleatoria',
          description: '✅ Actividad completada: ${widget.activity.description}',
        );
      } else if (_activityType == ActivityType.simple) {
        await _photoRepository.savePhoto(
          imagePath: 'icon:simple',
          activityName: widget.activity.title,
          activityCategory: 'Aleatoria',
          description: '✅ Actividad completada: ${widget.activity.description}',
        );
      }

      setState(() {
        _isCompleted = true;
        _isLoading = false;
      });

      // Notificar completado
      widget.onCompleted();
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al completar: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  bool get _canComplete {
    switch (_activityType) {
      case ActivityType.photo:
        return _imageFile != null;
      case ActivityType.text:
        return _textController.text.trim().isNotEmpty;
      case ActivityType.meditation:
        return _currentCycle > 0;
      case ActivityType.simple:
        return true;
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isCompleted) {
      return _buildCompletedView();
    }
    
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Encabezado de la actividad
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    _categoryColor.withOpacity(0.15),
                    _categoryColor.withOpacity(0.05),
                  ],
                ),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: _categoryColor.withOpacity(0.3),
                  width: 2,
                ),
                boxShadow: [
                  BoxShadow(
                    color: _categoryColor.withOpacity(0.1),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: _categoryColor,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(
                          _getActivityIcon(),
                          color: Colors.white,
                          size: 28,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Text(
                          widget.activity.title,
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: AppColors.color1,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  Text(
                    widget.activity.description,
                    style: TextStyle(
                      fontSize: 16,
                      height: 1.6,
                      color: AppColors.color1.withOpacity(0.8),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      _buildInfoChip(
                        Icons.timer_outlined,
                        '${widget.activity.duration} min',
                        _categoryColor,
                      ),
                      _buildInfoChip(
                        _getDifficultyIcon(widget.activity.difficulty),
                        widget.activity.difficultyLabel,
                        AppColors.color4,
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 28),

            // Contenido específico según el tipo
            if (_activityType == ActivityType.photo) ...[
              _buildPhotoSection(),
            ] else if (_activityType == ActivityType.text) ...[
              _buildTextSection(),
            ] else if (_activityType == ActivityType.meditation) ...[
              _buildMeditationSection(),
            ] else ...[
              _buildSimpleSection(),
            ],

            const SizedBox(height: 28),

            // Botón de completar
            ElevatedButton.icon(
              icon: _isLoading
                  ? const SizedBox(
                      width: 22,
                      height: 22,
                      child: CircularProgressIndicator(
                        strokeWidth: 2.5,
                        color: Colors.white,
                      ),
                    )
                  : const Icon(Icons.check_circle, size: 24),
              label: Text(
                _isLoading ? 'Guardando...' : 'Completar actividad',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 18),
                backgroundColor: _categoryColor,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
                elevation: 3,
              ),
              onPressed: (_canComplete && !_isLoading) ? _completeActivity : null,
            ),
            
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildCompletedView() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TweenAnimationBuilder(
              duration: const Duration(milliseconds: 600),
              tween: Tween<double>(begin: 0.0, end: 1.0),
              builder: (context, double value, child) {
                return Transform.scale(
                  scale: value,
                  child: Container(
                    padding: const EdgeInsets.all(28),
                    decoration: BoxDecoration(
                      color: Colors.green.withOpacity(0.15),
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.green.withOpacity(0.3),
                          blurRadius: 20,
                          spreadRadius: 5,
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.check_circle,
                      size: 100,
                      color: Colors.green,
                    ),
                  ),
                );
              },
            ),
            const SizedBox(height: 32),
            Text(
              '¡Actividad completada!',
              style: TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.bold,
                color: AppColors.color1,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              decoration: BoxDecoration(
                color: _categoryColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: _categoryColor.withOpacity(0.3),
                  width: 2,
                ),
              ),
              child: Column(
                children: [
                  Icon(
                    Icons.photo_album,
                    color: _categoryColor,
                    size: 36,
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'Guardado en tu álbum',
                    style: TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),
            Text(
              'Cargando siguiente actividad...',
              style: TextStyle(
                fontSize: 15,
                color: AppColors.color3,
                fontStyle: FontStyle.italic,
              ),
            ),
            const SizedBox(height: 16),
            CircularProgressIndicator(
              color: _categoryColor,
              strokeWidth: 3,
            ),
          ],
        ),
      ),
    );
  }

  IconData _getActivityIcon() {
    switch (_activityType) {
      case ActivityType.photo:
        return Icons.camera_alt;
      case ActivityType.text:
        return Icons.edit_note;
      case ActivityType.meditation:
        return Icons.self_improvement;
      case ActivityType.simple:
        return Icons.check_circle_outline;
    }
  }

  Widget _buildPhotoSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: _categoryColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: _categoryColor.withOpacity(0.3),
              width: 2,
            ),
          ),
          child: Row(
            children: [
              Icon(
                Icons.camera_alt,
                color: _categoryColor,
                size: 26,
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: Text(
                  'Captura o selecciona una foto',
                  style: TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        if (_imageFile == null)
          Container(
            height: 200,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: _categoryColor.withOpacity(0.3),
                width: 3,
              ),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.add_photo_alternate_outlined,
                  size: 64,
                  color: _categoryColor.withOpacity(0.5),
                ),
                const SizedBox(height: 12),
                Text(
                  'Añade una foto',
                  style: TextStyle(
                    color: AppColors.color3,
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          )
        else
          Stack(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: Image.file(
                  _imageFile!,
                  height: 200,
                  width: double.infinity,
                  fit: BoxFit.cover,
                ),
              ),
              Positioned(
                top: 8,
                right: 8,
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.black54,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: IconButton(
                    icon: const Icon(Icons.close, color: Colors.white),
                    onPressed: () {
                      setState(() {
                        _imageFile = null;
                      });
                    },
                  ),
                ),
              ),
            ],
          ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: ElevatedButton.icon(
                icon: const Icon(Icons.camera_alt),
                label: const Text('Cámara'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  backgroundColor: _categoryColor,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                onPressed: () => _pickImage(ImageSource.camera),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: ElevatedButton.icon(
                icon: const Icon(Icons.photo_library),
                label: const Text('Galería'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  backgroundColor: _categoryColor.withOpacity(0.8),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                onPressed: () => _pickImage(ImageSource.gallery),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildTextSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: _categoryColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: _categoryColor.withOpacity(0.3),
              width: 2,
            ),
          ),
          child: Row(
            children: [
              Icon(
                Icons.edit_note,
                color: _categoryColor,
                size: 26,
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: Text(
                  'Escribe tu respuesta',
                  style: TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: _categoryColor.withOpacity(0.1),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: TextField(
            controller: _textController,
            maxLines: 8,
            maxLength: 500,
            decoration: InputDecoration(
              hintText: 'Escribe aquí tus pensamientos...',
              hintStyle: TextStyle(
                color: AppColors.color3.withOpacity(0.5),
                fontSize: 15,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: _categoryColor),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(
                  color: _categoryColor.withOpacity(0.3),
                  width: 2,
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: _categoryColor, width: 2),
              ),
              filled: true,
              fillColor: Colors.white,
              contentPadding: const EdgeInsets.all(16),
            ),
            style: TextStyle(
              fontSize: 16,
              color: AppColors.color1,
              height: 1.5,
            ),
            onChanged: (value) => setState(() {}),
          ),
        ),
      ],
    );
  }

  Map<String, int> _getBreathingPattern() {
    final title = widget.activity.title.toLowerCase();
    final description = widget.activity.description.toLowerCase();
    
    if (title.contains('4-2-6') || description.contains('4') && description.contains('2') && description.contains('6')) {
      return {'inhale': 4, 'hold1': 2, 'exhale': 6, 'hold2': 0};
    } else if (title.contains('cuadrada') || (description.contains('4s') && description.contains('retén'))) {
      return {'inhale': 4, 'hold1': 4, 'exhale': 4, 'hold2': 4};
    } else {
      return {'inhale': 4, 'hold1': 0, 'exhale': 4, 'hold2': 0};
    }
  }

  void _startMeditation() {
    final pattern = _getBreathingPattern();
    
    _breathController?.dispose();
    
    setState(() {
      _isMeditating = true;
      _currentCycle = 0;
      _totalCycles = 10;
      _breathPhase = 'Inhala'; 
    });

    _breathController = AnimationController(
      duration: const Duration(milliseconds: 100),
      vsync: this,
    );
    
    _breathAnimation = Tween<double>(begin: 0.3, end: 0.3).animate(_breathController!);

    _runBreathingCycle(pattern);
  }

  Future<void> _runBreathingCycle(Map<String, int> pattern) async {
    if (!mounted || !_isMeditating || _currentCycle >= _totalCycles) {
      if (mounted) {
        setState(() {
          _isMeditating = false;
          _breathPhase = '';
        });
      }
      return;
    }

    setState(() => _currentCycle++);

    // Inhalar
    if (pattern['inhale']! > 0 && _isMeditating) {
      setState(() => _breathPhase = 'Inhala');
      
      _breathController!.duration = Duration(seconds: pattern['inhale']!);
      _breathAnimation = Tween<double>(begin: 0.3, end: 1.0).animate(
        CurvedAnimation(parent: _breathController!, curve: Curves.easeInOut),
      );
      
      _breathController!.reset();
      await _breathController!.forward();
      
      if (!_isMeditating || !mounted) return;
    }

    // Mantener
    if (pattern['hold1']! > 0 && _isMeditating) {
      setState(() => _breathPhase = 'Mantén');
      await Future.delayed(Duration(seconds: pattern['hold1']!));
      
      if (!_isMeditating || !mounted) return;
    }

    // Exhalar
    if (pattern['exhale']! > 0 && _isMeditating) {
      setState(() => _breathPhase = 'Exhala');
      
      _breathController!.duration = Duration(seconds: pattern['exhale']!);
      _breathAnimation = Tween<double>(begin: 1.0, end: 0.3).animate(
        CurvedAnimation(parent: _breathController!, curve: Curves.easeInOut),
      );
      
      _breathController!.reset();
      await _breathController!.forward();
      
      if (!_isMeditating || !mounted) return;
    }

    // Mantener
    if (pattern['hold2']! > 0 && _isMeditating) {
      setState(() => _breathPhase = 'Mantén');
      await Future.delayed(Duration(seconds: pattern['hold2']!));
      
      if (!_isMeditating || !mounted) return;
    }

    if (_isMeditating && mounted) {
      _runBreathingCycle(pattern);
    }
  }

  void _stopMeditation() {
    _breathController?.stop();
    _breathController?.reset();
    setState(() {
      _isMeditating = false;
      _breathPhase = '';
      _currentCycle = 0;
    });
  }

  Widget _buildMeditationSection() {
    if (!_isMeditating) {
      return Container(
        padding: const EdgeInsets.all(32),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              _categoryColor.withOpacity(0.2),
              _categoryColor.withOpacity(0.05),
            ],
          ),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: _categoryColor.withOpacity(0.3),
            width: 2,
          ),
        ),
        child: Column(
          children: [
            Icon(
              Icons.self_improvement,
              size: 90,
              color: _categoryColor,
            ),
            const SizedBox(height: 20),
            const Text(
              'Ejercicio de respiración',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            Text(
              '${widget.activity.duration} minutos',
              style: TextStyle(
                fontSize: 17,
                color: _categoryColor,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 28),
            ElevatedButton.icon(
              onPressed: _startMeditation,
              icon: const Icon(Icons.play_arrow, size: 26),
              label: const Text(
                'Comenzar',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 18),
                backgroundColor: _categoryColor,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(25),
                ),
                elevation: 3,
              ),
            ),
          ],
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            _categoryColor.withOpacity(0.1),
            _categoryColor.withOpacity(0.05),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        children: [
          Text(
            'Ciclo $_currentCycle de $_totalCycles',
            style: TextStyle(
              fontSize: 16,
              color: AppColors.color3,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 32),
          
          SizedBox(
            width: 240,
            height: 240,
            child: Center(
              child: AnimatedBuilder(
                animation: _breathAnimation ?? AlwaysStoppedAnimation(0.5),
                builder: (context, child) {
                  final size = 100 + ((_breathAnimation?.value ?? 0.5) * 140);
                  return Container(
                    width: size,
                    height: size,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: RadialGradient(
                        colors: [
                          _categoryColor,
                          _categoryColor.withOpacity(0.6),
                        ],
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: _categoryColor.withOpacity(0.4),
                          blurRadius: 30,
                          spreadRadius: 10,
                        ),
                      ],
                    ),
                    child: Center(
                      child: Text(
                        _breathPhase,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
          
          const SizedBox(height: 40),
          
          OutlinedButton.icon(
            onPressed: _stopMeditation,
            icon: const Icon(Icons.stop),
            label: const Text('Detener'),
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 14),
              foregroundColor: _categoryColor,
              side: BorderSide(color: _categoryColor, width: 2),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSimpleSection() {
    return Container(
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        color: _categoryColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: _categoryColor.withOpacity(0.3),
          width: 2,
        ),
      ),
      child: Column(
        children: [
          Icon(
            Icons.check_circle_outline,
            size: 70,
            color: _categoryColor,
          ),
          const SizedBox(height: 16),
          const Text(
            'Realiza esta actividad y márcala como completada',
            style: TextStyle(
              fontSize: 16,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildInfoChip(IconData icon, String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: color.withOpacity(0.15),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.3)),
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
}
