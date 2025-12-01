import 'package:flutter/material.dart';
import 'package:get/get.dart'; // Import GetX for dialogs
import 'package:internet_connection_checker/internet_connection_checker.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart'; // For loading indicator

class NetworkConnection {
  static bool isDialogOpen = false;  // Flag to track if dialog is open

  static void checkInternetConnection() {
    // Initial check for internet connection (just in case)
    _checkConnectionStatus();

    // Listen for network connection status changes
    InternetConnectionChecker().onStatusChange.listen((status) {
      if (status == InternetConnectionStatus.disconnected && !isDialogOpen) {
        // Show the dialog immediately when the network is disconnected
        _showNoInternetDialog();
      } else if (status == InternetConnectionStatus.connected && isDialogOpen) {
        // Close the dialog immediately when the internet is restored
        Get.back();
        isDialogOpen = false;  // Reset the flag
      }
    });
  }

  // Initial internet connection check to respond immediately when offline
  static Future<void> _checkConnectionStatus() async {
    bool isConnected = await InternetConnectionChecker().hasConnection;

    if (!isConnected && !isDialogOpen) {
      // Show the dialog if offline
      _showNoInternetDialog();
    } else if (isConnected && isDialogOpen) {
      // Close the dialog if online
      Get.back();
      isDialogOpen = false;  // Reset the flag
    }
  }

  // Show the No Internet dialog
  static void _showNoInternetDialog() {
    isDialogOpen = true;
    Get.dialog(
      AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15.0), // Rounded corners
        ),
        title: Text(
          'No Internet Connection Found!',
          style: TextStyle(
            fontSize: 18.0,
            fontWeight: FontWeight.bold,
            color: Colors.red,
          ),
        ),
        content: Padding(
          padding: const EdgeInsets.only(top: 10),
          child: Text(
            'Please check your internet connection',
            style: TextStyle(fontSize: 16.0, color: Colors.black),
          ),
        ),
        actions: [
          Center(  // Centering the button
            child: TextButton(
              style: TextButton.styleFrom(
                backgroundColor: Colors.red,  // Red background for button
                padding: EdgeInsets.symmetric(horizontal: 40, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30.0),  // Rounded button
                ),
              ),
              onPressed: () async {
                // Show loading indicator while checking connection
                EasyLoading.show(status: 'Checking...');
                bool isConnected = await InternetConnectionChecker().hasConnection;
                EasyLoading.dismiss(); // Hide loading indicator

                if (isConnected) {
                  // If internet is restored, close the dialog immediately
                  Get.back(); // Close the dialog
                  isDialogOpen = false;  // Reset the flag
                } else {
                  // If still offline, keep dialog open
                  debugPrint("Still offline, keep dialog open.");
                }
              },
              child: Text(
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
      barrierDismissible: false, // Prevent dismissing by tapping outside
    );
}
}