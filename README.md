#  Serenalea

Serenalea es una aplicación móvil (Flutter) enfocada en el bienestar emocional. Permite a los usuarios registrar su estado de ánimo en un diario, realizar actividades guiadas (creativas, de observación, paseos, mindfulness...), conservar los recuerdos fotográficos de esas actividades y consultar estadísticas de su progreso a lo largo del tiempo.

##  Características principales

- **Registro y autenticación** de usuarios con Firebase Auth, incluyendo un cuestionario inicial (*assessment*) para personalizar la experiencia según el perfil del usuario.
- **Diario emocional**: espacio para escribir y revisar entradas de diario.
- **Actividades por categorías**: catálogo de actividades (creativas, de observación, paseos, mindfulness, etc.) con distintos niveles de dificultad y duración, además de una opción de "actividad aleatoria".
- **Álbum de fotos**: las fotos tomadas durante las actividades se guardan automáticamente con metadatos (actividad, categoría, fecha) y se pueden buscar y filtrar desde una galería con vista de detalle y zoom.
- **Estadísticas**: panel con el progreso y la evolución del usuario.
- **Perfil de usuario**: gestión de datos personales y cambio de contraseña.

##  Stack técnico

- **Framework**: [Flutter](https://flutter.dev/) (Dart, SDK ^3.8.1)
- **Backend**: [Firebase](https://firebase.google.com/) — `firebase_core`, `firebase_auth`, `cloud_firestore`
- **Otras dependencias relevantes**:
  - `image_picker` — selección/captura de fotos
  - `audioplayers` — reproducción de audio (p. ej. sonidos de relajación)
  - `intl` — formateo de fechas en español
- **Testing**: `flutter_test`, `mockito`, `build_runner`
- **Plataformas soportadas**: Android, iOS, Web, Linux, Windows (proyecto Flutter multiplataforma)

##  Estructura del proyecto

```
lib/
├── core/                     # Constantes, tema visual y utilidades
│   ├── constants/
│   ├── theme/
│   └── utils/
├── data/                     # Capa de datos
│   ├── models/                # DTOs: Activity, Diary, User, Photo, Category
│   ├── repositories/           # Repositorios que abstraen el acceso a datos
│   └── services/               # Servicios de Firestore
├── presentation/             # Capa de presentación
│   ├── pages/                  # Pantallas: login, registro, home, diario,
│   │                            # actividades, estadísticas, perfil, álbum de fotos
│   ├── routes/                 # Definición de rutas de la app
│   └── widgets/                # Widgets reutilizables
├── firebase_options.dart
└── main.dart
```

##  Puesta en marcha

### Requisitos previos

- [Flutter SDK](https://docs.flutter.dev/get-started/install) instalado y configurado (`flutter doctor` sin errores).
- Un proyecto de [Firebase](https://console.firebase.google.com/) con Authentication y Cloud Firestore habilitados.

### Instalación

1. Clona el repositorio y entra en la carpeta del proyecto.
2. Instala las dependencias:
   ```bash
   flutter pub get
   ```
3. Configura Firebase para el proyecto (si aún no está configurado) con la CLI de FlutterFire:
   ```bash
   flutterfire configure
   ```
   Esto generará/actualizará `lib/firebase_options.dart` con las credenciales de tu propio proyecto de Firebase.
4. Ejecuta la aplicación:
   ```bash
   flutter run
   ```

> La primera vez que se ejecuta con la base de datos vacía, `DatabaseInitializer` inicializa Firestore con datos de ejemplo (categorías y actividades).

##  Tests

El proyecto incluye tests unitarios, de widgets y de rendimiento:

```bash
flutter test
```

Se cubren, entre otros: modelos de datos (`Activity`, `Diary`, `User`), validadores y helpers, el selector de tipo de actividad, la barra de navegación inferior y las frases de gratitud.

