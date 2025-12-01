import 'package:flutter/material.dart';
import 'package:medbook/pages/home_page.dart';
import 'blog2.dart';
import 'package:medbook/components/Footer.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class BlogPage extends StatefulWidget {
  const BlogPage({super.key});

  @override
  State<BlogPage> createState() => _BlogPageState();
}

class _BlogPageState extends State<BlogPage> {
  late Future<List<dynamic>> _blogsFuture;
  final String apiUrl = 'https://medbook-backend-cd0b.onrender.com/api/blog/topic';

  @override
  void initState() {
    super.initState();
    _blogsFuture = _fetchBlogs();
  }

  Future<List<dynamic>> _fetchBlogs() async {
    try {
      final response = await ApiServiceBlog.fetchBlogs(apiUrl);
      return response;
    } catch (e) {
      debugPrint('Error fetching blogs: $e');
      rethrow;
    }
  }

  void _navigateToHomePage() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const HomePage()),
    );
  }

  void _navigateToFirstBlog() async {
    try {
      final blogs = await _blogsFuture;
      if (blogs.isNotEmpty) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => BlogDetailPage(blog: blogs[0]),
          ),
        );
      }
    } catch (e) {
      debugPrint('Navigation error: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7FAFC),
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
              'Health Guide',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            backgroundColor: Colors.transparent,
            elevation: 2,
            centerTitle: true,
            iconTheme: const IconThemeData(color: Colors.white),
          ),
        ),
      ),

      body: GestureDetector(
        onPanUpdate: (details) {
          if (details.delta.dx > 10) {
            _navigateToFirstBlog();
          } else if (details.delta.dx < -10) {
            _navigateToHomePage();
          }
        },
        child: FutureBuilder<List<dynamic>>(
          future: _blogsFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(
                    Color.fromARGB(255, 239, 48, 34),
                  ),
                ),
              );
            } else if (snapshot.hasError) {
              return _buildErrorWidget(snapshot.error!);
            } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return const Center(
                child: Text(
                  'No blogs available.',
                  style: TextStyle(
                    fontSize: 18,
                    color: Colors.grey,
                  ),
                ),
              );
            }

            final blogs = snapshot.data!;

            return LayoutBuilder(
              builder: (context, constraints) {
                int crossAxisCount = 1;
                if (constraints.maxWidth > 1200) {
                  crossAxisCount = 3;
                } else if (constraints.maxWidth > 800) {
                  crossAxisCount = 2;
                }

                return RefreshIndicator(
                  onRefresh: () async {
                    setState(() {
                      _blogsFuture = _fetchBlogs();
                    });
                    await _blogsFuture;
                  },
                  color: const Color.fromARGB(255, 239, 48, 34),
                  
                  child: GridView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: blogs.length,
                    gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
  maxCrossAxisExtent: 250, // Decent width for each card
  crossAxisSpacing: 16,
  mainAxisSpacing: 16,
  childAspectRatio: 3 / 4, // You can adjust this based on card height
),
                    itemBuilder: (context, index) {
                      final blog = blogs[index];
                      final imageUrl = blog['bannerUrl'] ;
                      final title = blog['topic']?.toString() ?? 'Untitled';

                      return InkWell(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => BlogDetailPage(blog: blog),
                            ),
                          );
                        },
                        borderRadius: BorderRadius.circular(8),
                        child: Card(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          elevation: 4,
                          clipBehavior: Clip.antiAlias,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                child: imageUrl != null 
                                  ? Image.network(
                                      imageUrl,
                                      width: double.infinity,
                                      fit: BoxFit.cover,
                                      loadingBuilder: (context, child, loadingProgress) {
                                        if (loadingProgress == null) return child;
                                        return Center(
                                          child: CircularProgressIndicator(
                                            value: loadingProgress.expectedTotalBytes != null
                                                ? loadingProgress.cumulativeBytesLoaded /
                                                    loadingProgress.expectedTotalBytes!
                                                : null,
                                          ),
                                        );
                                      },
                                    )
                                  : Container(
                                      color: Colors.grey[200],
                                      child: const Center(
                                        child: Icon(
                                          Icons.image_not_supported,
                                          color: Colors.grey,
                                          size: 40,
                                        ),
                                      ),
                                    ),
                              ),
                              Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                                child: Text(
                                  title,
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                    color: Color(0xFF333333),
                                  ),
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
            );
          },
        ),
      ),
      bottomNavigationBar: const Footer(title: "none"),
    );
  }

  Widget _buildErrorWidget(dynamic error) {
    String errorMessage = 'An error occurred';
    String details = '';

    if (error is FormatException) {
      errorMessage = 'Data format error';
      details = error.message;
    } else if (error is http.ClientException) {
      errorMessage = 'Network error';
      details = error.message;
    } else if (error is Exception) {
      errorMessage = error.toString();
    }

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(8),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, color: Colors.red, size: 50),
            const SizedBox(height: 20),
            Text(
              errorMessage,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.red,
              ),
              textAlign: TextAlign.center,
            ),
            if (details.isNotEmpty) ...[
              const SizedBox(height: 10),
              Text(
                details,
                style: const TextStyle(fontSize: 14),
                textAlign: TextAlign.center,
              ),
            ],
            const SizedBox(height: 20),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color.fromARGB(255, 239, 48, 34),
                foregroundColor: Colors.white,
              ),
              onPressed: () {
                setState(() {
                  _blogsFuture = _fetchBlogs();
                });
              },
              child: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }
}

class ApiServiceBlog {
  static Future<List<dynamic>> fetchBlogs(String apiUrl) async {
    try {
      final response = await http.get(
        Uri.parse(apiUrl),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      );

      debugPrint('API Response Status: ${response.statusCode}');
      debugPrint('API Response Body: ${response.body}');

      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);
        
        // Handle the specific format your API is using
        if (jsonData is Map && jsonData.containsKey('resultData')) {
          if (jsonData['resultData'] is List) {
            return jsonData['resultData'];
          }
        }
        // Keep the other format checks as fallback
        else if (jsonData is List) {
          return jsonData;
        }
        else if (jsonData is Map) {
          if (jsonData['data'] is List) {
            return jsonData['data'];
          } else if (jsonData['blogs'] is List) {
            return jsonData['blogs'];
          } else if (jsonData['items'] is List) {
            return jsonData['items'];
          } else if (jsonData['results'] is List) {
            return jsonData['results'];
          }
        }

        throw FormatException(
          'Unexpected API response format. Expected a list or object with list property.\n'
          'Received type: ${jsonData.runtimeType}\n'
          'Full response: $jsonData'
        );
      } else {
        throw http.ClientException(
          'Request failed with status ${response.statusCode}\n'
          'Response: ${response.body}'
        );
      }
    } on http.ClientException {
      rethrow;
    } on FormatException {
      rethrow;
    } catch (e) {
      throw Exception('Failed to fetch blogs: $e');
    }
  }
}