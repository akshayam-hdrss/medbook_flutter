// import 'dart:convert';
// import 'package:flutter/material.dart';
// import 'package:http/http.dart' as http;
// import 'package:medbook/pages/home_page.dart';
// import 'package:medbook/pages/Starting_page.dart';
// import 'package:medbook/pages/auth/ForgotPassword.dart';
// import 'package:medbook/services/secure_storage_service.dart';

// class LoginPage extends StatefulWidget {
//   const LoginPage({super.key});

//   @override
//   State<LoginPage> createState() => _LoginPageState();
// }

// class _LoginPageState extends State<LoginPage> {
//   final TextEditingController _emailController = TextEditingController();
//   final TextEditingController _passwordController = TextEditingController();
//   double _buttonScale = 1.0;
//   String? _errorMessage;

//   final SecureStorageService storageService = SecureStorageService();

//   void _showMessage(String message) {
//   setState(() {
//     _errorMessage = message;
//   });

//   // Clear the message after 5 seconds
//   Future.delayed(const Duration(seconds: 5), () {
//     if (mounted) {
//       setState(() {
//         _errorMessage = null;
//       });
//     }
//   });
// }

// Future<void> _loginUser() async {
//   final email = _emailController.text.trim();
//   final password = _passwordController.text.trim();

//   if (email.isEmpty || password.isEmpty) {
//     _showMessage("Please enter both email and password");
//     return;
//   }

//   final loginUrl = Uri.parse('https://medbook-backend-1.onrender.com/api/user/login');
//   final profileUrl = Uri.parse('https://medbook-backend-1.onrender.com/api/user/profile');

//   try {
//     final response = await http.post(
//       loginUrl,
//       headers: {'Content-Type': 'application/json'},
//       body: jsonEncode({'email': email, 'password': password}),
//     );

//     final responseBody = jsonDecode(response.body);

//     if (response.statusCode == 200 && responseBody['message'] == 'Login successful') {
//       final token = responseBody['token'];
//       await storageService.saveToken(token); // Save token securely

//       /// 🔄 Fetch user profile
//       final profileResponse = await http.get(
//         profileUrl,
//         headers: {
//           'Content-Type': 'application/json',
//           'Authorization': 'Bearer $token',
//         },
//       );

//       if (profileResponse.statusCode == 200) {
//         final profileBody = jsonDecode(profileResponse.body);
//         final user = profileBody['user'];

//         // ✅ Save user details securely or in a global state
//         await storageService.saveUserDetails(jsonEncode(user));

//         // 🚀 Navigate to HomePage
//         Navigator.pushReplacement(
//           context,
//           MaterialPageRoute(builder: (_) => HomePage()),
//         );
//       } else {
//         _showMessage("Failed to fetch user profile");
//       }
//     } else {
//       final errorMessage = responseBody['message'] ?? "Login failed. Please try again.";
//       _showMessage(errorMessage);
//     }
//   } catch (e) {
//     _showMessage("An error occurred. Please try again.");
//   }
// }

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
//                   const SizedBox(height: 5),
//                   Text(
//                     "Medbook",
//                     style: TextStyle(
//                       fontSize: isTablet ? 36 : 28,
//                       fontFamily: 'Impact',
//                       color: Colors.white,
//                       letterSpacing: 1.5,
//                     ),
//                   ),
//                   const SizedBox(height: 30),
//                   _buildInputField(
//                     icon: Icons.person,
//                     hint: "Username",
//                     controller: _emailController,
//                     isPassword: false,
//                     isTablet: isTablet,
//                   ),
//                   const SizedBox(height: 16),
//                   _buildInputField(
//                     icon: Icons.lock,
//                     hint: "Password",
//                     controller: _passwordController,
//                     isPassword: true,
//                     isTablet: isTablet,
//                   ),
//                   const SizedBox(height: 8),
//                   Align(
//                     alignment: Alignment.centerRight,
//                     child: TextButton(
//                       onPressed: () {
//                         Navigator.push(
//                           context,
//                           MaterialPageRoute(builder: (_) => const ForgotPasswordPage()),
//                         );
//                       },
//                       child: const Text(
//                         "Forgot Password?",
//                         style: TextStyle(
//                           color: Colors.white,
//                           fontWeight: FontWeight.bold,
//                           fontSize: 12,
//                         ),
//                       ),
//                     ),
//                   ),
//                   const SizedBox(height: 20),
//                   if (_errorMessage != null)
//   Padding(
//     padding: const EdgeInsets.only(bottom: 12.0),
//     child: Text(
//       _errorMessage!,
//       style: const TextStyle(
//         color: Colors.yellowAccent,
//         fontSize: 13,
//         fontWeight: FontWeight.w600,
//       ),
//     ),
//   ),
//                   GestureDetector(
//                     onTapDown: (_) => setState(() => _buttonScale = 0.95),
//                     onTapUp: (_) {
//                       setState(() => _buttonScale = 1.0);
//                       _loginUser(); // 🔐 Login action
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
//                             "LOGIN",
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
//                   TextButton(
//                     onPressed: () {
//                       Navigator.pushReplacement(
//                         context,
//                         MaterialPageRoute(builder: (_) => StartingPage()),
//                       );
//                     },
//                     child: const Text(
//                       "← Back to Start",
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
//     required bool isPassword,
//     required bool isTablet,
//   }) {
//     return TextField(
//       controller: controller,
//       obscureText: isPassword,
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
//      ),
// );
// }
// }import 'dart:convert';



