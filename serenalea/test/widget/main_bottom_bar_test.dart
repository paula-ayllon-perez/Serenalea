import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:serenalea/presentation/widgets/main_drawer.dart';

void main() {
  group('MainBottomBar Widget Tests (Caja Negra)', () {
    testWidgets('renderiza los 5 elementos de navegación', (WidgetTester tester) async {
      // Arrange & Act
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            bottomNavigationBar: MainBottomBar(),
          ),
        ),
      );

      // Assert
      expect(find.byType(BottomNavigationBar), findsOneWidget);
      expect(find.text('Home'), findsOneWidget);
      expect(find.text('Diario'), findsOneWidget);
      expect(find.text('Estadísticas'), findsOneWidget);
      expect(find.text('Random'), findsOneWidget);
      expect(find.text('Actividades'), findsOneWidget);
    });

    testWidgets('renderiza los 5 iconos correctos', (WidgetTester tester) async {
      // Arrange & Act
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            bottomNavigationBar: MainBottomBar(),
          ),
        ),
      );

      // Assert
      expect(find.byIcon(Icons.home), findsOneWidget);
      expect(find.byIcon(Icons.book), findsOneWidget);
      expect(find.byIcon(Icons.bar_chart), findsOneWidget);
      expect(find.byIcon(Icons.shuffle), findsOneWidget);
      expect(find.byIcon(Icons.list), findsOneWidget);
    });

    testWidgets('el índice inicial es 0 (Home)', (WidgetTester tester) async {
      // Arrange & Act
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            bottomNavigationBar: MainBottomBar(),
          ),
        ),
      );

      // Assert
      final bottomNavBar = tester.widget<BottomNavigationBar>(
        find.byType(BottomNavigationBar),
      );
      expect(bottomNavBar.currentIndex, 0);
    });

    testWidgets('al tocar un item navega a la ruta correcta', (WidgetTester tester) async {
      // Arrange
      String? navigatedRoute;
      
      await tester.pumpWidget(
        MaterialApp(
          onGenerateRoute: (settings) {
            navigatedRoute = settings.name;
            return MaterialPageRoute(
              builder: (context) => Scaffold(
                appBar: AppBar(title: Text(settings.name ?? 'Unknown')),
                bottomNavigationBar: const MainBottomBar(),
              ),
            );
          },
          initialRoute: '/home',
        ),
      );

      await tester.pumpAndSettle();

      // Act: Tocar "Diario" (índice 1)
      await tester.tap(find.byIcon(Icons.book));
      await tester.pumpAndSettle();

      // Assert
      expect(navigatedRoute, '/diary');
    });

    testWidgets('tiene un color de fondo definido', (WidgetTester tester) async {
      // Arrange & Act
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            bottomNavigationBar: MainBottomBar(),
          ),
        ),
      );

      // Assert
      final bottomNavBar = tester.widget<BottomNavigationBar>(
        find.byType(BottomNavigationBar),
      );
      expect(bottomNavBar.backgroundColor, isNotNull);
    });

    testWidgets('los items seleccionados son blancos', (WidgetTester tester) async {
      // Arrange & Act
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            bottomNavigationBar: MainBottomBar(),
          ),
        ),
      );

      // Assert
      final bottomNavBar = tester.widget<BottomNavigationBar>(
        find.byType(BottomNavigationBar),
      );
      expect(bottomNavBar.selectedItemColor, Colors.white);
    });

    testWidgets('los items no seleccionados son blancos con opacidad', (WidgetTester tester) async {
      // Arrange & Act
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            bottomNavigationBar: MainBottomBar(),
          ),
        ),
      );

      // Assert
      final bottomNavBar = tester.widget<BottomNavigationBar>(
        find.byType(BottomNavigationBar),
      );
      expect(bottomNavBar.unselectedItemColor, Colors.white70);
    });

    testWidgets('el tipo de BottomNavigationBar es fixed', (WidgetTester tester) async {
      // Arrange & Act
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            bottomNavigationBar: MainBottomBar(),
          ),
        ),
      );

      // Assert
      final bottomNavBar = tester.widget<BottomNavigationBar>(
        find.byType(BottomNavigationBar),
      );
      expect(bottomNavBar.type, BottomNavigationBarType.fixed);
    });
  });
}
