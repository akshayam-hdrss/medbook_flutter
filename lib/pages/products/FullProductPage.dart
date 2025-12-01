// import 'package:flutter/material.dart';
// import 'package:medbook/components/footer.dart';
// import 'package:medbook/pages/products/product_page.dart';

// class FullProductPage extends StatelessWidget {
//   final List<dynamic> products;

//   const FullProductPage({super.key, required this.products});

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: PreferredSize(
//         preferredSize: const Size.fromHeight(kToolbarHeight),
//         child: Container(
//           decoration: const BoxDecoration(
//             gradient: LinearGradient(
//               colors: [
//                 Color.fromARGB(255, 225, 119, 20), // Orange
//                 Color.fromARGB(255, 239, 48, 34), // Red
//               ],
//               stops: [0.0, 0.5],
//               begin: Alignment.topLeft,
//               end: Alignment.bottomRight,
//             ),
//           ),
//           child: AppBar(
//             title: const Text(
//               'All Products',
//               style: TextStyle(color: Colors.white),
//             ),
//             backgroundColor: Colors.transparent, // to let gradient show
//             elevation: 0,
//             foregroundColor: Colors.white,
//             iconTheme: const IconThemeData(color: Colors.white),
//             centerTitle: true,
//           ),
//         ),
//       ),

//       body: Padding(
//         padding: const EdgeInsets.all(16.0),
//         child: GridView.builder(
//           itemCount: products.length,
//           gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
//             crossAxisCount: 3,
//             mainAxisSpacing: 16,
//             crossAxisSpacing: 16,
//             childAspectRatio: 0.9,
//           ),
//           itemBuilder: (context, index) {
//             final product = products[index];
//             return _buildGridCard(
//               imageUrl: product['imageUrl'],
//               title: product['productName'],
//               onTap: () {
//                 Navigator.push(
//                   context,
//                   MaterialPageRoute(
//                     builder: (context) =>
//                         ProductPage(productId: product['id'].toString()),
//                   ),
//                 );
//               },
//             );
//           },
//         ),
//       ),
//        bottomNavigationBar: const Footer(title: "none"),
//     );
//   }

//   Widget _buildGridCard({
//     required String imageUrl,
//     required String title,
//     required VoidCallback onTap,
//   }) {
//     return GestureDetector(
//       onTap: onTap,
//       child: Container(
//         decoration: BoxDecoration(
//           gradient: const LinearGradient(
//             colors: [Color(0xFFF7F5F5), Color(0xFFFAF0F0)],
//             begin: Alignment.topLeft,
//             end: Alignment.bottomRight,
//           ),
//           borderRadius: BorderRadius.circular(20),
//           border: Border.all(
//             color: const Color.fromARGB(255, 182, 179, 179),
//             width: 1,
//           ),
//           boxShadow: [
//             BoxShadow(
//               color: const Color.fromARGB(255, 154, 152, 152).withOpacity(0.05),
//               blurRadius: 8,
//               offset: const Offset(2, 4),
//             ),
//           ],
//         ),

//         padding: const EdgeInsets.all(12),
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             Expanded(
//               child: ClipRRect(
//                 borderRadius: BorderRadius.circular(16),
//                 child: Image.network(
//                   imageUrl,
//                   fit: BoxFit.contain,
//                   width: double.infinity,
//                   errorBuilder: (context, error, stackTrace) =>
//                       const Icon(Icons.broken_image, size: 40),
//                 ),
//               ),
//             ),
//             const SizedBox(height: 8),
//             FittedBox(
//               fit: BoxFit.scaleDown,
//               child: Text(
//                 title,
//                 textAlign: TextAlign.center,
//                 style: const TextStyle(
//                   fontSize: 13,
//                   fontWeight: FontWeight.w600,
//                   color: Colors.black,
//                 ),
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }

import 'package:flutter/material.dart';
import 'package:medbook/components/footer.dart';
import 'package:medbook/pages/products/productpage0.dart';

class FullProductPage extends StatefulWidget {
  final List<dynamic> products;

  const FullProductPage({super.key, required this.products});

  @override
  State<FullProductPage> createState() => _FullProductPageState();
}

class _FullProductPageState extends State<FullProductPage> {
  late List<dynamic> _filteredProducts;
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _filteredProducts = widget.products;
    _searchController.addListener(_filterProducts);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _filterProducts() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      _filteredProducts = widget.products.where((product) {
        final name = (product['productName'] ?? '').toLowerCase();
        return name.contains(query);
      }).toList();
    });
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
              stops: [0.0, 0.5],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: AppBar(
            title: const Text(
              'All Products',
              style: TextStyle(color: Colors.white),
            ),
            backgroundColor: Colors.transparent,
            elevation: 0,
            foregroundColor: Colors.white,
            iconTheme: const IconThemeData(color: Colors.white),
            centerTitle: true,
          ),
        ),
      ),
      body: Column(
        children: [
          // Search Bar
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Container(
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
                style: TextStyle(fontSize: 16, color: Colors.grey.shade800),
              ),
            ),
          ),
          // Products Grid
          Expanded(
            child: _filteredProducts.isEmpty
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
                          'Try a different search term',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey.withOpacity(0.5),
                          ),
                        ),
                      ],
                    ),
                  )
                : Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: GridView.builder(
                      itemCount: _filteredProducts.length,
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 3,
                            mainAxisSpacing: 16,
                            crossAxisSpacing: 16,
                            childAspectRatio: 0.9,
                          ),
                      itemBuilder: (context, index) {
                        final product = _filteredProducts[index];
                        return _buildGridCard(
                          context: context,
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
                        );
                      },
                    ),
                  ),
          ),
        ],
      ),
      bottomNavigationBar: const Footer(title: "none"),
    );
  }

  Widget _buildGridCard({
    required BuildContext context, // ✅ pass context
    required String imageUrl,
    required String title,
    required VoidCallback onTap,
  }) {
    // Get screen width to adjust font size dynamically
    double screenWidth = MediaQuery.of(context).size.width;
    double fontSize = screenWidth < 360
        ? 10
        : screenWidth < 600
        ? 13
        : 22;

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
                overflow: TextOverflow.ellipsis,
                softWrap: true,
                style: TextStyle(
                  fontSize: fontSize, // ✅ Now dynamic
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
}
