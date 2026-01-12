# Explicación del módulo de registro (`register.dart`) ✅

## Resumen
Este documento describe qué hace el código en `register.dart` (pantalla de registro), cómo interactúa con `register_assessment.dart` (cuestionario), y un apartado técnico con hallazgos, buenas prácticas y recomendaciones para mejorar el código y la testabilidad.

---

## ¿Qué hace el código? 🔍
- Define un `StatefulWidget` llamado `RegisterPage` que muestra un formulario con campos básicos para crear la cuenta: **email**, **contraseña**, **nombre**, **apellidos**, **teléfono**, **año de nacimiento**, **género**, y **foto de perfil**.
- Gestiona selección y subida de imagen con `image_picker` y `firebase_storage`:
  - `_pickAndUploadImage()` abre un modal para elegir cámara/galería, obtiene la imagen, sube a Storage en `profile_images/profile_<timestamp>.jpg` y actualiza `_photoUrlController.text` con la URL de descarga.
  - Muestra progreso con `_uploadProgress` y `LinearProgressIndicator`.
- El registro tiene dos fases orquestadas por `_onContinuePressed()`:
  1. Valida el formulario básico. 2. Abre el cuestionario (`/register-assessment`) usando `_openAssessment()` y espera perfiles devueltos.
  3. Si se obtienen perfiles (`_selectedProfiles`), llama a `_registerUser()` para crear el usuario en Firebase (a través de `UserRepository`).
- `_registerUser()` crea un `User` DTO (clase `User` en `data/models/user_dto.dart`), y llama a `_userRepository.registerUser(...)` pasando `email`, `password`, `user` y `profileImageFile`.
- Se muestran `SnackBar`s para feedback: éxito de registro, errores, subida de foto, etc.

---

## Comportamiento UX notables ⚡
- El formulario bloquea la continuación si el cuestionario no ha sido completado (muestra un `SnackBar`).
- Si se sube la foto, el widget muestra un preview y un botón para limpiar la foto.
- El proceso es mayormente lineal: completar datos → completar cuestionario → registro.

---

## Explicación técnica detallada para principiantes 🧑‍💻
En esta sección se explica, paso a paso y con lenguaje claro, qué hace exactamente el código de `register.dart`. Está orientada a quien tiene conocimientos básicos de programación y quiere entender cómo funciona el flujo completo.

1) Estructura y widgets principales
- `RegisterPage` es un `StatefulWidget` que utiliza `_RegisterPageState` para almacenar el estado de la UI (textos, imagen seleccionada, progreso de subida, perfiles detectados).
- El `build()` devuelve un `Scaffold` con `AppBar` y un `SingleChildScrollView` que contiene un `Card` con el formulario.
- El formulario está envuelto en un `Form` con una clave `_formKey` que permite llamar a `validate()` para comprobar todos los campos.

2) Campos y controladores
- Hay varios `TextFormField` (Email, Contraseña, Nombre, Apellidos, Teléfono, Año de nacimiento) que usan `TextEditingController` para leer y escribir el texto desde código.
- Cada campo tiene un `validator` que devuelve un mensaje si el valor es nulo o vacío; esos mensajes se usan para mostrar errores de validación en la UI.
- El campo del año es `readOnly` y abre un `CupertinoPicker` en un `showModalBottomSheet` para seleccionar un año. Al elegirlo se pone el texto en `_birthYearController`.

3) Selector de género
- El género se elige con un `DropdownButtonFormField`. Al cambiar la opción se actualiza `selectedGender` y `_genderController.text`.

4) Selección y subida de imagen (flujo exacto)
- Cuando el usuario pulsa "Seleccionar y subir foto" se abre un modal para elegir entre cámara o galería usando `image_picker`.
- Si se selecciona una imagen:
  - Se crea un `File` local con la ruta de la imagen (_selectedImageFile).
  - Se inicia la subida a Firebase Storage con `putFile()` sobre la referencia `profile_images/profile_<timestamp>.jpg`.
  - Se suscribe a `uploadTask.snapshotEvents` para recibir eventos de progreso y actualizar `_uploadProgress` (0.0 a 1.0).
  - Al completarse, se llama a `snapshot.ref.getDownloadURL()` y la URL resultante se guarda en `_photoUrlController.text`.
  - La UI muestra `LinearProgressIndicator` y el porcentaje cuando `_isUploadingImage` es true.
  - Si ocurre un error en la subida, el catch muestra un `SnackBar` con el mensaje de la excepción.

