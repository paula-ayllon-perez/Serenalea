import 'dart:io';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../core/constants/colors.dart';
import '../../../data/models/photo_memory_dto.dart';
import '../../../data/repositories/photo_repository.dart';

class PhotoAlbumPage extends StatefulWidget {
  const PhotoAlbumPage({Key? key}) : super(key: key);

  @override
  State<PhotoAlbumPage> createState() => _PhotoAlbumPageState();
}

class _PhotoAlbumPageState extends State<PhotoAlbumPage> {
  final PhotoRepository _photoRepository = PhotoRepository();
  List<PhotoMemory> _allPhotos = [];
  List<PhotoMemory> _filteredPhotos = [];
  List<String> _categories = [];
  String? _selectedCategory;
  bool _isLoading = true;
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadPhotos();
    _loadCategories();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadPhotos() async {
    setState(() => _isLoading = true);
    try {
      final photos = await _photoRepository.getUserPhotos();
      setState(() {
        _allPhotos = photos;
        _filteredPhotos = photos;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al cargar fotos: $e')),
        );
      }
    }
  }

  Future<void> _loadCategories() async {
    final categories = await _photoRepository.getUserCategories();
    setState(() => _categories = categories);
  }

  void _filterPhotos() {
    setState(() {
      _filteredPhotos = _allPhotos.where((photo) {
        final matchesSearch = _searchController.text.isEmpty ||
            photo.activityName.toLowerCase().contains(_searchController.text.toLowerCase());
        final matchesCategory = _selectedCategory == null || photo.activityCategory == _selectedCategory;
        return matchesSearch && matchesCategory;
      }).toList();
    });
  }

  void _resetFilters() {
    setState(() {
      _selectedCategory = null;
      _searchController.clear();
      _filteredPhotos = _allPhotos;
    });
  }

