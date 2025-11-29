import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

/// Widget que selecciona un tipo de actividad
/// (Simulación de un widget de selección de la app)
class ActivityTypeSelector extends StatefulWidget {
  final Function(String) onTypeSelected;
  final String? initialType;

  const ActivityTypeSelector({
    Key? key,
    required this.onTypeSelected,
    this.initialType,
  }) : super(key: key);

  @override
  State<ActivityTypeSelector> createState() => _ActivityTypeSelectorState();
}

class _ActivityTypeSelectorState extends State<ActivityTypeSelector> {
  String? _selectedType;

  @override
  void initState() {
    super.initState();
    _selectedType = widget.initialType;
  }

  void _selectType(String type) {
    setState(() {
      _selectedType = type;
    });
    widget.onTypeSelected(type);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const Text(
          'Selecciona el tipo de actividad',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 20),
        Wrap(
          spacing: 12,
          runSpacing: 12,
          children: [
            _buildTypeChip('photo', Icons.camera_alt, 'Foto'),
            _buildTypeChip('text', Icons.edit, 'Texto'),
            _buildTypeChip('meditation', Icons.self_improvement, 'Meditación'),
            _buildTypeChip('simple', Icons.check_circle, 'Simple'),
          ],
        ),
      ],
    );
  }

  Widget _buildTypeChip(String type, IconData icon, String label) {
    final isSelected = _selectedType == type;
    return FilterChip(
      label: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 18),
          const SizedBox(width: 8),
          Text(label),
        ],
      ),
      selected: isSelected,
      onSelected: (selected) {
        if (selected) {
          _selectType(type);
        }
      },
      backgroundColor: Colors.grey.shade200,
      selectedColor: Colors.blue.shade100,
    );
  }
}

void main() {
  group('ActivityTypeSelector Widget Tests (Caja Negra)', () {
    testWidgets('renderiza el título correctamente', (WidgetTester tester) async {
      // Arrange & Act
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ActivityTypeSelector(onTypeSelected: (_) {}),
          ),
        ),
      );

      // Assert
      expect(find.text('Selecciona el tipo de actividad'), findsOneWidget);
    });

    testWidgets('renderiza los 4 tipos de actividad', (WidgetTester tester) async {
      // Arrange & Act
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ActivityTypeSelector(onTypeSelected: (_) {}),
          ),
        ),
      );

      // Assert
      expect(find.text('Foto'), findsOneWidget);
      expect(find.text('Texto'), findsOneWidget);
      expect(find.text('Meditación'), findsOneWidget);
      expect(find.text('Simple'), findsOneWidget);
    });

    testWidgets('renderiza los iconos correctos', (WidgetTester tester) async {
      // Arrange & Act
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ActivityTypeSelector(onTypeSelected: (_) {}),
          ),
        ),
      );

      // Assert
      expect(find.byIcon(Icons.camera_alt), findsOneWidget);
      expect(find.byIcon(Icons.edit), findsOneWidget);
      expect(find.byIcon(Icons.self_improvement), findsOneWidget);
      expect(find.byIcon(Icons.check_circle), findsOneWidget);
    });

    testWidgets('no hay tipo seleccionado inicialmente por defecto', (WidgetTester tester) async {
      // Arrange & Act
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ActivityTypeSelector(onTypeSelected: (_) {}),
          ),
        ),
      );

      // Assert
      final chips = tester.widgetList<FilterChip>(find.byType(FilterChip));
      for (final chip in chips) {
        expect(chip.selected, false);
      }
    });

    testWidgets('selecciona el tipo inicial proporcionado', (WidgetTester tester) async {
      // Arrange & Act
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ActivityTypeSelector(
              onTypeSelected: (_) {},
              initialType: 'meditation',
            ),
          ),
        ),
      );

      // Assert
      final chips = tester.widgetList<FilterChip>(find.byType(FilterChip)).toList();
      expect(chips[0].selected, false); // photo
      expect(chips[1].selected, false); // text
      expect(chips[2].selected, true);  // meditation ✅
      expect(chips[3].selected, false); // simple
    });

    testWidgets('al tocar un chip se marca como seleccionado', (WidgetTester tester) async {
      // Arrange
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ActivityTypeSelector(onTypeSelected: (_) {}),
          ),
        ),
      );

      // Act: Tocar "Foto"
      await tester.tap(find.text('Foto'));
      await tester.pumpAndSettle();

      // Assert
      final chips = tester.widgetList<FilterChip>(find.byType(FilterChip)).toList();
      expect(chips[0].selected, true);  // photo ✅
      expect(chips[1].selected, false); // text
      expect(chips[2].selected, false); // meditation
      expect(chips[3].selected, false); // simple
    });

    testWidgets('al tocar un chip se ejecuta el callback con el tipo correcto', (WidgetTester tester) async {
      // Arrange
      String? selectedType;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ActivityTypeSelector(
              onTypeSelected: (type) {
                selectedType = type;
              },
            ),
          ),
        ),
      );

      // Act: Tocar "Meditación"
      await tester.tap(find.text('Meditación'));
      await tester.pumpAndSettle();

      // Assert
      expect(selectedType, 'meditation');
    });

    testWidgets('solo un tipo puede estar seleccionado a la vez', (WidgetTester tester) async {
      // Arrange
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ActivityTypeSelector(onTypeSelected: (_) {}),
          ),
        ),
      );

      // Act: Seleccionar "Texto"
      await tester.tap(find.text('Texto'));
      await tester.pumpAndSettle();

      // Assert: Solo "Texto" está seleccionado
      var chips = tester.widgetList<FilterChip>(find.byType(FilterChip)).toList();
      expect(chips[1].selected, true); // text ✅

      // Act: Seleccionar "Simple"
      await tester.tap(find.text('Simple'));
      await tester.pumpAndSettle();

      // Assert: Solo "Simple" está seleccionado
      chips = tester.widgetList<FilterChip>(find.byType(FilterChip)).toList();
      expect(chips[1].selected, false); // text deseleccionado
      expect(chips[3].selected, true);  // simple ✅
    });

    testWidgets('el callback se ejecuta cada vez que se selecciona un tipo', (WidgetTester tester) async {
      // Arrange
      final selectedTypes = <String>[];

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ActivityTypeSelector(
              onTypeSelected: (type) {
                selectedTypes.add(type);
              },
            ),
          ),
        ),
      );

      // Act: Seleccionar múltiples tipos en secuencia
      await tester.tap(find.text('Foto'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Texto'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Simple'));
      await tester.pumpAndSettle();

      // Assert
      expect(selectedTypes, ['photo', 'text', 'simple']);
    });

    testWidgets('los chips no seleccionados tienen color gris', (WidgetTester tester) async {
      // Arrange & Act
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ActivityTypeSelector(onTypeSelected: (_) {}),
          ),
        ),
      );

      // Assert
      final chips = tester.widgetList<FilterChip>(find.byType(FilterChip)).toList();
      for (final chip in chips) {
        if (!chip.selected) {
          expect(chip.backgroundColor, Colors.grey.shade200);
        }
      }
    });

    testWidgets('los chips seleccionados tienen color azul', (WidgetTester tester) async {
      // Arrange & Act
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ActivityTypeSelector(
              onTypeSelected: (_) {},
              initialType: 'photo',
            ),
          ),
        ),
      );

      // Assert
      final chips = tester.widgetList<FilterChip>(find.byType(FilterChip)).toList();
      expect(chips[0].selected, true);
      expect(chips[0].selectedColor, Colors.blue.shade100);
    });
  });
}
