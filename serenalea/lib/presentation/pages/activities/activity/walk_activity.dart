
import 'package:flutter/material.dart';
import 'dart:math';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import '../../../../core/constants/colors.dart';
import '../../../../data/repositories/photo_repository.dart';

class WalkActivityPage extends StatefulWidget {
  const WalkActivityPage({Key? key}) : super(key: key);

  @override
  State<WalkActivityPage> createState() => _WalkActivityPageState();
}

class _WalkActivityPageState extends State<WalkActivityPage> {
  final List<String> prompts = [
    "Encuentra un lugar donde puedas escuchar claramente el sonido del agua.",
    "Camina hasta ver un árbol más alto que un edificio cercano.",
    "Busca una pared con un mural, grafiti o pintura llamativa.",
    "Localiza un banco que esté completamente a la sombra.",
    "Encuentra un rincón donde haya flores de al menos tres colores diferentes.",
    "Camina hasta que veas un cartel con una palabra que empiece por la letra S.",
    "Busca una puerta o ventana pintada de un color poco común (como morado, turquesa o rosa).",
    "Encuentra un sitio desde el que puedas ver el horizonte sin edificios tapándolo.",
    "Busca una fuente, estanque o cualquier lugar con agua en movimiento.",
    "Camina hasta encontrar un árbol con ramas que formen una figura curiosa.",
    "Encuentra un lugar donde puedas oír claramente el canto de pájaros.",
    "Busca un edificio o lugar que tenga algún detalle arquitectónico que no habías notado antes.",
    "Camina hasta encontrar un sitio que tenga un olor agradable distinto al de tu casa.",
    "Encuentra un objeto con textura rugosa y uno con textura muy lisa.",
    "Busca un letrero o cartel con un número primo."
  ];

  int currentIndex = 0;
  final Random _random = Random();
  File? _imageFile;
  final ImagePicker _picker = ImagePicker();
  final PhotoRepository _photoRepository = PhotoRepository();

  @override
  void initState() {
    super.initState();
    currentIndex = _random.nextInt(prompts.length);
  }

  void _nextPrompt() {
    setState(() {
      int next;
      do {
        next = _random.nextInt(prompts.length);
      } while (next == currentIndex && prompts.length > 1);
      currentIndex = next;
      _imageFile = null; // Reinicia la foto al cambiar de reto
    });
  }

  Future<void> _takePhoto() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.camera);
    if (pickedFile != null) {
      setState(() {
        _imageFile = File(pickedFile.path);
      });
      
      // Guardar la foto en el álbum
      try {
        await _photoRepository.savePhoto(
          imagePath: pickedFile.path,
          activityName: 'Actividad de Paseo',
          activityCategory: 'Walk',
          description: prompts[currentIndex],
        );
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('✓ Foto guardada en tu álbum'),
              duration: Duration(seconds: 2),
              backgroundColor: Colors.green,
            ),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error al guardar: $e')),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Actividad: Paseo'),
        backgroundColor: AppColors.color1,
        foregroundColor: AppColors.white,
        elevation: 0,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: AppColors.color2.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.color1.withOpacity(0.12),
                      blurRadius: 12,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    Icon(Icons.directions_walk_rounded, color: AppColors.color1, size: 40),
                    const SizedBox(height: 12),
                    Text(
                      prompts[currentIndex],
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w600,
                        color: AppColors.color1,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 28),
              ElevatedButton.icon(
                icon: const Icon(Icons.camera_alt_rounded),
                label: const Text('Tomar foto'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                  textStyle: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  backgroundColor: AppColors.color2,
                  foregroundColor: AppColors.white,
                  elevation: 4,
                ),
                onPressed: _takePhoto,
              ),
              if (_imageFile != null) ...[
                const SizedBox(height: 20),
                ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: Image.file(
                    _imageFile!,
                    width: 220,
                    height: 220,
                    fit: BoxFit.cover,
                  ),
                ),
              ],
              const SizedBox(height: 28),
              ElevatedButton.icon(
                icon: const Icon(Icons.refresh_rounded),
                label: const Text('Siguiente reto'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                  textStyle: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  backgroundColor: AppColors.color1,
                  foregroundColor: AppColors.white,
                  elevation: 4,
                ),
                onPressed: _nextPrompt,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
