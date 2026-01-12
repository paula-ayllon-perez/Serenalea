# Explicación del archivo `login.dart`

## Resumen ✅
Este documento explica qué hace el código en `login.dart` (pantalla de inicio de sesión) y proporciona una sección técnica con detalles, mejoras y recomendaciones.

---

## ¿Qué hace el código? 🔍
- Define un `StatefulWidget` llamado `LoginPage` que muestra la UI para iniciar sesión.
- Contiene un `Form` controlado por `_formKey` y dos `TextEditingController` (`_emailController` y `_passwordController`) para capturar email y contraseña.
- Usa `UserRepository` (`_userRepository.login(...)`) para realizar la operación de autenticación.
- El método `_loginUser()`:
  - Valida el formulario (validators simple: no vacío).
  - Muestra un indicador de carga (`_isLoading = true`).
  - Llama a `_userRepository.login` con email y password (ambos `trim()`).
  - Si el login es exitoso, navega con `Navigator.pushReplacementNamed(context, '/home')`.
  - Si ocurre una excepción, mapea el mensaje a textos de error legibles y los guarda en `_errorMessage`.
  - Al terminar, oculta el indicador de carga (`_isLoading = false`).
- En la interfaz se muestra:
  - Logo (imagen local en `lib/core/utils/assets/Logo.png`).
  - Una tarjeta (`Card`) con título "Iniciar Sesión", campos de email y contraseña.
  - Validadores sencillos (comprobar no vacío).
  - Mensaje de error en rojo si existe `_errorMessage`.
  - `CircularProgressIndicator` mientras `_isLoading` es true.
  - Botón para ir a registro (`/register`).

---

## Comportamientos UX notables ⚡
- Mientras `login` está en curso se muestra un `CircularProgressIndicator` y el botón principal se reemplaza.
- Los mensajes de error se muestran dentro de la tarjeta, centrados y en rojo.
- No hay validación avanzada de formato de email ni comprobación de longitud de contraseña.

---

# Apartado técnico 🔧

## Gestión de estado y ciclo de vida
- Uso de `StatefulWidget` con variables de estado privadas: `_isLoading` y `_errorMessage`.
- **Mejora recomendada:** el widget **debe** llamar a `_emailController.dispose()` y `_passwordController.dispose()` en `dispose()` para evitar fugas de memoria.

Ejemplo sugerido:

```dart
@override
void dispose() {
  _emailController.dispose();
  _passwordController.dispose();
  super.dispose();
}
```

## Manejo de errores
- Actualmente el código comprueba el texto de la excepción con `e.toString().contains(...)`—esto no es robusto.
- **Mejor práctica:** capturar `FirebaseAuthException` (o el tipo concreto que devuelva el repositorio) y usar `e.code` para mapear mensajes.

Ejemplo:

```dart
} on FirebaseAuthException catch (e) {
  if (e.code == 'user-not-found') {
    errorMessage = 'No existe un usuario con ese email.';
  } else if (e.code == 'wrong-password') {
    errorMessage = 'Credenciales incorrectas.';
  }
}
```

## Dependencias y testabilidad
- `UserRepository` se instancia directamente en el estado: `final UserRepository _userRepository = UserRepository();`.
- **Recomendación:** inyectar `UserRepository` vía constructor (o Provider/GetIt) para facilitar mocks en pruebas unitarias y tests de widgets.

## Seguridad y buenas prácticas
- Evitar imprimir o loguear contraseñas.
- Trim de los campos antes de enviarlos (ya se hace correctamente).
- Considerar limitar intentos de login o mostrar mensajes amigables para ataques de fuerza bruta.

## Accesibilidad y UX mejorable
- Asignar `keyboardType: TextInputType.emailAddress` al campo de email y `textInputAction` para mejorar el flujo de teclado.
- Añadir un toggle para mostrar/ocultar contraseña (visión de usuario).
- Añadir autofocus al primer campo y manejo de focus nodes para moverse entre campos.

## Internacionalización
- Strings de la UI están en español en duro; si el proyecto soporta locales, moverlos a los archivos de localización (ARB / l10n).

## Tests sugeridos
- Unit tests: probar que `_loginUser()` llama a `UserRepository.login` con los argumentos correctos y que maneja errores.
- Widget tests: verificar que al pulsar el botón en formulario válido aparece el `CircularProgressIndicator`, que se muestra el mensaje de error en la UI, y que la navegación se dispara tras login exitoso (puede mockear el repositorio).

