import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:medbook/components/Footer.dart';
import 'package:medbook/components/common/loading_widget.dart';
import 'package:medbook/components/videoCarousel.dart';
import 'package:medbook/pages/DoctorSchedule/DoctorSchedule.dart';
import 'dart:convert';
import 'package:medbook/pages/Hospitals/HospitalPage4.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:medbook/Services/secure_storage_service.dart';

class Traditional3 extends StatefulWidget {
  final String traditionalTypeId;
  final String traditionalId;
  final String? district;
  final String? area;

  const Traditional3({
    super.key,
    required this.traditionalTypeId,
    required this.traditionalId,
    this.district,
    this.area,
  });

  @override
  State<Traditional3> createState() => _Traditional3State();
}

class _Traditional3State extends State<Traditional3> {
  late Future<List<Map<String, dynamic>>> _doctorsFuture;
  late Future<Map<String, dynamic>> _adsFuture;
  List<Map<String, dynamic>> _allDoctors = [];
  List<Map<String, dynamic>> _filteredDoctors = [];
  final TextEditingController _searchController = TextEditingController();
  String _selectedSpeciality = 'All';

  // ⭐ Favourite system
  Map<String, bool> favouriteStatus = {};
  Map<String, int?> favouriteIds = {};
  String? _userId;

  @override
  void initState() {
    super.initState();
    _initializeData();
    _doctorsFuture = fetchDoctors(widget.traditionalId).then((doctors) {
      setState(() {
        _allDoctors = doctors;
        _filteredDoctors = doctors;
      });
      return doctors;
    });
    _adsFuture = fetchTraditionalAds();
  }

  // ⭐ Initialize all data
  Future<void> _initializeData() async {
    await _loadUserId();
    await loadFavourites();
  }

  // ⭐ Load user ID from secure storage
  Future<void> _loadUserId() async {
    final storage = SecureStorageService();
    final user = await storage.getUserDetails();
    _userId = user?["id"]?.toString();
  }

  // ⭐ Fetch favourite doctors - USING SPECIFIC USER ID ENDPOINT
  Future<void> loadFavourites() async {
    if (_userId == null) return;

    try {
      // ✅ CORRECT ENDPOINT: Use userfavorites/favorites/userId to get favorites for specific user
      final url = Uri.parse(
        "https://medbook-backend-1.onrender.com/api/userfavorites/favorites/$_userId",
      );
      final res = await http.get(url);

      if (res.statusCode != 200) {
        print("Failed to load favorites: ${res.statusCode}");
        return;
      }

      final List data = jsonDecode(res.body);

      favouriteStatus.clear();
      favouriteIds.clear();

      for (var fav in data) {
        // Since we're fetching for specific user, all favorites belong to this user
        final doctorId = fav["doctorId"]?.toString();
        if (doctorId != null) {
          favouriteStatus[doctorId] = true;
          favouriteIds[doctorId] = fav["id"];
        }
      }

      if (mounted) {
        setState(() {});
      }
    } catch (e) {
      print("Favourite load error: $e");
    }
  }

  // ⭐ Add favourite - USING CORRECT ENDPOINT
  Future<void> addFavourite(String doctorId) async {
    if (_userId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please login to add favourites")),
      );
      return;
    }

    // Optimistic UI update
    favouriteStatus[doctorId] = true;
    if (mounted) setState(() {});

    try {
      // ✅ CORRECT ENDPOINT for adding favorites
      final url = Uri.parse(
        "https://medbook-backend-1.onrender.com/api/userfavorites/favorites/",
      );
      final body = jsonEncode({"doctorId": doctorId, "userId": _userId});

      final res = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: body,
      );

