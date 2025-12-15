// lib/utils/check_network.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:internet_connection_checker/internet_connection_checker.dart';

class NetworkCheck {
  static bool _dialogShown = false;
  
  static Future<void> showDialogIfOffline() async {
    // Don't show if already showing
    if (_dialogShown) return;
    
    try {
      bool isConnected = await InternetConnectionChecker().hasConnection;
      
      if (!isConnected && !_dialogShown) {
        _dialogShown = true;
        
        // Show the dialog
        Get.dialog(
          WillPopScope(
            onWillPop: () async => false, // Prevent closing with back button
            child: AlertDialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15.0),
              ),
              title: const Row(
                children: [
                  Icon(Icons.wifi_off, color: Colors.red),
                  SizedBox(width: 10),
                  Text(
                    'No Internet',
                    style: TextStyle(
                      fontSize: 18.0,
                      fontWeight: FontWeight.bold,
                      color: Colors.red,
                    ),
                  ),
                ],
              ),
              content: const Text(
                'Please check your internet connection and try again.',
                style: TextStyle(fontSize: 16.0),
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
                      bool isConnected = await InternetConnectionChecker().hasConnection;
                      if (isConnected) {
                        Get.back();
                        _dialogShown = false;
                      }
                    },
                    child: const Text(
                      'Try Again',
                      style: TextStyle(
                        fontSize: 16.0,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          barrierDismissible: false,
        );
      }
    } catch (e) {
      print('Error checking network: $e');
    }
  }
  
  static void closeDialog() {
    if (_dialogShown) {
      Get.back();
      _dialogShown = false;
    }
  }
}