  void _showPhotoDetail(PhotoMemory photo) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PhotoDetailPage(photo: photo, onDelete: () {
          _loadPhotos();
          Navigator.pop(context);
        }),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: CustomScrollView(
        slivers: [
          // AppBar moderno con efecto de degradado
          SliverAppBar(
            expandedHeight: 160,
            floating: false,
            pinned: true,
            backgroundColor: AppColors.color1,
            flexibleSpace: FlexibleSpaceBar(
              title: const Text(
                'Álbum de Fotos',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  shadows: [
                    Shadow(color: Colors.black26, blurRadius: 4),
                  ],
                ),
              ),
              background: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      AppColors.color1,
                      AppColors.color2,
                      AppColors.color3,
                    ],
                  ),
                ),
                child: Center(
                  child: Icon(
                    Icons.photo_library_rounded,
                    size: 60,
                    color: Colors.white.withOpacity(0.3),
                  ),
                ),
              ),
            ),
          ),

          // Barra de búsqueda y filtros
          SliverToBoxAdapter(
            child: Container(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  // Barra de búsqueda
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.color3.withOpacity(0.2),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: TextField(
                      controller: _searchController,
                      onChanged: (_) => _filterPhotos(),
                      decoration: InputDecoration(
                        hintText: 'Buscar por nombre de actividad...',
                        prefixIcon: Icon(Icons.search, color: AppColors.color2),
                        suffixIcon: _searchController.text.isNotEmpty
                            ? IconButton(
                                icon: Icon(Icons.clear, color: AppColors.color3),
                                onPressed: () {
                                  _searchController.clear();
                                  _filterPhotos();
                                },
                              )
                            : null,
                        border: InputBorder.none,
                        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  
                  // Filtros de categoría
                  if (_categories.isNotEmpty) ...[
                    Row(
                      children: [
                        Text(
                          'Categorías:',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: AppColors.color1,
                          ),
                        ),
                        const SizedBox(width: 8),
                        if (_selectedCategory != null)
                          TextButton.icon(
                            icon: const Icon(Icons.clear, size: 16),
                            label: const Text('Limpiar'),
                            onPressed: _resetFilters,
                            style: TextButton.styleFrom(
                              foregroundColor: AppColors.color3,
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    SizedBox(
                      height: 45,
                      child: ListView(
                        scrollDirection: Axis.horizontal,
                        children: _categories.map((category) {
                          final isSelected = _selectedCategory == category;
                          return Padding(
                            padding: const EdgeInsets.only(right: 8),
                            child: FilterChip(
                              label: Text(category),
                              selected: isSelected,
                              onSelected: (selected) {
                                setState(() {
                                  _selectedCategory = selected ? category : null;
                                  _filterPhotos();
                                });
                              },
                              backgroundColor: Colors.white,
                              selectedColor: AppColors.color4,
                              labelStyle: TextStyle(
                                color: isSelected ? Colors.white : AppColors.color2,
                                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                              ),
                              elevation: isSelected ? 4 : 2,
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),

          // Contador de fotos
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                '${_filteredPhotos.length} ${_filteredPhotos.length == 1 ? 'foto' : 'fotos'}',
                style: TextStyle(
                  fontSize: 14,
                  color: AppColors.color3,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ),
          const SliverToBoxAdapter(child: SizedBox(height: 16)),

          // Grid de fotos o mensaje vacío
          _isLoading
              ? const SliverFillRemaining(
                  child: Center(child: CircularProgressIndicator()),
                )
              : _filteredPhotos.isEmpty
                  ? SliverFillRemaining(
                      child: Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.photo_library_outlined,
                              size: 80,
                              color: AppColors.color3.withOpacity(0.5),
                            ),
                            const SizedBox(height: 16),
                            Text(
                              _searchController.text.isNotEmpty || _selectedCategory != null
                                  ? 'No se encontraron fotos'
                                  : 'Aún no tienes fotos',
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: AppColors.color2,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              _searchController.text.isNotEmpty || _selectedCategory != null
                                  ? 'Intenta con otros filtros'
                                  : 'Completa actividades y captura momentos',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 14,
                                color: AppColors.color3,
                              ),
                            ),
                          ],
                        ),
                      ),
                    )
                  : SliverPadding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      sliver: SliverGrid(
                        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          crossAxisSpacing: 12,
                          mainAxisSpacing: 12,
                          childAspectRatio: 0.75,
                        ),
                        delegate: SliverChildBuilderDelegate(
                          (context, index) {
                            final photo = _filteredPhotos[index];
                            return _PhotoCard(
                              photo: photo,
                              onTap: () => _showPhotoDetail(photo),
                            );
                          },
                          childCount: _filteredPhotos.length,
                        ),
                      ),
                    ),
          const SliverToBoxAdapter(child: SizedBox(height: 20)),
        ],
      ),
    );
  }
}

// Helpers para iconos de categoría y fallback de imagen
IconData _iconForCategory(String category) {
  switch (category.toLowerCase()) {
    case 'meditación':
    case 'meditacion':
      return Icons.self_improvement_rounded;
    case 'texto':
    case 'escritura':
      return Icons.edit_note_rounded;
    case 'paseo':
    case 'caminar':
      return Icons.directions_walk_rounded;
    case 'arte':
    case 'dibujar':
      return Icons.brush_rounded;
    case 'lectura':
    case 'leer':
      return Icons.book_rounded;
    case 'simple':
      return Icons.check_circle_rounded;
    default:
      return Icons.photo_library_rounded;
  }
}

Color _colorForCategory(String category) {
  switch (category.toLowerCase()) {
    case 'meditación':
    case 'meditacion':
      return const Color(0xFF7B68EE); // Morado
    case 'texto':
    case 'escritura':
      return const Color(0xFF00BCD4); // Cian
    case 'paseo':
    case 'caminar':
      return const Color(0xFF4CAF50); // Verde
    case 'arte':
    case 'dibujar':
      return const Color(0xFFFF7043); // Naranja
    case 'lectura':
    case 'leer':
      return const Color(0xFF795548); // Marrón
    case 'simple':
      return const Color(0xFF4CAF50);
    default:
      return AppColors.color4;
  }
}

Widget _buildCategoryIcon(String category, double size) {
  final iconData = _iconForCategory(category);
  final backgroundColor = _colorForCategory(category);
  return Container(
    decoration: BoxDecoration(
      gradient: LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          backgroundColor,
          backgroundColor.withOpacity(0.7),
        ],
      ),
    ),
    child: Center(
      child: Icon(
        iconData,
        size: size,
        color: Colors.white,
      ),
    ),
  );
}

class _PhotoCard extends StatelessWidget {
  final PhotoMemory photo;
  final VoidCallback onTap;

  const _PhotoCard({
    required this.photo,
    required this.onTap,
  });

