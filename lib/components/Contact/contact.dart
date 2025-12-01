import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:url_launcher/url_launcher.dart';

class Contact extends StatelessWidget {
  const Contact({super.key});

  // Contact Info
  final String phone = "7871117474";
  final String email = "admin@aktechnologies.ind.in";
  final String instagramUrl =
      "https://www.instagram.com/medbook.ind.in?igsh=MWp6OWthOHNhcmxwag==";
  final String address =
      "https://www.google.com/maps/dir//2nd+Floor,+Sunrise+Crystal+Complex,+Thadagam+Main+Rd,+Kalappa+Naicken+Palayam,+Coimbatore,+Tamil+Nadu+641108/@11.0585921,76.9127197,19z/data=!4m7!4m6!1m1!4e2!1m2!1m1!1s0x3ba8f5005ad23041:0x31b7bf352fa30bc9!3e0?utm_campaign=ml-d&g_ep=Eg1tbF8yMDI1MTExOV8wIJvbDyoASAJQAg%3D%3D";

  Future<void> _launchCaller(String number) async {
    final Uri callUri = Uri.parse('tel:$number');
    if (await canLaunchUrl(callUri)) {
      await launchUrl(callUri);
    }
  }

  Future<void> _launchWhatsApp(String number) async {
    final Uri whatsappUri = Uri.parse('https://wa.me/$number');
    if (await canLaunchUrl(whatsappUri)) {
      await launchUrl(whatsappUri, mode: LaunchMode.externalApplication);
    }
  }

  Future<void> _launchMapLink(String url) async {
    if (await canLaunchUrl(Uri.parse(url))) {
      await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
    }
  }

  Future<void> _launchEmail(String email) async {
    final Uri emailLaunchUri = Uri(scheme: 'mailto', path: email);
    if (await canLaunchUrl(emailLaunchUri)) {
      await launchUrl(emailLaunchUri);
    }
  }

  Future<void> _launchInstagram(String url) async {
    if (await canLaunchUrl(Uri.parse(url))) {
      await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
    }
  }

  Widget _actionButton(IconData icon, Color color, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.all(8),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: color.withOpacity(0.1),
          border: Border.all(color: color),
        ),
        child: Icon(icon, color: color, size: 26),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(kToolbarHeight),
        child: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Color.fromARGB(255, 225, 119, 20), // Orange
                Color.fromARGB(255, 239, 48, 34), // Red
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: AppBar(
            iconTheme: const IconThemeData(color: Colors.white),
            title: const Text(
              'Contact Us',
              style: TextStyle(color: Colors.white),
            ),
            backgroundColor: Colors.transparent,
            elevation: 0,
            centerTitle: true,
          ),
        ),
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          double width = constraints.maxWidth;

          // mobile <600, tablet >=600
          bool isTablet = width >= 600;

          return SingleChildScrollView(
            padding: EdgeInsets.symmetric(
              horizontal: isTablet ? 32 : 16,
              vertical: 16,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "About MedBook",
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 10),
                const Text(
                  "MedBook is your complete digital healthcare companion that connects patients to hospitals, clinics, doctors, diagnostic centers, and verified health services. "
                  "We bridge the gap between patients and providers by offering real-time appointment booking, transparent service listings, and access to health content through videos and blogs.\n\n"
                  "Whether you’re looking for trusted specialists, local clinics, home care providers, or medical products, MedBook brings everything into a single, easy-to-use platform. "
                  "We aim to empower users across India — from urban to rural — with trusted health services and digital convenience.",
                  style: TextStyle(fontSize: 16),
                  textAlign: TextAlign.justify,
                ),
                const SizedBox(height: 30),
                const Text(
                  "Reach Us",
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 20),

                // Responsive action buttons
                Center(
                  child: Wrap(
                    alignment: WrapAlignment.center,
                    spacing: isTablet ? 40 : 16,
                    runSpacing: 16,
                    children: [
                      _actionButton(
                        FontAwesomeIcons.phone,
                        Colors.lightBlueAccent,
                        () => _launchCaller(phone),
                      ),
                      _actionButton(
                        FontAwesomeIcons.whatsapp,
                        Colors.green,
                        () => _launchWhatsApp(phone),
                      ),
                      _actionButton(
                        FontAwesomeIcons.mapMarkerAlt,
                        Colors.deepOrange,
                        () => _launchMapLink(address),
                      ),
                      _actionButton(
                        FontAwesomeIcons.envelope,
                        Colors.teal,
                        () => _launchEmail(email),
                      ),
                      _actionButton(
                        FontAwesomeIcons.instagram,
                        Colors.purple,
                        () => _launchInstagram(instagramUrl),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
