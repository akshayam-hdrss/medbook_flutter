// update nantha
import 'package:flutter/material.dart';
import 'package:medbook/components/Offers/offers.dart';
import 'package:medbook/pages/Favourties/favourites_page.dart';
import 'package:medbook/pages/Schedule/DoctorSchedulePage.dart';
import 'package:medbook/pages/Schedule/doctor_list_page.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:medbook/pages/home_page.dart';
import 'package:medbook/pages/complain.dart';
import 'package:medbook/pages/services/service_page.dart'; // Complain Page
import 'package:medbook/Services/secure_storage_service.dart';
import 'package:medbook/pages/Schedule/DoctorManage.dart';
import 'package:medbook/pages/Schedule/ServiceManage.dart';

class Footer extends StatefulWidget {
  final String title; // Add the title parameter

  const Footer({super.key, required this.title}); // Modify the constructor

  @override
  _FooterState createState() => _FooterState();
}

class _FooterState extends State<Footer> {
  // List of button titles
  final List<String> buttonTitles = [
    "Home",
    "Emergency",
    "Schedule",
    "Complaint",
    "offers",
    "none",
  ];

  int _selectedIndex = 0; // Default to Home being selected

  @override
  Widget build(BuildContext context) {
    // Find the index of the title that matches widget.title
    _selectedIndex = buttonTitles.indexOf(widget.title);

    // Print the title for debugging
    print("The current title is: ${widget.title}");

    return Container(
      padding: EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Color.fromARGB(255, 254, 254, 254),
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(35),
          topRight: Radius.circular(35),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.3), // Light shadow
            spreadRadius: 5,
            blurRadius: 10,
            offset: Offset(0, -2), // Shadow appears above the box
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildFooterButton(
            iconPath: 'lib/Assets/footer_icons/home.png',
            title: buttonTitles[0],
            isSelected: _selectedIndex == 0,
            onPressed: () {
              if (widget.title != "Home") {
                setState(() {
                  _selectedIndex = 0;
                });
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => HomePage()),
                );
              }
            },
          ),
          _buildFooterButton(
            iconPath: 'lib/Assets/footer_icons/offer.png',
            title: buttonTitles[4],
            isSelected: _selectedIndex == 4,
            onPressed: () {
              if (widget.title != "offers") {
                setState(() {
                  _selectedIndex = 4;
                });
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => OffersPage()),
                );
              }
            },
          ),

          _buildFooterButton(
            iconPath: 'lib/Assets/footer_icons/schedule.png',
            title: buttonTitles[2],
            isSelected: _selectedIndex == 2,
            onPressed: () async {
              if (widget.title != "Schedule") {
                setState(() {
                  _selectedIndex = 2;
                });

                final storage = SecureStorageService();
                final userDetails = await storage.getUserDetails();

                if (userDetails != null) {
                  var userData = userDetails;
                  if (userData.containsKey('user')) {
                    userData = userData['user'];
                  }

                  int isDoctor = userData['isDoctor'] ?? 0;
                  int isService = userData['isService'] ?? 0;

                  if (isDoctor == 1) {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const DoctorManage()),
                    );
                  } else if (isService == 1) {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const ServiceManage()),
                    );
                  } else {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const DoctorListPage()),
                    );
                  }
                } else {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const DoctorListPage()),
                  );
                }
              }
            },
          ),

          _buildFooterButton(
            iconPath: 'lib/Assets/footer_icons/complaint.png',
            title: buttonTitles[3],
            isSelected: _selectedIndex == 3,
            onPressed: () {
              if (widget.title != "Complaint") {
                setState(() {
                  _selectedIndex = 3;
                });
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => ComplainPage()),
                );
              }
            },
          ),

          _buildFooterIconButton(
            icon: FontAwesomeIcons.solidHeart,
            title: "Favourites",
            isSelected: _selectedIndex == 1,
            onPressed: () {
              if (widget.title != "Favourites") {
                setState(() => _selectedIndex = 1);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const FavouritesPage(),
                  ),
                );
              }
            },
          ),
        ],
      ),
    );
  }

  Widget _buildFooterButton({
    required String iconPath,
    required String title,
    required bool isSelected,
    required VoidCallback onPressed,
  }) {
    final bool isEmergency = title == "Favourites";
    final screenWidth = MediaQuery.of(context).size.width;
    final bool isSmallScreen = screenWidth < 350;

    final double iconSize = isEmergency
        ? (isSmallScreen ? 30 : 45)
        : (isSmallScreen ? 20 : 30);

    final double fontSize = isEmergency
        ? (isSmallScreen ? 7 : 9)
        : (isSmallScreen ? 7 : 10);

    return Expanded(
      child: GestureDetector(
        onTap: onPressed,
        child: Container(
          padding: isEmergency
              ? const EdgeInsets.fromLTRB(10, 1, 10, 15)
              : const EdgeInsets.all(10),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Image.asset(
                iconPath,
                width: iconSize,
                height: iconSize,
                color: isSelected
                    ? (isEmergency ? Colors.red : Colors.deepOrange)
                    : const Color(0xFFA6A2A2),
              ),
              const SizedBox(height: 5),
              Text(
                title,
                style: TextStyle(
                  fontSize: fontSize,
                  fontWeight: FontWeight.bold,
                  color: isSelected
                      ? (isEmergency ? Colors.red : Colors.deepOrange)
                      : const Color(0xFFA6A2A2),
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFooterIconButton({
    required IconData icon,
    required String title,
    required bool isSelected,
    required VoidCallback onPressed,
  }) {
    final bool isSmallScreen = MediaQuery.of(context).size.width < 350;

    return Expanded(
      child: GestureDetector(
        onTap: onPressed,
        child: Container(
          padding: const EdgeInsets.all(10),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              FaIcon(
                icon,
                size: isSmallScreen ? 22 : 28,
                color: isSelected ? Colors.deepOrange : const Color(0xFFA6A2A2),
              ),
              const SizedBox(height: 5),
              Text(
                title,
                style: TextStyle(
                  fontSize: isSmallScreen ? 7 : 10,
                  fontWeight: FontWeight.bold,
                  color: isSelected
                      ? Colors.deepOrange
                      : const Color(0xFFA6A2A2),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
