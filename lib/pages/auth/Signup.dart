// import 'dart:convert';
// import 'package:flutter/material.dart';
// import 'package:http/http.dart' as http;
// import 'package:medbook/pages/Starting_page.dart';
// import 'package:medbook/pages/auth/Login.dart';

// class SignupPage extends StatefulWidget {
//   const SignupPage({super.key});

//   @override
//   State<SignupPage> createState() => _SignupPageState();
// }

// class _SignupPageState extends State<SignupPage> {
//   final TextEditingController _nameController = TextEditingController();
//   final TextEditingController _dobController = TextEditingController();
//   final TextEditingController _addressController = TextEditingController();
//   final TextEditingController _pincodeController = TextEditingController();
//   final TextEditingController _emailController = TextEditingController();
//   final TextEditingController _phoneController = TextEditingController();
//   final TextEditingController _passwordController = TextEditingController();
//   final TextEditingController _confirmPasswordController =
//       TextEditingController();

//   String? _selectedGender;
//   String? _errorMessage;

//   String _block = '';
//   String _district = '';
//   String _state = '';

//   double _buttonScale = 1.0;
//   bool _isLoading = false;

//   Future<void> _fetchLocationFromPincode(String pincode) async {
//     if (pincode.length != 6) return;

//     final response = await http.get(
//       Uri.parse('https://api.postalpincode.in/pincode/$pincode'),
//     );

//     if (response.statusCode == 200) {
//       final data = json.decode(response.body);
//       if (data[0]['Status'] == 'Success') {
//         final postOffice = data[0]['PostOffice'][0];
//         setState(() {
//           _block = postOffice['Block'] ?? '';
//           _district = postOffice['District'] ?? '';
//           _state = postOffice['State'] ?? '';
//         });
//       } else {
//         setState(() {
//           _block = '';
//           _district = '';
//           _state = '';
//         });
//         _showError("Invalid Pincode");
//       }
//     } else {
//       _showError("Failed to fetch location");
//     }
//   }

//   Future<void> _signupUser() async {
//     if (_nameController.text.isEmpty ||
//         _dobController.text.isEmpty ||
//         // _addressController.text.isEmpty ||
//         _pincodeController.text.isEmpty ||
//         _emailController.text.isEmpty ||
//         _phoneController.text.isEmpty ||
//         _passwordController.text.isEmpty ||
//         _confirmPasswordController.text.isEmpty ||
//         _selectedGender == null) {
//       _showError("Please fill in all fields.");
//       return;
//     }

//     if (_passwordController.text != _confirmPasswordController.text) {
//       _showError("Passwords do not match.");
//       return;
//     }

//     setState(() => _isLoading = true);

//     final url = Uri.parse(
//       "https://medbook-backend-1.onrender.com/api/user/signup",
//     );

//     final response = await http.post(
//       url,
//       headers: {"Content-Type": "application/json"},
//       body: jsonEncode({
//         "name": _nameController.text,
//         "email": _emailController.text,
//         "password": _passwordController.text,
//         "phone": _phoneController.text,
//         "pincode": _pincodeController.text,
//         "gender": _selectedGender,
//         "dob": _dobController.text,
//         "block": _block,
//         "district": _district,
//         "state": _state,
//         "address": _addressController.text,
//       }),
//     );

//     setState(() => _isLoading = false);

//     if (response.statusCode == 200 || response.statusCode == 201) {
//       Navigator.pushReplacement(
//         context,
//         MaterialPageRoute(builder: (_) => const LoginPage()),
//       );
//     } else {
//       final message = jsonDecode(response.body)['message'] ?? "Signup failed.";
//       _showError(message);
//     }
//   }

//   void _showError(String message) {
//     setState(() => _errorMessage = message);

