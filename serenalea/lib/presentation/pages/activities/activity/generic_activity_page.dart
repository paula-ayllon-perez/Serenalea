import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../../core/constants/colors.dart';
import '../../../../data/models/activity_dto.dart';
import '../../../../data/repositories/photo_repository.dart';

enum ActivityType {
  photo,      // Requiere foto (creatividad, observación, paseo)
  text,       // Requiere escribir texto (diario)
  meditation, // Meditación/respiración con temporizador
  simple,     // Solo completar sin requisitos
}

class GenericActivityPage extends StatefulWidget {
  final Activity activity;
  final String categoryName;
  final Color categoryColor;

  const GenericActivityPage({
    Key? key,
    required this.activity,
    required this.categoryName,
    required this.categoryColor,
  }) : super(key: key);

  @override
  State<GenericActivityPage> createState() => _GenericActivityPageState();
}

class _GenericActivityPageState extends State<GenericActivityPage> with TickerProviderStateMixin {
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

  ActivityType get _activityType {
    // Usar el campo activityType de la base de datos
    print('🔍 Activity: ${widget.activity.title}');
    print('🔍 activityType from DB: ${widget.activity.activityType}');
    
    switch (widget.activity.activityType.toLowerCase()) {
      case 'photo':
        print('✅ Detected type: PHOTO');
        return ActivityType.photo;
      case 'text':
        print('✅ Detected type: TEXT');
        return ActivityType.text;
      case 'meditation':
        print('✅ Detected type: MEDITATION');
        return ActivityType.meditation;
      case 'simple':
        print('✅ Detected type: SIMPLE');
        return ActivityType.simple;
      default:
        print('⚠️ Unknown type, defaulting to SIMPLE');
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
        'categoryName': widget.categoryName,
        'activityType': widget.activity.activityType,
        'score': widget.activity.score,
        'duration': widget.activity.duration, // Duración en minutos
        'completedAt': FieldValue.serverTimestamp(),
      });

      // Guardar en el álbum según el tipo de actividad
      if (_activityType == ActivityType.photo && _imageFile != null) {
        // Actividades con foto
        await _photoRepository.savePhoto(
          imagePath: _imageFile!.path,
          activityName: widget.activity.title,
          activityCategory: widget.categoryName,
          description: widget.activity.description,
        );
      } else if (_activityType == ActivityType.text && _textController.text.trim().isNotEmpty) {
        // Actividades de texto: guardar con marcador especial
        await _photoRepository.savePhoto(
          imagePath: 'icon:text', // Marcador para mostrar icono de texto
          activityName: widget.activity.title,
          activityCategory: widget.categoryName,
          description: _textController.text.trim(), // Solo la respuesta del usuario
        );
      } else if (_activityType == ActivityType.meditation) {
        // Actividades de meditación: guardar con marcador especial
        await _photoRepository.savePhoto(
          imagePath: 'icon:meditation', // Marcador para mostrar icono de meditación
          activityName: widget.activity.title,
          activityCategory: widget.categoryName,
          description: '✅ Actividad completada: ${widget.activity.description}',
        );
      } else if (_activityType == ActivityType.simple) {
        // Actividades simples: guardar con marcador especial
        await _photoRepository.savePhoto(
          imagePath: 'icon:simple', // Marcador para mostrar icono de check
          activityName: widget.activity.title,
          activityCategory: widget.categoryName,
          description: '✅ Actividad completada: ${widget.activity.description}',
        );
      }

      setState(() {
        _isCompleted = true;
        _isLoading = false;
      });

