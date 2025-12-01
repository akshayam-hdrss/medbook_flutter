import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:medbook/components/Events/EventsPage1.dart';
import 'package:medbook/components/ImageCarousel1.dart';
import 'package:medbook/components/Location/LocationDropdown.dart';
import 'package:medbook/components/common/loading_widget.dart';
import 'package:medbook/components/footer.dart';
import 'package:http/http.dart' as http;
import 'package:medbook/components/videoCarousel.dart';
import 'package:medbook/pages/blogs/blog.dart';
import 'package:medbook/pages/products/FullProductPage.dart';
import 'package:medbook/pages/products/productpage0.dart';
import 'dart:convert';
import 'dart:async';
import 'package:medbook/pages/services/FullServicePage.dart';
import 'package:medbook/pages/Doctors/Doctors_Page3.dart';
import 'package:medbook/components/Header/Header.dart';
import 'package:medbook/Services/secure_storage_service.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:http/http.dart' as http;
// Import the pages for Hospital, Doctors, and Traditional
import 'package:medbook/pages/Hospitals/HospitalPage1.dart';
import 'package:medbook/pages/Doctors/Doctors_page1.dart';
import 'package:medbook/pages/Traditional/Traditional1.dart';
import 'package:medbook/pages/services/service_page0.dart';
import 'dart:io';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with TickerProviderStateMixin {
  late AnimationController _swipeController;
  late Animation<double> _swipeAnimation;

  final SecureStorageService _secureStorageService = SecureStorageService();
  late ScrollController _doctorScrollController;
  late Timer _scrollTimer;
  double _scrollPosition = 0;
  List<Map<String, dynamic>> services = [];
  List<Map<String, dynamic>> products = [];
  List<Map<String, dynamic>> topDoctors = [];
  List<Map<String, dynamic>> primeCareIcons = [];
  bool isLoading = true;
  List<String> videoUrls = [];
  bool _userTouching = false;
  Timer? _resumeScrollTimer;
  List<String> adImageUrls = [];
  List<String> adVideoUrls = [];

  String? selectedDistrict;
  String? selectedArea;

  // Tamil Nadu districts and areas
  final Map<String, List<String>> tamilNaduData = {
    // 'Chennai': ['Adyar', 'Anna Nagar', 'T Nagar', 'Velachery'],
    'Coimbatore': [
      'Annur',
      'Avinashi Road',
      'Eachanari',
      'Ganapathy',
      'Gandhipuram',
      'Irugur',
      'Kalapatti',
      'Karumathampatti',
      'Kavundampalayam',
      'Kinathukadavu',
      'Kovilpalayam',
      'Kovaipudur',
      'Kurichi',
      'Madukkarai',
      'Mettupalayam',
      'Mettupalayam Road',
      'Nanjundapuram',
      'Nehru Nagar',
      'Ondipudur',
      'Pappanaickenpalayam',
      'Peelamedu',
      'Periyanaickenpalayam',
      'Perur',
      'Podanur',
      'Pollachi Road',
      'Race Course',
      'Ramanathapuram',
      'RS Puram',
      'Saibaba Colony',
      'Saravanampatti',
      'Sidhapudur',
      'Singanallur',
      'Sirumugai',
      'Somanur',
      'Sundarapuram',
      'Sulur',
      'Tatabad',
      'Thondamuthur',
      'Thudiyalur',
      'Town Hall',
      'Ukkadam',
      'Vadakovai',
      'Vadavalli',
      'Vellalore',
      'Veerakeralam',
      'Vilankurichi',
    ]..sort(),
    // 'Madurai': ['Anna Nagar', 'KK Nagar', 'Thirunagar'],
    // 'Salem': ['Ammapet', 'Fairlands', 'Hasthampatti'],
  };

  Future<void> _loadAdImages() async {
    const String url =
        'https://medbook-backend-1.onrender.com/api/ads/gallery/default';
    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        final List<dynamic> resultData = data['resultData'];

        List<String> urls = [];
        for (var item in resultData) {
          if (item['imageUrl'] is List) {
            urls.addAll(List<String>.from(item['imageUrl']));
          }
        }
        List<String> videoUrls = [];
        for (var item in resultData) {
          if (item['youtubeLinks'] is List) {
            videoUrls.addAll(List<String>.from(item['youtubeLinks']));
          }
        }

        setState(() {
          adImageUrls = urls;
          adVideoUrls = videoUrls;
        });
      } else {
        throw Exception('Failed to load ad images');
      }
    } catch (e) {
      print('Ad Load Error: $e');
    }
  }

  Future<void> _detectCurrentLocation() async {
    try {
      print('🛰 Starting location detection');

      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) return;

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) return;
      }

      if (permission == LocationPermission.deniedForever) return;

      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.best,
      );

      print("Got position: ${position.latitude}, ${position.longitude}");

      String detectedDistrict = "Unknown District";
      String detectedArea = "Unknown Area";

      if (kIsWeb) {
        final url = Uri.parse(
          "https://nominatim.openstreetmap.org/reverse?format=jsonv2&lat=${position.latitude}&lon=${position.longitude}",
        );
        final response = await http.get(url);
        if (response.statusCode == 200) {
          final data = json.decode(response.body);
          detectedDistrict =
              data['address']?['county'] ??
              data['address']?['state_district'] ??
              "Unknown District";

          detectedArea =
              data['address']?['suburb'] ??
              data['address']?['neighbourhood'] ??
              data['address']?['city_district'] ??
              data['address']?['city'] ??
              data['address']?['town'] ??
              data['address']?['village'] ??
              "Unknown Area";
        }
      } else {
        final placemarks = await placemarkFromCoordinates(
          position.latitude,
          position.longitude,
        );
        if (placemarks.isNotEmpty) {
          final place = placemarks.first;
          detectedDistrict =
              place.subAdministrativeArea ??
              place.locality ??
              place.administrativeArea ??
              "Unknown District";

          detectedArea =
              place.subLocality ??
              place.locality ??
              place.subAdministrativeArea ??
              place.administrativeArea ??
              "Unknown Area";
        }
      }

      // ✅ Dynamically remove directional suffixes (North, South, East, West)
      detectedDistrict = detectedDistrict.replaceAll(
        RegExp(r'\s+(North|South|East|West)$', caseSensitive: false),
        '',
      );

      print("📍 District: $detectedDistrict | Area: $detectedArea");

      setState(() {
        selectedDistrict = detectedDistrict;
        selectedArea = detectedArea;
      });

      await _secureStorageService.saveSelectedDistrict(detectedDistrict);
      await _secureStorageService.saveSelectedArea(detectedArea);
    } catch (e, s) {
      print('❌ Location Error: $e');
      print(s);
    }
  }

  Future<void> _loadPrimeCareIcons() async {
    const String url =
        'https://medbook-backend-1.onrender.com/api/primecareicon';
    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        setState(() {
          primeCareIcons = data.map<Map<String, dynamic>>((icon) {
            return {
              'id': icon['id'],
              'image': icon['image'],
              'name': icon['name'],
            };
          }).toList();
        });
      } else {
        throw Exception('Failed to load PrimeCare icons');
      }
    } catch (e) {
      print('PrimeCare Icons Load Error: $e');
    }
  }

  @override
  void initState() {
    super.initState();
    //swipe animation
    _swipeController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
    );

    _swipeAnimation = Tween<double>(begin: 0, end: 12).animate(
      CurvedAnimation(parent: _swipeController, curve: Curves.easeInOut),
    );

    // LOOP every 1 seconds
    Timer.periodic(const Duration(milliseconds: 1500), (_) {
      if (mounted) {
        _swipeController.forward(from: 0);
      }
    });

    _loadSavedLocation();
    _loadData();
    _doctorScrollController = ScrollController();
    _loadAdImages();
    _loadPrimeCareIcons();

    //  _detectCurrentLocation();

    _scrollTimer = Timer.periodic(const Duration(milliseconds: 100), (timer) {
      if (_doctorScrollController.hasClients && !_userTouching) {
        _scrollPosition += 2;
        if (_scrollPosition >=
            _doctorScrollController.position.maxScrollExtent) {
          _scrollPosition = 0;
        }
        _doctorScrollController.animateTo(
          _scrollPosition,
          duration: const Duration(milliseconds: 100),
          curve: Curves.linear,
        );
      }
    });
  }

  @override
  void dispose() {
    _scrollTimer.cancel();
    _doctorScrollController.dispose();
    _swipeController.dispose();
    //swipe animation
    super.dispose();
  }

  void _pauseAutoScroll() {
    _userTouching = true;
    _resumeScrollTimer?.cancel();
    _resumeScrollTimer = Timer(const Duration(seconds: 2), () {
      _userTouching = false;
    });
  }

  Future<void> _loadSavedLocation() async {
    final district = await _secureStorageService.getSelectedDistrict();
    final area = await _secureStorageService.getSelectedArea();
    setState(() {
      selectedDistrict = district?.isEmpty ?? true ? null : district;
      selectedArea = area?.isEmpty ?? true ? null : area;
    });
  }

  Future<void> _loadData() async {
    await _loadServices();
    await _loadProducts();
    await _loadTopDoctors();
  }

  Future<void> _loadServices() async {
    const String url =
        'https://medbook-backend-1.onrender.com/api/services/available-service-types';
    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        final List<dynamic> resultData = data['resultData'];

        // Convert to List<Map> first
        List<Map<String, dynamic>> tempServices = resultData
            .map<Map<String, dynamic>>((serviceType) {
              return {
                'serviceName': serviceType['name']?.toString() ?? '',
                'id': serviceType['id'].toString(),
                'imageUrl': serviceType['imageUrl']?.toString() ?? '',
                'orderNo': serviceType['order_no'] ?? 0,
              };
            })
            .toList();

        // Sort by order_no (ascending)
        tempServices.sort(
          (a, b) => (a['orderNo'] as int).compareTo(b['orderNo'] as int),
        );

        setState(() {
          services = tempServices;
          isLoading = false;
        });
      } else {
        throw Exception('Failed to load services');
      }
    } catch (e) {
      print('Error: $e');
      setState(() => isLoading = false);
    }
  }

  Future<void> _loadProducts() async {
    const String url =
        'https://medbook-backend-1.onrender.com/api/products/availableProductType';
    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        final List<dynamic> resultData = data['resultData'];
        setState(() {
          products = resultData.map<Map<String, dynamic>>((product) {
            return {
              'productName': product['name']?.toString() ?? '',
              'id': product['id'].toString(),
              'imageUrl': product['imageUrl']?.toString() ?? '',
            };
          }).toList();
        });
      } else {
        throw Exception('Failed to load products');
      }
    } catch (e) {
      print('Product Load Error: $e');
    }
  }

  Future<void> _loadTopDoctors() async {
    const String url =
        'https://medbook-backend-1.onrender.com/api/doctor/topdoctors';
    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        final List<dynamic> resultData = data['resultData'];

        setState(() {
          topDoctors = resultData.map<Map<String, dynamic>>((doctor) {
            return {
              'doctorName': doctor['doctorName']?.toString() ?? '',
              'businessName': doctor['businessName']?.toString() ?? '',
              'degree': doctor['degree']?.toString() ?? 'MBBS',
              'rating': doctor['rating']?.toString() ?? '0',
              'id': doctor['id']?.toString() ?? '',
              'imageUrl': doctor['imageUrl']?.toString() ?? '',
              'doctorTypeName': doctor['doctorTypeName']?.toString() ?? '',
            };
          }).toList();
        });
      } else {
        throw Exception('Failed to load top doctors');
      }
    } catch (e) {
      print('Doctor Load Error: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,

      backgroundColor: Colors.white,
      body: isLoading
          ? const AppLoadingWidget()
          : PageView(
              scrollDirection: Axis.horizontal,
              reverse: true,
              children: [_buildMainHomeContent(context), const BlogPage()],
            ),
    );
  }

  Widget _buildMainHomeContent(BuildContext context) {
    // Add "ALL" option to the districts
    final List<String> districtOptions = ['ALL', ...tamilNaduData.keys];

    return Column(
      children: [
        Header(),

        const SizedBox(height: 20),
        Expanded(
          child: SingleChildScrollView(
            padding: EdgeInsets.zero,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                LayoutBuilder(
                  builder: (context, constraints) {
                    final isTablet = constraints.maxWidth >= 600;
                    final districtOptions = ['ALL', ...tamilNaduData.keys];

                    if (isTablet) {
                      return Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16.0,
                          vertical: 10,
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // LEFT SIDE (District + Swipe)
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                ConstrainedBox(
                                  constraints: const BoxConstraints(
                                    maxWidth: 160,
                                  ), // <<< safer width
                                  child: buildDistrictPicker(districtOptions),
                                ),
                                const SizedBox(height: 14),
                                swipeToBlogAnimation(),
                              ],
                            ),

                            // RIGHT SIDE (Location + Current Location)
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                ConstrainedBox(
                                  constraints: const BoxConstraints(
                                    maxWidth: 180,
                                  ), // <<< safer width
                                  child: buildAreaPicker(),
                                ),
                                const SizedBox(height: 14),
                                Padding(
                                  padding: const EdgeInsets.only(
                                    left: 8,
                                  ), // <<< small shift inward
                                  child: buildCurrentLocationButton(),
                                ),
                              ],
                            ),
                          ],
                        ),
                      );
                    }

                    // ---------------- MOBILE LAYOUT ------------------

                    return Padding(
                      padding: const EdgeInsets.only(top: 10, bottom: 6),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // LEFT SIDE
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              ConstrainedBox(
                                constraints: const BoxConstraints(
                                  maxWidth: 160,
                                ),
                                child: buildDistrictPicker(districtOptions),
                              ),
                              const SizedBox(height: 14),
                              swipeToBlogAnimation(),
                            ],
                          ),

                          // RIGHT SIDE
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              ConstrainedBox(
                                constraints: const BoxConstraints(
                                  maxWidth: 140,
                                ),
                                child: buildAreaPicker(),
                              ),
                              const SizedBox(height: 14),
                              Padding(
                                padding: const EdgeInsets.only(
                                  left: 6,
                                ), // <<< shift button left slightly
                                child: buildCurrentLocationButton(),
                              ),
                            ],
                          ),
                        ],
                      ),
                    );
                  },
                ),

                if (adImageUrls.isNotEmpty)
                  ImageCarousel1(imageUrls: adImageUrls)
                else
                  const AppLoadingWidget(),
                const SizedBox(height: 30),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: const Text(
                    "PrimeCare",
                    style: TextStyle(fontSize: 25, fontWeight: FontWeight.bold),
                  ),
                ),

                const SizedBox(height: 20),

                primeCareIcons.isEmpty
                    ? const AppLoadingWidget()
                    : Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: primeCareIcons.map((icon) {
                          final imageUrl = icon['image'] as String;
                          final name = icon['name'] as String;

                          return _buildIconCard(
                            imageUrl: imageUrl,
                            label: name.toUpperCase(),
                            onTap: () {
                              final normalized = name.toUpperCase().trim();

                              if (normalized == "HOSPITALS") {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => HospitalPage1(
                                      selectedDistrict: selectedDistrict,
                                      selectedArea: selectedArea,
                                    ),
                                  ),
                                );
                              } else if (normalized == "DOCTORS") {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => DoctorsPage1(
                                      selectedDistrict: selectedDistrict,
                                      selectedArea: selectedArea,
                                    ),
                                  ),
                                );
                              } else if (normalized ==
                                      "TRADITIONAL TREATMENTS" ||
                                  normalized == "TRADITIONAL") {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => Traditional1(
                                      selectedDistrict: selectedDistrict,
                                      selectedArea: selectedArea,
                                    ),
                                  ),
                                );
                              }
                            },
                          );
                        }).toList(),
                      ),

                const SizedBox(height: 30),
                Divider(color: Colors.grey.shade300, thickness: 1, height: 1),

                const SizedBox(height: 30),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: const Text(
                    "HealthCare",
                    style: TextStyle(fontSize: 25, fontWeight: FontWeight.bold),
                  ),
                ),

                const SizedBox(height: 30),

                /// Services Grid
                isLoading
                    ? const AppLoadingWidget()
                    : LayoutBuilder(
                        builder: (context, constraints) {
                          int crossAxisCount = 3;
                          double fontSize = constraints.maxWidth < 600
                              ? 13
                              : 22;

                          if (constraints.maxWidth >= 600 &&
                              constraints.maxWidth < 900) {
                            crossAxisCount = 3;
                          } else if (constraints.maxWidth >= 900) {
                            crossAxisCount = 4;
                          }

                          double childAspectRatio = constraints.maxWidth < 600
                              ? 0.9
                              : 1.5;

                          final filteredServices = services
                              .where(
                                (service) =>
                                    service['serviceName'].trim() !=
                                    'EMERGENCY',
                              )
                              .toList();

                          return GridView.builder(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16.0,
                            ),
                            itemCount: services.length > 6
                                ? 6
                                : services.length,
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            gridDelegate:
                                SliverGridDelegateWithFixedCrossAxisCount(
                                  crossAxisCount: crossAxisCount,
                                  mainAxisSpacing: 16,
                                  crossAxisSpacing: 16,
                                  childAspectRatio: childAspectRatio,
                                ),
                            itemBuilder: (context, index) {
                              final service = filteredServices[index];
                              return _buildGridCard(
                                imageUrl: service['imageUrl'],
                                title: service['serviceName'],
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => ServicePage0(
                                        serviceId: service['id'].toString(),
                                      ),
                                    ),
                                  );
                                },
                                fontSize: fontSize,
                              );
                            },
                          );
                        },
                      ),
                const SizedBox(height: 25),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: SizedBox(
                    width: 100,
                    height: 40,
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                FullServicePage(services: services),
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.deepOrange,
                        foregroundColor: Colors.white,
                        textStyle: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 4,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                      ),
                      child: const Text("See More"),
                    ),
                  ),
                ),

                const SizedBox(height: 30),
                Divider(color: Colors.grey.shade300, thickness: 1, height: 1),
                const SizedBox(height: 30),

                Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    SizedBox(
                      width: double.infinity,
                      child: VideoCarousel(videoUrls: adVideoUrls),
                    ),
                    const SizedBox(height: 30),
                    Divider(
                      color: Colors.grey.shade300,
                      thickness: 1,
                      height: 1,
                    ),
                  ],
                ),

                const SizedBox(height: 30),

                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 20),
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.white,
                        Colors.white,
                        Color.fromRGBO(199, 33, 8, 1.0),
                        Color.fromRGBO(199, 33, 8, 1.0),
                      ],
                      stops: [0.0, 0.5, 0.5, 1.0],
                    ),
                  ),

                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Padding(
                        padding: EdgeInsets.symmetric(horizontal: 12),
                        child: Text(
                          "Top Stars",
                          style: TextStyle(
                            fontSize: 25,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),

                      SizedBox(
                        height: 220,
                        child: Listener(
                          onPointerDown: (_) => _pauseAutoScroll(),
                          onPointerUp: (_) => _pauseAutoScroll(),
                          child: ListView.builder(
                            controller: _doctorScrollController,
                            scrollDirection: Axis.horizontal,
                            itemCount: topDoctors.length,
                            itemBuilder: (context, index) {
                              final doctor = topDoctors[index];

                              return Container(
                                width: 180,
                                margin: EdgeInsets.only(
                                  left: index == 0 ? 10 : 5,
                                  right: index == topDoctors.length - 1
                                      ? 10
                                      : 5,
                                ),
                                child: _buildTopDoctorCard(
                                  imageUrl: doctor['imageUrl'],
                                  doctorName: doctor['doctorName'],
                                  doctorTypeName: doctor['doctorTypeName'],
                                  rating: doctor['rating'].toString(),
                                  onTap: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => Doctors_Page3(
                                          doctorId: doctor['id'].toString(),
                                        ),
                                      ),
                                    );
                                  },
                                ),
                              );
                            },
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 30),
                Divider(color: Colors.grey.shade300, thickness: 1, height: 1),
                const SizedBox(height: 30),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: const Text(
                    "Products",
                    style: TextStyle(fontSize: 25, fontWeight: FontWeight.bold),
                  ),
                ),

                const SizedBox(height: 30),

                /// Products
                isLoading
                    ? const AppLoadingWidget()
                    : LayoutBuilder(
                        builder: (context, constraints) {
                          int crossAxisCount;
                          if (constraints.maxWidth < 400) {
                            crossAxisCount = 3; // small phones → 2 per row
                          } else if (constraints.maxWidth < 900) {
                            crossAxisCount = 3;
                          } else {
                            crossAxisCount = 4;
                          }

                          double childAspectRatio;
                          if (constraints.maxWidth < 400) {
                            childAspectRatio =
                                0.9; // smaller phones → taller cards
                          } else if (constraints.maxWidth < 600) {
                            childAspectRatio = 0.9;
                          } else {
                            childAspectRatio = 1.5;
                          }

                          // ✅ Add this back
                          double fontSize = constraints.maxWidth < 600
                              ? 13
                              : 22;

                          return GridView.builder(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16.0,
                            ),
                            itemCount: products.length > 6
                                ? 6
                                : products.length,
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            gridDelegate:
                                SliverGridDelegateWithFixedCrossAxisCount(
                                  crossAxisCount: crossAxisCount,
                                  mainAxisSpacing: 17,
                                  crossAxisSpacing: 17,
                                  childAspectRatio: childAspectRatio,
                                ),
                            itemBuilder: (context, index) {
                              final product = products[index];
                              return _buildGridCard(
                                imageUrl: product['imageUrl'],
                                title: product['productName'],
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => ProductPage0(
                                        productId: product['id'].toString(),
                                      ),
                                    ),
                                  );
                                },
                                fontSize: fontSize, // ✅ now works
                              );
                            },
                          );
                        },
                      ),

                const SizedBox(height: 20),

                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      SizedBox(
                        width: 100,
                        height: 40,
                        child: ElevatedButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    FullProductPage(products: products),
                              ),
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.deepOrange,
                            foregroundColor: Colors.white,
                            textStyle: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                            ),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 4,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20),
                            ),
                          ),
                          child: const Text("See More"),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 30),
              ],
            ),
          ),
        ),
        Footer(title: "Home"),
      ],
    );
  }

  Widget _buildIconCard({
    required String imageUrl,
    required String label,
    required VoidCallback onTap,
  }) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isTablet = screenWidth > 600;
    final cardWidth = isTablet ? 150.0 : 100.0;
    final cardHeight = isTablet ? 180.0 : 130.0;
    final iconSize = isTablet ? 70.0 : 50.0;
    final fontSize = isTablet ? 16.0 : 10.0;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: cardWidth,
        height: cardHeight,
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFFF7F5F5), Color(0xFFFAF0F0)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: const Color.fromARGB(255, 182, 179, 179),
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: const Color.fromARGB(255, 154, 152, 152).withOpacity(0.05),
              blurRadius: 8,
              offset: const Offset(2, 4),
            ),
          ],
        ),
        padding: const EdgeInsets.all(12),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.network(
              imageUrl,
              height: iconSize,
              width: iconSize,
              fit: BoxFit.contain,
              errorBuilder: (context, error, stackTrace) =>
                  const Icon(Icons.broken_image, size: 40),
            ),
            const SizedBox(height: 12),
            Text(
              label,
              textAlign: TextAlign.center,
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: fontSize,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
                letterSpacing: 0.5,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTopDoctorCard({
    required String imageUrl,
    required String doctorName,
    required String doctorTypeName,
    required String rating,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          const SizedBox(height: 6),
          ClipRRect(
            borderRadius: BorderRadius.circular(0),
            child: Container(
              height: 150,
              width: 120,
              decoration: BoxDecoration(
                border: Border.all(color: Colors.red, width: 2),
              ),
              child: Image.network(
                imageUrl,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) =>
                    const Icon(Icons.broken_image, size: 40),
              ),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            doctorName,
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.bold,
              color: Color.fromARGB(255, 255, 255, 255),
            ),
          ),
          Text(
            doctorTypeName,
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.bold,
              color: Color.fromARGB(255, 255, 255, 255),
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.star,
                color: Color.fromARGB(255, 255, 238, 0),
                size: 14,
              ),
              const SizedBox(width: 4),
              Text(
                rating,
                style: const TextStyle(fontSize: 12, color: Colors.white),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildGridCard({
    required String imageUrl,
    required String title,
    required VoidCallback onTap,
    required double fontSize,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [
              Color.fromARGB(255, 255, 255, 255),
              Color.fromARGB(255, 246, 237, 237),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: const Color.fromARGB(255, 182, 179, 179),
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: const Color.fromARGB(255, 154, 152, 152).withOpacity(0.05),
              blurRadius: 8,
              offset: const Offset(2, 4),
            ),
          ],
        ),
        padding: const EdgeInsets.all(12),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Expanded(
              flex: 3,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: Image.network(
                  imageUrl,
                  fit: BoxFit.contain,
                  width: double.infinity,
                  errorBuilder: (context, error, stackTrace) =>
                      const Icon(Icons.broken_image, size: 40),
                ),
              ),
            ),
            const SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: Text(
                title,
                textAlign: TextAlign.center,
                maxLines: 4,
                overflow: TextOverflow.ellipsis, // optional for very long text
                softWrap: true,
                style: TextStyle(
                  fontSize: fontSize,
                  fontWeight: FontWeight.w600,
                  color: Colors.black,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ------------------------- REUSABLE WIDGETS -------------------------

  Widget buildDistrictPicker(List<String> districtOptions) {
    return LocationDropdown(
      label: selectedDistrict ?? 'District',
      onTap: () async {
        final district = await showDialog<String>(
          context: context,
          builder: (context) => SimpleDialog(
            title: const Text('Select District'),
            children: districtOptions.map((district) {
              return SimpleDialogOption(
                child: Text(district),
                onPressed: () => Navigator.pop(context, district),
              );
            }).toList(),
          ),
        );

        if (district != null) {
          if (district == 'ALL') {
            setState(() {
              selectedDistrict = null;
              selectedArea = null;
            });
            await _secureStorageService.saveSelectedDistrict('');
            await _secureStorageService.saveSelectedArea('');
          } else {
            setState(() {
              selectedDistrict = district;
              selectedArea = null;
            });
            await _secureStorageService.saveSelectedDistrict(district);
            await _secureStorageService.saveSelectedArea('');
          }
        }
      },
    );
  }

  Widget buildAreaPicker() {
    return LocationDropdown(
      label: selectedArea ?? 'Location',
      onTap: () {
        if (selectedDistrict == null) return;

        final List<String> areas = [
          'ALL',
          ...List<String>.from(tamilNaduData[selectedDistrict] ?? []),
        ]..sort();

        showDialog<String>(
          context: context,
          builder: (context) => SimpleDialog(
            title: Text('Select Area in $selectedDistrict'),
            children: areas.map((area) {
              return SimpleDialogOption(
                child: Text(area),
                onPressed: () => Navigator.pop(context, area),
              );
            }).toList(),
          ),
        ).then((area) async {
          if (area != null) {
            if (area == 'ALL') {
              setState(() => selectedArea = null);
              await _secureStorageService.saveSelectedArea('');
            } else {
              setState(() => selectedArea = area);
              await _secureStorageService.saveSelectedArea(area);
            }
          }
        });
      },
    );
  }

  Widget buildCurrentLocationButton() {
    return GestureDetector(
      onTap: () async {
        await _detectCurrentLocation();
        setState(() {});
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: const Color.fromARGB(255, 199, 33, 8),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: const Color.fromARGB(255, 199, 33, 8),
            width: 1.2,
          ),
        ),
        child: const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.my_location, size: 14, color: Colors.white),
            SizedBox(width: 5),
            Text(
              "current location",
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget swipeToBlogAnimation() {
    return AnimatedBuilder(
      animation: _swipeAnimation,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(_swipeAnimation.value, 0),
          child: Row(
            children: const [
              Text(
                "swipe to blogs",
                style: TextStyle(
                  fontSize: 12,
                  color: Color.fromARGB(255, 199, 33, 8),
                  fontWeight: FontWeight.w600,
                ),
              ),
              SizedBox(width: 4),
              Icon(
                Icons.arrow_forward_ios,
                size: 12,
                color: Color.fromARGB(255, 199, 33, 8),
              ),
            ],
          ),
        );
      },
    );
  }
}