//     Future.delayed(const Duration(seconds: 5), () {
//       if (mounted) {
//         setState(() => _errorMessage = null);
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
//               vertical: 30,
//             ),
//             child: Container(
//               width: isTablet ? 550 : double.infinity,
//               padding: const EdgeInsets.all(24),
//               decoration: BoxDecoration(
//                 color: Colors.white.withOpacity(0.1),
//                 borderRadius: BorderRadius.circular(20),
//                 border: Border.all(color: Colors.white30),
//               ),
//               child: Column(
//                 mainAxisSize: MainAxisSize.min,
//                 children: [
//                   Image.asset(
//                     'lib/Assets/images/medbook_logo.png',
//                     width: 90,
//                     height: 90,
//                   ),
//                   const SizedBox(height: 5),
//                   const Text(
//                     "Medbook",
//                     style: TextStyle(
//                       fontSize: 26,
//                       fontFamily: 'Impact',
//                       color: Colors.white,
//                     ),
//                   ),
//                   const SizedBox(height: 30),

//                   _buildTextField("Full Name", _nameController, false),
//                   _buildDatePickerField(_dobController),

//                   _buildTextField("Address", _addressController, false),
//                   _buildTextField(
//                     "Pincode",
//                     _pincodeController,
//                     false,
//                     onChanged: (value) {
//                       if (value.length == 6) {
//                         _fetchLocationFromPincode(value);
//                       }
//                     },
//                   ),
//                   _buildReadOnlyField("Area", _block),
//                   _buildReadOnlyField("District", _district),
//                   _buildReadOnlyField("State", _state),

//                   _buildDropdownField("Gender", ["Male", "Female", "Others"]),
//                   _buildTextField("Email", _emailController, false),
//                   _buildTextField("Phone Number", _phoneController, false),
//                   _buildTextField("Password", _passwordController, true),
//                   _buildTextField(
//                     "Confirm Password",
//                     _confirmPasswordController,
//                     true,
//                   ),

//                   const SizedBox(height: 20),
//                   if (_errorMessage != null)
//                     Padding(
//                       padding: const EdgeInsets.only(bottom: 12),
//                       child: Text(
//                         _errorMessage!,
//                         style: const TextStyle(
//                           color: Colors.yellowAccent,
//                           fontSize: 13,
//                         ),
//                         textAlign: TextAlign.center,
//                       ),
//                     ),

//                   GestureDetector(
//                     onTapDown: (_) => setState(() => _buttonScale = 0.95),
//                     onTapUp: (_) async {
//                       setState(() => _buttonScale = 1.0);
//                       await _signupUser();
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
//                         child: Center(
//                           child: _isLoading
//                               ? const CircularProgressIndicator()
//                               : const Text(
//                                   "SIGN UP",
//                                   style: TextStyle(
//                                     color: Color(0xFFE93D3D),
//                                     fontSize: 16,
//                                     fontWeight: FontWeight.bold,
//                                     letterSpacing: 1,
//                                   ),
//                                 ),
//                         ),
//                       ),
//                     ),
//                   ),

//                   const SizedBox(height: 30),
//                   TextButton(
//                     onPressed: () {
//                       Navigator.pushReplacement(
//                         context,
//                         MaterialPageRoute(builder: (_) => const StartingPage()),
//                       );
//                     },
//                     child: const Text(
//                       "← Back to Start",
//                       style: TextStyle(color: Colors.white, fontSize: 13),
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

// Widget _buildDatePickerField(TextEditingController controller) {
//   return TextField(
//     controller: controller,
//     readOnly: true,
//     style: const TextStyle(color: Colors.white), // white text color
//     decoration: const InputDecoration(
//       labelText: "Date of Birth (YYYY-MM-DD)",
//       labelStyle: TextStyle(color: Colors.white), // white label text
//       enabledBorder: UnderlineInputBorder(
//         borderSide: BorderSide(color: Colors.white), // white bottom border
//       ),
//       focusedBorder: UnderlineInputBorder(
//         borderSide: BorderSide(color: Colors.white), // white bottom border on focus
//       ),
//       suffixIcon: Icon(Icons.calendar_today, color: Colors.white), // white icon
//     ),
//     onTap: () async {
//       DateTime? pickedDate = await showDatePicker(
//         context: context,
//         initialDate: DateTime(2000),
//         firstDate: DateTime(1900),
//         lastDate: DateTime.now(),
//       );