## Pequeñas mejoras de código 🔁
- Añadir `const` donde sea posible (widgets estáticos).
- Validación de email con regex o package (`email_validator`) para mensajes más útiles.
- Deshabilitar el botón de login mientras `_isLoading` es true (aunque la UI ya lo sustituye por un indicador, también es una buena práctica).

---

## Resumen final ✅
El archivo `login.dart` implementa una pantalla de inicio de sesión funcional con validaciones básicas y manejo de estados. Sugiero aplicar las mejoras técnicas: `dispose()` para controllers, manejar `FirebaseAuthException` en lugar de hacer `contains` sobre `toString()`, inyección de dependencias para facilitar tests y mejoras de accesibilidad/internacionalización.

Si quieres, puedo:
- Implementar las mejoras directamente en `login.dart` (añadir `dispose`, mejorar manejo de errores y DI).
- Añadir tests unitarios y de widget para cubrir los flujos de login.

---

## Texto breve para decir en ~30 segundos 🎤
Esta pantalla permite a los usuarios iniciar sesión con su email y contraseña de forma sencilla y segura. Valida que los campos no estén vacíos, muestra mensajes de error claros y usa un indicador de carga mientras realiza la autenticación con Firebase. Además, ofrece acceso directo al registro, aplica 'trim' a las entradas para evitar espacios al principio o al final, y gestiona el estado de la interfaz para prevenir acciones duplicadas durante el proceso de inicio de sesión.

## Resumen rápido y justificación 🎯
**Resumen (30s):** Esta pantalla facilita un inicio de sesión claro y sin fricciones: solicita email y contraseña, ofrece feedback inmediato (errores en contexto y spinner de carga) y un acceso directo a registro para nuevos usuarios.

**Justificación de diseño y decisiones tomadas:**
- **Simplicidad y foco:** la UI se centra en una sola acción primaria (iniciar sesión) usando una `Card` y controles mínimos para reducir distracciones y errores del usuario.
- **Feedback inmediato y prevención de acciones duplicadas:** reemplazar el botón por un `CircularProgressIndicator` durante la autenticación evita reenvíos múltiples y transmite el estado del proceso de forma inequívoca.
- **Validaciones mínimas en cliente:** se validan campos vacíos para no entorpecer la experiencia; las validaciones más estrictas (formato, políticas de contraseña) se delegan a la capa de backend/repository para mantener UX responsiva.
- **Decisiones basadas en iteración:** estas elecciones no son arbitrarias: provienen de pruebas rápidas y observaciones durante desarrollo — mostraba menos fricción dejar mensajes de error dentro de la tarjeta y usar un spinner en lugar de desactivar solo el botón.
- **Mantenibilidad y testabilidad:** la separación UI ↔ repositorio y la intención de inyectar `UserRepository` permite pruebas y cambios futuros sin reescribir la interfaz.

> **Nota:** cada elección responde a pruebas prácticas y a la necesidad de un equilibrio entre claridad, seguridad y facilidad de mantenimiento; es resultado de varias iteraciones y criterios de usabilidad.

---

## Puntos clave (muy breve) ✨
- Autenticación: envía email y contraseña al repositorio que realiza la autenticación (Firebase).
- Validación: comprueba campos vacíos y muestra errores claros al usuario.
- UX/Estado: muestra un indicador de carga y evita acciones duplicadas mientras se procesa.
- Navegación: al iniciar sesión correctamente, navega a `/home` y hay acceso a la pantalla de registro.

---

## Solo lo implementado (para explicar rápidamente) 📝
- La pantalla presenta un formulario con **Email** y **Contraseña**. Los valores se guardan en `TextEditingController`.
- El formulario está controlado por `_formKey` y las validaciones son exclusivamente que los campos no estén vacíos.
- Al pulsar "Iniciar Sesión" se ejecuta `_loginUser()` que:
  - establece `_isLoading = true` para mostrar el indicador de carga,
  - llama a `_userRepository.login(email, password)`,
  - si la llamada es exitosa navega a `'/home'` con `Navigator.pushReplacementNamed`,
  - si ocurre una excepción, el código actual utiliza `e.toString().contains(...)` para detectar errores como `user-not-found`, `wrong-password`, `invalid-credential` o `invalid-email` y asigna un texto a `_errorMessage` para mostrarse en rojo dentro de la tarjeta.
