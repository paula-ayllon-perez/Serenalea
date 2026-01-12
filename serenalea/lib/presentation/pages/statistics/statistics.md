# Estadísticas — explicación de `statistics_page.dart`

## Resumen
Documento que explica cómo se calculan y muestran las estadísticas del usuario en `StatisticsPage`, incluye detalles técnicos implementados, 3–4 puntos clave breves y un texto de ~30 segundos para presentar la funcionalidad.

---

## ¿Qué hace `statistics_page.dart`? 🔍
- Es un `StatefulWidget` que consulta Firestore para calcular y renderizar métricas de uso del usuario: actividades completadas, tiempo total invertido, entradas de diario y rachas.
- Lee dos colecciones: `completedActivities` y `diaryEntries` filtradas por `userId` para construir todas las métricas.
- Inicializa series temporales (últimos 7 días por día y 30 días agrupados por semana) y las rellena en memoria con los conteos obtenidos de `completedAt`.
- Calcula rachas (`currentStreak`, `longestStreak`) extrayendo fechas únicas (sin hora) y analizando días consecutivos.
- Presenta la información con tarjetas, gráficas simples (barras y barras por semana), y se puede refrescar con `RefreshIndicator`.

**Comportamientos implementados (técnico):**
- Consultas: dos `get()` a Firestore con filtros `where('userId', isEqualTo: userId)` — coste O(N) sobre documentos retornados.
- Agregación: suma de `duration` (valora 5 min por defecto si falta duración), conteo por `categoryName` y por `activityType` (mapeado a nombres legibles por `_getTypeDisplayName`).
- Series temporales: crea llaves formateadas (`dd/MM`) para los últimos 7 días y llaves por rango semanal (`dd/MM-dd/MM`) para 30 días; asigna cada actividad completada al bucket correspondiente.
- Rachas: construye un `Set` de fechas (día) desde `completedAt` y calcula racha actual (comprobando días consecutivos desde hoy) y la racha más larga con un recorrido sobre fechas ordenadas.
- Robustez visual y UX: manejo de estados `_isLoading`, `try/catch` con `debugPrint` en errores, valores por defecto y protecciones para divisiones por cero en porcentajes.

**Consideraciones de rendimiento y límites:**
- Todas las agregaciones se realizan en el cliente sobre los documentos descargados; con muchos registros esto implica mayor uso de memoria y tiempo (no hay agregaciones en el servidor ni paginación).
- La agrupación semanal para 30 días parsea las llaves de semana y hace comprobaciones por documento, lo que agrega coste adicional O(N * W) en peor caso (W = número de semanas buckets).

---

## Puntos clave (muy breve) ✨
- **Agregación Cliente:** Todas las métricas (minutos, conteos, series) se calculan en memoria a partir de los documentos descargados.
- **Series Temporales:** Últimos 7 días (por día) y 30 días (por semana) inicializados con llaves `dd/MM` y `dd/MM-dd/MM` respectivamente.
- **Rachas por Fecha:** Rachas calculadas con `Set<DateTime>` (solo día) para precisión en días consecutivos.
- **UX Resistente:** `RefreshIndicator`, indicadores de carga y mensajes/gradientes para estados vacíos o motivacionales.

---

## Texto de ~30 segundos para decir en voz alta 🎤
La pantalla de Estadísticas descarga las actividades completadas y entradas de diario del usuario y calcula métricas clave en cliente: tiempo total invertido, distribución por categoría y tipo, actividad diaria de la última semana y por semanas del último mes. Además calcula rachas (actual y máxima) basadas en fechas únicas. Todo esto se presenta con tarjetas, pequeñas gráficas y un refresco manual para mantener los datos actualizados.

## Resumen rápido y justificación 🎯
**Resumen (30s):** Estadísticas consolida en cliente las métricas de uso (minutos invertidos, conteos por categoría, series temporales de 7 y 30 días y rachas) a partir de las colecciones `completedActivities` y `diaryEntries`, presentándolas con tarjetas y gráficas para una visión inmediata del progreso del usuario.

