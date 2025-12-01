import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:medbook/services/secure_storage_service.dart';

class ComplaintDialog extends StatefulWidget {
  const ComplaintDialog({super.key});

  @override
  _ComplaintDialogState createState() => _ComplaintDialogState();
}

class _ComplaintDialogState extends State<ComplaintDialog> {
  final TextEditingController subjectController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();
  final TextEditingController locationController = TextEditingController();
  final FlutterSecureStorage _storage = FlutterSecureStorage();

  List<Uint8List> imagePreviews = [];
  List<String> gallery = [];
  bool isUploading = false;

  Future<void> pickImage() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(source: ImageSource.gallery);
    if (picked == null) return;

    final bytes = await picked.readAsBytes();

    if (!mounted) return;
    setState(() {
      isUploading = true;
    });

    final request = http.MultipartRequest(
      'POST',
      Uri.parse('https://medbook-backend-1.onrender.com/api/upload'),
    );

    request.files.add(http.MultipartFile.fromBytes(
      'image',
      bytes,
      filename: picked.name,
      contentType: MediaType('image', 'jpeg'),
    ));

    final response = await request.send();

    if (!mounted) return;

    final respStr = await response.stream.bytesToString();
    final respJson = jsonDecode(respStr);

    if (response.statusCode == 200 && respJson['imageUrl'] != null) {
      setState(() {
        imagePreviews.add(bytes);
        gallery.add(respJson['imageUrl']);
        isUploading = false;
      });
    } else {
      setState(() {
        isUploading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Image upload failed: ${response.statusCode}')),
      );
    }
  }

  void removeImage(int index) {
    setState(() {
      imagePreviews.removeAt(index);
      gallery.removeAt(index);
    });
  }

  Future<void> submitComplaint() async {
    final subject = subjectController.text.trim();
    final desc = descriptionController.text.trim();
    final location = locationController.text.trim();

    if (subject.isEmpty || desc.isEmpty || location.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill all fields')),
      );
      return;
    }

    final storage = SecureStorageService();
    final token = await storage.getToken();

    if (token == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('User not authenticated')),
      );
      return;
    }

    final url = Uri.parse('https://medbook-backend-1.onrender.com/api/complaint');
    final response = await http.post(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode({
        "subject": subject,
        "description": desc,
        "location": location,
        "gallery": gallery,
      }),
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      Navigator.of(context).pop();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Complaint submitted successfully!')),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to submit complaint: ${response.statusCode}')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Send Complaint'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: subjectController,
              decoration: const InputDecoration(labelText: 'Subject'),
            ),
            TextField(
              controller: descriptionController,
              decoration: const InputDecoration(labelText: 'Description'),
              maxLines: 3,
            ),
            TextField(
              controller: locationController,
              decoration: const InputDecoration(labelText: 'Location'),
            ),
            const SizedBox(height: 10),
            if (isUploading) const CircularProgressIndicator(),
            if (imagePreviews.isNotEmpty)
              Column(
                children: List.generate(imagePreviews.length, (index) {
                  return Row(
                    children: [
                      Image.memory(imagePreviews[index], height: 80, width: 80, fit: BoxFit.cover),
                      const SizedBox(width: 8),
                      Expanded(child: Text(gallery[index], maxLines: 2, overflow: TextOverflow.ellipsis)),
                      IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red),
                        onPressed: () => removeImage(index),
                      ),
                    ],
                  );
                }),
              ),
            TextButton.icon(
              onPressed: isUploading ? null : pickImage,
              icon: const Icon(Icons.image),
              label: const Text("Upload Image"),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          child: const Text('Cancel', style: TextStyle(color: Colors.red)),
          onPressed: () => Navigator.of(context).pop(),
        ),
        ElevatedButton(
          onPressed: isUploading ? null : submitComplaint,
          child: const Text('Submit'),
        ),
      ],
    );
  }
}
