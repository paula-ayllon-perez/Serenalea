import 'package:flutter/material.dart';
import '../../../core/constants/colors.dart';

class PhotoAlbumPage extends StatefulWidget {
  const PhotoAlbumPage({Key? key}) : super(key: key);

  @override
  State<PhotoAlbumPage> createState() => _PhotoAlbumPageState();
}

class _PhotoAlbumPageState extends State<PhotoAlbumPage> {
  // Aquí se implementará la lógica para cargar y mostrar las fotos
  // guardadas de las actividades
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Álbum de fotos'),
        backgroundColor: AppColors.color1,
      ),
      backgroundColor: AppColors.background,
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.photo_library_rounded,
                size: 80,
                color: AppColors.color2,
              ),
              const SizedBox(height: 24),
              Text(
                'Álbum de fotos',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: AppColors.color1,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'Aquí podrás ver todas las fotos que has capturado durante tus actividades.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 16,
                  color: AppColors.color2,
                ),
              ),
              const SizedBox(height: 32),
              Text(
                'Esta función estará disponible próximamente',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14,
                  color: AppColors.color3,
                  fontStyle: FontStyle.italic,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
