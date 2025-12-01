import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class DonateSection extends StatelessWidget {
  const DonateSection({super.key});

  void _showUPIDialog(BuildContext context) {
    final TextEditingController amountController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Enter Donation Amount"),
        content: TextField(
          controller: amountController,
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(
            labelText: "Amount (INR)",
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel"),
          ),
          ElevatedButton(
            onPressed: () {
              final amount = amountController.text.trim();
              if (amount.isNotEmpty) {
                Navigator.pop(context);
                _launchUPIPayment(amount);
              }
            },
            child: const Text("Donate"),
          ),
        ],
      ),
    );
  }

  void _launchUPIPayment(String amount) async {
    final upiUrl = Uri.parse(
      'upi://pay?pa=aihmscbe-3@okicici&pn=Charity&am=$amount&cu=INR',
    );

    if (await canLaunchUrl(upiUrl)) {
      await launchUrl(upiUrl, mode: LaunchMode.externalApplication);
    } else {
      debugPrint('Could not launch UPI app');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 20.0),
        child: ElevatedButton(
          onPressed: () => _showUPIDialog(context),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.deepOrange,
            padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
          child: const Text(
            "Donate Now",
            style: TextStyle(fontSize: 16, color: Colors.white),
          ),
        ),
      ),
    );
  }
}
