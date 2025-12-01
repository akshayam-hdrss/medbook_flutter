import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:medbook/components/Charities/CharitiesPage2.dart';
import 'package:medbook/components/Footer.dart';
import 'package:medbook/components/common/loading_widget.dart';
import 'package:medbook/pages/home_page.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class CharitiesPage1 extends StatefulWidget {
  const CharitiesPage1({super.key});

  @override
  State<CharitiesPage1> createState() => _CharitiesPage1State();
}

class _CharitiesPage1State extends State<CharitiesPage1> {
  List<dynamic> charities = [];
  bool isLoading = true;
  bool hasError = false;
  String errorMessage = '';

  @override
  void initState() {
    super.initState();
    fetchCharities();
  }

  Future<void> fetchCharities() async {
    try {
      final response = await http
          .get(
            Uri.parse(
              'https://medbook-backend-cd0b.onrender.com/api/charities/',
            ),
          )
          .timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final jsonResponse = jsonDecode(response.body);
        if (jsonResponse is Map && jsonResponse['resultData'] is List) {
          setState(() {
            charities = jsonResponse['resultData'];
            isLoading = false;
            hasError = false;
          });
        } else {
          throw FormatException(
            'Invalid data format: Expected resultData array',
          );
        }
      } else {
        throw HttpException('HTTP ${response.statusCode}: ${response.body}');
      }
    } on http.ClientException catch (e) {
      _handleError('Network error: ${e.message}');
    } on FormatException catch (e) {
      _handleError('Data format error: ${e.message}');
    } on TimeoutException {
      _handleError('Request timed out');
    } catch (e) {
      _handleError('Unexpected error: $e');
    }
  }

  void _handleError(String message) {
    debugPrint(message);
    setState(() {
      isLoading = false;
      hasError = true;
      errorMessage = 'Failed to load charities. Please try again later.';
    });
  }

  void _retryFetch() {
    setState(() {
      isLoading = true;
      hasError = false;
    });
    fetchCharities();
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
                Color.fromARGB(255, 225, 119, 20),
                Color.fromARGB(255, 239, 48, 34),
              ],
              stops: [0.0, 0.5],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: AppBar(
            leading: IconButton(
              icon: const Icon(Icons.arrow_back),
              onPressed: () {
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (context) => HomePage()),
                  (route) => false,
                );
              },
            ),
            title: const Text(
              'Charities',
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
      backgroundColor: const Color(0xFFF8F6FF),
      body: isLoading
          ? const AppLoadingWidget()
          : hasError
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Text(errorMessage),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: _retryFetch,
                    child: const Text('Retry'),
                  ),
                ],
              ),
            )
          : LayoutBuilder(
              builder: (context, constraints) {
                int crossAxisCount = 1;
                double childAspectRatio = 2.0;
                double horizontalPadding = 20;

                if (constraints.maxWidth >= 1024) {
                  crossAxisCount = 3;
                  childAspectRatio = 1.6;
                  horizontalPadding = 24;
                } else if (constraints.maxWidth >= 600) {
                  crossAxisCount = 2;
                  childAspectRatio = 1.8;
                  horizontalPadding = 20;
                } else {
                  crossAxisCount = 1;
                  childAspectRatio = 1.5;
                  horizontalPadding = 16;
                }

                return Center(
                  child: Container(
                    constraints: const BoxConstraints(maxWidth: 1000),
                    padding: EdgeInsets.symmetric(
                      horizontal: horizontalPadding,
                      vertical: 20,
                    ),
                    child: GridView.builder(
                      itemCount: charities.length,
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: crossAxisCount,
                        crossAxisSpacing: 16,
                        mainAxisSpacing: 16,
                        childAspectRatio: childAspectRatio,
                      ),
                      itemBuilder: (context, index) {
                        final charity = charities[index];
                        return CharityCard(
                          title: charity['title'] ?? 'No Title',
                          description:
                              charity['description'] ?? 'No Description',
                          imagePath:
                              charity['imageUrl'] ??
                              'lib/Assets/images/DoctorPic.png',
                          charityId: charity['id']?.toString() ?? '',
                        );
                      },
                    ),
                  ),
                );
              },
            ),
      bottomNavigationBar: const Footer(title: "Charity"),
    );
  }
}

class CharityCard extends StatelessWidget {
  final String title;
  final String description;
  final String imagePath;
  final String charityId;

  const CharityCard({
    super.key,
    required this.title,
    required this.description,
    required this.imagePath,
    required this.charityId,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => CharityPage2(charityId: charityId),
          ),
        );
      },
      borderRadius: BorderRadius.circular(8),
      child: Card(
        elevation: 3,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(12),
                bottomLeft: Radius.circular(12),
              ),
              child: Image.network(
                imagePath,
                width: 120,
                height: 150,
                fit: BoxFit.cover,
                loadingBuilder: (context, child, loadingProgress) {
                  if (loadingProgress == null) return child;
                  return Center(child: AppLoadingWidget());
                },
                errorBuilder: (context, error, stackTrace) => Image.asset(
                  'lib/Assets/images/DoctorPic.png',
                  width: 120,
                  height: 150,
                  fit: BoxFit.contain,
                ),
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      description,
                      style: const TextStyle(
                        fontSize: 14,
                        color: Colors.black87,
                      ),
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
