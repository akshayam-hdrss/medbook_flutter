// import 'package:flutter/material.dart';
// import 'package:medbook/pages/auth/Login.dart';

// class ForgotPasswordPage extends StatefulWidget {
//   const ForgotPasswordPage({super.key});

//   @override
//   State<ForgotPasswordPage> createState() => _ForgotPasswordPageState();
// }

// class _ForgotPasswordPageState extends State<ForgotPasswordPage> {
//   final TextEditingController _emailController = TextEditingController();
//   double _buttonScale = 1.0;
//   String? _message;

//   void _showMessage(String msg) {
//     setState(() {
//       _message = msg;
//     });

//     Future.delayed(const Duration(seconds: 5), () {
//       if (mounted) {
//         setState(() {
//           _message = null;
//         });
//       }
//     });
//   }

//   @override
//   Widget build(BuildContext context) {
//     final screenWidth = MediaQuery.of(context).size.width;
//     final bool isTablet = screenWidth > 600;

//     return Scaffold(
//       body: Container(
//         width: double.infinity,
//         height: double.infinity,
//         decoration: const BoxDecoration(
//           gradient: LinearGradient(
//             colors: [Color(0xFFE93D3D), Color(0xFFFF7E5F)],
//             begin: Alignment.topLeft,
//             end: Alignment.bottomRight,
//           ),
//         ),
//         child: Center(
//           child: SingleChildScrollView(
//             padding: EdgeInsets.symmetric(
//               horizontal: isTablet ? 40 : 20,
//               vertical: isTablet ? 40 : 20,
//             ),
//             child: Container(
//               width: isTablet ? 500 : double.infinity,
//               padding: const EdgeInsets.all(24),
//               decoration: BoxDecoration(
//                 color: Colors.white.withOpacity(0.1),
//                 borderRadius: BorderRadius.circular(20),
//                 border: Border.all(color: Colors.white30, width: 1),
//                 boxShadow: [
//                   BoxShadow(
//                     color: Colors.black.withOpacity(0.05),
//                     blurRadius: 10,
//                     offset: const Offset(0, 4),
//                   ),
//                 ],
//               ),
//               child: Column(
//                 mainAxisSize: MainAxisSize.min,
//                 children: [
//                   Image.asset(
//                     'lib/Assets/images/medbook_logo.png',
//                     width: isTablet ? 120 : 90,
//                     height: isTablet ? 120 : 90,
//                   ),
//                   const SizedBox(height: 10),
//                   Text(
//                     "Forgot Password",
//                     style: TextStyle(
//                       fontSize: isTablet ? 30 : 24,
//                       fontFamily: 'Impact',
//                       color: Colors.white,
//                       letterSpacing: 1.2,
//                     ),
//                   ),
//                   const SizedBox(height: 30),

//                   // Input field
//                   _buildInputField(
//                     icon: Icons.email,
//                     hint: "Enter your email",
//                     controller: _emailController,
//                     isTablet: isTablet,
//                   ),
//                   const SizedBox(height: 20),

//                   // Error/success message
//                   if (_message != null)
//                     Padding(
//                       padding: const EdgeInsets.only(bottom: 12.0),
//                       child: Text(
//                         _message!,
//                         style: const TextStyle(
//                           color: Colors.yellowAccent,
//                           fontSize: 13,
//                           fontWeight: FontWeight.w600,
//                         ),
//                       ),
//                     ),

//                   // Submit button
//                   GestureDetector(
//                     onTapDown: (_) => setState(() => _buttonScale = 0.95),
//                     onTapUp: (_) {
//                       setState(() => _buttonScale = 1.0);
//                       final email = _emailController.text.trim();
//                       if (email.isNotEmpty) {
//                         // Trigger reset logic or API call here
//                         _showMessage("Reset link sent to $email");
//                       } else {
//                         _showMessage("Please enter your email");
//                       }
//                     },
//                     child: AnimatedScale(
//                       scale: _buttonScale,
//                       duration: const Duration(milliseconds: 100),
//                       child: Container(
//                         width: double.infinity,
//                         padding: const EdgeInsets.symmetric(vertical: 16),
//                         decoration: BoxDecoration(
//                           color: Colors.white,
//                           borderRadius: BorderRadius.circular(12),
//                         ),
//                         child: const Center(
//                           child: Text(
//                             "Reset Password",
//                             style: TextStyle(
//                               color: Color(0xFFE93D3D),
//                               fontSize: 16,
//                               fontWeight: FontWeight.bold,
//                               letterSpacing: 1,
//                             ),
//                           ),
//                         ),
//                       ),
//                     ),
//                   ),
//                   const SizedBox(height: 30),

//                   // Back to login
//                   TextButton(
//                     onPressed: () {
//                       Navigator.pushReplacement(
//                         context,
//                         MaterialPageRoute(builder: (_) => const LoginPage()),
//                       );
//                     },
//                     child: const Text(
//                       "← Back to Login",
//                       style: TextStyle(
//                         color: Colors.white,
//                         fontSize: 13,
//                       ),
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//           ),
//         ),
//       ),
//     );
//   }

