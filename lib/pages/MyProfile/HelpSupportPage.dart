import 'package:flutter/material.dart';

class HelpSupportPage extends StatelessWidget {
  const HelpSupportPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Help & Support"),
        backgroundColor: const Color.fromARGB(255, 233, 61, 61),
        iconTheme: const IconThemeData(color: Colors.white),
        titleTextStyle: const TextStyle(
          fontFamily: 'Impact',
          fontSize: 24,
          color: Colors.white,
        ),
      ),

      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const Text(
            "Need help? Find answers below or contact support.",
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
          ),

          const SizedBox(height: 20),

          // -------------------- Accordion 1 --------------------
          ExpansionTile(
            leading: const Icon(Icons.help_outline, color: Colors.redAccent),
            title: const Text(
              "How to book an appointment?",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
            ),
            children: const [
              Padding(
                padding: EdgeInsets.all(16),
                child: Text(
                  "To book an appointment:\n\n"
                  "1. In prime care choose Doctors or Hospitals.\n "
                  "2. Choose your doctor or hospital in the list.\n"
                  "3. Select a doctor.\n"
                  "4. Choose date & time.\n"
                  "5. Click 'Book Appointment'.",
                  style: TextStyle(fontSize: 16),
                ),
              ),
            ],
          ),

          // -------------------- Accordion 2 --------------------
          ExpansionTile(
            leading: const Icon(Icons.lock_reset, color: Colors.redAccent),
            title: const Text(
              "How to reset my password?",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
            ),
            children: const [
              Padding(
                padding: EdgeInsets.all(16),
                child: Text(
                  "Follow these steps to reset your password:\n\n"
                  "1. Go to Login page.\n"
                  "2. Click 'Forgot Password'.\n"
                  "3. Enter your registered mobile number.\n"
                  "4. Create a new password.",
                  style: TextStyle(fontSize: 16),
                ),
              ),
            ],
          ),

          // -------------------- Accordion 3 --------------------
          ExpansionTile(
            leading: const Icon(Icons.person_outline, color: Colors.redAccent),
            title: const Text(
              "How to update profile information?",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
            ),
            children: const [
              Padding(
                padding: EdgeInsets.all(16),
                child: Text(
                  "To update your profile:\n\n"
                  "1. Go to 'My Profile'.\n"
                  "2. Click the Edit icon.\n"
                  "3. Update your details.\n"
                  "4. Tap Save.",
                  style: TextStyle(fontSize: 16),
                ),
              ),
            ],
          ),

          const SizedBox(height: 20),

          // -------------------- Contact Section --------------------
          Card(
            elevation: 2,
            color: const Color(0xFFF6F9FF),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Padding(
              padding: EdgeInsets.all(16),
              child: Row(
                children: [
                  Icon(Icons.email, color: Colors.redAccent, size: 30),
                  SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      "If you need more help, contact us at:\n"
                      "support@medbook.com",
                      style: TextStyle(fontSize: 16),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
