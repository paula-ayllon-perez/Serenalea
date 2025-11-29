import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

/// Widget simple que muestra una frase de gratitud
/// (Simulación de un widget visual de la app)
class GratitudePhraseWidget extends StatelessWidget {
  final String phrase;
  final Color? backgroundColor;

  const GratitudePhraseWidget({
    Key? key,
    required this.phrase,
    this.backgroundColor,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: backgroundColor ?? Colors.blue.shade50,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Text(
        phrase,
        style: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w500,
          color: Colors.black87,
        ),
        textAlign: TextAlign.center,
      ),
    );
  }
}

void main() {
  group('GratitudePhraseWidget Tests (Caja Negra)', () {
    testWidgets('renderiza la frase proporcionada', (WidgetTester tester) async {
      // Arrange
      const phrase = 'Gracias por seguir adelante a pesar de las dificultades.';

      // Act
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: GratitudePhraseWidget(phrase: phrase),
          ),
        ),
      );

      // Assert
      expect(find.text(phrase), findsOneWidget);
    });

    testWidgets('aplica el padding correcto', (WidgetTester tester) async {
      // Arrange & Act
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: GratitudePhraseWidget(
              phrase: 'Hoy es un nuevo día lleno de oportunidades.',
            ),
          ),
        ),
      );

      // Assert
      final container = tester.widget<Container>(
        find.byType(Container),
      );
      expect(container.padding, const EdgeInsets.all(16));
    });

    testWidgets('aplica borde redondeado', (WidgetTester tester) async {
      // Arrange & Act
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: GratitudePhraseWidget(
              phrase: 'Gracias por las oportunidades que trae cada día.',
            ),
          ),
        ),
      );

      // Assert
      final container = tester.widget<Container>(find.byType(Container));
      final decoration = container.decoration as BoxDecoration;
      expect(decoration.borderRadius, BorderRadius.circular(12));
    });

    testWidgets('usa color de fondo predeterminado cuando no se proporciona', (WidgetTester tester) async {
      // Arrange & Act
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: GratitudePhraseWidget(
              phrase: 'Hoy estás brillando con luz propia',
            ),
          ),
        ),
      );

      // Assert
      final container = tester.widget<Container>(find.byType(Container));
      final decoration = container.decoration as BoxDecoration;
      expect(decoration.color, Colors.blue.shade50);
    });

    testWidgets('usa color de fondo personalizado cuando se proporciona', (WidgetTester tester) async {
      // Arrange
      const customColor = Colors.purple;

      // Act
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: GratitudePhraseWidget(
              phrase: 'Hoy es un nuevo día',
              backgroundColor: customColor,
            ),
          ),
        ),
      );

      // Assert
      final container = tester.widget<Container>(find.byType(Container));
      final decoration = container.decoration as BoxDecoration;
      expect(decoration.color, customColor);
    });

    testWidgets('el texto tiene tamaño de fuente 18', (WidgetTester tester) async {
      // Arrange & Act
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: GratitudePhraseWidget(
              phrase: 'Gracias por todo lo que tengo',
            ),
          ),
        ),
      );

      // Assert
      final text = tester.widget<Text>(find.byType(Text));
      expect(text.style?.fontSize, 18);
    });

    testWidgets('el texto está centrado', (WidgetTester tester) async {
      // Arrange & Act
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: GratitudePhraseWidget(
              phrase: 'Gracias por las oportunidades',
            ),
          ),
        ),
      );

      // Assert
      final text = tester.widget<Text>(find.byType(Text));
      expect(text.textAlign, TextAlign.center);
    });

    testWidgets('el texto tiene peso de fuente medium (500)', (WidgetTester tester) async {
      // Arrange & Act
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: GratitudePhraseWidget(
              phrase: 'Hoy es un gran día',
            ),
          ),
        ),
      );

      // Assert
      final text = tester.widget<Text>(find.byType(Text));
      expect(text.style?.fontWeight, FontWeight.w500);
    });

    testWidgets('renderiza frases largas correctamente', (WidgetTester tester) async {
      // Arrange
      const longPhrase = 'Esta es una frase muy larga que debería renderizarse '
          'correctamente sin problemas de overflow o truncamiento en el widget.';

      // Act
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: Padding(
              padding: EdgeInsets.all(20),
              child: GratitudePhraseWidget(phrase: longPhrase),
            ),
          ),
        ),
      );

      // Assert
      expect(find.text(longPhrase), findsOneWidget);
      expect(tester.takeException(), isNull); // No hay overflow
    });

    testWidgets('renderiza frases cortas correctamente', (WidgetTester tester) async {
      // Arrange
      const shortPhrase = 'Gracias';

      // Act
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: GratitudePhraseWidget(phrase: shortPhrase),
          ),
        ),
      );

      // Assert
      expect(find.text(shortPhrase), findsOneWidget);
    });
  });
}
