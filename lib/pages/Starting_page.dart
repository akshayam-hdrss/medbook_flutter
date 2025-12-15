// starting_page.dart - UPDATED WITH NetworkCheck
import 'dart:async'; // ADD THIS IMPORT for Timer
import 'package:flutter/material.dart';
import 'package:medbook/components/Termsandconditions/Termsandconditions.dart';
import 'package:medbook/pages/auth/Login.dart';
import 'package:medbook/pages/auth/Signup.dart';
import 'package:medbook/utils/check_network.dart'; // CHANGE TO check_network.dart

class StartingPage extends StatefulWidget {
  const StartingPage({super.key});

  @override
  State<StartingPage> createState() => _StartingPageState();
}

class _StartingPageState extends State<StartingPage> {
  late Timer _networkTimer; // Timer for periodic checks

  @override
  void initState() {
    super.initState();
    
    // Initialize network check AFTER screen is built
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      // Check immediately when screen loads
      await NetworkCheck.showDialogIfOffline();
      
      // Keep checking every 3 seconds
      _networkTimer = Timer.periodic(const Duration(seconds: 3), (timer) async {
        await NetworkCheck.showDialogIfOffline();
      });
    });
  }

  @override
  void dispose() {
    // Cancel the timer when page is disposed
    _networkTimer.cancel();
    NetworkCheck.closeDialog(); // Close dialog if open
    super.dispose();
  }

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
                ? screenWidth * 0.75
                : screenWidth * 0.95;

            return Stack( // Use Stack to overlay network test button
              children: [
                SingleChildScrollView(
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

                            const SizedBox(height: 20),
                            // Login & Sign Up Buttons
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
                                    ),
                                    textStyle: const TextStyle(
                                      fontSize: 20,
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
                                    ),
                                    textStyle: const TextStyle(
                                      fontSize: 20,
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
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16.0,
                                vertical: 12,
                              ),
                              child: TextButton(
                                onPressed: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) =>
                                          const TermsAndConditions(),
                                    ),
                                  );
                                },
                                child: const Text(
                                  "*Terms & Conditions",
                                  style: TextStyle(
                                    color: Color.fromARGB(255, 237, 237, 237),
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
                ),
                
                // Network Test Button (Top Right Corner)
                Positioned(
                  top: 20,
                  right: 20,
                  child: Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.2),
                          blurRadius: 4,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: IconButton(
                      onPressed: () async {
                        print('📡 Manual network check triggered');
                        await NetworkCheck.showDialogIfOffline();
                      },
                      icon: const Icon(
                        Icons.wifi_find,
                        color: Colors.red,
                        size: 20,
                      ),
                      padding: EdgeInsets.zero,
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}