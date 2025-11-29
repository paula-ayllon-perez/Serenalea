# 📸 Álbum de Fotos - Documentación

## Descripción General

El **Álbum de Fotos** es una funcionalidad innovadora que permite a los usuarios guardar y visualizar todas las fotos capturadas durante las actividades de la aplicación SerenaLea. Las fotos se organizan automáticamente por fecha y pueden filtrarse por categoría de actividad o buscarse por nombre.

## 🎨 Características Principales

### 1. **Diseño Innovador y Moderno**
- **SliverAppBar con degradado**: AppBar expandible con efecto visual atractivo
- **Grid responsivo**: Vista en cuadrícula de 2 columnas con aspecto ratio optimizado
- **Cards con Hero animations**: Transiciones fluidas al ver detalles de fotos
- **Gradientes y sombras**: Diseño con profundidad visual usando colores de la paleta de la app
- **Vista detallada inmersiva**: Pantalla completa con fondo negro e InteractiveViewer para zoom

### 2. **Búsqueda y Filtrado**
- **Barra de búsqueda**: Búsqueda en tiempo real por nombre de actividad
- **Filtros por categoría**: Chips interactivos para filtrar por tipo de actividad
  - Creativa
  - Observación
  - Walk
  - Mindfulness (futuro)
- **Contador dinámico**: Muestra el número de fotos filtradas

### 3. **Guardado Automático**
- Las fotos se guardan automáticamente cuando se toman o seleccionan en:
  - ✅ Actividad Creativa
  - ✅ Actividad de Observación
  - ✅ Actividad de Paseo
- **Notificación visual**: SnackBar de confirmación al guardar
- **Metadata incluida**: 
  - Nombre de la actividad
  - Categoría
  - Fecha y hora exacta
  - Descripción del reto/desafío

### 4. **Vista de Detalles**
- **Imagen en pantalla completa**: Fondo negro para mejor visualización
- **InteractiveViewer**: Zoom y pan para explorar la imagen
- **Información completa**:
  - Nombre de la actividad
  - Categoría (badge)
  - Fecha y hora formateada en español
  - Descripción del reto completado
- **Opción de eliminación**: Con confirmación de seguridad

### 5. **Organización por Fecha**
- Las fotos más recientes aparecen primero
- Formato de fecha legible en español: "dd MMM yyyy"
- Fecha completa en vista detallada: "EEEE, dd MMMM yyyy - HH:mm"

## 🏗️ Arquitectura

### Archivos Creados

```
lib/
├── data/
│   ├── models/
│   │   └── photo_memory_dto.dart      # Modelo de datos para fotos
│   └── services/
│       └── photo_firestore.dart       # Servicio de gestión de fotos
└── presentation/
    └── pages/
        └── profile/
            └── photo_album.dart        # UI del álbum (actualizado)
```

### Modificaciones en Actividades

Se actualizaron las siguientes actividades para integrar el guardado automático:
- `creative_actovity.dart`
- `observing_activity.dart`
- `walk_activity.dart`

## 📦 Modelo de Datos

### PhotoMemory
```dart
class PhotoMemory {
  final String id;
  final String userId;
  final String activityName;
  final String activityCategory;
  final String imagePath;
  final DateTime date;
  final String? description;
}
```

## 🔥 Firebase Integration

### Colección: `photo_memories`
Estructura de documentos:
```json
{
  "userId": "string",
  "activityName": "string",
  "activityCategory": "string",
  "imagePath": "string (ruta local)",
  "date": "Timestamp",
  "description": "string (opcional)"
}
```

### Índices Recomendados
Para optimizar las consultas:
- Índice compuesto: `userId` (Ascending) + `date` (Descending)
- Índice compuesto: `userId` (Ascending) + `activityCategory` (Ascending) + `date` (Descending)

## 🎯 Flujo de Usuario

1. **Completar actividad**: Usuario toma/selecciona foto en una actividad
2. **Guardado automático**: La foto se guarda con metadata en Firestore
3. **Confirmación**: SnackBar verde confirma el guardado
4. **Acceso al álbum**: Desde perfil → "Álbum de fotos"
5. **Exploración**: Buscar, filtrar y ver fotos
6. **Vista detallada**: Tap en foto para vista completa con zoom
7. **Gestión**: Opción de eliminar fotos individuales

## 🎨 Paleta de Colores Usada

```dart
AppColors.color1      // #436A92 - Azul principal
AppColors.color2      // #5B82AB - Azul medio
AppColors.color3      // #7499C4 - Azul claro
AppColors.color4      // #8CB1DC - Azul muy claro
AppColors.softBlue    // #E3F0FF - Azul suave para fondos
AppColors.background  // #DEE8F5 - Fondo general
```

## 📱 Responsive Design

- Grid adapta el número de columnas según el ancho de pantalla
- Textos y botones con tamaños proporcionales
- SafeArea implementado en vistas de detalle
- Scrolling optimizado con CustomScrollView y Slivers

## 🔒 Seguridad

- **Autenticación requerida**: Solo usuarios autenticados pueden guardar/ver fotos
- **Fotos privadas**: Cada usuario solo ve sus propias fotos
- **Confirmación de eliminación**: Dialog de confirmación antes de borrar

## 🚀 Mejoras Futuras (Opcionales)

1. **Firebase Storage**: Subir imágenes a la nube en lugar de solo rutas locales
2. **Compartir fotos**: Funcionalidad para compartir en redes sociales
3. **Edición básica**: Filtros, recorte, ajustes de brillo/contraste
4. **Albums temáticos**: Agrupar fotos en álbumes personalizados
5. **Estadísticas**: Mostrar cantidad de fotos por categoría, racha de días, etc.
6. **Slideshow**: Vista automática de fotos
7. **Exportar**: Descargar todas las fotos de un período

## 🐛 Manejo de Errores

- Try-catch en todas las operaciones de Firestore
- ErrorBuilder en Image.file para imágenes corruptas
- Validación de usuario autenticado
- Mensajes informativos para estados vacíos

## 📝 Notas de Implementación

- **Fechas en español**: Se inicializa `intl` con locale 'es' en `main.dart`
- **Hero animations**: Mismo tag (photo.id) en card y vista detallada
- **Performance**: Grid lazy-loading con SliverGrid
- **UX**: Feedback visual inmediato en todas las acciones