      if (res.statusCode == 200 || res.statusCode == 201) {
        final saved = jsonDecode(res.body);
        favouriteIds[doctorId] = saved["id"];

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Added to favourites"),
            duration: Duration(seconds: 2),
          ),
        );
      } else {
        // Revert on error
        favouriteStatus[doctorId] = false;
        if (mounted) setState(() {});

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Failed to add to favourites"),
            backgroundColor: Colors.orange,
          ),
        );
      }
    } catch (e) {
      // Revert on error
      favouriteStatus[doctorId] = false;
      if (mounted) setState(() {});

      print("Add favourite error: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Error: ${e.toString()}"),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  // ⭐ Remove favourite - USING CORRECT ENDPOINT
  Future<void> removeFavourite(String doctorId) async {
    final favId = favouriteIds[doctorId];
    if (favId == null) return;

    // Optimistic UI update
    favouriteStatus[doctorId] = false;
    if (mounted) setState(() {});

    try {
      // ✅ CORRECT ENDPOINT for removing favorites
      final url = Uri.parse(
        "https://medbook-backend-1.onrender.com/api/userfavorites/favorites/$favId",
      );

      final res = await http.delete(url);

      if (res.statusCode == 200) {
        favouriteIds[doctorId] = null;

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Removed from favourites"),
            duration: Duration(seconds: 2),
          ),
        );
      } else {
        // Revert on error
        favouriteStatus[doctorId] = true;
        if (mounted) setState(() {});

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Failed to remove from favourites"),
            backgroundColor: Colors.orange,
          ),
        );
      }
    } catch (e) {
      // Revert on error
      favouriteStatus[doctorId] = true;
      if (mounted) setState(() {});

      print("Remove favourite error: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Error: ${e.toString()}"),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<List<Map<String, dynamic>>> fetchDoctors(String id) async {
    final storage = SecureStorageService();
    final selectedArea = await storage.getSelectedArea() ?? '';
    final selectedDistrict = await storage.getSelectedDistrict() ?? '';

    final url =
        'https://medbook-backend-1.onrender.com/api/doctor?traditionalId=$id&location=$selectedArea&district=$selectedDistrict';
    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final List<dynamic> doctorList = data['resultData'];

      // ✅ Map with order_no included
      final doctors = doctorList.map<Map<String, dynamic>>((item) {
        return {
          'id': item['id'],
          'name': item['doctorName'] ?? 'N/A',
          'imageUrl': item['imageUrl'] ?? '',
          'speciality': item['speciality'] ?? '',
          'designation': item['designation'] ?? '',
          'phone': item['phone'] ?? '',
          'degree': item['degree'] ?? '',
          'rating': item['rating'] ?? '0.0',
          'order_no': item['order_no'], // ✅ Add order_no
        };
      }).toList();

      // ✅ Sort by order_no (nulls go last)
      doctors.sort((a, b) {
        final orderA = a['order_no'];
        final orderB = b['order_no'];

        if (orderA == null && orderB == null) return 0;
        if (orderA == null) return 1; // null goes last
        if (orderB == null) return -1;

        return orderA.compareTo(orderB);
      });

      return doctors;
    } else {
      throw Exception('Failed to load doctors');
    }
  }

  void _filterDoctors() {
    String query = _searchController.text.toLowerCase();
    setState(() {
      _filteredDoctors = _allDoctors.where((doctor) {
        final name = (doctor['name'] ?? '').toLowerCase();
        final speciality = (doctor['speciality'] ?? '').toLowerCase();

        final matchesSearch = query.isEmpty || name.contains(query);
        final matchesSpeciality =
            _selectedSpeciality == 'All' ||
            speciality == _selectedSpeciality.toLowerCase();

        return matchesSearch && matchesSpeciality;
      }).toList();
    });
  }

  Future<Map<String, dynamic>> fetchTraditionalAds() async {
    try {
      final response = await http.get(
        Uri.parse(
          'https://medbook-backend-1.onrender.com/api/ads/gallery/traditional?typeId=${widget.traditionalTypeId}&itemId=${widget.traditionalId}',
        ),
      );
      final data = json.decode(response.body);
      if (data['result'] == 'Success' && data['resultData'].isNotEmpty) {
        return data;
      }
      return {'youtubeLinks': []};
    } catch (e) {
      return {'youtubeLinks': []};
    }
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

  // ⭐ Refresh favourites
  Future<void> _refreshFavourites() async {
    await loadFavourites();
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
              colors: [Color(0xFFE17714), Color(0xFFEF3022)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: AppBar(
            title: const Text(
              "Expert Practitioners",
              style: TextStyle(color: Colors.white),
            ),
            centerTitle: true,
            backgroundColor: Colors.transparent,
            elevation: 0,
            iconTheme: const IconThemeData(color: Colors.white),
            actions: [
              IconButton(
                icon: const Icon(Icons.favorite),
                onPressed: _refreshFavourites,
                tooltip: "Refresh favourites",
              ),
            ],
          ),
        ),
      ),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: _doctorsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const AppLoadingWidget();
          } else if (snapshot.hasError) {
            return const Center(child: Text("Error loading doctors"));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text("No doctors available"));
          }

          final specialities = [
            'All',
            ...{
              ..._allDoctors.map(
                (e) => (e['speciality'] ?? '').toString().trim(),
              ),
            }.where((e) => e.isNotEmpty),
          ];

          return Column(
            children: [
              // Search and Filter UI
              Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  children: [
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
                          hintText: 'Search by name',
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
                                    _filterDoctors();
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
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.grey.shade800,
                        ),
                        onChanged: (value) => _filterDoctors(),
                      ),
                    ),
                    const SizedBox(height: 14),
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
                        value: _selectedSpeciality,
                        isExpanded: true,
                        underline: const SizedBox(),
                        icon: Icon(
                          Icons.arrow_drop_down_rounded,
                          color: Colors.grey.shade600,
                        ),
                        items: specialities.map((speciality) {
                          return DropdownMenuItem<String>(
                            value: speciality,
                            child: Padding(
                              padding: const EdgeInsets.symmetric(vertical: 8),
                              child: Text(
                                speciality,
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
                            _selectedSpeciality = value!;
                            _filterDoctors();
                          });
                        },
                      ),
                    ),
                  ],
                ),
              ),

              // Show "No results found" if filtered list is empty
              if (_filteredDoctors.isEmpty)
                Expanded(
                  child: Padding(
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
                          'Try a different search term or speciality',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey.withOpacity(0.5),
                          ),
                        ),
                      ],
                    ),
                  ),
                )
              else
                Expanded(
                  child: ListView(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    children: [
                      // Group doctors by speciality
                      ..._buildCategorizedDoctors(),
                      const SizedBox(height: 20),

                      // Video Carousel
                      FutureBuilder<Map<String, dynamic>>(
                        future: _adsFuture,
                        builder: (context, adsSnapshot) {
                          if (adsSnapshot.connectionState ==
                              ConnectionState.waiting) {
                            return const AppLoadingWidget();
                          } else if (adsSnapshot.hasError ||
                              !adsSnapshot.hasData) {
                            return const SizedBox(); // Show nothing if error
                          }

                          final youtubeLinks =
                              adsSnapshot
                                  .data!['resultData'][0]['youtubeLinks'] ??
                              [];
                          if (youtubeLinks.isEmpty) return const SizedBox();

                          return VideoCarousel(
                            videoUrls: List<String>.from(youtubeLinks),
                          );
                        },
                      ),
                      const SizedBox(height: 20),
                    ],
                  ),
                ),
            ],
          );
        },
      ),
      bottomNavigationBar: const Footer(title: "none"),
    );
  }

  List<Widget> _buildCategorizedDoctors() {
    final Map<String, List<Map<String, dynamic>>> categorizedDoctors = {};

    for (var doc in _filteredDoctors) {
      String speciality = doc['speciality']?.trim() ?? 'Others';
      if (speciality.isEmpty) speciality = 'Others';
      categorizedDoctors.putIfAbsent(speciality, () => []).add(doc);
    }

    return categorizedDoctors.entries.map((entry) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            entry.key,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.redAccent,
            ),
          ),
          const SizedBox(height: 8),
          ...entry.value.map((doctor) => _buildDoctorCard(doctor)),
          const SizedBox(height: 24),
        ],
      );
    }).toList();
  }

  Widget _buildDoctorCard(Map<String, dynamic> doctor) {
    final phone = doctor['phone'] ?? '';
    final location = doctor['location'] ?? '';
    final imageUrl = doctor['imageUrl'] ?? '';
    final doctorName = doctor['name'] ?? '';
    final doctorId = doctor['id'].toString();
    final rating = doctor['rating'] ?? '4.5';
    final degree = doctor['degree'] ?? '';
    final designation = doctor['designation'] ?? '';
    final isFav = favouriteStatus[doctorId] == true;

    return Stack(
      children: [
        GestureDetector(
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => HospitalPage4(doctorId: doctorId),
            ),
          ),
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
                Column(
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
                            'lib/Assets/icons/doctor.png',
                            height: 140,
                            width: 120,
                            fit: BoxFit.cover,
                          );
                        },
                      ),
                    ),

                    const SizedBox(height: 8),
                    Row(
                      children: [
                        ..._buildStarIcons(double.tryParse(rating) ?? 0.0),
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
                  ],
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        doctorName,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        degree,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        designation,
                        style: const TextStyle(
                          fontSize: 13,
                          color: Colors.grey,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          GestureDetector(
                            onTap: () => _makePhoneCall(phone),
                            child: _actionButton(
                              FontAwesomeIcons.phone,
                              Colors.lightBlueAccent,
                            ),
                          ),
                          const SizedBox(width: 12),
                          GestureDetector(
                            onTap: () => _launchWhatsApp(phone),
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
                          onPressed: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => DoctorSchedule(
                                doctorName: doctorName,
                                doctorId: doctorId,
                                doctorNo: phone,
                              ),
                            ),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color.fromARGB(
                              255,
                              234,
                              29,
                              29,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
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
        ),

        // ❤️ Favourite button
        Positioned(
          right: 10,
          top: 10,
          child: StatefulBuilder(
            builder: (context, refresh) {
              return GestureDetector(
                onTap: () async {
                  if (isFav) {
                    await removeFavourite(doctorId);
                  } else {
                    await addFavourite(doctorId);
                  }
                  // Force UI refresh
                  if (mounted) {
                    refresh(() {});
                    setState(() {});
                  }
                },
                child: Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Icon(
                    isFav ? Icons.favorite : Icons.favorite_border,
                    color: isFav ? Colors.red : Colors.grey,
                    size: 24,
                  ),
                ),
              );
            },
          ),
        ),
      ],
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
