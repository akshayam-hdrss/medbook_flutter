import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:medbook/components/Footer.dart';
import 'package:medbook/components/common/loading_widget.dart';
import 'package:medbook/utils/api_service.dart';
import 'package:medbook/pages/products/product_page3.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:medbook/Services/secure_storage_service.dart';

class ProductPage2 extends StatefulWidget {
  final String productTypeId;

  const ProductPage2({super.key, required this.productTypeId});

  @override
  State<ProductPage2> createState() => _ProductPage2State();
}

class _ProductPage2State extends State<ProductPage2> {
  List<dynamic> productList = [];
  List<dynamic> filteredProducts = [];
  bool isLoading = true;
  final TextEditingController _searchController = TextEditingController();
  String _selectedLocation = 'All Locations';
  List<String> locations = ['All Locations'];

  // ⭐ Favourite system for PRODUCTS
  Map<String, bool> favouriteStatus = {};
  Map<String, int?> favouriteIds = {};
  String? _userId;

  @override
  void initState() {
    super.initState();
    _initializeData();
    _searchController.addListener(_filterProducts);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  // ⭐ Initialize all data
  Future<void> _initializeData() async {
    await _loadUserId();
    await loadFavourites();
    await fetchProductList();
  }

  // ⭐ Load user ID from secure storage
  Future<void> _loadUserId() async {
    final storage = SecureStorageService();
    final user = await storage.getUserDetails();
    _userId = user?["id"]?.toString();
  }

  // ⭐ Fetch favourite PRODUCTS - USING SPECIFIC USER ID ENDPOINT
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
        // Check for PRODUCT favorites (not doctor or service)
        final productId = fav["productId"]?.toString();
        if (productId != null) {
          favouriteStatus[productId] = true;
          favouriteIds[productId] = fav["id"];
        }
      }

