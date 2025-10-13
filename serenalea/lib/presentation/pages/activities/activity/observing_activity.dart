import 'dart:io';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../../../../core/constants/colors.dart';

class ObservingActivityPage extends StatefulWidget {
  const ObservingActivityPage({Key? key}) : super(key: key);

  @override
  State<ObservingActivityPage> createState() => _ObservingActivityPageState();
}

class _ObservingActivityPageState extends State<ObservingActivityPage> {
  final List<String> observingChallenges = [
    'Mira las nubes y encuentra una letra o forma específica (ej. “M”).',
    'Observa a tu alrededor y encuentra algo que tenga forma de corazón.',
    'Encuentra tres objetos que tengan el mismo color.',
    'Busca un reflejo curioso en alguna superficie cercana.',
    'Mira alrededor e identifica un patrón repetido (rejillas, baldosas, ventanas…).',
    'Encuentra un número o letra escondida en el entorno.',
    'Busca un objeto que parezca “fuera de lugar” y piensa por qué.',
    'Mira por la ventana y localiza algo que esté en movimiento.',
    'Encuentra algo que te parezca divertido o inesperado.',
    'Mira hacia arriba y busca un detalle arquitectónico que nunca habías notado.'
  ];

  int challengeIndex = 0;
  File? _imageFile;

  @override
  void initState() {
    super.initState();
    _setRandomChallenge();
  }

  void _setRandomChallenge() {
    final random = Random();
    challengeIndex = random.nextInt(observingChallenges.length);
    setState(() {});
  }

  Future<void> _pickImage(ImageSource source) async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: source, maxWidth: 900, maxHeight: 900);
    if (pickedFile != null) {
      setState(() {
        _imageFile = File(pickedFile.path);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Actividad de Observación'),
        backgroundColor: AppColors.color1,
      ),
      backgroundColor: AppColors.background,
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 22, horizontal: 20),
                decoration: BoxDecoration(
                  color: AppColors.softBlue,
                  borderRadius: BorderRadius.circular(22),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.color3.withOpacity(0.18),
                      blurRadius: 18,
                      offset: const Offset(0, 8),
                    ),
                  ],
                  border: Border.all(
                    color: AppColors.color1.withOpacity(0.22),
                    width: 1.5,
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.visibility_rounded, color: AppColors.color2, size: 28),
                        const SizedBox(width: 8),
                        Text(
                          'Reto de observación',
                          style: TextStyle(
                            fontSize: 19,
                            fontWeight: FontWeight.bold,
                            color: AppColors.color2,
                            letterSpacing: 0.2,
                          ),
                        ),
                        const Spacer(),
                        IconButton(
                          icon: const Icon(Icons.refresh_rounded),
                          color: AppColors.color2,
                          tooltip: 'Nuevo reto',
                          onPressed: _setRandomChallenge,
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Text(
                      observingChallenges[challengeIndex],
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w500,
                        color: AppColors.color1,
                        height: 1.35,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),
              _imageFile == null
                  ? Container(
                      width: double.infinity,
                      height: 180,
                      decoration: BoxDecoration(
                        color: AppColors.color4.withOpacity(0.18),
                        borderRadius: BorderRadius.circular(18),
                        border: Border.all(color: AppColors.color3.withOpacity(0.18)),
                      ),
                      child: Center(
                        child: Text(
                          'Sube o toma una foto para completar el reto',
                          style: TextStyle(
                            color: AppColors.color2,
                            fontSize: 16,
                          ),
                        ),
                      ),
                    )
                  : ClipRRect(
                      borderRadius: BorderRadius.circular(18),
                      child: Image.file(_imageFile!, height: 180, width: double.infinity, fit: BoxFit.cover),
                    ),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ElevatedButton.icon(
                    icon: const Icon(Icons.camera_alt_rounded),
                    label: const Text('Tomar foto'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.color1,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
                    ),
                    onPressed: () => _pickImage(ImageSource.camera),
                  ),
                  const SizedBox(width: 18),
                  ElevatedButton.icon(
                    icon: const Icon(Icons.photo_library_rounded),
                    label: const Text('Subir foto'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.color2,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
                    ),
                    onPressed: () => _pickImage(ImageSource.gallery),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
