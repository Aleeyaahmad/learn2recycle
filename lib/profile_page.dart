import 'dart:io';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'start_screen.dart';
import 'recycle_info.dart';

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

  Future<void> _clearStoredDataOnLogout() async {
    final prefs = await SharedPreferences.getInstance();
    final imagePaths = prefs.getStringList('stored_images') ?? [];
    for (var path in imagePaths) {
      final file = File(path);
      if (await file.exists()) {
        await file.delete();
      }
    }
    await prefs.remove('stored_images');
    await prefs.remove('detection_output');
  }

  void _logout() async {
    await _clearStoredDataOnLogout();
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();

    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => StartScreen()),
      (route) => false,
    );
  }

  void _showCustomDialog({required String title, required Widget content}) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(
          title,
          style: TextStyle(
            fontFamily: 'Comfortaa',
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        content: content,
        actions: [
          TextButton(
            child: Text(
              "Close",
              style: TextStyle(
                fontFamily: 'Comfortaa',
                fontWeight: FontWeight.bold,
                color: Color(0xFFa4c291),
              ),
            ),
            onPressed: () => Navigator.pop(context),
          )
        ],
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      ),
    );
  }

  void _showAboutDialog() {
    _showCustomDialog(
      title: "About App",
      content: Text(
        "Learn2Recycle is an interactive app to help you recycle smarter and save the planet! 🌱\n\nVersion: 1.0.0\n©2025 Learn2Recycle",
        style: TextStyle(fontFamily: 'Comfortaa'),
      ),
    );
  }

  void _showAboutOptions() {
    showModalBottomSheet(
      context: context,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Wrap(
        children: [
          ListTile(
            leading: Image.asset('assets/icons/about-us.png', height: 28, width: 28, color: Colors.black),
            title: Text("About Developer", style: TextStyle(fontFamily: 'Comfortaa', fontWeight: FontWeight.bold)),
            onTap: () {
              Navigator.pop(context);
              _showCustomDialog(
                title: "About Developer",
                content: Text(
                  "A committed-one to making recycling easy and accessible for everyone.",
                  style: TextStyle(fontFamily: 'Comfortaa'),
                ),
              );
            },
          ),
          ListTile(
            leading: Image.asset('assets/icons/about-app.png', height: 28, width: 28, color: Colors.black),
            title: Text("About App", style: TextStyle(fontFamily: 'Comfortaa', fontWeight: FontWeight.bold)),
            onTap: () {
              Navigator.pop(context);
              _showAboutDialog();
            },
          ),
        ],
      ),
    );
  }

  void _showHelpSupportOptions() {
    showModalBottomSheet(
      context: context,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Wrap(
        children: [
          ListTile(
            leading: Image.asset('assets/icons/faq.png', height: 28, width: 28, color: Colors.black),
            title: Text("FAQ", style: TextStyle(fontFamily: 'Comfortaa', fontWeight: FontWeight.bold)),
            onTap: () {
              Navigator.pop(context);
              _showCustomDialog(
                title: "FAQs",
                content: SizedBox(
                  width: double.maxFinite,
                  child: ListView(
                    shrinkWrap: true,
                    children: [
                      ExpansionTile(
                        iconColor: Colors.black,
                        collapsedIconColor: Colors.black,
                        trailing: Image.asset('assets/icons/expand.png', height: 15, width: 15, color: Colors.black),
                        title: Text("How does Learn2Recycle work?", style: TextStyle(fontFamily: 'Comfortaa')),
                        children: [
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16.0),
                            child: Text(
                              "Learn2Recycle helps you identify recyclable waste, classify them, and locate local recycling centers.",
                              style: TextStyle(fontFamily: 'Comfortaa'),
                            ),
                          ),
                        ],
                      ),
                      ExpansionTile(
                        iconColor: Colors.black,
                        collapsedIconColor: Colors.black,
                        trailing: Image.asset('assets/icons/expand.png', height: 15, width: 15, color: Colors.black),
                        title: Text("Is Learn2Recycle free?", style: TextStyle(fontFamily: 'Comfortaa')),
                        children: [
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16.0),
                            child: Text(
                              "Yes! It's completely free to use with no hidden charges.",
                              style: TextStyle(fontFamily: 'Comfortaa'),
                            ),
                          ),
                        ],
                      ),
                      ExpansionTile(
                        iconColor: Colors.black,
                        collapsedIconColor: Colors.black,
                        trailing: Image.asset('assets/icons/expand.png', height: 15, width: 15, color: Colors.black),
                        title: Text("Do I need internet to use the app?", style: TextStyle(fontFamily: 'Comfortaa')),
                        children: [
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16.0),
                            child: Text(
                              "Some features work offline, but for the best experience including location-based services, internet is recommended.",
                              style: TextStyle(fontFamily: 'Comfortaa'),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
          ListTile(
            leading: Image.asset('assets/icons/contact.png', height: 28, width: 28, color: Colors.black),
            title: Text("Contact", style: TextStyle(fontFamily: 'Comfortaa', fontWeight: FontWeight.bold)),
            onTap: () {
              Navigator.pop(context);
              _showCustomDialog(
                title: "Contact",
                content: Text(
                  "Email: \naleeyaahmad03@gmail.com\nPhone: \n+60 133028544",
                  style: TextStyle(fontFamily: 'Comfortaa'),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  void _promptUsername() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: Text("Enter Your Name", style: TextStyle(fontFamily: 'Comfortaa', fontSize: 20, fontWeight: FontWeight.bold)),
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
            child: Text("Save", style: TextStyle(fontFamily: 'Comfortaa', fontSize: 16, fontWeight: FontWeight.bold)),
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
        title: Text("Profile", style: TextStyle(fontSize: 20, fontFamily: 'Comfortaa', fontWeight: FontWeight.bold, color: Colors.white)),
        centerTitle: true,
        backgroundColor: Color(0xFFa4c291),
        elevation: 0,
        actions: [
          Builder(
            builder: (context) => IconButton(
              icon: Image.asset('assets/icons/settings.png', height: 28, width: 28, color: Colors.white),
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
              decoration: BoxDecoration(color: Color(0xFFa4c291)),
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SizedBox(height: 10),
                    Text("Settings", style: TextStyle(fontFamily: 'Comfortaa', fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white)),
                  ],
                ),
              ),
            ),
            ListTile(
              leading: Image.asset('assets/icons/logout.png', height: 25, width: 25),
              title: Text("Logout", style: TextStyle(fontFamily: 'Comfortaa', fontSize: 15, color: Colors.black)),
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
                    SizedBox(height: 30),
                    SizedBox(
                      width: 250,
                      height: 60,
                      child: ElevatedButton.icon(
                        onPressed: _showAboutOptions,
                        icon: Image.asset('assets/icons/info.png', height: 24, width: 24, color: Colors.white),
                        label: Text(
                          "About",
                          style: TextStyle(fontFamily: 'Comfortaa', fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Color(0xFFa4c291),
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        ),
                      ),
                    ),
                    SizedBox(height: 12),
                    SizedBox(
                      width: 250,
                      height: 60,
                      child: ElevatedButton.icon(
                        onPressed: _showHelpSupportOptions,
                        icon: Image.asset('assets/icons/support.png', height: 24, width: 24, color: Colors.white),
                        label: Text(
                          "Help & Support",
                          style: TextStyle(fontFamily: 'Comfortaa', fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Color(0xFFa4c291),
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        ),
                      ),
                    ),
                    SizedBox(height: 12),
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