      if (mounted) {
        setState(() {});
      }
    } catch (e) {
      print("Favourite load error: $e");
    }
  }

  // ⭐ Add PRODUCT to favourite - USING CORRECT ENDPOINT
  Future<void> addFavourite(String productId) async {
    if (_userId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please login to add favourites")),
      );
      return;
    }

    // Optimistic UI update
    favouriteStatus[productId] = true;
    if (mounted) setState(() {});

    try {
      // ✅ CORRECT ENDPOINT for adding PRODUCT favorites
      final url = Uri.parse(
        "https://medbook-backend-1.onrender.com/api/userfavorites/favorites/",
      );
      final body = jsonEncode({"productId": productId, "userId": _userId});

      final res = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: body,
      );

      if (res.statusCode == 200 || res.statusCode == 201) {
        final saved = jsonDecode(res.body);
        favouriteIds[productId] = saved["id"];

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Added to favourites"),
            duration: Duration(seconds: 2),
          ),
        );
      } else {
        // Revert on error
        favouriteStatus[productId] = false;
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
      favouriteStatus[productId] = false;
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

  // ⭐ Remove PRODUCT from favourite - USING CORRECT ENDPOINT
  Future<void> removeFavourite(String productId) async {
    final favId = favouriteIds[productId];
    if (favId == null) return;

    // Optimistic UI update
    favouriteStatus[productId] = false;
    if (mounted) setState(() {});

    try {
      // ✅ CORRECT ENDPOINT for removing PRODUCT favorites
      final url = Uri.parse(
        "https://medbook-backend-1.onrender.com/api/userfavorites/favorites/$favId",
      );

      final res = await http.delete(url);

      if (res.statusCode == 200) {
        favouriteIds[productId] = null;

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Removed from favourites"),
            duration: Duration(seconds: 2),
          ),
        );
      } else {
        // Revert on error
        favouriteStatus[productId] = true;
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
      favouriteStatus[productId] = true;
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

  Future<void> fetchProductList() async {
    try {
      final data = await ApiService.fetchProductsByProductType(
        widget.productTypeId,
      );
      final uniqueLocations = data
          .map((e) => e['location']?.toString().trim() ?? 'Unknown Location')
          .toSet()
          .toList();

      setState(() {
        productList = data;
        filteredProducts = data;
        locations = ['All Locations', ...uniqueLocations];
        isLoading = false;
      });
    } catch (e) {
      print("Error fetching product list: $e");
      setState(() {
        isLoading = false;
      });
    }
  }

  void _filterProducts() {
    String query = _searchController.text.toLowerCase();
    setState(() {
      filteredProducts = productList.where((product) {
        final name = (product['productName'] ?? '').toLowerCase();
        final business = (product['businessName'] ?? '').toLowerCase();
        final location = (product['location'] ?? '').toString().trim();

        final matchesSearch =
            query.isEmpty || name.contains(query) || business.contains(query);
        final matchesLocation =
            _selectedLocation == 'All Locations' ||
            location == _selectedLocation;

        return matchesSearch && matchesLocation;
      }).toList();
    });
  }

  void showMessage(String message) {
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
              " Products",
              style: TextStyle(color: Colors.white),
            ),
            backgroundColor: Colors.transparent,
            elevation: 0,
            centerTitle: true,
            iconTheme: const IconThemeData(color: Colors.white),
            foregroundColor: Colors.white,
          ),
        ),
      ),
      body: isLoading
          ? const AppLoadingWidget()
          : productList.isEmpty
          ? const Center(child: Text("No related products found."))
          : Column(
              children: [
                // Search and Filter Bar
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
                            hintText: 'Search products...',
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
                                      _filterProducts();
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
                          onChanged: (_) => _filterProducts(),
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
                              _filterProducts();
                            });
                          },
                        ),
                      ),
                    ],
                  ),
                ),
                // Products List
                Expanded(
                  child: filteredProducts.isEmpty
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
                          itemCount: filteredProducts.length,
                          itemBuilder: (context, index) {
                            final product = filteredProducts[index];
                            final imageUrl = product['imageUrl'] ?? '';
                            final productName = product['productName'] ?? 'N/A';
                            final businessName = product['businessName'] ?? '';
                            final location = product['location'] ?? '';
                            final price = product['price']?.toString() ?? 'N/A';
                            final phone = product['phone'] ?? '';
                            final productId = product['id'].toString();
                            final isFav = favouriteStatus[productId] == true;

                            return Stack(
                              children: [
                                GestureDetector(
                                  onTap: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) =>
                                            ProductPage3(productId: productId),
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
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        ClipRRect(
                                          borderRadius: BorderRadius.circular(
                                            12,
                                          ),
                                          child: Image.network(
                                            imageUrl.isNotEmpty ? imageUrl : "",
                                            height: 140,
                                            width: 120,
                                            fit: BoxFit.cover,
                                            errorBuilder:
                                                (context, error, stackTrace) {
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
                                                productName,
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
                                              Text(
                                                'Price: ₹$price',
                                                style: const TextStyle(
                                                  fontSize: 14,
                                                  fontWeight: FontWeight.w600,
                                                  color: Colors.deepOrange,
                                                ),
                                              ),
                                              const SizedBox(height: 10),
                                              Row(
                                                children: [
                                                  GestureDetector(
                                                    onTap: () => showMessage(
                                                      "Calling $phone...",
                                                    ),
                                                    child: _actionIcon(
                                                      FontAwesomeIcons.phone,
                                                      Colors.lightBlueAccent,
                                                    ),
                                                  ),
                                                  const SizedBox(width: 12),
                                                  GestureDetector(
                                                    onTap: () => showMessage(
                                                      "Opening WhatsApp for $phone...",
                                                    ),
                                                    child: _actionIcon(
                                                      FontAwesomeIcons.whatsapp,
                                                      Colors.green,
                                                    ),
                                                  ),
                                                  const SizedBox(width: 12),
                                                  GestureDetector(
                                                    onTap: () => showMessage(
                                                      "Showing map for $location...",
                                                    ),
                                                    child: _actionIcon(
                                                      FontAwesomeIcons
                                                          .mapMarkerAlt,
                                                      const Color(0xFFFF5722),
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

                                // ❤️ Favourite button for PRODUCTS
                                Positioned(
                                  right: 10,
                                  top: 10,
                                  child: StatefulBuilder(
                                    builder: (context, refresh) {
                                      return GestureDetector(
                                        onTap: () async {
                                          if (isFav) {
                                            await removeFavourite(productId);
                                          } else {
                                            await addFavourite(productId);
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
                                            borderRadius: BorderRadius.circular(
                                              20,
                                            ),
                                            boxShadow: [
                                              BoxShadow(
                                                color: Colors.black.withOpacity(
                                                  0.1,
                                                ),
                                                blurRadius: 4,
                                                offset: const Offset(0, 2),
                                              ),
                                            ],
                                          ),
                                          child: Icon(
                                            isFav
                                                ? Icons.favorite
                                                : Icons.favorite_border,
                                            color: isFav
                                                ? Colors.red
                                                : Colors.grey,
                                            size: 24,
                                          ),
                                        ),
                                      );
                                    },
                                  ),
                                ),
                              ],
                            );
                          },
                        ),
                ),
              ],
            ),
      bottomNavigationBar: const Footer(title: "none"),
    );
  }

  Widget _actionIcon(IconData icon, Color color) {
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
}
