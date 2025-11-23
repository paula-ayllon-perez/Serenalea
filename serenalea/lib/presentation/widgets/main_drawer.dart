import 'package:flutter/material.dart';
import 'package:serenalea/core/theme/app_theme.dart';

class MainBottomBar extends StatefulWidget {
  const MainBottomBar({Key? key}) : super(key: key);

  @override
  State<MainBottomBar> createState() => _MainBottomBarState();
}

class _MainBottomBarState extends State<MainBottomBar> {
  int _selectedIndex = 0;

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
    switch (index) {
      case 0:
        Navigator.pushNamed(context, '/'); // Home
        break;
      case 1:
        Navigator.pushNamed(context, '/diary'); // Diario
        break;
      case 2:
        Navigator.pushNamed(context, '/statistics'); // Estadísticas
        break;
      case 3:
        Navigator.pushNamed(context, '/random-activities'); // Actividades aleatorias
        break;
      case 4:
        Navigator.pushNamed(context, '/activities'); // Categorías de actividades
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      type: BottomNavigationBarType.fixed,
      backgroundColor: AppTheme.lightTheme.primaryColor,
      selectedItemColor: Colors.white,
      unselectedItemColor: Colors.white70,
      currentIndex: _selectedIndex,
      onTap: _onItemTapped,
      items: const [
        BottomNavigationBarItem(
          icon: Icon(Icons.home),
          label: 'Home',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.book),
          label: 'Diario',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.bar_chart),
          label: 'Estadísticas',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.shuffle),
          label: 'Random',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.list),
          label: 'Actividades',
        ),
      ],
    );
  }
}