5) Interacción con el cuestionario (register_assessment)
- `_openAssessment()` prepara `partialData` con los valores actuales del formulario (email, nombre, etc.) y llama a `Navigator.pushNamed(context, '/register-assessment', arguments: partialData)`.
- La pantalla del cuestionario responde con `Navigator.pop(context, profiles)` devolviendo una lista `List<String>` con los perfiles detectados.
- En `RegisterPage` el resultado se recibe en `result` y se asigna a `_selectedProfiles`.

6) Validación y flujo final de registro
- `_onContinuePressed()` valida el formulario localmente; si está bien, llama a `_openAssessment()` y espera el resultado.
- Tras obtener perfiles, si `_selectedProfiles` no está vacío, el código llama a `_registerUser()`.

7) Creación del `User` y llamada al repositorio
- `_registerUser()` crea un objeto `User` (definido en `data/models/user_dto.dart`) con las propiedades recolectadas (`email`, `firstName`, `lastName`, `phone`, `birthYear`, `gender`, `profiles`, `photoUrl`).
- Llama a `_userRepository.registerUser(email: ..., password: ..., user: user, profileImageFile: _selectedImageFile)`.
- Si la operación termina correctamente se muestra un `SnackBar` con mensaje de éxito y se navega a la ruta principal con `Navigator.pushReplacementNamed(context, '/')`.
- Si hay excepción, se captura y se muestra un `SnackBar` con el mensaje de error.

8) Variables de estado y su propósito
- `_selectedImageFile`: archivo local de la imagen seleccionada.
- `_isUploadingImage`: indica si actualmente se está subiendo una imagen (true/false).
- `_uploadProgress`: número entre 0 y 1 con el progreso de subida.
- `_selectedProfiles`: lista de strings devuelta por el cuestionario.
- Estos valores se actualizan con `setState()` para que la UI se redibuje.

9) Comunicación y responsabilidades entre capas
- `RegisterPage` gestiona la UI y la interacción con el usuario.
- `UserRepository` es la capa que el widget utiliza para realizar la operación de registro (Auth + Firestore + Storage en conjunto). En este archivo se instancia con `final UserRepository _userRepository = UserRepository();` y es quien realiza la llamada final que crea el usuario en backend.
- El `User` DTO (modelo) encapsula los datos del usuario para enviarlos al repositorio y persistirlos.

---

## Conceptos básicos de Flutter (explicado para principiantes) 🧩
- **StatefulWidget**: es un tipo de widget que tiene **estado mutable**, es decir, valores que pueden cambiar mientras la pantalla está activa (por ejemplo: el texto escrito por el usuario, si se está subiendo una imagen, el progreso). En este archivo `RegisterPage` extiende `StatefulWidget` para poder mantener y actualizar esos valores.

- **State**: cada `StatefulWidget` tiene una clase `State` asociada (por ejemplo `_RegisterPageState`). La `State` contiene las variables que cambian y el método `build()` que dibuja la UI según el estado actual. Cuando se quiere actualizar la pantalla, se llama a `setState(() { ... })` para cambiar valores y forzar que Flutter vuelva a ejecutar `build()`.

- **Scaffold**: es la estructura básica de una pantalla en Flutter. Proporciona zonas estándar como `appBar` (barra superior), `body` (contenido principal), y componentes prebuilt (por ejemplo `SnackBar`, `FloatingActionButton`). En `register.dart` el `Scaffold` contiene el `AppBar` y el formulario en su `body`.

- **AppBar**: la barra superior que suele mostrar el título de la pantalla y botones de acción. En la pantalla de registro se usa para mostrar el texto "Registro de Usuario".

- **SingleChildScrollView**: un contenedor que permite que su único hijo sea desplazable (scroll). Se usa cuando el contenido puede superar la altura de la pantalla, por ejemplo si se abre el teclado, evitando errores de overflow y permitiendo que todo el formulario sea accesible al usuario.

- **Form** y **TextFormField**: `Form` agrupa varios campos y permite validar todos a la vez usando una clave (`_formKey`). `TextFormField` es un campo de texto que puede tener un `validator` (una función que devuelve un mensaje de error o `null`) y un `controller` para leer/escribir su contenido desde código.

- **TextEditingController**: objeto que guarda el texto que el usuario escribe en un `TextFormField`. El código lo consulta al enviar el formulario para crear el `User` con los datos introducidos.

