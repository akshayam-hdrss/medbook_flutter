import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:medbook/components/common/loading_widget.dart';
import 'package:medbook/widgets/ComplaintDetails.dart';
import '../widgets/complaint_popup.dart';
import '../components/footer.dart';
import 'package:medbook/services/secure_storage_service.dart';

class ComplainPage extends StatefulWidget {
  const ComplainPage({super.key});

  @override
  State<ComplainPage> createState() => _ComplainPageState();
}

class _ComplainPageState extends State<ComplainPage> {
  List<dynamic> allComplaints = [];
  List<dynamic> myComplaints = [];

  bool isLoading = true;
  bool isLoadingMy = true;

  final storage = SecureStorageService();

  @override
  void initState() {
    super.initState();
    fetchAllComplaints();
    fetchMyComplaints();
  }

  Future<void> fetchAllComplaints() async {
    final url = Uri.parse('https://medbook-backend-1.onrender.com/api/complaints');
    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          allComplaints = data['complaints'] ?? [];
          isLoading = false;
        });
      } else {
        throw Exception("Failed to load all complaints");
      }
    } catch (e) {
      print('Error fetching all complaints: $e');
      setState(() => isLoading = false);
    }
  }

  Future<void> fetchMyComplaints() async {
    final token = await storage.getToken(); // jwt_token
    final url = Uri.parse('https://medbook-backend-1.onrender.com/api/complaints/user');

    try {
      final response = await http.get(
        url,
        headers: {'Authorization': 'Bearer $token'},
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          myComplaints = data['complaints'] ?? [];
          isLoadingMy = false;
        });
      } else {
        print("Failed to fetch my complaints: ${response.body}");
        setState(() => isLoadingMy = false);
      }
    } catch (e) {
      print('Error fetching my complaints: $e');
      setState(() => isLoadingMy = false);
    }
  }

  void refreshMyComplaints() {
    setState(() {
      isLoadingMy = true;
    });
    fetchMyComplaints();
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: Colors.white,
       appBar: PreferredSize(
  preferredSize: const Size.fromHeight(kToolbarHeight + 48),
  child: Container(
    decoration: const BoxDecoration(
      gradient: LinearGradient(
        colors: [
          Color.fromARGB(255, 225, 119, 20), // Orange
          Color.fromARGB(255, 239, 48, 34),  // Red
        ],
        stops: [0.0, 0.5],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
    ),
    child: AppBar(
      centerTitle: true,
      backgroundColor: Colors.transparent,
      elevation: 0,
      iconTheme: const IconThemeData(color: Colors.white),
      title: const Text(
        'Complaints',
        style: TextStyle(color: Colors.white),
      ),
      bottom: const PreferredSize(
        preferredSize: Size.fromHeight(48),
        child: Column(
          children: [
            Divider(
              height: 1,
              thickness: 1,
              color: Colors.white,
            ),
            TabBar(
              labelColor: Colors.white,
              unselectedLabelColor: Colors.white70,
              indicatorColor: Colors.white,
              tabs: [
                Tab(text: 'All Complaints'),
                Tab(text: 'My Complaints'),
              ],
            ),
          ],
        ),
      ),
    ),
  ),
),


        body: TabBarView(
          children: [
            buildComplaintsTab(context, allComplaints, isLoading),
            buildMyComplaintsTab(context),
          ],
        ),
        bottomNavigationBar: Footer(title: "Complaint"),
      ),
    );
  }

  Widget buildComplaintsTab(BuildContext context, List<dynamic> list, bool loading) {
    double screenWidth = MediaQuery.of(context).size.width;
    double cardWidth = screenWidth < 600 ? screenWidth * 0.9 : 500;

    if (loading) return const AppLoadingWidget();
    if (list.isEmpty) return const Center(child: Text("No complaints found."));

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: list
            .map((complaint) => _buildComplaintCard(context, cardWidth, complaint))
            .toList(),
      ),
    );
  }

  Widget buildMyComplaintsTab(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double cardWidth = screenWidth < 600 ? screenWidth * 0.9 : 500;

    if (isLoadingMy) {
      return const AppLoadingWidget();
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          if (myComplaints.isEmpty)
            const Text("You have not submitted any complaints yet."),
          ...myComplaints
              .map((complaint) => _buildComplaintCard(context, cardWidth, complaint))
              ,
          const SizedBox(height: 20),
          Center(
            child: ElevatedButton(
              onPressed: () async {
                await showDialog(
                  context: context,
                  builder: (_) => ComplaintDialog(),
                );
                refreshMyComplaints(); // Refresh after submission
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.deepOrange,
                padding:
                    const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
              ),
              child: const Text(
                'Send Your Complaint',
                style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildComplaintCard(BuildContext context, double cardWidth, dynamic complaint) {
     return GestureDetector(
    onTap: () => showComplaintDetailsDialog(context, complaint),
    child: Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Container(
        width: cardWidth,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: const [
            BoxShadow(color: Colors.black26, blurRadius: 6, offset: Offset(0, 3)),
          ],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const CircleAvatar(
              radius: 30,
              backgroundColor: Colors.grey,
              child: Icon(Icons.person, color: Colors.white, size: 50),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    complaint['subject'] ?? 'No Subject',
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    complaint['description'] ?? '',
                    style: const TextStyle(color: Colors.black87),
                  ),
                  const SizedBox(height: 5),
                  if (complaint['location'] != null)
                    Text(
                      '📍 ${complaint['location']}',
                      style: const TextStyle(color: Colors.black54),
                    ),
                  const SizedBox(height: 8),
                  if (complaint['gallery'] != null &&
                      complaint['gallery'].isNotEmpty)
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.network(
                        complaint['gallery'][0],
                        height: 120,
                        width: double.infinity,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) =>
                            const Text('Image not available'),
                      ),
                    ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Text('Status: ',
                          style: TextStyle(fontWeight: FontWeight.w600)),
                      Text(
                        complaint['status'] ?? 'Unknown',
                        style: TextStyle(
                          color: (complaint['status'] == 'Completed')
                              ? Colors.green
                              : Colors.orange,
                        ),
                      ),
                    ],
                  )
                ],
              ),
            ),
          ],
        ),
      ),
    )
  );
  }
}
