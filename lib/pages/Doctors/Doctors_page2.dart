import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:medbook/components/Footer.dart';
import 'package:medbook/components/common/loading_widget.dart';
import 'dart:convert';
import 'package:medbook/pages/Hospitals/HospitalPage4.dart';
import 'package:medbook/Services/secure_storage_service.dart';

class DoctorsPage2 extends StatefulWidget {
  final String doctorTypeId;
  final String? selectedDistrict;
  final String? selectedArea;

  const DoctorsPage2({
    super.key,
    required this.doctorTypeId,
    this.selectedDistrict,
    this.selectedArea,
  });

  @override
  State<DoctorsPage2> createState() => _DoctorsPage2State();
}

class _DoctorsPage2State extends State<DoctorsPage2> {
  // Make _doctors nullable to handle initialization properly
  Future<List<Map<String, dynamic>>>? _doctors;

  final TextEditingController _searchController = TextEditingController();
  List<Map<String, dynamic>> _filteredDoctors = [];
  List<Map<String, dynamic>> _allDoctors = [];
  String _selectedArea = 'All Areas';
  List<String> _availableAreas = ['All Areas'];

  // ⭐ Favourite system
  Map<String, bool> favouriteStatus = {};
  Map<String, int?> favouriteIds = {};
  String? _userId;

  @override
  void initState() {
    super.initState();
    _initializeData();
  }

  // ⭐ Initialize all data
  Future<void> _initializeData() async {
    await _loadUserId();
    await loadFavourites();

    // Initialize _doctors future
    _doctors = _fetchAndProcessDoctors();
  }

  // ⭐ Load user ID from secure storage
  Future<void> _loadUserId() async {
    final storage = SecureStorageService();
    final user = await storage.getUserDetails();
    _userId = user?["id"]?.toString();
  }

