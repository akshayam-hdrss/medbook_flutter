import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:medbook/components/Footer.dart';
import 'package:medbook/components/common/loading_widget.dart';
import 'package:medbook/pages/ServiceSchedule/ServiceSchedule.dart';
import 'package:medbook/pages/services/service_page3.dart';
import 'package:medbook/utils/api_service.dart';
import 'package:url_launcher/url_launcher.dart';

class ServicesPage2 extends StatefulWidget {
  final String serviceTypeId;

  const ServicesPage2({super.key, required this.serviceTypeId});

  @override
  State<ServicesPage2> createState() => _ServicesPage2State();
}

class _ServicesPage2State extends State<ServicesPage2> {
  List<dynamic>? services;
  List<dynamic>? filteredServices;
  bool isLoading = true;
  String? error;
  final TextEditingController _searchController = TextEditingController();
  String _selectedLocation = 'All Locations';
  List<String> locations = ['All Locations'];

  @override
  void initState() {
    super.initState();
    loadServices();
    _searchController.addListener(_filterServices);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> loadServices() async {
    try {
      final data = await fetchServicesByType(widget.serviceTypeId);
      // Extract unique locations from services
      final uniqueLocations = data
          .map((e) => e['location']?.toString().trim() ?? 'Unknown Location')
          .toSet()
          .toList();

      setState(() {
        services = data;
        filteredServices = data;
        locations = ['All Locations', ...uniqueLocations];
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        error = e.toString();
        isLoading = false;
      });
    }
  }

  void _filterServices() {
    String query = _searchController.text.toLowerCase();
    setState(() {
      filteredServices = services?.where((service) {
        final name = (service['serviceName'] ?? '').toLowerCase();
        final business = (service['businessName'] ?? '').toLowerCase();
        final location = (service['location'] ?? '').toString().trim();

        final matchesSearch =
            query.isEmpty || name.contains(query) || business.contains(query);
        final matchesLocation =
            _selectedLocation == 'All Locations' ||
            location == _selectedLocation;

        return matchesSearch && matchesLocation;
      }).toList();
    });
  }

  Future<void> _makePhoneCall(String phoneNumber) async {
    final Uri uri = Uri(scheme: 'tel', path: phoneNumber);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    } else {
      _showError("Cannot make call.");
    }
  }