      // Mostrar mensaje de éxito
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Row(
              children: [
                Icon(Icons.check_circle, color: Colors.white),
                SizedBox(width: 12),
                Expanded(
                  child: Text(
                    '¡Actividad completada y guardada en tu álbum!',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 3),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }

      // Cerrar la página después de 2 segundos
      Future.delayed(const Duration(seconds: 2), () {
        if (mounted) Navigator.pop(context);
      });
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
        return _currentCycle > 0; // Al menos un ciclo completado
      case ActivityType.simple:
        return true;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.activity.title),
        backgroundColor: widget.categoryColor,
      ),
      backgroundColor: AppColors.background,
      body: _isCompleted ? _buildCompletedView() : _buildActivityView(),
    );
  }

  Widget _buildCompletedView() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.green.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.check_circle,
                size: 100,
                color: Colors.green,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              '¡Actividad completada!',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: AppColors.color1,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              decoration: BoxDecoration(
                color: widget.categoryColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: widget.categoryColor.withOpacity(0.3),
                  width: 2,
                ),
              ),
              child: Column(
                children: [
                  Icon(
                    Icons.photo_album,
                    color: widget.categoryColor,
                    size: 32,
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Guardado en tu álbum',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Podrás verlo cuando quieras',
                    style: TextStyle(
                      fontSize: 14,
                      color: AppColors.color3,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),
            const CircularProgressIndicator(),
            const SizedBox(height: 16),
            Text(
              'Cerrando...',
              style: TextStyle(color: AppColors.color3),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActivityView() {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Descripción de la actividad
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: widget.categoryColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: widget.categoryColor.withOpacity(0.3),
                  width: 2,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.info_outline,
                        color: widget.categoryColor,
                        size: 28,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          'Instrucciones',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: widget.categoryColor,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    widget.activity.description,
                    style: TextStyle(
                      fontSize: 16,
                      height: 1.5,
                      color: AppColors.color1,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      _buildInfoChip(
                        Icons.timer,
                        '${widget.activity.duration} min',
                        AppColors.color2,
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

            const SizedBox(height: 32),

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

            const SizedBox(height: 32),

            // Botón de completar
            ElevatedButton.icon(
              icon: _isLoading
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : const Icon(Icons.check_circle),
              label: Text(_isLoading ? 'Guardando...' : 'Completar actividad'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                backgroundColor: widget.categoryColor,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                textStyle: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              onPressed: (_canComplete && !_isLoading) ? _completeActivity : null,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPhotoSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: widget.categoryColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: widget.categoryColor.withOpacity(0.3),
              width: 2,
            ),
          ),
          child: Row(
            children: [
              Icon(
                Icons.camera_alt,
                color: widget.categoryColor,
                size: 28,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  'Captura o selecciona una foto',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: widget.categoryColor,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        if (_imageFile == null)
          Container(
            height: 220,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: widget.categoryColor.withOpacity(0.3),
                width: 3,
                style: BorderStyle.solid,
              ),
              boxShadow: [
                BoxShadow(
                  color: widget.categoryColor.withOpacity(0.1),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.add_photo_alternate_outlined,
                  size: 72,
                  color: widget.categoryColor.withOpacity(0.5),
                ),
                const SizedBox(height: 16),
                Text(
                  'Toca un botón para agregar foto',
                  style: TextStyle(
                    color: AppColors.color3,
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Tu foto se guardará en el álbum',
                  style: TextStyle(
                    color: AppColors.color3.withOpacity(0.7),
                    fontSize: 13,
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
                  height: 220,
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
                  backgroundColor: widget.categoryColor,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 2,
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
                  backgroundColor: widget.categoryColor.withOpacity(0.8),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 2,
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
            color: widget.categoryColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: widget.categoryColor.withOpacity(0.3),
              width: 2,
            ),
          ),
          child: Row(
            children: [
              Icon(
                Icons.edit_note,
                color: widget.categoryColor,
                size: 28,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  'Escribe tu respuesta',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: widget.categoryColor,
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
                color: widget.categoryColor.withOpacity(0.1),
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
                borderSide: BorderSide(color: widget.categoryColor),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(
                  color: widget.categoryColor.withOpacity(0.3),
                  width: 2,
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: widget.categoryColor, width: 2),
              ),
              filled: true,
              fillColor: Colors.white,
              contentPadding: const EdgeInsets.all(16),
              counterStyle: TextStyle(
                color: AppColors.color3,
                fontSize: 12,
              ),
            ),
            style: TextStyle(
              fontSize: 16,
              color: AppColors.color1,
              height: 1.5,
            ),
            onChanged: (value) => setState(() {}),
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Icon(
              Icons.info_outline,
              size: 16,
              color: AppColors.color3,
            ),
            const SizedBox(width: 6),
            Expanded(
              child: Text(
                'Tu respuesta se guardará en el álbum de recuerdos',
                style: TextStyle(
                  fontSize: 13,
                  color: AppColors.color3,
                  fontStyle: FontStyle.italic,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Map<String, int> _getBreathingPattern() {
    // Extraer patrón de respiración del título y descripción
    final title = widget.activity.title.toLowerCase();
    final description = widget.activity.description.toLowerCase();
    
    if (title.contains('4-2-6') || description.contains('4') && description.contains('2') && description.contains('6')) {
      return {'inhale': 4, 'hold1': 2, 'exhale': 6, 'hold2': 0};
    } else if (title.contains('cuadrada') || (description.contains('4s') && description.contains('retén'))) {
      return {'inhale': 4, 'hold1': 4, 'exhale': 4, 'hold2': 4};
    } else {
      // Patrón por defecto
      return {'inhale': 4, 'hold1': 0, 'exhale': 4, 'hold2': 0};
    }
  }

  void _startMeditation() {
    final pattern = _getBreathingPattern();
    final totalSeconds = pattern['inhale']! + pattern['hold1']! + pattern['exhale']! + pattern['hold2']!;
    
    // Limpiar controlador anterior si existe
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
    if (!mounted) return;
    
    if (!_isMeditating || _currentCycle >= _totalCycles) {
      if (mounted) {
        setState(() {
          _isMeditating = false;
          _breathPhase = '';
        });
      }
      return;
    }

    if (mounted) {
      setState(() => _currentCycle++);
    }

    // Inhalar
    if (pattern['inhale']! > 0 && _isMeditating) {
      if (mounted) {
        setState(() => _breathPhase = 'Inhala');
      }
      
      _breathController!.duration = Duration(seconds: pattern['inhale']!);
      _breathAnimation = Tween<double>(begin: 0.3, end: 1.0).animate(
        CurvedAnimation(parent: _breathController!, curve: Curves.easeInOut),
      );
      
      _breathController!.reset();
      await _breathController!.forward();
      
      if (!_isMeditating || !mounted) return;
    }

    // Mantener (hold1)
    if (pattern['hold1']! > 0 && _isMeditating) {
      if (mounted) {
        setState(() => _breathPhase = 'Mantén');
      }
      await Future.delayed(Duration(seconds: pattern['hold1']!));
      
      if (!_isMeditating || !mounted) return;
    }

    // Exhalar
    if (pattern['exhale']! > 0 && _isMeditating) {
      if (mounted) {
        setState(() => _breathPhase = 'Exhala');
      }
      
      _breathController!.duration = Duration(seconds: pattern['exhale']!);
      _breathAnimation = Tween<double>(begin: 1.0, end: 0.3).animate(
        CurvedAnimation(parent: _breathController!, curve: Curves.easeInOut),
      );
      
      _breathController!.reset();
      await _breathController!.forward();
      
      if (!_isMeditating || !mounted) return;
    }

    // Mantener (hold2)
    if (pattern['hold2']! > 0 && _isMeditating) {
      if (mounted) {
        setState(() => _breathPhase = 'Mantén');
      }
      await Future.delayed(Duration(seconds: pattern['hold2']!));
      
      if (!_isMeditating || !mounted) return;
    }

    // Continuar con el siguiente ciclo
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
      // Vista inicial con botón de comenzar
      return Container(
        padding: const EdgeInsets.all(32),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              widget.categoryColor.withOpacity(0.2),
              widget.categoryColor.withOpacity(0.05),
            ],
          ),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: widget.categoryColor.withOpacity(0.3),
            width: 2,
          ),
        ),
        child: Column(
          children: [
            Icon(
              Icons.self_improvement,
              size: 100,
              color: widget.categoryColor,
            ),
            const SizedBox(height: 24),
            Text(
              'Ejercicio de respiración',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: AppColors.color1,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            Text(
              '${widget.activity.duration} minutos',
              style: TextStyle(
                fontSize: 18,
                color: AppColors.color2,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 32),
            ElevatedButton.icon(
              onPressed: _startMeditation,
              icon: const Icon(Icons.play_arrow, size: 28),
              label: const Text(
                'Comenzar',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 48, vertical: 20),
                backgroundColor: widget.categoryColor,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
                elevation: 4,
              ),
            ),
          ],
        ),
      );
    }

    // Vista durante la meditación con animación
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            widget.categoryColor.withOpacity(0.1),
            widget.categoryColor.withOpacity(0.05),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        children: [
          // Contador de ciclos
          Text(
            'Ciclo $_currentCycle de $_totalCycles',
            style: TextStyle(
              fontSize: 16,
              color: AppColors.color3,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 32),
          
          // Círculo animado con contenedor fijo
          SizedBox(
            width: 260,
            height: 260,
            child: Center(
              child: AnimatedBuilder(
                animation: _breathAnimation ?? AlwaysStoppedAnimation(0.5),
                builder: (context, child) {
                  final size = 120 + ((_breathAnimation?.value ?? 0.5) * 140);
                  return Container(
                    width: size,
                    height: size,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: RadialGradient(
                        colors: [
                          widget.categoryColor,
                          widget.categoryColor.withOpacity(0.6),
                        ],
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: widget.categoryColor.withOpacity(0.4),
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
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
          
          const SizedBox(height: 48),
          
          // Botón para detener
          OutlinedButton.icon(
            onPressed: _stopMeditation,
            icon: const Icon(Icons.stop),
            label: const Text('Detener'),
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
              foregroundColor: widget.categoryColor,
              side: BorderSide(color: widget.categoryColor, width: 2),
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
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: widget.categoryColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          Icon(
            Icons.check_circle_outline,
            size: 80,
            color: widget.categoryColor,
          ),
          const SizedBox(height: 16),
          Text(
            'Realiza esta actividad y márcala como completada',
            style: TextStyle(
              fontSize: 16,
              color: AppColors.color1,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildInfoChip(IconData icon, String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: color),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
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
