import 'package:flutter/material.dart';

class EditProfilePage extends StatefulWidget {
  const EditProfilePage({super.key});

  @override
  State<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _nameController =
      TextEditingController(text: "User_Name");
  final TextEditingController _emailController =
      TextEditingController(text: "User@example.com");
  final TextEditingController _phoneController =
      TextEditingController(text: "9876543210");
  final TextEditingController _addressController =
      TextEditingController(text: "Chennai, India");

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Edit Profile"),
        iconTheme: const IconThemeData(color: Colors.white),
        titleTextStyle: const TextStyle(
          fontFamily: 'Impact',
          fontSize: 24,
          color: Colors.white,
        ),
        backgroundColor: const Color.fromARGB(255, 233, 61, 61),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              // Profile image
              const CircleAvatar(
                radius: 50,
                backgroundColor: Color.fromARGB(255, 233, 61, 61),
                child: Icon(Icons.person, color: Color.fromARGB(255, 255, 255, 255), size: 80),// White background for the avatar
              ),
              const SizedBox(height: 20),

              _buildTextField("Full Name", _nameController),
              _buildTextField("Email", _emailController),
              _buildTextField("Phone", _phoneController),
              _buildTextField("Address", _addressController),

              const SizedBox(height: 30),

              ElevatedButton(
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    // Save logic here
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Profile Updated!')),
                    );
                    Navigator.pop(context); // Go back to profile page
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.deepOrange,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  "Save",
                  style: TextStyle(color: Colors.white, fontSize: 16),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(String label, TextEditingController controller) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: TextFormField(
        controller: controller,
        validator: (value) =>
            value == null || value.isEmpty ? "Required" : null,
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        ),
      ),
    );
  }
}