**Justificación detallada y técnica (explicado en profundidad):**
- **Por qué calcular en cliente (decisión tomada):** durante la fase inicial del producto priorizamos rapidez de desarrollo y transparencia en los cálculos; traer los documentos y agregar en memoria permite iterar rápidamente sobre la lógica (p. ej., cómo bucketizar por día/semana, qué considerar como duración mínima) sin cambiar backend. Esta opción facilita pruebas locales y correcciones rápidas al algoritmo.

- **Trade-offs y límites:** calcular todo en cliente es simple pero tiene coste O(N) en tiempo y memoria respecto al número de documentos descargados. Para usuarios con cientos o miles de registros, esto puede aumentar latencias y consumo de memoria y lectura de Firestore (coste monetario). Por eso documentamos el comportamiento y planteamos migrar a agregaciones server-side o paginación cuando el uso lo requiera.

- **Normalización temporal y zonas horarias:** las series y rachas usan normalización a fecha (startOfDay/endOfDay) en la zona horaria del dispositivo/servicio para evitar off-by-one en rachas. Es recomendable uniformizar el timezone (UTC o locale del usuario) y documentarlo; en producción, decidir una política (p. ej., almacenar timestamps UTC y convertir localmente al agrupar por día) evita inconsistencias.

- **Cálculo de rachas (algoritmo):** se construye un Set<DateTime> con las fechas únicas (sin hora) de `completedAt`. Para la racha actual, se verifica desde hoy hacia atrás si existe cada día consecutivo; para la racha más larga se recorre el conjunto ordenado y se cuenta secuencias de días consecutivos. Esta aproximación es O(D log D) por la ordenación, con D = días únicos con actividad.

- **Bucketización de series temporales:**
  - Últimos 7 días: un bucket por día (`dd/MM`) donde cada `completedAt` se asigna al bucket de su fecha normalizada.
  - Últimos 30 días: agrupación por semanas (ej. `01/01-07/01`) para suavizar variaciones y mantener la gráfica legible.
  - Para asignación eficiente, calcular el índice del bucket por resta de días y evitar parsers de string en loops críticos.

- **Duraciones y valores faltantes:** si una actividad no tiene `duration` se considera un valor por defecto (p. ej., 5 minutos) para no penalizar agregaciones; documenta esta heurística y plantéate recoger duración obligatoria a futuro.

- **UX y presentación:** usar `RefreshIndicator` y estados explícitos (`_isLoading`) ofrece control y previsibilidad al usuario; tarjetas con totales y gráficas permites escaneo rápido. Se prefirió claridad y estabilidad en lugar de compactar muchas métricas en una sola vista.

- **Monitoreo y criterios para optimizar:** medir la cantidad media de documentos por usuario y latencias; si el 95º percentil de documentos supera un umbral (p. ej., 500–1.000 docs consultados por cálculo) recomendamos:
  1. Migrar agregaciones a Cloud Functions (batch o incremental) o usar Firestore aggregation queries donde sea posible.
  2. Implementar paginación o consultas por rango de fecha (where completedAt >= startDate) para reducir lectura.
  3. Mantener un cache local o precomputado (e.g., documento `user_stats`) actualizado por triggers para lecturas rápidas.

- **Pruebas y validación:** añadir tests unitarios para: asignación de buckets, cálculo de rachas (casos borde: días faltantes, cambios de mes/año), y manejo de duraciones ausentes. Añadir tests de integración que simulen conjuntos de datos (fakes) para validar rendimiento y exactitud.

- **Evolución técnica sugerida:**
  - Implementar límites de consulta por fecha y paginación.
  - Considerar Cloud Functions que calculen y escriban estadísticas preagregadas por usuario (reducción de coste y latencia en lectura).
  - Añadir métricas analíticas (eventos: `stats_viewed`, latencia de cálculo, número de docs leídos) para validar el momento de migrar a agregaciones server-side.

> **Nota:** las decisiones realizadas buscan un equilibrio entre velocidad de desarrollo, trazabilidad y experiencia de usuario; están documentadas y listas para escalar según las métricas y el crecimiento del producto.

---

> Archivo creado: `lib/presentation/pages/statistics/statistics.md`