//       if (pickedDate != null) {
//         String formattedDate = "${pickedDate.year}-${pickedDate.month.toString().padLeft(2, '0')}-${pickedDate.day.toString().padLeft(2, '0')}";
//         controller.text = formattedDate;
//       }
//     },
//   );
// }

//   Widget _buildTextField(
//     String label,
//     TextEditingController controller,
//     bool isPassword, {
//     Function(String)? onChanged,
//   }) {
//     return Padding(
//       padding: const EdgeInsets.symmetric(vertical: 8),
//       child: TextField(
//         controller: controller,
//         obscureText: isPassword,
//         onChanged: onChanged,
//         style: const TextStyle(fontSize: 14, color: Colors.white),
//         decoration: InputDecoration(
//           hintText: label,
//           hintStyle: const TextStyle(
//             color: Color(0xFFF5F5F5),
//             fontWeight: FontWeight.w500,
//           ),
//           enabledBorder: const UnderlineInputBorder(
//             borderSide: BorderSide(color: Colors.white70, width: 1.5),
//           ),
//           focusedBorder: const UnderlineInputBorder(
//             borderSide: BorderSide(color: Colors.white, width: 2),
//           ),
//         ),
//       ),
//     );
//   }

//   Widget _buildReadOnlyField(String label, String value) {
//     return Padding(
//       padding: const EdgeInsets.symmetric(vertical: 8),
//       child: TextField(
//         enabled: false,
//         controller: TextEditingController(text: value),
//         style: const TextStyle(fontSize: 14, color: Colors.white),
//         decoration: InputDecoration(
//           labelText: label,
//           labelStyle: const TextStyle(color: Colors.white70),
//           disabledBorder: const UnderlineInputBorder(
//             borderSide: BorderSide(color: Colors.white30),
//           ),
//         ),
//       ),
//     );
//   }

//   Widget _buildDropdownField(String label, List<String> items) {
//     return Padding(
//       padding: const EdgeInsets.symmetric(vertical: 8),
//       child: DropdownButtonFormField<String>(
//         value: _selectedGender,
//         dropdownColor: const Color(0xFFE93D3D),
//         style: const TextStyle(color: Colors.white),
//         iconEnabledColor: Colors.white,
//         decoration: const InputDecoration(
//           hintText: "Gender",
//           hintStyle: TextStyle(
//             color: Color(0xFFF5F5F5),
//             fontWeight: FontWeight.w500,
//           ),
//           enabledBorder: UnderlineInputBorder(
//             borderSide: BorderSide(color: Colors.white70, width: 1.5),
//           ),
//           focusedBorder: UnderlineInputBorder(
//             borderSide: BorderSide(color: Colors.white, width: 2),
//           ),
//         ),
//         items: items.map((item) {
//           return DropdownMenuItem(value: item, child: Text(item));
//         }).toList(),
//         onChanged: (value) => setState(() => _selectedGender = value),
//       ),
//     );
//   }
// }
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:medbook/pages/Starting_page.dart';
import 'package:medbook/pages/auth/Login.dart';

// ================= DOB FORMATTER ==================
class DobInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    String digits = newValue.text.replaceAll(RegExp(r'[^0-9]'), ''); // keep only numbers
    String newText = '';

    for (int i = 0; i < digits.length && i < 8; i++) {
      if (i == 2 || i == 4) newText += '-'; // add dash after dd and mm
      newText += digits[i];
    }

    return TextEditingValue(
      text: newText,
      selection: TextSelection.collapsed(offset: newText.length),
    );
  }
}

// ================= SIGNUP PAGE ==================
class SignupPage extends StatefulWidget {
  const SignupPage({super.key});

  @override
  State<SignupPage> createState() => _SignupPageState();
}