  // ⭐ Fetch and process doctors
  Future<List<Map<String, dynamic>>> _fetchAndProcessDoctors() async {
    try {
      final doctors = await fetchDoctors(widget.doctorTypeId);

      if (mounted) {
        setState(() {
          _allDoctors = List.from(doctors);
          _filteredDoctors = List.from(_allDoctors);

          // Extract areas
          final areas =
              doctors
                  .map((doc) => doc['location']?.toString().trim())
                  .where(
                    (loc) =>
                        loc != null &&
                        loc.isNotEmpty &&
                        loc.toLowerCase() != 'unknown',
                  )
                  .toSet()
                  .toList()
                ..sort();

          _availableAreas = ['All Areas', ...areas.cast<String>()];
        });
      }

      return doctors;
    } catch (e) {
      print("Error fetching doctors: $e");
      rethrow;
    }
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

  // ⭐ Add favourite
  Future<void> addFavourite(String doctorId) async {
    if (_userId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please login to add favourites")),
      );
      return;
    }

    // Optimistic UI update
    favouriteStatus[doctorId] = true;
    setState(() {});

    try {
      final url = Uri.parse(
        "https://medbook-backend-1.onrender.com/api/userfavorites/favorites",
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

        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text("Added to favourites")));
      } else {
        // Revert on error
        favouriteStatus[doctorId] = false;
        setState(() {});
      }
    } catch (e) {
      // Revert on error
      favouriteStatus[doctorId] = false;
      setState(() {});
    }
  }

  // ⭐ Remove favourite
  Future<void> removeFavourite(String doctorId) async {
    final favId = favouriteIds[doctorId];
    if (favId == null) return;

    // Optimistic UI update
    favouriteStatus[doctorId] = false;
    setState(() {});

    try {
      final url = Uri.parse(
        "https://medbook-backend-1.onrender.com/api/userfavorites/favorites/$favId",
      );

      final res = await http.delete(url);

      if (res.statusCode == 200) {
        favouriteIds[doctorId] = null;

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Removed from favourites")),
        );
      } else {
        // Revert on error
        favouriteStatus[doctorId] = true;
        setState(() {});
      }
    } catch (e) {
      // Revert on error
      favouriteStatus[doctorId] = true;
      setState(() {});
    }
  }

  // ⭐ Fetch doctors list
  Future<List<Map<String, dynamic>>> fetchDoctors(String id) async {
    final storage = SecureStorageService();
    final selectedArea = await storage.getSelectedArea() ?? '';
    final selectedDistrict = await storage.getSelectedDistrict() ?? '';

    final url =
        'https://medbook-backend-1.onrender.com/api/doctor?doctorTypeId=$id&location=$selectedArea&district=$selectedDistrict';

    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final List<dynamic> doctorList = data['resultData'];

      doctorList.sort((a, b) {
        final aOrder = a['order_no'];
        final bOrder = b['order_no'];

        if (aOrder == null && bOrder == null) return 0;
        if (aOrder == null) return 1;
        if (bOrder == null) return -1;

        return (aOrder as int).compareTo(bOrder as int);
      });

      return doctorList.map<Map<String, dynamic>>((item) {
        return {
          'id': item['id'],
          'name': item['doctorName'] ?? 'N/A',
          'imageUrl': item['imageUrl'] ?? '',
          'speciality': item['speciality'] ?? '',
          'location': item['location'] ?? 'Unknown',
          'phone': item['phone'] ?? '',
          'degree': item['degree'] ?? '',
          'rating': item['rating'] ?? '0.0',
          'businessName': item['businessName'] ?? '',
          'designation': item['designation'] ?? '',
        };
      }).toList();
    } else {
      throw Exception('Failed to load doctors');
    }
  }

  // ⭐ Search filter
  void _filterDoctors() {
    setState(() {
      final query = _searchController.text.toLowerCase();

      _filteredDoctors = _allDoctors.where((doctor) {
        final nameMatch =
            query.isEmpty ||
            (doctor['name']?.toLowerCase().contains(query) ?? false) ||
            (doctor['speciality']?.toLowerCase().contains(query) ?? false) ||
            (doctor['businessName']?.toLowerCase().contains(query) ?? false);

        final areaMatch =
            _selectedArea == 'All Areas' ||
            (doctor['location']?.toLowerCase() == _selectedArea.toLowerCase());

        return nameMatch && areaMatch;
      }).toList();
    });
  }

  // ⭐ UI Building
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
              "Expert Practitioners",
              style: TextStyle(color: Colors.white),
            ),
            centerTitle: true,
            backgroundColor: Colors.transparent,
            elevation: 0,
            iconTheme: const IconThemeData(color: Colors.white),
          ),
        ),
      ),

      // BODY
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: _doctors,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const AppLoadingWidget();
          } else if (snapshot.hasError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text("Error loading doctors"),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: () {
                      setState(() {
                        _doctors = _fetchAndProcessDoctors();
                      });
                    },
                    child: const Text("Retry"),
                  ),
                ],
              ),
            );
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text("No doctors available"));
          }

          return Column(
            children: [
              _buildSearchAndFilter(),
              Expanded(
                child: _filteredDoctors.isEmpty
                    ? const Center(child: Text("No doctors match your search"))
                    : ListView(
                        padding: const EdgeInsets.all(16),
                        children: _filteredDoctors
                            .map((doctor) => _buildDoctorCard(doctor))
                            .toList(),
                      ),
              ),
            ],
          );
        },
      ),

      bottomNavigationBar: const Footer(title: "none"),
    );
  }

  // ⭐ Search + Filter UI
  Widget _buildSearchAndFilter() {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          // SEARCH BOX
          TextField(
            controller: _searchController,
            decoration: InputDecoration(
              hintText: 'Search doctor',
              prefixIcon: const Icon(Icons.search, color: Colors.orange),
              suffixIcon: _searchController.text.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () {
                        _searchController.clear();
                        _filterDoctors();
                      },
                    )
                  : null,
              filled: true,
              fillColor: Colors.white,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: BorderSide.none,
              ),
            ),
            onChanged: (value) => _filterDoctors(),
          ),
          const SizedBox(height: 14),

          // AREA FILTER
          DropdownButton<String>(
            value: _selectedArea,
            isExpanded: true,
            underline: const SizedBox(),
            items: _availableAreas.map((area) {
              return DropdownMenuItem<String>(value: area, child: Text(area));
            }).toList(),
            onChanged: (value) {
              setState(() {
                _selectedArea = value!;
              });
              _filterDoctors();
            },
          ),
        ],
      ),
    );
  }

  // ⭐ Doctor Card with Favourite
  Widget _buildDoctorCard(Map<String, dynamic> doctor) {
    final doctorId = doctor['id'].toString();
    final isFav = favouriteStatus[doctorId] == true;

    return Stack(
      children: [
        GestureDetector(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => HospitalPage4(doctorId: doctorId),
              ),
            );
          },
          child: _doctorCardUI(doctor),
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
                  refresh(() {});
                },
                child: Container(
                  padding: const EdgeInsets.all(4),
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

  // ⭐ Doctor Card UI Content
  Widget _doctorCardUI(Map<String, dynamic> doctor) {
    final imageUrl = doctor['imageUrl'] ?? '';
    final name = doctor['name'] ?? '';
    final rating = doctor['rating'] ?? '0.0';
    final location = doctor['location'] ?? '';
    final degree = doctor['degree'] ?? '';
    final businessName = doctor['businessName'] ?? '';
    final speciality = doctor['speciality'] ?? '';

    return Container(
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
        children: [
          // IMAGE
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Image.network(
              imageUrl,
              height: 130,
              width: 110,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => Image.asset(
                'lib/Assets/icons/doctor.png',
                height: 130,
                width: 110,
                fit: BoxFit.cover,
              ),
              loadingBuilder: (context, child, loadingProgress) {
                if (loadingProgress == null) return child;
                return Container(
                  height: 130,
                  width: 110,
                  color: Colors.grey[200],
                  child: const Center(child: AppLoadingWidget()),
                );
              },
            ),
          ),

          const SizedBox(width: 16),

          // DETAILS
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                if (degree.isNotEmpty)
                  Text(
                    degree,
                    style: const TextStyle(fontSize: 14),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                if (speciality.isNotEmpty)
                  Text(
                    speciality,
                    style: const TextStyle(fontSize: 14),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                if (businessName.isNotEmpty)
                  Text(
                    businessName,
                    style: const TextStyle(fontSize: 14),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    const Icon(Icons.location_on, color: Colors.grey, size: 16),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        location,
                        style: const TextStyle(
                          color: Colors.grey,
                          fontSize: 13,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    const Icon(Icons.star, color: Colors.amber, size: 16),
                    const SizedBox(width: 4),
                    Text(
                      rating,
                      style: const TextStyle(fontWeight: FontWeight.w500),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
