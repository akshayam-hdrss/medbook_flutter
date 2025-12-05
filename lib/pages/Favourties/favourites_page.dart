import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:medbook/Services/secure_storage_service.dart';
import 'package:medbook/components/Footer.dart';
import 'package:medbook/components/common/loading_widget.dart';
import 'package:medbook/pages/Hospitals/HospitalPage4.dart';
import 'package:medbook/pages/products/product_page3.dart';
import 'package:medbook/pages/services/service_page.dart';
import 'package:medbook/pages/services/service_page3.dart';

class FavouritesPage extends StatefulWidget {
  const FavouritesPage({super.key});

  @override
  State<FavouritesPage> createState() => _FavouritesPageState();
}

class _FavouritesPageState extends State<FavouritesPage> {
  List<dynamic> favouriteItems = [];
  bool loading = true;
  String? _userId;

  @override
  void initState() {
    super.initState();
    _initializeFavourites();
  }

  // -------------------------------------------------------------
  // INITIALIZE FAVOURITES
  // -------------------------------------------------------------
  Future<void> _initializeFavourites() async {
    final storage = SecureStorageService();
    final user = await storage.getUserDetails();
    _userId = user?['id']?.toString();

    if (_userId == null) {
      setState(() {
        loading = false;
        favouriteItems = [];
      });
      return;
    }

    await loadFavourites();
  }

  // -------------------------------------------------------------
  // FETCH USER FAVOURITES WITH DETAILS - CORRECT ENDPOINT
  // -------------------------------------------------------------
  Future<void> loadFavourites() async {
    try {
      // ✅ CORRECT ENDPOINT: /api/userfavorites/details/userId
      final response = await http.get(
        Uri.parse(
          "https://medbook-backend-1.onrender.com/api/userfavorites/details/$_userId",
        ),
      );

      if (response.statusCode != 200) {
        setState(() {
          loading = false;
          favouriteItems = [];
        });
        return;
      }

      final List<dynamic> data = json.decode(response.body);

      // Process the data directly from the API response
      List<Map<String, dynamic>> processedItems = [];

      for (var fav in data) {
        // Doctor favorites
        if (fav['doctorId'] != null) {
          processedItems.add({
            "favId": fav["favoriteId"],
            "userId": fav["userId"],
            "doctorId": fav["doctorId"],
            "type": "doctor",
            "data": {
              "id": fav["doctorId"],
              "doctorName": fav["doctorName"] ?? "Unknown Doctor",
              "imageUrl": fav["doctorImage"] ?? "",
              "businessName": fav["doctorBusinessName"] ?? "",
              "designation": fav["designation"] ?? "",
              "category": fav["category"] ?? "",
              "location": fav["doctorLocation"] ?? "",
              "phone": fav["doctorPhone"] ?? "",
              "whatsapp": fav["doctorWhatsapp"] ?? "",
              "rating": fav["rating"] ?? "0.0",
              "experience": fav["doctorExperience"] ?? "",
              "degree": fav["degree"] ?? "",
              "address1": fav["doctorAddress1"] ?? "",
              "address2": fav["doctorAddress2"] ?? "",
              "mapLink": fav["doctorMapLink"] ?? "",
              "about": fav["doctorAbout"] ?? "",
              "youtube": fav["doctorYoutube"] ?? "",
              "gallery": fav["doctorGallery"] ?? [],
              "banner": fav["doctorBanner"] ?? "",
              "district": fav["doctorDistrict"] ?? "",
              "pincode": fav["doctorPincode"] ?? "",
              "order_no": fav["doctorOrder"] ?? 0,
            },
          });
        }
        // Service favorites
        else if (fav['serviceId'] != null) {
          processedItems.add({
            "favId": fav["favoriteId"],
            "userId": fav["userId"],
            "serviceId": fav["serviceId"],
            "type": "service",
            "data": {
              "id": fav["serviceId"],
              "name": fav["serviceName"] ?? "Unknown Service",
              "imageUrl": fav["serviceImage"] ?? "",
              "businessName": fav["serviceBusinessName"] ?? "",
              "location": fav["serviceLocation"] ?? "",
              "phone": fav["servicePhone"] ?? "",
              "whatsapp": fav["serviceWhatsapp"] ?? "",
              "experience": fav["serviceExperience"] ?? "",
              "address1": fav["serviceAddress1"] ?? "",
              "address2": fav["serviceAddress2"] ?? "",
              "mapLink": fav["serviceMapLink"] ?? "",
              "about": fav["serviceAbout"] ?? "",
              "youtube": fav["serviceYoutube"] ?? "",
              "gallery": fav["serviceGallery"] ?? [],
              "banner": fav["serviceBanner"] ?? "",
              "district": fav["serviceDistrict"] ?? "",
              "pincode": fav["servicePincode"] ?? "",
              "order_no": fav["serviceOrder"] ?? 0,
            },
          });
        }
        // Product favorites
        else if (fav['productId'] != null) {
          processedItems.add({
            "favId": fav["favoriteId"],
            "userId": fav["userId"],
            "productId": fav["productId"],
            "type": "product",
            "data": {
              "id": fav["productId"],
              "name": fav["productName"] ?? "Unknown Product",
              "price": fav["price"] ?? "0",
              "imageUrl": fav["productImage"] ?? "",
              "businessName": fav["productBusinessName"] ?? "",
              "location": fav["productLocation"] ?? "",
              "phone": fav["productPhone"] ?? "",
              "whatsapp": fav["productWhatsapp"] ?? "",
              "experience": fav["productExperience"] ?? "",
              "address1": fav["productAddress1"] ?? "",
              "address2": fav["productAddress2"] ?? "",
              "mapLink": fav["productMapLink"] ?? "",
              "about": fav["productAbout"] ?? "",
              "youtube": fav["productYoutube"] ?? "",
              "gallery": fav["productGallery"] ?? [],
              "banner": fav["productBanner"] ?? "",
              "district": fav["productDistrict"] ?? "",
              "pincode": fav["productPincode"] ?? "",
              "order_no": fav["productOrder"] ?? 0,
            },
          });
        }
      }

      // Remove duplicates (based on your data showing multiple entries for same doctor)
      final uniqueItems = <String, Map<String, dynamic>>{};
      for (var item in processedItems) {
        String key;
        if (item["type"] == "doctor") {
          key = "doctor_${item["doctorId"]}";
        } else if (item["type"] == "service") {
          key = "service_${item["serviceId"]}";
        } else {
          key = "product_${item["productId"]}";
        }

        // Keep the item with the highest favId (most recent)
        if (!uniqueItems.containsKey(key) ||
            (uniqueItems.containsKey(key) &&
                item["favId"] > uniqueItems[key]!["favId"])) {
          uniqueItems[key] = item;
        }
      }

      setState(() {
        favouriteItems = uniqueItems.values.toList();
        loading = false;
      });
    } catch (e) {
      print("Error loading favourites: $e");
      setState(() {
        loading = false;
        favouriteItems = [];
      });
    }
  }

