# Actividades Aleatorias — explicación de archivos

## Resumen
Este documento describe qué hace el archivo `random_activites.dart`, cuáles son sus comportamientos implementados, 3–4 puntos clave muy breves y un texto de ~30 segundos listo para decir en voz alta.

---

## ¿Qué hace `random_activites.dart`? 🔍
- Es un `StatefulWidget` que muestra una actividad aleatoria al usuario y permite completarla o saltarla.
- Carga todas las actividades desde `ActivityRepository.getAllActivities()` y elige una con `Random.nextInt`.
- Mantiene estado local: actividad actual (`_currentActivity`), indicador de carga (`_isLoading`) y contador de completadas (`_completedCount`).
- Al completar una actividad aumenta `_completedCount`, muestra un `SnackBar` de éxito y, tras 1.5s, carga otra actividad automáticamente.
- Al saltar una actividad se carga otra inmediatamente; si no hay actividades muestra un mensaje de vacío y un botón para reintentar.

**Comportamientos clave implementados:**
- Renderizado de la actividad con `RandomActivityWidget` (se pasa `ValueKey(_currentActivity!.id)` para forzar reconstrucción cuando cambia la actividad).
- Manejo de errores básico con `try/catch` en `_loadRandomActivity` (si falla se oculta el loader, no se lanza excepción a UI más allá del estado).
- Indicadores visuales: `CircularProgressIndicator` mientras carga y UI de estado cuando no hay actividades.

**Detalles técnicos:**
- Selección aleatoria uniforme entre las actividades cargadas (sin ponderación ni filtrado por perfil en este flujo).
- La llamada `getAllActivities()` descarga la lista completa cada vez (coste O(A) por carga), no hay caching ni páginación implementada.
- Uso de `mounted` antes de llamar a `setState` en callbacks asíncronos y `Future.delayed` para temporizar la recarga.

---

## Puntos clave (muy breve) ✨
- **Selección Aleatoria Uniforme:** Elige una actividad al azar de la lista completa cargada.
- **Recarga Automática:** Al completar, incrementa contador, muestra `SnackBar` y recarga tras 1.5s.
- **Resiliencia Visual:** Muestra loader, mensajes de vacío y botón "Reintentar" cuando no hay datos o falla la carga.


---

## Texto de ~30 segundos para decir en voz alta 🎤
La pantalla de Actividades Aleatorias carga todas las actividades y selecciona una al azar; al completarla se muestra un `SnackBar` de éxito, aumenta el contador y se carga otra automáticamente tras 1.5 segundos. Si no hay actividades o la carga falla, se muestra un estado de vacío con opción para reintentar.

## Resumen rápido y justificación 🎯
**Resumen (30s):** Presenta una actividad a la vez, anima al usuario a completarla mediante refuerzo positivo (contador + SnackBar) y permite saltar actividad para mantener la fluidez; la selección aleatoria se hace en cliente para facilitar itear y testear.

**Justificación de diseño y decisiones tomadas:**
- **Enfoque en la acción:** mostrar solo una actividad reduce la fricción cognitiva y facilita que el usuario decida realizarla ahora.
- **Refuerzo positivo y continuidad:** el contador de completadas y los SnackBars funcionan como micro-recompensas que aumentan la motivación y el engagement.
- **Simplicidad para iterar:** la elección aleatoria en cliente permite tests rápidos y prototipado; está documentada y preparada para optimizar (p. ej., ponderación, filtros por perfil, prefetch) cuando las métricas lo indiquen.
- **Feedback y accesibilidad:** temporizar la recarga (1.5s) y mostrar mensajes claros evita saltos bruscos de UI y mejora la experiencia en distintos dispositivos.

> **Nota:** estas decisiones se fundamentan en iteraciones y pruebas internas para priorizar la experiencia del usuario y la facilidad de mantenimiento; se revisarán según métricas de uso.

---

> Archivo creado: `lib/presentation/pages/activities/random.md`