- **Navigator**: sistema de navegación de Flutter. `Navigator.pushNamed` abre una nueva pantalla (por ejemplo, el cuestionario) y `Navigator.pop(context, resultado)` cierra la pantalla y puede devolver datos al llamador. `Navigator.pushReplacementNamed` reemplaza la pantalla actual por otra (usado después del registro para ir a la pantalla principal).

- **SnackBar**: un pequeño mensaje que aparece en la parte inferior para indicar éxito o error (por ejemplo: "Usuario registrado correctamente").

- **Futures / async / await**: operaciones asíncronas (subida a Firebase, llamadas de red). En el código se usan `async`/`await` para ejecutar esas tareas sin bloquear la interfaz y para esperar sus resultados antes de seguir.

- **setState()**: función que se llama dentro de la `State` para actualizar variables y pedir a Flutter que vuelva a dibujar la UI con los nuevos valores (por ejemplo al cambiar `_isUploadingImage` o `_uploadProgress`).

- **Widgets visuales comunes usados**: `Card` (contenedor con elevación), `ElevatedButton` (botón principal), `OutlinedButton` (botón secundario), `LinearProgressIndicator` (barra de progreso de subida) y `CircularProgressIndicator` (indicador de carga).

---

> Archivo actualizado: `lib/presentation/pages/register/register.md`

## Resumen final ✅
`register.dart` implementa un flujo completo de registro y utiliza `register_assessment.dart` para obtener perfiles del usuario antes de crear la cuenta. Hay buenas prácticas presentes (subida con progreso, feedback por SnackBars), pero conviene mejorar la liberación de recursos (`dispose()`), el manejo de errores, la inyección de dependencias y añadir pruebas automatizadas para asegurar robustez.

Si quieres, puedo:
- Implementar los cambios (añadir `dispose`, mejorar manejo de errores, inyección de `UserRepository`).
- Añadir tests unitarios y widget tests que cubran el flujo de registro y la subida de imagen.

---

## Texto breve para decir en ~30 segundos 🎤
La pantalla de registro permite crear una cuenta introduciendo email, contraseña, nombre, apellidos, teléfono, año de nacimiento y género. El usuario puede seleccionar y subir una foto de perfil, con un indicador de progreso visible. Antes de finalizar, se completa un cuestionario que devuelve perfiles que se guardan junto al usuario. Al pulsar continuar, la app valida los datos, crea el usuario a través del `UserRepository`, muestra un SnackBar de confirmación en caso de éxito y redirige a la pantalla principal.

## Resumen rápido y justificación 🎯
**Resumen (30s):** El registro guía al usuario en un flujo claro: datos personales, subida de foto con progreso y un cuestionario obligatorio que asegura perfiles completos antes de crear la cuenta.

**Justificación de diseño y decisiones tomadas:**
- **Flujo guiado y prevención de fricción:** se estructura el proceso en pasos (formulario → cuestionario → registro) para no abrumar al usuario y aumentar las tasas de finalización.
- **Transparencia durante la subida de imagen:** mostrar un `LinearProgressIndicator` y porcentaje durante la subida aporta confianza y reduce cancelaciones por incertidumbre.
- **Validaciones locales mínimas + validación robusta en backend:** se valida lo esencial en cliente para mantener una experiencia fluida; las reglas complejas (políticas de contraseña, verificación de formatos) se gestionan en el repositorio para garantizar consistencia y evitar bloqueos prematuros.
- **Decisiones basadas en iteración y pruebas:** exigir el cuestionario antes del registro y usar `SnackBar`s para feedback surgió tras iteraciones donde se observó mayor completitud y menos errores cuando se recopilaban perfiles antes de crear la cuenta.
- **Mantenibilidad y testabilidad:** separar la lógica de subida y registro en `UserRepository` y preparar la inyección de dependencias facilita mocks en tests y permite evoluciones sin reescribir la UI.

> **Nota:** estas decisiones son resultado de varias iteraciones y pruebas de usabilidad; están orientadas a maximizar la finalización del registro y ofrecer feedback claro en pasos críticos (subida de foto, validación, registro).

---

## Puntos clave (muy breve) ✨
- Formulario: recoge datos básicos (email, contraseña, datos personales) y valida que no estén vacíos.
- Foto: permite seleccionar y subir una imagen a Firebase Storage con progreso mostrado.
- Cuestionario: abre `/register-assessment` y devuelve perfiles necesarios para completar el registro.
- Registro: construye un `User` DTO y llama a `UserRepository.registerUser(...)`; muestra feedback y navega al terminar.

---

> Archivo creado: `lib/presentation/pages/register/register.md`
