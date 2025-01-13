import 'package:flutter/material.dart';
import 'package:flutter_application_1/pages/settings_page.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Optional: If you want to add an AppBar, do so here:
      // appBar: AppBar(title: const Text('Profile')),
      body: Column(
        children: [
          // Top Profile Section
          Container(
            color: Colors.grey[200],
            padding: const EdgeInsets.fromLTRB(16, 40, 16, 20),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Profile avatar
                CircleAvatar(
                  radius: 40,
                  backgroundColor: Colors.blueGrey,
                  child: Icon(
                    Icons.person,
                    color: Colors.white,
                    size: 40,
                  ),
                ),
                const SizedBox(width: 16),
                // Username
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(top: 8.0),
                        child: Text(
                          'Username',
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(top: 8.0),
                        child: Text(
                          'Company Name',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.black54,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                IconButton(
                  icon: Icon(Icons.home, color: Colors.black87),
                  onPressed: () {
                    Navigator.pop(context);
                  },
                ),
                IconButton(
                  icon: Icon(Icons.settings, color: Colors.black87),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => SettingsPage()),
                    );
                  },
                ), // Settings
              ],
            ),
          ),

          // Companies Section
          // Use Flexible or Expanded so the list can scroll (if needed).
          Expanded(
            child: Container(
              color: Colors.white,
              child: ListView(
                children: [
                  _buildCompanyTile('Company 1'),
                  _buildCompanyTile('Company 2'),
                  _buildCompanyTile('Company 3'),
                  // Add more if needed
                ],
              ),
            ),
          ),

          // Bottom Info Section
          Container(
            color: Colors.grey[300],
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                // Left text (Company Name)
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Company Name',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'No. of Shares and other details',
                        style: TextStyle(fontSize: 14),
                      ),
                    ],
                  ),
                ),
                // Right side: dropdown arrow & share count
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    // The dropdown icon
                    Icon(
                      Icons.arrow_drop_down,
                      size: 28,
                      color: Colors.black87,
                    ),
                    // Some placeholder for share count or other details
                    const SizedBox(height: 8),
                    Text(
                      '#### #### ####',
                      style: TextStyle(fontSize: 14),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCompanyTile(String companyName) {
    return Container(
      decoration: const BoxDecoration(
        border: Border(
          bottom: BorderSide(color: Colors.grey), // horizontal divider
        ),
      ),
      child: ExpansionTile(
        title: Text(companyName),
        trailing: const Icon(Icons.chevron_right),
        children: [
          // Here is the expanded content
          Container(
            color: Colors.white,
            padding: const EdgeInsets.all(16.0),
            child: const Text('Company Details'),
          ),
        ],
      ),
    );
  }
}