  Future<void> _launchWhatsApp(String phoneNumber) async {
    final cleanPhone = phoneNumber.replaceAll(' ', '').replaceAll('+', '');
    final Uri uri = Uri.parse("https://wa.me/$cleanPhone");
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    } else {
      _showError("Cannot open WhatsApp.");
    }
  }

  Future<void> _launchMapLink(String location) async {
    final Uri uri = Uri.parse(
      "https://www.google.com/maps/search/?api=1&query=$location",
    );
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    } else {
      _showError("Cannot open map.");
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6F7FB),
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(kToolbarHeight),
        child: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Color.fromARGB(255, 225, 119, 20),
                Color.fromARGB(255, 239, 48, 34),
              ],
              stops: [0.0, 0.5],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: AppBar(
            title: const Text(
              "HealthCare",
              style: TextStyle(color: Colors.white),
            ),
            centerTitle: true,
            backgroundColor: Colors.transparent,
            elevation: 0,
            iconTheme: const IconThemeData(color: Colors.white),
          ),
        ),
      ),

      body: isLoading
          ? const AppLoadingWidget()
          : error != null
          ? Center(child: Text("Error: $error"))
          : services == null || services!.isEmpty
          ? const Center(child: Text("No services found."))
          : Column(
              children: [
                // Search and Location Filter Bar
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      // Search Bar
                      Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(14),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.orange.withOpacity(0.1),
                              blurRadius: 10,
                              offset: const Offset(0, 3),
                            ),
                          ],
                        ),
                        child: TextField(
                          controller: _searchController,
                          decoration: InputDecoration(
                            hintText: 'Search Healthcare...',
                            hintStyle: TextStyle(
                              color: Colors.grey.shade500,
                              fontSize: 15,
                            ),
                            prefixIcon: const Padding(
                              padding: EdgeInsets.all(14),
                              child: Icon(
                                Icons.search_rounded,
                                color: Color(0xFFF37A20),
                                size: 26,
                              ),
                            ),
                            suffixIcon: _searchController.text.isNotEmpty
                                ? IconButton(
                                    icon: Icon(
                                      Icons.close_rounded,
                                      color: Colors.grey.shade400,
                                    ),
                                    onPressed: () {
                                      _searchController.clear();
                                      _filterServices();
                                      FocusScope.of(context).unfocus();
                                    },
                                  )
                                : null,
                            filled: true,
                            fillColor: Colors.white,
                            contentPadding: const EdgeInsets.symmetric(
                              vertical: 2,
                              horizontal: 18,
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(14),
                              borderSide: BorderSide.none,
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(14),
                              borderSide: BorderSide.none,
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(14),
                              borderSide: BorderSide(
                                color: const Color(0xFFF37A20).withOpacity(0.6),
                                width: 1.8,
                              ),
                            ),
                          ),
                          onChanged: (_) => _filterServices(),
                        ),
                      ),
                      const SizedBox(height: 14),
                      // Location Filter Dropdown
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 14),
                        decoration: BoxDecoration(
                          color: Colors.grey.shade50,
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(
                            color: Colors.grey.shade200,
                            width: 1.5,
                          ),
                        ),
                        child: DropdownButton<String>(
                          value: _selectedLocation,
                          isExpanded: true,
                          underline: const SizedBox(),
                          icon: Icon(
                            Icons.arrow_drop_down_rounded,
                            color: Colors.grey.shade600,
                          ),
                          items: locations.map((location) {
                            return DropdownMenuItem<String>(
                              value: location,
                              child: Padding(
                                padding: const EdgeInsets.symmetric(
                                  vertical: 8,
                                ),
                                child: Text(
                                  location,
                                  style: TextStyle(
                                    fontSize: 15,
                                    color: Colors.grey.shade800,
                                  ),
                                ),
                              ),
                            );
                          }).toList(),
                          onChanged: (value) {
                            setState(() {
                              _selectedLocation = value!;
                              _filterServices();
                            });
                          },
                        ),
                      ),
                    ],
                  ),
                ),

                // Services List
                Expanded(
                  child: filteredServices!.isEmpty
                      ? Padding(
                          padding: const EdgeInsets.only(top: 50),
                          child: Column(
                            children: [
                              Icon(
                                Icons.search_off,
                                size: 60,
                                color: Colors.grey.withOpacity(0.5),
                              ),
                              const SizedBox(height: 16),
                              Text(
                                'No results found',
                                style: TextStyle(
                                  fontSize: 18,
                                  color: Colors.grey.withOpacity(0.7),
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'Try a different search term or location',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.grey.withOpacity(0.5),
                                ),
                              ),
                            ],
                          ),
                        )
                      : ListView.builder(
                          padding: const EdgeInsets.all(16),
                          itemCount: filteredServices!.length,
                          itemBuilder: (context, index) {
                            final service = filteredServices![index];
                            final phone = service['phone'] ?? '';
                            final location = service['location'] ?? '';
                            final imageUrl = service['imageUrl'] ?? '';
                            final name = service['serviceName'] ?? 'N/A';
                            final businessName = service['businessName'] ?? '';
                            final rating = service['rating'] ?? '0.0';
                            final serviceId = service['id'].toString();

                            return GestureDetector(
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) =>
                                        ServicesPage3(serviceId: serviceId),
                                  ),
                                );
                              },
                              child: Container(
                                margin: const EdgeInsets.only(bottom: 20),
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(16),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.05),
                                      blurRadius: 8,
                                      offset: const Offset(0, 4),
                                    ),
                                  ],
                                ),
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    ClipRRect(
                                      borderRadius: BorderRadius.circular(12),
                                      child: Image.network(
                                        imageUrl.isNotEmpty ? imageUrl : "",
                                        height: 140,
                                        width: 120,
                                        fit: BoxFit.cover,
                                        errorBuilder: (context, error, stackTrace) {
                                          return Image.asset(
                                            'lib/Assets/images/product_page2/dummy.jpg',
                                            height: 140,
                                            width: 120,
                                            fit: BoxFit.cover,
                                          );
                                        },
                                      ),
                                    ),

                                    const SizedBox(width: 16),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            name,
                                            style: const TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                          const SizedBox(height: 4),
                                          Text(
                                            businessName,
                                            style: const TextStyle(
                                              fontSize: 14,
                                              fontWeight: FontWeight.w500,
                                            ),
                                          ),
                                          const SizedBox(height: 4),
                                          Text(
                                            location,
                                            style: const TextStyle(
                                              fontSize: 13,
                                              color: Colors.grey,
                                            ),
                                          ),
                                          const SizedBox(height: 8),
                                          Row(
                                            children: [
                                              ..._buildStarIcons(
                                                double.tryParse(rating) ?? 0.0,
                                              ),
                                              const SizedBox(width: 4),
                                              Text(
                                                rating,
                                                style: const TextStyle(
                                                  fontSize: 13,
                                                  fontWeight: FontWeight.w500,
                                                ),
                                              ),
                                            ],
                                          ),
                                          const SizedBox(height: 10),
                                          Row(
                                            children: [
                                              GestureDetector(
                                                onTap: () =>
                                                    _makePhoneCall(phone),
                                                child: _actionButton(
                                                  FontAwesomeIcons.phone,
                                                  Colors.lightBlueAccent,
                                                ),
                                              ),
                                              const SizedBox(width: 12),
                                              GestureDetector(
                                                onTap: () =>
                                                    _launchWhatsApp(phone),
                                                child: _actionButton(
                                                  FontAwesomeIcons.whatsapp,
                                                  Colors.green,
                                                ),
                                              ),
                                              const SizedBox(width: 12),
                                              _actionIcon(
                                                () => _launchMapLink(location),
                                                FontAwesomeIcons.mapMarkerAlt,
                                                const Color(0xFFFF5722),
                                              ),
                                            ],
                                          ),
                                          const SizedBox(height: 12),
                  SizedBox(
                    width: 160,
                    height: 45,
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => ServiceSchedule(
                              serviceName: name,
                              serviceId: serviceId,
                              servicePhone: phone,
                            ),
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color.fromARGB(255, 234, 29, 29),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 10,
                        ),
                      ),
                      child: const Text(
                        "Book Now",
                        style: TextStyle(fontSize: 14, color: Colors.white),
                      ),
                    ),
                  ),
                
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                ),
              ],
            ),
      bottomNavigationBar: const Footer(title: "none"),
    );
  }

  Widget _actionButton(IconData icon, Color color) {
    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Center(child: FaIcon(icon, color: Colors.white, size: 18)),
    );
  }

  List<Widget> _buildStarIcons(double rating) {
    List<Widget> stars = [];
    for (int i = 1; i <= 5; i++) {
      if (i <= rating) {
        stars.add(const Icon(Icons.star, color: Colors.amber, size: 16));
      } else if (i - rating <= 0.5) {
        stars.add(const Icon(Icons.star_half, color: Colors.amber, size: 16));
      } else {
        stars.add(const Icon(Icons.star_border, color: Colors.amber, size: 16));
      }
    }
    return stars;
  }
}

Widget _actionIcon(VoidCallback onTap, IconData icon, Color color) {
  return GestureDetector(
    onTap: onTap,
    child: Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Center(child: FaIcon(icon, color: Colors.white, size: 18)),
    ),
  );
}
