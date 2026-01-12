# Perfil & Álbum de fotos — explicación

## Resumen ✅
Documento que explica qué hace `profile.dart` (pantalla de Perfil) y cómo se integra el Álbum de fotos en la app. Incluye comportamiento UX, detalles técnicos, mejoras sugeridas y un **resumen rápido con justificación** para uso en presentaciones o documentación de producto.

---

## ¿Qué hace `ProfilePage`? 🔍
- Muestra los datos del usuario autenticado (nombre, apellidos, email, año de nacimiento, género, teléfono y perfiles detectados) usando `FirebaseAuth` + Firestore.
- Permite alternar entre vista de solo lectura y edición: al pulsar editar se muestran campos (`TextFormField`) para actualizar datos.
- Gestiona la actualización de perfil con `_saveChanges(...)` que valida el formulario, construye un `User` DTO y llama a `_userRepository.updateUser(uid, updatedUser)`.
- Proporciona acciones adicionales: acceso al **Álbum de fotos**, cambio de contraseña, reinicio temporal de datos (botón de desarrollo) y cierre de sesión.
- Buenas prácticas ya implementadas: los `TextEditingController` se liberan en `dispose()` y hay validadores en los campos principales.

---

## ¿Qué hace el Álbum de fotos? 📸
- El Álbum de fotos es una funcionalidad ligada al usuario que permite subir, listar y visualizar fotos (PhotoMemory). Las fotos pueden almacenarse en Firebase Storage y sus metadatos en Firestore.
- Flujo típico:
  - Selección de imagen (cámara/galería) → subida a Storage → obtención de URL de descarga → guardado de metadatos en `photo_memories` (ej. `imagePath`, `createdAt`, `userId`, `description`).
  - Visualización: lista de fotos, previsualización, posibilidad de eliminar o compartir.
- Nota: `PhotoMemory.imagePath` puede contener **ruta local** (antes de subir) o **URL de Storage** (después de subir). Esto se debe documentar y el UI debe manejar ambos casos.

---

## Comportamientos UX notables ⚡
- UX claro y orientado a la tarea: en `ProfilePage` la vista principal es lectura y el modo edición se activa explícitamente para evitar cambios accidentales.
- Feedback de procesos: el guardado muestra spinner en el botón (`CircularProgressIndicator`) y la subida de imágenes utiliza `LinearProgressIndicator` con porcentaje para dar confianza al usuario.
- Mensajes de error y confirmación se muestran con `SnackBar`, y el reinicio de datos requiere confirmación (AlertDialog) para evitar acciones accidentales.

---

## Apartado técnico 🔧
- **Controladores:** `TextEditingController` se crean y se liberan en `dispose()` (ya implementado). Buen ejemplo.
- **Validación:** hay `validator` en `TextFormField` para nombre, apellido, teléfono y año; la validación numérica del año incluye rango (1900–2024) para evitar entradas inválidas.
- **Manejo de errores:** las excepciones se capturan en `_saveChanges` y se muestran al usuario; se recomienda mapear errores concretos desde el repositorio para mensajes más robustos.
- **Inyección de dependencias:** el `UserRepository` se instancia en la clase; se sugiere inyectarlo (constructor, Provider o GetIt) para facilitar tests y reemplazos en entornos (mock vs prod).
- **Seguridad/privacidad:** evitar imprimir información sensible (nunca registrar contraseñas). Asegurar reglas de Firestore para que cada usuario lea/escriba solo sus recursos.
- **Código temporal:** el botón "Reiniciar Actividades (Dev)" está expuesto en la UI; considerar ocultarlo detrás de un flag de entorno o removerlo en builds de producción.

---

## Problemas potenciales y mejoras 🔁
- Paginación/performace del Álbum: si hay muchas fotos, añadir paginación (limit/offset o cursors) y caching de imágenes (cached_network_image) para mejorar rendimiento y UX.
- Manejo de imágenes locales vs remotas: normalizar `PhotoMemory.imagePath` para evitar casos ambiguos en UI.
- Tests: añadir widget tests para edición de perfil y flujo de Album (selección + subida + visualización), y unit tests para `_saveChanges` usando un `UserRepository` mock.
- Registro y métricas: añadir eventos analíticos (e.g., perfil actualizado, foto subida) para medir uso real y validar decisiones de diseño.

---

## Resumen rápido y justificación 🎯
**Resumen (30s):** La pantalla de Perfil ofrece una vista limpia de los datos del usuario y un modo de edición claro; integra acciones directas (álbum de fotos, cambio de contraseña y reinicio de datos en entorno de desarrollo) y muestra feedback inmediato en operaciones críticas.

**Justificación de diseño y decisiones tomadas:**
- **Claridad y seguridad:** separar lectura y edición minimiza errores accidentales y permite al usuario revisar sus datos antes de guardar.
- **Feedback visible en procesos largos:** mostrar indicadores durante guardado o subida reduce incertidumbre y disminuye reintentos prematuros.
- **Simplicidad técnica durante iteración:** algunas operaciones (por ejemplo, filtrados o listados) se mantuvieron simples y en memoria para acelerar el desarrollo y las pruebas iniciales; estas decisiones fueron tomadas deliberadamente tras iteraciones y pruebas de usabilidad para priorizar la experiencia del usuario y la mantenibilidad temprana.
- **Preparado para evolucionar:** la arquitectura actual favorece mover optimizaciones (p. ej., paginación, consultas indexadas) cuando las métricas de uso lo requieran. Cada elección responde a observaciones durante el desarrollo y pruebas internas, no es arbitraria.

> **Nota:** estas decisiones reflejan iteraciones prácticas y criterios de usabilidad: claridad, robustez y facilidad de evolución.

---

## Texto breve para decir en ~30 segundos 🎤
Perfil muestra los datos del usuario y un modo de edición explícito; el Álbum de fotos permite subir y ver imágenes vinculadas al usuario con progreso visible. Las decisiones de diseño priorizan claridad, feedback durante procesos largos y facilidad de mantenimiento tras varias iteraciones.

---

¿Quieres que añada ejemplos concretos de pruebas de usabilidad o que enlace fragmentos de código relevantes (`profile.dart`, `ALBUM_FOTOS_README.md`) dentro de este documento? ✏️