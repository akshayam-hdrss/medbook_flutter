// ignore_for_file: unused_fie
import 'package:flutter/material.dart';
import 'package:medbook/pages/Schedule/DoctorSchedulePage.dart';
import 'package:medbook/pages/Schedule/doctor_list_page.dart';
import 'package:medbook/pages/auth/Login.dart';
import 'package:medbook/components/Footer.dart';

// ignore: unused_import
import 'package:medbook/pages/MyProfile/EditProfilePage.dart';
import 'package:medbook/pages/MyProfile/PrivacyPolicyPage.dart';
import 'package:medbook/pages/MyProfile/HelpSupportPage.dart';
import 'package:medbook/pages/MyProfile/AppointmentHistoryPage.dart';

import 'package:medbook/services/secure_storage_service.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  bool isNotificationsEnabled = true; // State for the notification toggle
  Map<String, dynamic>? _userDetails;
  String? _userName;
  String? _userEmail;

  @override
  void initState() {
    super.initState();
    _loadUserDetails();
  }

  Future<void> _loadUserDetails() async {
    final storage = SecureStorageService();
    final userDetails = await storage.getUserDetails();

    if (userDetails != null) {
      setState(() {
        _userDetails = userDetails;
        _userName = userDetails['name'];
        _userEmail = userDetails['email'];
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("My Profile"),
        iconTheme: const IconThemeData(color: Colors.white),
        titleTextStyle: const TextStyle(
          fontFamily: 'Impact',
          fontSize: 24,
          color: Colors.white,
        ),
        backgroundColor: Color.fromARGB(255, 233, 61, 61),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Profile Header
            LayoutBuilder(
              builder: (context, constraints) {
                double padding = constraints.maxWidth > 600
                    ? 30
                    : 16; // Adjust padding based on screen size
                return Container(
                  margin: const EdgeInsets.symmetric(vertical: 15),
                  padding: EdgeInsets.symmetric(
                    vertical: 30,
                    horizontal: padding,
                  ),
                  decoration: BoxDecoration(
                    color: const Color.fromARGB(255, 233, 61, 61),
                    borderRadius: BorderRadius.circular(10),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black26,
                        blurRadius: 6,
                        offset: Offset(0, 3),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      const CircleAvatar(
                        backgroundColor: Colors.white,
                        radius: 50,
                        child: Icon(
                          Icons.person,
                          color: Color.fromARGB(255, 0, 0, 0),
                          size: 80,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        _userName ?? "User_Name",
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 19,
                          fontWeight: FontWeight.bold,
                        ),
                      ),

                      // Text(
                      //   _userEmail ?? "user@example.com",
                      //   style: const TextStyle(color: Colors.white70),
                      // ),
                      const SizedBox(height: 10),
                      // ElevatedButton.icon(
                      //   onPressed: () {
                      //     Navigator.push(
                      //       context,
                      //       MaterialPageRoute(builder: (context) => EditProfilePage()),
                      //     );
                      //   },
                      //   icon: const Icon(Icons.edit, size: 18),
                      //   label: const Text("Edit Profile"),
                      //   style: ElevatedButton.styleFrom(
                      //     backgroundColor: Colors.white,
                      //     foregroundColor: Colors.deepOrange,
                      //   ),
                      // )
                    ],
                  ),
                );
              },
            ),
            // Profile Options
            _buildOption(
              context,
              Icons.notifications,
              "Notifications",
              isSwitch: true,
            ),
            _buildOption(
              context,
              Icons.history,
              "Appointment History",
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const DoctorListPage()),
                );
              },
            ),
            _buildOption(
              context,
              Icons.help_outline,
              "Help & Support",
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => HelpSupportPage()),
                );
              },
            ),
            _buildOption(
              context,
              Icons.privacy_tip,
              "Privacy Policy",
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => PrivacyPolicyPage()),
                );
              },
            ),
            // _buildOption(context, Icons.logout, "Logout", onTap: () {
            //   Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => LoginPage()));
            // }),
            _buildOption(
              context,
              Icons.logout,
              "Logout",
              onTap: () async {
                final shouldLogout = await showDialog<bool>(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: const Text('Logout'),
                    content: const Text('Are you sure you want to log out?'),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context, false),
                        child: const Text('Cancel'),
                      ),
                      TextButton(
                        onPressed: () => Navigator.pop(context, true),
                        child: const Text('Logout'),
                      ),
                    ],
                  ),
                );

                if (shouldLogout == true) {
                  final storage = SecureStorageService();
                  await storage.deleteToken();

                  Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(builder: (_) => const LoginPage()),
                    (route) => false,
                  );
                }
              },
            ),
          ],
        ),
      ),
      bottomNavigationBar: Footer(title: "Home"),
    );
  }

  // Modified _buildOption to handle both Switch and navigation
  Widget _buildOption(
    BuildContext context,
    IconData icon,
    String title, {
    bool isSwitch = false,
    VoidCallback? onTap,
  }) {
    return ListTile(
      leading: Icon(icon, color: Colors.deepOrange),
      title: Text(title),
      trailing: isSwitch
          ? Switch(
              value: isNotificationsEnabled,
              onChanged: (value) {
                setState(() {
                  isNotificationsEnabled = value;
                });
              },
              activeColor: Colors.deepOrange,
            )
          : const Icon(Icons.arrow_forward_ios, size: 16),
      onTap: onTap,
    );
  }
}