  // -------------------------------------------------------------
  // REMOVE FAVOURITE
  // -------------------------------------------------------------
  Future<void> removeFavourite(int favId) async {
    try {
      final response = await http.delete(
        Uri.parse(
          "https://medbook-backend-1.onrender.com/api/userfavorites/favorites/$favId",
        ),
      );

      if (response.statusCode == 200) {
        // Remove from local list
        setState(() {
          favouriteItems.removeWhere((item) => item["favId"] == favId);
        });

        // Show success message
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Removed from favourites"),
            backgroundColor: Colors.red,
            duration: Duration(seconds: 2),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Failed to remove favourite"),
            backgroundColor: Colors.orange,
          ),
        );
      }
    } catch (e) {
      print("Error removing favourite: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Error: ${e.toString()}"),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  // -------------------------------------------------------------
  // NAVIGATE TO DOCTOR DETAILS
  // -------------------------------------------------------------
  void _navigateToDoctorDetails(String doctorId) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => HospitalPage4(doctorId: doctorId)),
    );
  }

  // -------------------------------------------------------------
  // NAVIGATE TO SERVICE DETAILS
  // -------------------------------------------------------------
  void _navigateToServiceDetails(String serviceId) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => ServicesPage3(serviceId: serviceId)),
    );
  }

  void _navigateToProductDetails(String productId) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => ProductPage3(productId: productId)),
    );
  }

  // -------------------------------------------------------------
  // REFRESH FAVOURITES
  // -------------------------------------------------------------
  Future<void> _refreshFavourites() async {
    if (_userId != null) {
      setState(() {
        loading = true;
      });
      await loadFavourites();
    }
  }

  // -------------------------------------------------------------
  // UI
  // -------------------------------------------------------------
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFF8F2),
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
              "Favourites",
              style: TextStyle(color: Colors.white),
            ),
            centerTitle: true,
            backgroundColor: Colors.transparent,
            elevation: 0,
            iconTheme: const IconThemeData(color: Colors.white),
          ),
        ),
      ),

      body: loading
          ? const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [const AppLoadingWidget(), SizedBox(height: 16)],
              ),
            )
          : _userId == null
          ? const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.person_off, size: 80, color: Colors.grey),
                  SizedBox(height: 20),
                  Text(
                    "Please login to view favourites",
                    style: TextStyle(fontSize: 18, color: Colors.grey),
                  ),
                  SizedBox(height: 10),
                  Text(
                    "Login to add and view your favourite items",
                    style: TextStyle(fontSize: 14, color: Colors.grey),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            )
          : favouriteItems.isEmpty
          ? RefreshIndicator(
              onRefresh: _refreshFavourites,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                child: SizedBox(
                  height: MediaQuery.of(context).size.height * 0.8,
                  child: const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.favorite_border,
                          size: 80,
                          color: Colors.grey,
                        ),
                        SizedBox(height: 20),
                        Text(
                          "No Favourites yet",
                          style: TextStyle(fontSize: 18, color: Colors.grey),
                        ),
                        SizedBox(height: 10),
                        Text(
                          "Add doctors, services or products to see them here",
                          style: TextStyle(fontSize: 14, color: Colors.grey),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            )
          : RefreshIndicator(
              onRefresh: _refreshFavourites,
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  _buildSection("Doctors", "doctor"),
                  _buildSection("Services", "service"),
                  _buildSection("Products", "product"),
                ],
              ),
            ),

      bottomNavigationBar: const Footer(title: "none"),
    );
  }

  // -------------------------------------------------------------
  Widget _buildSection(String title, String type) {
    final items = favouriteItems.where((item) => item["type"] == type).toList();

    if (items.isEmpty) return const SizedBox();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "⭐ $title",
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: Colors.redAccent.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  "${items.length}",
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Colors.redAccent,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),

        ...items.map((fav) {
          if (type == "doctor")
            return _buildDoctorCard(fav["data"], fav["favId"]);
          if (type == "service")
            return _buildServiceCard(fav["data"], fav["favId"]);
          return _buildProductCard(fav["data"], fav["favId"]);
        }),

        const SizedBox(height: 24),
      ],
    );
  }

  // -------------------------------------------------------------
  // DOCTOR CARD
  // -------------------------------------------------------------
  Widget _buildDoctorCard(Map<String, dynamic> doctor, int favId) {
    final doctorName = doctor["doctorName"] ?? "Unknown Doctor";
    final imageUrl = doctor["imageUrl"] ?? "";
    final degree = doctor["degree"] ?? "";
    final designation = doctor["designation"] ?? "";
    final location = doctor["location"] ?? "Location not available";
    final rating = doctor["rating"] ?? "0.0";
    final businessName = doctor["businessName"] ?? "";
    // final experience = doctor["experience"] ?? "";

    return _wrapWithRemove(
      favId,
      InkWell(
        onTap: () => doctor["id"] != null
            ? _navigateToDoctorDetails(doctor["id"].toString())
            : null,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          margin: const EdgeInsets.only(bottom: 16),
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
              // Doctor Image
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.network(
                  imageUrl,
                  height: 130,
                  width: 110,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => Container(
                    height: 130,
                    width: 110,
                    color: Colors.grey[200],
                    child: const Center(
                      child: Icon(Icons.person, size: 50, color: Colors.grey),
                    ),
                  ),
                  loadingBuilder: (context, child, loadingProgress) {
                    if (loadingProgress == null) return child;
                    return Container(
                      height: 130,
                      width: 110,
                      color: Colors.grey[200],
                      child: const Center(child: const AppLoadingWidget()),
                    );
                  },
                ),
              ),
              const SizedBox(width: 16),

              // Doctor Details
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
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),

                    if (degree.isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Text(
                        degree,
                        style: const TextStyle(
                          fontSize: 14,
                          color: Colors.grey,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],

                    if (designation.isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Text(
                        designation,
                        style: const TextStyle(
                          fontSize: 14,
                          color: Colors.blueGrey,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],

                    if (businessName.isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Text(
                        businessName,
                        style: const TextStyle(
                          fontSize: 14,
                          color: Colors.grey,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],

                    // if (experience.isNotEmpty) ...[
                    //   const SizedBox(height: 4),
                    //   Text(
                    //     "Exp: $experience",
                    //     style: const TextStyle(
                    //       fontSize: 13,
                    //       color: Colors.green,
                    //     ),
                    //   ),
                    // ],
                    const SizedBox(height: 8),

                    Row(
                      children: [
                        const Icon(
                          Icons.location_on,
                          size: 14,
                          color: Colors.grey,
                        ),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            location,
                            style: const TextStyle(
                              fontSize: 13,
                              color: Colors.grey,
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
                        const Icon(Icons.star, size: 16, color: Colors.amber),
                        const SizedBox(width: 4),
                        Text(
                          rating,
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        // const Spacer(),
                        // if (doctor["phone"]?.isNotEmpty == true)
                        //   Row(
                        //     children: [
                        //       const Icon(
                        //         Icons.phone,
                        //         size: 14,
                        //         color: Colors.green,
                        //       ),
                        //       const SizedBox(width: 4),
                        //       Text(
                        //         doctor["phone"],
                        //         style: const TextStyle(
                        //           fontSize: 13,
                        //           color: Colors.grey,
                        //         ),
                        //       ),
                        //     ],
                        //   ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // -------------------------------------------------------------
  // SERVICE CARD
  // -------------------------------------------------------------
  Widget _buildServiceCard(Map<String, dynamic> service, int favId) {
    final serviceName = service["name"] ?? "Unknown Service";
    final imageUrl = service["imageUrl"] ?? "";
    final businessName = service["businessName"] ?? "";
    final location = service["location"] ?? "Location not available";
    final experience = service["experience"] ?? "";

    return _wrapWithRemove(
      favId,
      InkWell(
        onTap: () => service["id"] != null
            ? _navigateToServiceDetails(service["id"].toString())
            : null,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          margin: const EdgeInsets.only(bottom: 16),
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
              // Service Image
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.network(
                  imageUrl,
                  height: 130,
                  width: 110,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => Container(
                    height: 130,
                    width: 110,
                    color: Colors.grey[200],
                    child: const Center(
                      child: Icon(Icons.category, size: 50, color: Colors.grey),
                    ),
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

              // Service Details
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      serviceName,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),

                    if (businessName.isNotEmpty) ...[
                      const SizedBox(height: 6),
                      Text(
                        businessName,
                        style: const TextStyle(
                          fontSize: 14,
                          color: Colors.grey,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],

                    const SizedBox(height: 8),

                    if (experience.isNotEmpty) ...[
                      Row(
                        children: [
                          const Icon(
                            Icons.timelapse,
                            size: 14,
                            color: Colors.grey,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            experience,
                            style: const TextStyle(
                              fontSize: 13,
                              color: Colors.grey,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                    ],

                    Row(
                      children: [
                        const Icon(
                          Icons.location_on,
                          size: 14,
                          color: Colors.grey,
                        ),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            location,
                            style: const TextStyle(
                              fontSize: 13,
                              color: Colors.grey,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // -------------------------------------------------------------
  // PRODUCT CARD
  // -------------------------------------------------------------
  Widget _buildProductCard(Map<String, dynamic> product, int favId) {
    final productName = product["name"] ?? "Unknown Product";
    final imageUrl = product["imageUrl"] ?? "";
    final price = product["price"] ?? "0";
    final businessName = product["businessName"] ?? "";
    final location = product["location"] ?? "";

    return _wrapWithRemove(
      favId,
      InkWell(
        onTap: () => product["id"] != null
            ? _navigateToProductDetails(product["id"].toString())
            : null,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          margin: const EdgeInsets.only(bottom: 16),
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
              // Product Image
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.network(
                  imageUrl,
                  height: 130,
                  width: 110,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => Container(
                    height: 130,
                    width: 110,
                    color: Colors.grey[200],
                    child: const Center(
                      child: Icon(
                        Icons.shopping_bag,
                        size: 50,
                        color: Colors.grey,
                      ),
                    ),
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

              // Product Details
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      productName,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),

                    const SizedBox(height: 8),

                    Text(
                      "₹$price",
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.green,
                      ),
                    ),

                    if (businessName.isNotEmpty) ...[
                      const SizedBox(height: 6),
                      Text(
                        businessName,
                        style: const TextStyle(
                          fontSize: 14,
                          color: Colors.grey,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],

                    if (location.isNotEmpty) ...[
                      const SizedBox(height: 6),
                      Row(
                        children: [
                          const Icon(
                            Icons.location_on,
                            size: 12,
                            color: Colors.grey,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            location,
                            style: const TextStyle(
                              fontSize: 12,
                              color: Colors.grey,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // -------------------------------------------------------------
  // REMOVE HEART BUTTON WRAPPER
  // -------------------------------------------------------------
  Widget _wrapWithRemove(int favId, Widget child) {
    return Stack(
      children: [
        child,
        Positioned(
          right: 10,
          top: 10,
          child: GestureDetector(
            onTap: () => removeFavourite(favId),
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
              child: const FaIcon(
                FontAwesomeIcons.solidHeart,
                color: Colors.red,
                size: 22,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