class _SignupPageState extends State<SignupPage> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _dobController = TextEditingController();
  final TextEditingController _pincodeController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();

  String? _errorMessage;
  double _buttonScale = 1.0;
  bool _isLoading = false;

  // ================== SIGNUP FUNCTION ==================
  Future<void> _signupUser() async {
    if (_nameController.text.isEmpty ||
        _dobController.text.isEmpty ||
        _pincodeController.text.isEmpty ||
        _phoneController.text.isEmpty ||
        _passwordController.text.isEmpty ||
        _confirmPasswordController.text.isEmpty) {
      _showError("Please fill in all fields.");
      return;
    }

    if (_phoneController.text.length != 10) {
      _showError("Please enter a valid 10-digit mobile number.");
      return;
    }

    if (_pincodeController.text.length != 6) {
      _showError("Please enter a valid 6-digit pincode.");
      return;
    }

    if (_passwordController.text != _confirmPasswordController.text) {
      _showError("Passwords do not match.");
      return;
    }

    // ✅ Convert DOB from dd-mm-yyyy → yyyy-mm-dd
    String dobFormatted = _dobController.text;
    if (dobFormatted.isNotEmpty) {
      List<String> parts = dobFormatted.split("-");
      if (parts.length == 3) {
        dobFormatted = "${parts[2]}-${parts[1]}-${parts[0]}";
      } else {
        _showError("Invalid DOB format. Please use dd-mm-yyyy.");
        return;
      }
    }

    setState(() => _isLoading = true);
    final url = Uri.parse(
      "https://medbook-backend-1.onrender.com/api/user/signup",
    );

    try {
      final response = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "name": _nameController.text,
          "phone": _phoneController.text,
          "password": _passwordController.text,
          "pincode": _pincodeController.text,
          "dob": dobFormatted,
        }),
      );

      setState(() => _isLoading = false);

      if (response.statusCode == 200 || response.statusCode == 201) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const LoginPage()),
        );
      } else {
        final message =
            jsonDecode(response.body)['message'] ?? "Signup failed.";
        _showError(message);
      }
    } catch (e) {
      setState(() => _isLoading = false);
      _showError("Signup failed. Please check your backend and try again.");
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
                    width: 90,
                    height: 90,
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
                  _buildTextField("Full Name", _nameController, false),
                  _buildDateField(_dobController),
                  _buildTextField(
                    "Pincode",
                    _pincodeController,
                    false,
                    inputType: TextInputType.number,
                    inputFormatters: [
                      FilteringTextInputFormatter.digitsOnly,
                      LengthLimitingTextInputFormatter(6),
                    ],
                  ),
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
                  _buildTextField(
                    "Confirm Password",
                    _confirmPasswordController,
                    true,
                  ),
                  const SizedBox(height: 20),
                  if (_errorMessage != null)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: Text(
                        _errorMessage!,
                        style: const TextStyle(
                          color: Color.fromARGB(255, 252, 252, 251),
                          fontSize: 13,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  GestureDetector(
                    onTapDown: (_) => setState(() => _buttonScale = 0.95),
                    onTapUp: (_) async {
                      setState(() => _buttonScale = 1.0);
                      await _signupUser();
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
                                  "SIGN UP",
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
                  const SizedBox(height: 30),
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

// DOB FIELD (only manual typing, no calendar)
Widget _buildDateField(TextEditingController controller) {
  return TextField(
    controller: controller,
    keyboardType: TextInputType.number,
    inputFormatters: [
      FilteringTextInputFormatter.digitsOnly,
      LengthLimitingTextInputFormatter(10),
      DobInputFormatter(),
    ],
    style: const TextStyle(color: Colors.white),
    decoration: const InputDecoration(
      labelText: "Date of Birth (dd-mm-yyyy)",
      labelStyle: TextStyle(color: Colors.white),
      enabledBorder: UnderlineInputBorder(
        borderSide: BorderSide(color: Colors.white),
      ),
      focusedBorder: UnderlineInputBorder(
        borderSide: BorderSide(color: Colors.white),
      ),
    ),
  );
}


  // Generic text field
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
