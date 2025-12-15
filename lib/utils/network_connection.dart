// network_connection.dart - WITH BETTER ERROR HANDLING
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:internet_connection_checker/internet_connection_checker.dart';

class NetworkConnection {
  static bool isDialogOpen = false;
  static bool isInitialized = false;

  static void checkInternetConnection() {
    if (isInitialized) return;
    isInitialized = true;

    print('✅ NetworkConnection initialized');

    // Start checking
    _startMonitoring();
  }

  static Future<void> _startMonitoring() async {
    try {
      // Initial check
      await _checkConnection();

      // Listen for changes
      InternetConnectionChecker().onStatusChange.listen((status) async {
        await _checkConnection();
      });
    } catch (e) {
      print('❌ Error in network monitoring: $e');
    }
  }

  static Future<void> _checkConnection() async {
    try {
      bool isConnected = await InternetConnectionChecker().hasConnection;
      print('🌐 Internet connection: $isConnected');

      if (!isConnected && !isDialogOpen) {
        _showNoInternetDialog();
      } else if (isConnected && isDialogOpen) {
        _hideDialog();
      }
    } catch (e) {
      print('❌ Error checking connection: $e');
    }
  }

  static void _showNoInternetDialog() {
    if (isDialogOpen) return;

    isDialogOpen = true;

    // Delay to ensure context is ready
    Future.delayed(Duration.zero, () {
      try {
        Get.dialog(
          WillPopScope(
            onWillPop: () async => false, // Prevent back button from closing
            child: AlertDialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15.0),
              ),
              title: const Text(
                'No Internet Connection',
                style: TextStyle(
                  fontSize: 18.0,
                  fontWeight: FontWeight.bold,
                  color: Colors.red,
                ),
              ),
              content: const Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.wifi_off, size: 50, color: Colors.red),
                  SizedBox(height: 10),
                  Text(
                    'Please check your internet connection',
                    style: TextStyle(fontSize: 16.0, color: Colors.black),
                  ),
                ],
              ),
              actions: [
                Center(
                  child: TextButton(
                    style: TextButton.styleFrom(
                      backgroundColor: Colors.red,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 40,
                        vertical: 12,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30.0),
                      ),
                    ),
                    onPressed: () async {
                      bool isConnected =
                          await InternetConnectionChecker().hasConnection;
                      if (isConnected) {
                        _hideDialog();
                      }
                    },
                    child: const Text(
                      'Try Again',
                      style: TextStyle(fontSize: 16.0, color: Colors.white),
                    ),
                  ),
                ),
              ],
            ),
          ),
          barrierDismissible: false,
        );
        print('✅ Dialog shown successfully');
      } catch (e) {
        print('❌ Error showing dialog: $e');
        isDialogOpen = false;
      }
    });
  }

  static void _hideDialog() {
    if (isDialogOpen) {
      Get.back();
      isDialogOpen = false;
      print('✅ Dialog hidden');
    }
  }
}