//   Widget _buildInputField({
//     required IconData icon,
//     required String hint,
//     required TextEditingController controller,
//     required bool isTablet,
//   }) {
//     return TextField(
//       controller: controller,
//       keyboardType: TextInputType.emailAddress,
//       style: const TextStyle(fontSize: 14, color: Colors.white),
//       decoration: InputDecoration(
//         prefixIcon: Icon(icon, color: Colors.white),
//         hintText: hint,
//         hintStyle: TextStyle(
//           fontSize: isTablet ? 16 : 14,
//           color: Colors.white70,
//           fontWeight: FontWeight.w500,
//         ),
//         enabledBorder: const UnderlineInputBorder(
//           borderSide: BorderSide(color: Colors.white70, width: 1.5),
//         ),
//         focusedBorder: const UnderlineInputBorder(
//           borderSide: BorderSide(color: Colors.white, width: 2),
//         ),
//       ),
//     );
//   }
// }
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:medbook/pages/auth/Login.dart';

class ForgotPasswordPage extends StatefulWidget {
  const ForgotPasswordPage({super.key});

  @override
  State<ForgotPasswordPage> createState() => _ForgotPasswordPageState();
}

class _ForgotPasswordPageState extends State<ForgotPasswordPage> {
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _newPasswordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();

  double _buttonScale = 1.0;
  String? _message;

  void _showMessage(String msg) {
    setState(() => _message = msg);
    Future.delayed(const Duration(seconds: 5), () {
      if (mounted) setState(() => _message = null);
    });
  }

  Future<void> _resetPassword() async {
    final phone = _phoneController.text.trim();
    final newPassword = _newPasswordController.text.trim();
    final confirmPassword = _confirmPasswordController.text.trim();

    if (phone.isEmpty || newPassword.isEmpty || confirmPassword.isEmpty) {
      _showMessage("Please fill all fields");
      return;
    }

    if (newPassword != confirmPassword) {
      _showMessage("Passwords do not match");
      return;
    }

    final url = Uri.parse('https://medbook-backend-1.onrender.com/api/user/reset-password');

    try {
      final response = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"phone": phone, "newPassword": newPassword}),
      );

      final data = jsonDecode(response.body);
      if (response.statusCode == 200) {
        _showMessage(data['message']);
        // Go back to login after 2 sec
        Future.delayed(const Duration(seconds: 2), () {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => const LoginPage()),
          );
        });
      } else {
        _showMessage(data['message'] ?? "Failed to reset password");
      }
    } catch (e) {
      _showMessage("Error connecting to server");
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final bool isTablet = screenWidth > 600;

    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFFE93D3D), Color(0xFFFF7E5F)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Center(
          child: SingleChildScrollView(
            padding: EdgeInsets.symmetric(
              horizontal: isTablet ? 40 : 20,
              vertical: 30,
            ),
            child: Container(
              width: isTablet ? 500 : double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                // color: Colors.white.withOpacity(0.1),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: Colors.white30),
              ),
              child: Column(
                children: [
                  Image.asset(
                    'lib/Assets/images/medbook_logo.png',
                    width: isTablet ? 120 : 90,
                    height: isTablet ? 120 : 90,
                  ),
                  const SizedBox(height: 10),
                  Text(
                    "Reset Password",
                    style: TextStyle(
                      fontSize: isTablet ? 28 : 22,
                      fontFamily: 'Impact',
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 20),
                  _buildTextField("Mobile Number", _phoneController, false),
                  _buildTextField("New Password", _newPasswordController, true),
                  _buildTextField(
                    "Confirm Password",
                    _confirmPasswordController,
                    true,
                  ),
                  const SizedBox(height: 12),
                  if (_message != null)
                    Text(
                      _message!,
                      style: const TextStyle(
                        color: Color.fromARGB(255, 251, 251, 250),
                        fontSize: 14,
                      ),
                    ),
                  const SizedBox(height: 20),
                  GestureDetector(
                    onTapDown: (_) => setState(() => _buttonScale = 0.95),
                    onTapUp: (_) {
                      setState(() => _buttonScale = 1.0);
                      _resetPassword();
                    },
                    child: AnimatedScale(
                      scale: _buttonScale,
                      duration: const Duration(milliseconds: 100),
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Center(
                          child: Text(
                            "RESET PASSWORD",
                            style: TextStyle(
                              color: Color(0xFFE93D3D),
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  TextButton(
                    onPressed: () {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(builder: (_) => const LoginPage()),
                      );
                    },
                    child: const Text(
                      "← Back to Login",
                      style: TextStyle(color: Colors.white, fontSize: 13),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(
    String hint,
    TextEditingController controller,
    bool isPassword,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: TextField(
        controller: controller,
        obscureText: isPassword,
        keyboardType: isPassword ? TextInputType.text : TextInputType.phone,
        style: const TextStyle(fontSize: 14, color: Colors.white),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: const TextStyle(color: Color(0xFFF5F5F5)),
          enabledBorder: const UnderlineInputBorder(
            borderSide: BorderSide(color: Colors.white70, width: 1.5),
          ),
          focusedBorder: const UnderlineInputBorder(
            borderSide: BorderSide(color: Colors.white, width: 2),
          ),
        ),
      ),
    );
  }
}