import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:medbook/Services/secure_storage_service.dart';
import 'package:medbook/pages/home_page.dart';
import 'package:medbook/pages/Starting_page.dart';
import 'package:medbook/pages/auth/Signup.dart';
import 'package:medbook/pages/auth/ForgotPassword.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  String? _errorMessage;
  bool _isLoading = false;
  double _buttonScale = 1.0;

  // ================== LOGIN FUNCTION ==================
  Future<void> _loginUser() async {
    if (_phoneController.text.isEmpty || _passwordController.text.isEmpty) {
      _showError("Please fill in all fields.");
      return;
    }

    if (_phoneController.text.length != 10) {
      _showError("Please enter a valid 10-digit mobile number.");
      return;
    }

    setState(() => _isLoading = true);

    final loginUrl = Uri.parse("https://medbook-backend-1.onrender.com/api/user/login");
    final profileUrl = Uri.parse("https://medbook-backend-1.onrender.com/api/user/profile");

    try {
      // ✅ Login POST request
      final loginResponse = await http.post(
        loginUrl,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "phone": _phoneController.text,
          "password": _passwordController.text,
        }),
      );

      final loginBody = jsonDecode(loginResponse.body);
      print("Login Response: $loginBody");

      if (loginResponse.statusCode == 200 &&
          loginBody['message'] == "Login successful" &&
          loginBody['token'] != null) {
        final token = loginBody['token'];
        await SecureStorageService().saveToken(token);

        // 🔄 Fetch profile
        final profileResponse = await http.get(
          profileUrl,
          headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer $token',
          },
        );

        if (profileResponse.statusCode == 200) {
          final profileBody = jsonDecode(profileResponse.body);
          final user = profileBody['user'];
          await SecureStorageService().saveUserDetails(
            jsonEncode(user),
          ); // Save user details

          // 🚀 Navigate to HomePage and pass user if needed
          if (!mounted) return;
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => HomePage()),
          );
        } else {
          _showError("Failed to fetch user profile");
        }
      } else {
        _showError(loginBody['message'] ?? "Login failed");
      }
    } catch (e) {
      print("Login Error: $e");
      _showError("Login failed. Please check your backend and try again.");
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _showError(String message) {
    setState(() => _errorMessage = message);
    Future.delayed(const Duration(seconds: 5), () {
      if (mounted) setState(() => _errorMessage = null);
    });
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
                mainAxisSize: MainAxisSize.min,
                children: [
                  Image.asset(
                    'lib/Assets/images/medbook_logo.png',
                    width: isTablet ? 120 : 90,
                    height: isTablet ? 120 : 90,
                  ),
                  const SizedBox(height: 5),
                  const Text(
                    "Medbook",
                    style: TextStyle(
                      fontSize: 26,
                      fontFamily: 'Impact',
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 30),
                  _buildTextField(
                    "Mobile Number",
                    _phoneController,
                    false,
                    inputType: TextInputType.number,
                    inputFormatters: [
                      FilteringTextInputFormatter.digitsOnly,
                      LengthLimitingTextInputFormatter(10),
                    ],
                  ),
                  _buildTextField("Password", _passwordController, true),
                  const SizedBox(height: 8),
                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const ForgotPasswordPage(),
                          ),
                        );
                      },
                      child: const Text(
                        "Forgot Password?",
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  if (_errorMessage != null)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: Text(
                        _errorMessage!,
                        style: const TextStyle(
                          color: Color.fromARGB(255, 247, 247, 246),
                          fontSize: 13,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  GestureDetector(
                    onTapDown: (_) => setState(() => _buttonScale = 0.95),
                    onTapUp: (_) async {
                      setState(() => _buttonScale = 1.0);
                      await _loginUser();
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
                        child: Center(
                          child: _isLoading
                              ? const CircularProgressIndicator()
                              : const Text(
                                  "LOGIN",
                                  style: TextStyle(
                                    color: Color(0xFFE93D3D),
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    letterSpacing: 1,
                                  ),
                                ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  TextButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const SignupPage()),
                      );
                    },
                    child: const Text(
                      "Don't have an account? Sign Up",
                      style: TextStyle(color: Colors.white, fontSize: 13),
                    ),
                  ),
                  const SizedBox(height: 10),
                  TextButton(
                    onPressed: () {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(builder: (_) => const StartingPage()),
                      );
                    },
                    child: const Text(
                      "← Back to Start",
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
    String label,
    TextEditingController controller,
    bool isPassword, {
    TextInputType inputType = TextInputType.text,
    List<TextInputFormatter>? inputFormatters,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: TextField(
        controller: controller,
        obscureText: isPassword,
        keyboardType: inputType,
        inputFormatters: inputFormatters,
        style: const TextStyle(fontSize: 14, color: Colors.white),
        decoration: InputDecoration(
          hintText: label,
          hintStyle: const TextStyle(
            color: Color(0xFFF5F5F5),
            fontWeight: FontWeight.w500,
          ),
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
