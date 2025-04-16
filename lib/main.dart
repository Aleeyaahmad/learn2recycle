import 'package:flutter/material.dart';
import 'start_screen.dart';
import 'homepage.dart';
import 'map_page.dart';
import 'profile_page.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: StartScreen(),
    );
  }
}

class MainScreen extends StatefulWidget {
  @override
  _MainScreenState createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedIndex = 1; // Default: Home Screen

  final List<Widget> _pages = [
    MapPage(),
    HomePage(),
    ProfilePage(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_selectedIndex],

      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: Colors.white,
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        selectedItemColor: Colors.green[900],
        unselectedItemColor: Colors.grey,
        showUnselectedLabels: true,
        type: BottomNavigationBarType.fixed,
        items: [
          BottomNavigationBarItem(
            icon: _buildIcon('assets/icons/placeholder.png', 0),
            label: 'Nearby Recycler',
          ),
          BottomNavigationBarItem(
            icon: _buildIcon('assets/icons/camera.png', 1),
            label: 'Waste Detector',
          ),
          BottomNavigationBarItem(
            icon: _buildIcon('assets/icons/user.png', 2),
            label: 'Profile',
          ),
        ],
      ),
    );
  }

  // Function to build custom asset icons with highlight effect
  Widget _buildIcon(String assetPath, int index) {
    bool isSelected = _selectedIndex == index;

    return Container(
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: isSelected ? Colors.green[100] : Colors.transparent,
      ),
      padding: EdgeInsets.all(10),
      child: Image.asset(
        assetPath,
        height: 26,
        color: isSelected ? Colors.green[900] : Colors.grey,
      ),
    );
  }
}
