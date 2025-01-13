import 'package:flutter/material.dart';
import 'package:flutter_application_1/pages/profile_page.dart'; // Import the ProfilePage

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Register Your Company',
      home: RYC(),
    );
  }
}

class CustomHeader extends StatelessWidget implements PreferredSizeWidget {
  const CustomHeader({super.key});

  @override
  Size get preferredSize => Size.fromHeight(60);

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color.fromARGB(255, 171, 69, 69),
      padding: EdgeInsets.symmetric(horizontal: 16),
      child: SafeArea(
        bottom: false,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // Left side: Circle avatar
            CircleAvatar(
              radius: 20,
              backgroundColor: Colors.blueGrey,
              child: IconButton(
                icon: Icon(Icons.person, color: Colors.white),
                onPressed: () {
                  // Navigate to ProfilePage
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => ProfilePage()),
                  );
                },
              ),
            ),

            // Center: Username/Shareholder + Company Name
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Username / Shareholder',
                  style: TextStyle(
                    color: Colors.black87,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  'Company Name',
                  style: TextStyle(
                    color: Colors.black54,
                    fontSize: 14,
                  ),
                ),
              ],
            ),

            // Right side: Hamburger menu
            IconButton(
              icon: Icon(Icons.menu, color: Colors.black87),
              onPressed: () {
                // TODO: handle menu
              },
            ),
          ],
        ),
      ),
    );
  }
}

class RYC extends StatelessWidget {
  const RYC({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomHeader(),
      body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Center(child: Text('Body content here'))),
    );
  }
}
