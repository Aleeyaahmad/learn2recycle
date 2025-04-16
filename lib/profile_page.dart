import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'start_screen.dart'; // Replace with your actual StartScreen import

class ProfilePage extends StatefulWidget {
  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  String? _username;
  final TextEditingController _usernameController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    final prefs = await SharedPreferences.getInstance();
    final storedName = prefs.getString('username');

    if (storedName == null) {
      Future.delayed(Duration.zero, _promptUsername);
    } else {
      setState(() {
        _username = storedName;
      });
    }
  }

  Future<void> _saveProfile(String username) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('username', username);
    setState(() {
      _username = username;
    });
  }

  void _logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => StartScreen()),
      (route) => false,
    );
  }

  void _showAboutDialog() {
    showAboutDialog(
      context: context,
      applicationName: "Learn2Recycle",
      applicationVersion: "1.0.0",
      applicationLegalese: "©2025 Learn2Recycle",
      children: [
        Text("An interactive app to help you recycle smarter and save the planet! 🌱"),
      ],
    );
  }

  void _promptUsername() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: Text("Enter Your Name",
          style: TextStyle(fontFamily: 'Comfortaa', fontSize: 20, fontWeight: FontWeight.bold, color: Colors.black),),
          content: TextField(
          controller: _usernameController,
          decoration: InputDecoration(
            hintText: "Your name",
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          ),
        ),
        actions: [
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Color(0xFFa4c291),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            onPressed: () {
              final enteredName = _usernameController.text.trim();
              if (enteredName.isNotEmpty) {
                _saveProfile(enteredName);
                Navigator.pop(context);
              }
            },
            child: Text("Save", 
            style: TextStyle(fontFamily: 'Comfortaa', fontSize: 16, fontWeight: FontWeight.bold),),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFF0FFF0),
      appBar: AppBar(
        title: Text("Profile",
          style: TextStyle(
                fontSize: 20,
                fontFamily: 'Comfortaa',
                fontWeight: FontWeight.bold,
                color: Colors.white,),
                ),
        centerTitle: true,
        backgroundColor: Color(0xFFa4c291),
        elevation: 0,
        actions: [
          Builder(
            builder: (context) => IconButton(
              icon: Icon(Icons.settings, color: Colors.white),
              onPressed: () => Scaffold.of(context).openEndDrawer(),
            ),
          ),
        ],
      ),
      endDrawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            DrawerHeader(
              decoration: BoxDecoration(color: Color(0xFF447055)),
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.settings, size: 48, color: Color(0xFF447055)),
                    SizedBox(height: 10),
                    Text(
                      "Settings",
                      style: TextStyle(fontFamily: 'Comfortaa', fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white),
                    ),
                  ],
                ),
              ),
            ),
            ListTile(
              leading: Image.asset('assets/icons/about.png'),
              title: Text("About App"),
              onTap: _showAboutDialog,
            ),
            ListTile(
              leading: Image.asset('assets/icons/logout.png'),
              title: Text("Logout"),
              onTap: _logout,
            ),
          ],
        ),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircleAvatar(
                radius: 60,
                backgroundColor: Colors.green[300],
                child: Icon(Icons.person, size: 60, color: Colors.white),
              ),
              SizedBox(height: 20),
              if (_username != null)
                Column(
                  children: [
                    Text(
                      "Hello, $_username!",
                      style: TextStyle(
                        fontSize: 28,
                        fontFamily: 'Comfortaa',
                        color: Colors.green[900],
                      ),
                    ),
                    SizedBox(height: 10),
                    Text(
                      "Manage your profile and settings here.",
                      style: TextStyle(fontSize: 16, color: Colors.black54),
                      textAlign: TextAlign.center,
                    ),
                  ],
                )
              else
                CircularProgressIndicator(color: Colors.green),
            ],
          ),
        ),
      ),
    );
  }
}
