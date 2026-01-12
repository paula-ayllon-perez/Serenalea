# Home & Diary — explicación de archivos

## Resumen
Este documento describe qué hace **cada archivo** relacionado con la funcionalidad del diario en la app, presenta 3–4 puntos clave muy breves y un texto de ~30 segundos listo para decir en voz alta.

---

## ¿Qué hace cada archivo? 🔍

### `diary_page.dart` (UI / Pantalla)
- Es un `StatefulWidget` que construye la **pantalla del diario** que ve el usuario.
- Gestiona estado local: fecha seleccionada, entrada actual (`_currentEntry`), lista de entradas (`_allEntries`), y flags de carga/guardado (`_isLoading`, `_isSaving`).
- Funcionalidades implementadas:
  - Cargar la entrada del día seleccionado (`_loadEntryForDate`) llamando al `DiaryRepository`.
  - Cargar todas las entradas del usuario (`_loadAllEntries`) para mostrarlas cuando el usuario quiera ver el historial.
  - Guardar o actualizar una entrada (`_saveEntry`) construyendo un `DiaryEntryDto` y delegando en el repositorio.
  - Seleccionar fecha (`_selectDate`) con un `DatePicker` y ver entradas anteriores en un `showModalBottomSheet` con `DraggableScrollableSheet`.

**Detalles relevantes (consulta por fecha y rendimiento):**
- `getEntryByDate` (en `DiaryFirestore`) obtiene todas las entradas del usuario y filtra en memoria por el intervalo del día (normaliza `startOfDay` y `endOfDay`), comparando las fechas de las entradas para devolver la que coincide. Esto implica una lectura de todos los documentos del usuario y un filtrado local (complejidad O(n) respecto al número de entradas consultadas).
- La conversión entre `Timestamp` y `DateTime` se realiza al deserializar (`fromFirestore`), por lo que la comparación se hace con `DateTime` en memoria.
- `getUserEntries` también obtiene documentos y ordena en memoria antes de devolver la lista. Estos comportamientos son importantes porque afectan al rendimiento si un usuario tiene muchas entradas (las consultas no usan índices compuestos ni rangos en la consulta de Firestore en este código).
- Las operaciones lanzan `Exception` con mensajes legibles que la UI muestra en `SnackBar` en caso de error.

- UI:
  - Usa `Scaffold`, `AppBar`, `SingleChildScrollView` y varios `Card`/`Container` para mostrar estados (fecha futura, entrada existente, campo editable para hoy).
  - Provee feedback con `SnackBar` para errores y confirmaciones.


### `data/models/diary_entry_dto.dart` (Modelo / DTO)
- Define la clase `DiaryEntryDto` con campos: `id`, `userId`, `content`, `date`, `createdAt`, `updatedAt`.
- Incluye métodos de serialización:
  - `fromFirestore(DocumentSnapshot doc)` para construir el DTO desde un documento Firestore (convierte `Timestamp` a `DateTime`).
  - `toFirestore()` para convertir el objeto a un `Map<String, dynamic>` listo para subir a Firestore (convierte `DateTime` a `Timestamp`).
- Provee `copyWith()` para clonar y modificar inmutablemente una entrada.


### `data/repositories/diary_repository.dart` (Repositorio)
- Capa intermedia que expone métodos usados por la UI: `saveDiaryEntry`, `getEntryByDate`, `getUserEntries`, `getEntriesByDateRange`, `deleteDiaryEntry`.
- Internamente delega al servicio `DiaryFirestore` (no contiene lógica de Firestore, solo delegación).
- Se usa para desacoplar la UI de los detalles de acceso a la base de datos y facilitar testing y cambios futuros.


### `data/services/diary_firestore.dart` (Servicio / Data Layer)
- Implementa la lógica concreta de acceso a Firestore:
  - `saveDiaryEntry` crea o actualiza documentos en la colección `diary_entries`.
  - `getEntryByDate` busca entradas del usuario y filtra por día (normaliza a inicio/fin de día y busca en memoria los resultados).
  - `getUserEntries` obtiene todas las entradas del usuario y las ordena por fecha (más reciente primero).
  - `getEntriesByDateRange` filtra por rango de fechas en memoria y devuelve ordenadas.
  - `deleteDiaryEntry` elimina un documento por id.
- Lanza `Exception` con mensajes legibles si falla alguna operación.

---

### `home.dart` (UI / Pantalla - Home)
- Es un `StatefulWidget` que construye la pantalla de inicio (home) con una frase inspiradora aleatoria y una lista de actividades recomendadas.
- Gestiona estado: lista de recomendaciones (`_recommendedActivities`), mapa de categorías (`_categoriesMap`), bandera `_loadingRecommendations` y `gratitudeIndex`.
- Funcionalidades implementadas:
  - Carga categorías y actividades desde `CategoryRepository` y `ActivityRepository` y filtra recomendaciones basadas en los perfiles del usuario o la etiqueta `'todos'`.
  - Lee el documento del usuario en Firestore para obtener `profiles` cuando hay un usuario autenticado.
  - Muestra frases de gratitud aleatorias en la parte superior y permite regenerarlas con `_setRandomGratitude()`.
  - Abre la actividad seleccionada con `_openActivity()` navegando a `GenericActivityPage`.
  - Incluye utilidades como `_getIconData()` y `_getColor()` para renderizar íconos y colores según la categoría.

