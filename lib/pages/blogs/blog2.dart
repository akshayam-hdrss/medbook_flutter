import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:medbook/components/Footer.dart';
import 'package:medbook/components/common/loading_widget.dart';
import 'package:medbook/pages/blogs/blog3.dart';

class BlogDetailPage extends StatefulWidget {
  final Map<String, dynamic> blog;

  const BlogDetailPage({super.key, required this.blog});

  @override
  State<BlogDetailPage> createState() => _BlogDetailPageState();
}

class _BlogDetailPageState extends State<BlogDetailPage> {
  List<dynamic> blogList = [];
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    fetchRelatedBlogs();
  }

  Future<void> fetchRelatedBlogs() async {
    setState(() {
      isLoading = true;
    });

    try {
      final blogId = widget.blog['id']?.toString() ?? '';
      final response = await http.get(
        Uri.parse(
          'https://medbook-backend-1.onrender.com/api/blog/bytopic/$blogId',
        ),
      );

      if (response.statusCode == 200) {
        final jsonResponse = json.decode(response.body);
        final blogs = jsonResponse['resultData'];

        setState(() {
          blogList = blogs is List ? blogs : [blogs];
          isLoading = false;
        });
      } else {
        setState(() {
          isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      print('Error fetching blogs: $e');
    }
  }

  @override
  @override
  Widget build(BuildContext context) {
    final blog = widget.blog;
    final String topic = blog['topic'] ?? 'No Topic';
    final String bannerUrl = blog['bannerUrl'] ?? '';
    final String description =
        blog['description'] ?? 'No description available';

    return Scaffold(
      backgroundColor: const Color(0xFFF7FAFC),
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(kToolbarHeight),
        child: AppBar(
          centerTitle: true,
          title: Text(topic, style: const TextStyle(color: Colors.white)),
          flexibleSpace: Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Color(0xFFE85520),
                  Color(0xFFEA7E4D),
                ], // Your gradient colors
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
          ),
          elevation: 2,
          backgroundColor: Colors.transparent, // ✅ Transparent to show gradient
          iconTheme: const IconThemeData(color: Colors.white),
        ),
      ),

      body: LayoutBuilder(
        builder: (context, constraints) {
          final isTablet = constraints.maxWidth > 600;
          final contentWidth = isTablet ? 600.0 : double.infinity;
          final horizontalPadding = isTablet ? 24.0 : 16.0;

          return SingleChildScrollView(
            child: Center(
              child: SizedBox(
                width: contentWidth,
                child: Column(
                  children: [
                    // Banner Image
                    ClipRRect(
                      borderRadius: const BorderRadius.only(
                        bottomLeft: Radius.circular(18),
                        bottomRight: Radius.circular(18),
                      ),
                      child: bannerUrl.isNotEmpty
                          ? Image.network(
                              bannerUrl,
                              width: double.infinity,
                              height: isTablet ? 280 : 220,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) {
                                return Container(
                                  width: double.infinity,
                                  height: 220,
                                  color: Colors.grey[300],
                                  child: const Icon(Icons.image_not_supported),
                                );
                              },
                            )
                          : Container(
                              width: double.infinity,
                              height: 220,
                              color: Colors.grey[300],
                              child: const Icon(Icons.image_not_supported),
                            ),
                    ),

                    const SizedBox(height: 16),

                    // Description Box
                    Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: horizontalPadding,
                      ),
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.grey.shade300,
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Text(
                          description,
                          style: TextStyle(
                            fontSize: isTablet ? 18 : 16,
                            color: Colors.black87,
                            height: 1.6,
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 24),

                    // Related Blogs
                    Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: horizontalPadding,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Related Blogs',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 12),
                          if (isLoading)
                            const AppLoadingWidget()
                          else if (blogList.isEmpty)
                            const Text('No related blogs found')
                          else
                            ...blogList.map((item) {
                              final imageUrl =
                                  item['imageUrl']?.toString() ?? '';
                              final title =
                                  item['title']?.toString() ?? 'Untitled';
                              final author =
                                  item['author']?.toString() ?? 'Unknown';
                              final blogId = item['id']?.toString() ?? '';

                              return InkWell(
                                onTap: () {
                                  if (blogId.isNotEmpty) {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) =>
                                            BlogPage3(blogId: blogId),
                                      ),
                                    );
                                  }
                                },
                                child: Container(
                                  margin: const EdgeInsets.only(bottom: 16),
                                  padding: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(10),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.grey.shade300,
                                        blurRadius: 6,
                                        offset: const Offset(0, 2),
                                      ),
                                    ],
                                  ),
                                  child: Row(
                                    children: [
                                      ClipRRect(
                                        borderRadius: BorderRadius.circular(8),
                                        child: imageUrl.isNotEmpty
                                            ? Image.network(
                                                imageUrl,
                                                width: 70,
                                                height: 70,
                                                fit: BoxFit.cover,
                                              )
                                            : Container(
                                                width: 70,
                                                height: 70,
                                                color: Colors.grey[200],
                                                child: const Icon(Icons.image),
                                              ),
                                      ),
                                      const SizedBox(width: 12),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              title,
                                              style: const TextStyle(
                                                fontSize: 16,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                            const SizedBox(height: 6),
                                            Text(
                                              'By $author',
                                              style: const TextStyle(
                                                color: Colors.black54,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            }),
                        ],
                      ),
                    ),

                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),
          );
        },
      ),
      bottomNavigationBar: const Footer(title: "none"),
    );
  }
}
