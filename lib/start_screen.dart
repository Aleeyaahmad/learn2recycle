import 'package:flutter/material.dart';
import 'package:learn2recycle/main.dart';

class StartScreen extends StatefulWidget {
  @override
  _StartScreenState createState() => _StartScreenState();
}

class _StartScreenState extends State<StartScreen> {
  PageController _controller = PageController();
  int _currentIndex = 0;

  final List<Map<String, dynamic>> pages = [
    {
      'image': 'assets/icons/recycle.png',
      'title': 'Welcome to Learn2Recycle!',
      'description': 'You\'re now part of our eco-friendly mission. Let\'s get started!',
      'bgColor': Color(0xFFFFFDE7),
    },
    {
      'image': 'assets/icons/onboarding1.png',
      'title': 'Waste Detector',
      'description': 'Identify recyclable waste easily and reduce your carbon footprint.',
      'bgColor': Color(0xFFFFEBEE),
    },
    {
      'image': 'assets/icons/onboarding2.png',
      'title': 'Find Recyclers Nearby!',
      'description': 'Locate recycling centers near you and contribute actively.',
      'bgColor': Color(0xFFE0F7FA),
    },
  ];

  Widget _buildPage(Map<String, dynamic> page) {
    return Container(
      color: page['bgColor'],
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 60),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            Image.asset(
              page['image'],
              height: 250,
            ),
            Column(
              children: [
                Text(
                  page['title'],
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.w600,
                    fontFamily: 'Pacifico', // Custom title font
                    color: Colors.black87,
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 20),
                Text(
                  page['description'],
                  style: TextStyle(
                    fontSize: 16,
                    fontFamily: 'Comfortaa',
                    color: Colors.black54,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
            // Dot Indicator above buttons
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(pages.length, (index) {
                return Container(
                  margin: EdgeInsets.symmetric(horizontal: 4),
                  height: 8,
                  width: _currentIndex == index ? 16 : 8,
                  decoration: BoxDecoration(
                    color: _currentIndex == index ? Colors.black87 : Colors.grey,
                    borderRadius: BorderRadius.circular(4),
                  ),
                );
              }),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (_currentIndex < pages.length - 1)
                  OutlinedButton(
                    onPressed: () {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(builder: (_) => MainScreen()),
                      );
                    },
                    style: OutlinedButton.styleFrom(
                      side: BorderSide(color: Colors.black),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                    ),
                    child: Text(
                      'Skip',
                      style: TextStyle(color: Colors.black),
                    ),
                  ),
                SizedBox(width: 16),
                ElevatedButton(
                  onPressed: () {
                    if (_currentIndex < pages.length - 1) {
                      _controller.nextPage(
                        duration: Duration(milliseconds: 300),
                        curve: Curves.easeInOut,
                      );
                    } else {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(builder: (_) => MainScreen()),
                      );
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.black,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  ),
                  child: Text(_currentIndex == pages.length - 1 ? 'Let’s Start' : 'Next'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: PageView.builder(
        controller: _controller,
        itemCount: pages.length,
        onPageChanged: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        itemBuilder: (_, index) => _buildPage(pages[index]),
      ),
    );
  }
}
