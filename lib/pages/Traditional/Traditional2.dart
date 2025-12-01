import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:medbook/components/common/loading_widget.dart';
import 'package:medbook/utils/api_service.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:medbook/pages/Traditional/Traditional3.dart';

class Traditional2 extends StatefulWidget {
  final String traditionalTypeId;
  final String? district;
  final String? area;

  const Traditional2({super.key, required this.traditionalTypeId,this.district, this.area});

  @override
  _Traditional2State createState() => _Traditional2State();
}

class _Traditional2State extends State<Traditional2> {
  late Future<List<dynamic>> _treatmentsFuture;
  List<dynamic> _allTreatments = [];
  List<dynamic> _filteredTreatments = [];

  final TextEditingController _searchController = TextEditingController();
  String _selectedLocation = '';
  bool _isLoading = false;

  @override


@override
void initState() {
  super.initState();

  // Use passed area if available, otherwise 'All'
  _selectedLocation = widget.area ?? 'All';

  print('📍 Received District: ${widget.district}');
  print('📍 Received Area: ${widget.area}');

  _treatmentsFuture = ApiServicetraditional.fetchTraditionalByTypeId(
    widget.traditionalTypeId,
  ).then((data) {
    setState(() {
      _allTreatments = data;

      // Ensure _selectedLocation exists in the filtered list
      _filteredTreatments = _allTreatments.where((item) {
        final area = (item['area'] ?? '').toLowerCase();
        final filterArea = _selectedLocation.toLowerCase();
        return filterArea == 'all' || area == filterArea;
      }).toList();
    });
    return data;
  });
}


 void _filterTreatments() {
  String query = _searchController.text.toLowerCase();
  final filterArea = _selectedLocation.toLowerCase();

  setState(() {
    _filteredTreatments = _allTreatments.where((item) {
      final name = (item['name'] ?? '').toLowerCase();
      final area = (item['area'] ?? '').toLowerCase();

      final matchesSearch = query.isEmpty || name.contains(query);
      final matchesLocation = filterArea == 'all' || area == filterArea;

      return matchesSearch && matchesLocation;
    }).toList();
  });
}

  void _launchCaller(String phoneNumber) async {
    final uri = Uri(scheme: 'tel', path: phoneNumber);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    }
  }

  void _launchWhatsApp(String phoneNumber) async {
    final uri = Uri.parse(
      "https://wa.me/${phoneNumber.replaceAll('+', '').replaceAll(' ', '')}",
    );
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    }
  }

  void _launchMapLink(String mapUrl) async {
    final uri = Uri.parse(mapUrl);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
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

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Scaffold(
          appBar: PreferredSize(
            preferredSize: const Size.fromHeight(kToolbarHeight),
            child: Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Color.fromARGB(255, 225, 119, 20),
                    Color.fromARGB(255, 239, 48, 34),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: AppBar(
                title: const Text(
                  'Treatment Centers',
                  style: TextStyle(color: Colors.white),
                ),
                centerTitle: true,
                leading: IconButton(
                  icon: const Icon(Icons.arrow_back, color: Colors.white),
                  onPressed: () => Navigator.pop(context),
                ),
                backgroundColor: Colors.transparent,
                elevation: 0,
              ),
            ),
          ),
          body: FutureBuilder<List<dynamic>>(
            future: _treatmentsFuture,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const AppLoadingWidget(); // Loader handled by overlay
              } else if (snapshot.hasError) {
                return Center(child: Text('Error: ${snapshot.error}'));
              } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                return const Center(child: Text('No treatment centers found'));
              }

              final locations = [
  'All',
  ...{
    ..._allTreatments.map(
      (e) => (e['area'] ?? '').toString().trim(),
    ),
  }.where((e) => e.isNotEmpty),
];