**Detalles relevantes (algoritmo de comparación de perfiles):**
- Proceso implementado:
  1. Se cargan todas las actividades (`activities`) y las categorías (`categories`).
  2. Se obtiene la lista `userProfiles` desde el documento del usuario (si existe).
  3. Para cada actividad se convierte su `suitableProfiles` a minúsculas (`lower`) y se comprueba si contiene la etiqueta `'todos'` o si alguno de los `userProfiles` (también en minúsculas) aparece en `lower`.
  4. Si hay coincidencia, la actividad se añade a `_recommendedActivities`.
- Implementación: el chequeo es una comparación basada en igualdad de strings (case-insensitive) y usa un bucle anidado (para cada actividad, comprobar perfiles), con complejidad aproximada O(A * P) donde A es número de actividades y P la longitud de perfiles por actividad.
- Si no hay usuario autenticado, el filtro devuelve únicamente actividades que declaran `'todos'` en sus `suitableProfiles`.
- El código incluye `print()` para logs detallados (útil para debugging) y no realiza emparejamientos parciales o semánticos — solo comprobaciones de igualdad de texto.

- UI:
  - Usa `Scaffold`, `AppBar`, `MainBottomBar` y `SingleChildScrollView` con un diseño responsivo.
  - Muestra estado de carga con `CircularProgressIndicator` y mensajes cuando no hay recomendaciones.

---

## Puntos clave (muy breve) ✨
- **Filtrado Dinámico de Perfiles:** Cruce en tiempo real entre `suitableProfiles` (actividades) y `userProfiles` (usuario) para generar recomendaciones.
- **Persistencia Temporal Única:** Normalización de fechas (startOfDay/endOfDay) para recuperar entradas del diario sin duplicados.
- **Gestión de Estado Efímero:** Variables de estado (`gratitudeIndex`, `_isLoading`, `_isSaving`) controlan rotación de contenido y feedback de UI.
- **Mapeo de Metadatos a UI:** Conversión de tipos de Firestore (hex/string) a `Color` e `IconData` para representar categorías visualmente.

---

## Texto de ~30 segundos para decir en voz alta 🎤
Home aplica un filtrado dinámico de perfiles: cruza `suitableProfiles` (actividades) con `userProfiles` (usuario) para generar recomendaciones. Diary usa normalización temporal (startOfDay/endOfDay) para recuperar la entrada del día sin duplicados. La UI gestiona estado efímero (`gratitudeIndex`, `_isLoading`, `_isSaving`) para rotación de contenido y feedback inmediato. Las categorías se renderizan mediante mapeo de metadatos a UI (valores de Firestore convertidos a `Color` e `IconData`).

## Resumen rápido y justificación 🎯
**Resumen (30s):** Home muestra recomendaciones personalizadas mediante el cruce de perfiles del usuario con las etiquetas de cada actividad, mientras que Diary prioriza la consistencia temporal (normalizando fechas) para evitar duplicados y ofrecer un historial claro.

**Justificación de diseño y decisiones tomadas:**
- **Personalización simple y eficiente:** elegir un filtrado por etiquetas textuales (`suitableProfiles` vs `userProfiles`) aporta recomendaciones útiles con implementación clara y fácil de mantener, adecuada para las primeras iteraciones del producto.
- **Consistencia temporal sobre complejidad temprana:** normalizar fechas en cliente (startOfDay/endOfDay) simplifica la experiencia del usuario y evita entradas duplicadas; la decisión responde a priorizar precisión visible al usuario sobre optimizaciones aún no necesarias (p. ej., índices compuestos en Firestore) durante las pruebas iniciales.
- **Feedback inmediato y control de estado:** usar indicadores (`CircularProgressIndicator`, `SnackBar`) y flags (`_isLoading`, `_isSaving`) mejora la percepción de respuesta de la app y reduce errores por acciones concurrentes.
- **Balance rendimiento/mantenibilidad:** las operaciones que filtran en memoria se han aceptado temporalmente por la sencillez de la implementación y la facilidad de depuración; están documentadas y listas para optimizar si las métricas de uso lo requieren.
- **Decisiones basadas en iteración:** la forma de filtrar actividades y el diseño de la pantalla de Diary se establecieron tras prototipos y pruebas internas, buscando un equilibrio entre resultados relevantes para el usuario y esfuerzo de implementación.

> **Nota:** estas decisiones están pensadas para favorecer una experiencia consistente y predecible al usuario, manteniendo el código sencillo y fácil de evolucionar; se revisarán si los datos de uso o pruebas de rendimiento lo aconsejan.

---

> Archivo actualizado: `lib/presentation/pages/diary/homediary.md`
