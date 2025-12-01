
import 'package:flutter/material.dart';
import 'package:medbook/components/Termsandconditions/Termsandconditions.dart';
import 'package:medbook/pages/auth/Login.dart';
import 'package:medbook/pages/auth/Signup.dart';

class StartingPage extends StatelessWidget {
  const StartingPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 233, 61, 61),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            double screenWidth = constraints.maxWidth;

            // Increased logo size
            double logoSize = screenWidth >= 600
                ? screenWidth *
                      0.75 // Tablets
                : screenWidth * 0.95; // Mobiles

            return SingleChildScrollView(
              child: ConstrainedBox(
                constraints: BoxConstraints(minHeight: constraints.maxHeight),
                child: IntrinsicHeight(
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Spacer(flex: 1),

                        // Logo - enlarged
                        Image.asset(
                          'lib/Assets/images/medbook_logo.png',
                          width: logoSize,
                          height: logoSize * 1.0,
                          fit: BoxFit.contain,
                        ),

                        const SizedBox(height: 20), // Slight space below logo
                        // Login & Sign Up Buttons - default style
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            ElevatedButton(
                              onPressed: () {
                                Navigator.pushReplacement(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => const LoginPage(),
                                  ),
                                );
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.white,
                                foregroundColor: Colors.deepOrange,
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 40,
                                  vertical: 20,
                                ), // Increased size
                                textStyle: const TextStyle(
                                  fontSize: 20, // Bigger text
                                  fontWeight: FontWeight.bold,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(30),
                                ),
                              ),
                              child: const Text("Login"),
                            ),
                            const SizedBox(width: 30),
                            ElevatedButton(
                              onPressed: () {
                                Navigator.pushReplacement(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => const SignupPage(),
                                  ),
                                );
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.white,
                                foregroundColor: Colors.deepOrange,
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 40,
                                  vertical: 20,
                                ), // Increased size
                                textStyle: const TextStyle(
                                  fontSize: 20, // Bigger text
                                  fontWeight: FontWeight.bold,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(30),
                                ),
                              ),
                              child: const Text("Sign Up"),
                            ),
                          ],
                        ),

                        const Spacer(flex: 2),
                        Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12),
                  child: TextButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => TermsAndConditions()),
                      );
                    },
                    child: const Text(
                      "*Terms & Conditions",
                      style: TextStyle(
                        color: Color.fromARGB(255, 237, 237, 237), // You can change the text color
                        fontSize: 12,
                      ),
                    ),
                  ),
  ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