// Make sure selected value exists in the items
if (!locations.contains(_selectedLocation)) {
  locations.insert(1, _selectedLocation); // insert after 'All'
}

              return SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    children: [
                      // ✅ Search and Location Filter
                      Padding(
                        padding: const EdgeInsets.only(bottom: 16),
                        child: Column(
                          children: [
                            // Search Box
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
                                            _filterTreatments();
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
                                      color: const Color(
                                        0xFFF37A20,
                                      ).withOpacity(0.6),
                                      width: 1.8,
                                    ),
                                  ),
                                ),
                                style: TextStyle(
                                  fontSize: 16,
                                  color: Colors.grey.shade800,
                                ),
                                onChanged: (value) => _filterTreatments(),
                              ),
                            ),
                            const SizedBox(height: 14),

                            // Location Dropdown
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 14,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.grey.shade50,
                                borderRadius: BorderRadius.circular(14),
                                border: Border.all(
                                  color: Colors.grey.shade200,
                                  width: 1.5,
                                ),
                              ),
                              child: DropdownButton<String>(
                              value: locations.contains(_selectedLocation) ? _selectedLocation : 'All',
                              isExpanded: true,
                              underline: const SizedBox(),
                              icon: Icon(Icons.arrow_drop_down_rounded, color: Colors.grey.shade600),
                              items: locations.map((location) {
                                return DropdownMenuItem<String>(
                                  value: location,
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(vertical: 8),
                                    child: Text(
                                      location,
                                      style: TextStyle(fontSize: 15, color: Colors.grey.shade800),
                                    ),
                                  ),
                                );
                              }).toList(),
                              onChanged: (value) {
                                setState(() {
                                  _selectedLocation = value!;
                                  _filterTreatments();
                                });
                              },
                            )

                            ),
                          ],
                        ),
                      ),

                      // ✅ Show "No results" message
                      if (_filteredTreatments.isEmpty)
                        Padding(
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
                                'No Hospitals found in $_selectedLocation',
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
                      else
                        LayoutBuilder(
                          builder: (context, constraints) {
                            final isTablet = constraints.maxWidth >= 600;
                            final itemWidth = isTablet
                                ? (constraints.maxWidth / 2) - 16
                                : constraints.maxWidth;

                            return Wrap(
                              spacing: 16,
                              runSpacing: 16,
                              children: List.generate(
                                _filteredTreatments.length,
                                (index) {
                                  final item = _filteredTreatments[index];
                                  final imageUrl = item['imageUrl'] ?? '';
                                  final phone = item['phone'] ?? '';
                                  final mapLink = item['mapLink'] ?? '';
                                  final id = item['id'] ?? '';

                                  return GestureDetector(
                                    onTap: () async {
                                      setState(() => _isLoading = true);
                                      await Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) => Traditional3(
                                            traditionalTypeId:
                                                widget.traditionalTypeId,
                                            traditionalId: id.toString(),
                                             district: widget.district, // pass district
                                             area: widget.area,         // pass area
                                          ),
                                        ),
                                      );
                                      setState(() => _isLoading = false);
                                    },
                                    child: Container(
                                      width: itemWidth,
                                      padding: const EdgeInsets.all(12),
                                      decoration: BoxDecoration(
                                        color: Colors.white,
                                        borderRadius: BorderRadius.circular(16),
                                        boxShadow: [
                                          BoxShadow(
                                            color: Colors.black.withOpacity(
                                              0.05,
                                            ),
                                            blurRadius: 8,
                                            offset: const Offset(0, 4),
                                          ),
                                        ],
                                      ),
                                      child: Row(
                                        children: [
                                          Container(
                                            width: 100,
                                            height: 100,
                                            decoration: BoxDecoration(
                                              color: Colors.grey.shade200,
                                              image: DecorationImage(
                                                fit: BoxFit.cover,
                                                image: imageUrl.isNotEmpty
                                                    ? NetworkImage(imageUrl)
                                                    : const AssetImage(
                                                            'lib/Assets/images/medbook_logo.png',
                                                          )
                                                          as ImageProvider,
                                              ),
                                            ),
                                          ),
                                          const SizedBox(width: 16),
                                          Expanded(
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  item['name'] ?? 'No Name',
                                                  style: const TextStyle(
                                                    fontSize: 16,
                                                    fontWeight: FontWeight.w600,
                                                  ),
                                                ),
                                                const SizedBox(height: 4),
                                                Text(
                                                  item['area'] ?? '',
                                                  style: const TextStyle(
                                                    fontSize: 13,
                                                  ),
                                                ),
                                                const SizedBox(height: 10),
                                                Row(
                                                  children: [
                                                    _actionIcon(
                                                      () =>
                                                          _launchCaller(phone),
                                                      FontAwesomeIcons.phone,
                                                      Colors.blue,
                                                    ),
                                                    const SizedBox(width: 8),
                                                    _actionIcon(
                                                      () => _launchWhatsApp(
                                                        phone,
                                                      ),
                                                      FontAwesomeIcons.whatsapp,
                                                      Colors.green,
                                                    ),
                                                    const SizedBox(width: 8),
                                                    _actionIcon(
                                                      () => _launchMapLink(
                                                        mapLink,
                                                      ),
                                                      FontAwesomeIcons
                                                          .mapMarkerAlt,
                                                      const Color(0xFFFF5722),
                                                    ),
                                                  ],
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
                            );
                          },
                        ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),

        // ✅ Loader Overlay
        if (_isLoading) const Positioned.fill(child: AppLoadingWidget()),
      ],
    );
  }
}