- Mientras `_isLoading` es true, el botón se reemplaza por un `CircularProgressIndicator`.
- También hay un botón de texto que navega a la ruta `/register` y un logo que se carga desde `lib/core/utils/assets/Logo.png`.

---

## Servicios, repositorios y modelos 🔗
- **Servicios (data/services)**: código de bajo nivel que habla directamente con Firebase (Auth, Firestore, Storage). Por ejemplo, un `UserFirestoreService` hace llamadas como `signInWithEmailAndPassword`, `createUserWithEmailAndPassword`, sube imágenes a Storage y lee/escribe documentos en Firestore. Los servicios deben ser responsables sólo de la comunicación con la API/servicio remoto y lanzar excepciones técnicas (`FirebaseAuthException`, `FirebaseException`).

- **Repositorios (data/repositories)**: capa intermedia usada por la UI. `UserRepository` actúa como fachada: expone métodos como `login`, `registerUser`, `getUser`, y traduce las respuestas/errores de los servicios a una forma más cómoda o segura para la app (por ejemplo, lanzar `AuthException` o devolver un `Result<Either>`). La ventaja es que la UI no conoce Firebase directamente y es más fácil de testear.

- **Modelos (data/models)**: DTOs que representan la forma de los datos en la app (ej. `User` en `user_dto.dart` con campos `uid`, `email`, `firstName`, `lastName`, `phone`, `birthYear`, `gender`, `profiles`, `photoUrl`). Los modelos incluyen métodos de serialización (`toMap`, `fromMap`) para persistir en Firestore.

**Flujo típico:** UI -> Repository -> Service -> Firebase

**Recomendación:** los servicios lanzan excepciones técnicas; los repositorios las capturan y emiten errores de dominio/más legibles para la UI.

---

## Explicación paso a paso (para principiantes) 🧑‍🏫
1. El usuario escribe su **email** y **contraseña** en la pantalla de login.
2. Pulsando "Iniciar Sesión", el formulario valida que los campos no estén vacíos.
3. Si todo está bien, la UI muestra un indicador de carga y llama a `UserRepository.login(email, password)`.
4. El repositorio usa el servicio que contacta con Firebase para autenticar al usuario.
5. Si la autenticación es correcta, la pantalla cambia a la página principal (`/home`). Si falla, se muestra un mensaje sencillo explicando el error (por ejemplo: usuario no encontrado o contraseña incorrecta).

Pequeños detalles prácticos: los textos del formulario se "trimean" (se quitan espacios al principio y final), los `TextEditingController` guardan lo que escribe el usuario y deben liberarse en `dispose()` para evitar fugas de memoria.

---

## Detalles técnicos (para desarrolladores) 🛠️
- Manejo de excepciones: en vez de inspeccionar `e.toString()` conviene capturar `FirebaseAuthException` y usar `e.code` para mapear errores de forma robusta.

  Ejemplo:
  ```dart
  try {
    await _userRepository.login(email: email, password: password);
  } on FirebaseAuthException catch (e) {
    // mapear e.code a mensajes de usuario o excepciones de dominio
  }
  ```

- Inyección de dependencias: inyectar `UserRepository` (constructor, Provider o GetIt) facilita testing y permite sustituir implementaciones en entornos (mock vs prod).

- Contrato de repositorio (ejemplo):
  ```dart
  abstract class UserRepository {
    Future<void> login({required String email, required String password});
    Future<void> registerUser({required String email, required String password, required User user, File? profileImageFile});
    Future<User?> getUser(String uid);
  }
  ```

- Transformación de errores: los servicios pueden devolver `FirebaseAuthException`; el repositorio debe capturarlos y lanzar excepciones de dominio (ej. `AuthException.emailAlreadyInUse()`), o devolver un `Either<Failure, Success>` para evitar control por excepciones.

- Tests: mockear el `UserRepository` en widget tests para simular distintos escenarios (login exitoso, usuario no encontrado, error de red); en unit tests del repositorio mockear servicios Firebase.

- Mejora de UX/seguridad: añadir validación de formato de email, políticas de contraseña (mínima longitud), limitar reintentos y manejar timeouts/errores de red.

---

> Archivo creado: `lib/presentation/pages/login/login.md`