  Widget _buildImageOrIcon() {
    final path = photo.imagePath.trim();

    // Si es marcador explícito "icon:xxx", mapear a icono conocido o a la categoría
    if (path.startsWith('icon:')) {
      final iconType = path.substring(5);
      switch (iconType) {
        case 'text':
          return _buildCategoryIcon('texto', 80);
        case 'meditation':
          return _buildCategoryIcon('meditacion', 80);
        case 'simple':
          return _buildCategoryIcon('simple', 80);
        default:
          return _buildCategoryIcon(photo.activityCategory, 80);
      }
    }

    // Si hay ruta no vacía, intentar mostrar imagen (network o local)
    if (path.isNotEmpty) {
      if (path.startsWith('http')) {
        return Image.network(
          path,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) => _buildCategoryIcon(photo.activityCategory, 80),
        );
      } else {
        final file = File(path);
        if (file.existsSync()) {
          return Image.file(
            file,
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) => _buildCategoryIcon(photo.activityCategory, 80),
          );
        } else {
          return _buildCategoryIcon(photo.activityCategory, 80);
        }
      }
    }

    // Si no hay imagen, mostrar icono de la categoría
    return _buildCategoryIcon(photo.activityCategory, 80);
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Hero(
        tag: photo.id,
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: AppColors.color3.withOpacity(0.25),
                blurRadius: 8,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: Stack(
              fit: StackFit.expand,
              children: [
                // Imagen o icono
                _buildImageOrIcon(),
                
                // Gradiente oscuro en la parte inferior
                Positioned(
                  bottom: 0,
                  left: 0,
                  right: 0,
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.bottomCenter,
                        end: Alignment.topCenter,
                        colors: [
                          Colors.black.withOpacity(0.8),
                          Colors.transparent,
                        ],
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          photo.activityName,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          DateFormat('dd MMM yyyy', 'es').format(photo.date),
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.8),
                            fontSize: 11,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                
                // Badge de categoría
                Positioned(
                  top: 8,
                  right: 8,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppColors.color1.withOpacity(0.9),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      photo.activityCategory,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class PhotoDetailPage extends StatelessWidget {
  final PhotoMemory photo;
  final VoidCallback onDelete;

  const PhotoDetailPage({
    Key? key,
    required this.photo,
    required this.onDelete,
  }) : super(key: key);

  Widget _buildImageOrIcon() {
    final path = photo.imagePath.trim();

    if (path.startsWith('icon:')) {
      final iconType = path.substring(5);
      switch (iconType) {
        case 'text':
          return _buildCategoryIcon('texto', 150);
        case 'meditation':
          return _buildCategoryIcon('meditacion', 150);
        case 'simple':
          return _buildCategoryIcon('simple', 150);
        default:
          return _buildCategoryIcon(photo.activityCategory, 150);
      }
    }

    if (path.isNotEmpty) {
      if (path.startsWith('http')) {
        return Image.network(
          path,
          fit: BoxFit.contain,
          errorBuilder: (context, error, stackTrace) => _buildCategoryIcon(photo.activityCategory, 150),
        );
      } else {
        final file = File(path);
        if (file.existsSync()) {
          return Image.file(
            file,
            fit: BoxFit.contain,
            errorBuilder: (context, error, stackTrace) => _buildCategoryIcon(photo.activityCategory, 150),
          );
        } else {
          return _buildCategoryIcon(photo.activityCategory, 150);
        }
      }
    }

    return _buildCategoryIcon(photo.activityCategory, 150);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // Imagen en pantalla completa
          Center(
            child: Hero(
              tag: photo.id,
              child: InteractiveViewer(
                child: _buildImageOrIcon(),
              ),
            ),
          ),
          
          // Barra superior
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: Container(
              padding: EdgeInsets.only(
                top: MediaQuery.of(context).padding.top + 8,
                bottom: 16,
                left: 8,
                right: 8,
              ),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.black.withOpacity(0.7),
                    Colors.transparent,
                  ],
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(
                    icon: const Icon(Icons.close, color: Colors.white, size: 28),
                    onPressed: () => Navigator.pop(context),
                  ),
                  IconButton(
                    icon: const Icon(Icons.delete, color: Colors.white, size: 28),
                    onPressed: () async {
                      final confirm = await showDialog<bool>(
                        context: context,
                        builder: (context) => AlertDialog(
                          title: const Text('Eliminar foto'),
                          content: const Text('¿Estás seguro de que quieres eliminar esta foto?'),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(context, false),
                              child: const Text('Cancelar'),
                            ),
                            TextButton(
                              onPressed: () => Navigator.pop(context, true),
                              child: const Text('Eliminar', style: TextStyle(color: Colors.red)),
                            ),
                          ],
                        ),
                      );
                      
                      if (confirm == true) {
                        await PhotoRepository().deletePhoto(photo.id);
                        if (context.mounted) {
                          onDelete();
                        }
                      }
                    },
                  ),
                ],
              ),
            ),
          ),
          
          // Información de la foto
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.bottomCenter,
                  end: Alignment.topCenter,
                  colors: [
                    Colors.black.withOpacity(0.8),
                    Colors.transparent,
                  ],
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: AppColors.color1,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      photo.activityCategory,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    photo.activityName,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Icon(Icons.calendar_today, color: Colors.white.withOpacity(0.8), size: 16),
                      const SizedBox(width: 8),
                      Text(
                        DateFormat('EEEE, dd MMMM yyyy - HH:mm', 'es').format(photo.date),
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.8),
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                  if (photo.description != null && photo.description!.isNotEmpty) ...[
                    const SizedBox(height: 12),
                    Text(
                      photo.description!,
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.9),
                        fontSize: 15,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
