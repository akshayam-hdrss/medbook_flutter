import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;
import 'package:medbook/components/common/loading_widget.dart';
import 'package:medbook/services/secure_storage_service.dart';

class ServiceSchedule extends StatefulWidget {
  final String serviceName;
  final String serviceId;
  final String servicePhone;

  const ServiceSchedule({
    super.key,
    required this.serviceName,
    required this.serviceId,
    required this.servicePhone,
  });

  @override
  State<ServiceSchedule> createState() => _ServiceScheduleState();
}

class _ServiceScheduleState extends State<ServiceSchedule> {
  DateTime selectedDate = DateTime.now();
  String selectedSlot = '';
  String customerGender = "Male";

  final nameController = TextEditingController();
  final ageController = TextEditingController();
  final descriptionController = TextEditingController();
  final contactController = TextEditingController();

  final List<String> slots = [];
  bool showAllSlots = false;

  bool isLoading = true;
  bool bookingAvailable = true;
  int? fetchedServiceId;

  final ScrollController _scrollController = ScrollController();
  final GlobalKey _detailsKey = GlobalKey();

  @override
  void initState() {
    super.initState();
    fetchServiceByPhone();
    generateTimeSlots();
  }

  void generateTimeSlots() {
    final DateFormat formatter = DateFormat('hh:mm a');
    DateTime start = DateTime(2025, 1, 1, 9, 0);
    DateTime end = DateTime(2025, 1, 1, 18, 0);

    while (start.isBefore(end) || start.isAtSameMomentAs(end)) {
      slots.add(formatter.format(start));
      start = start.add(const Duration(minutes: 10));
    }
  }

  String convertTo24Hour(String time) {
    try {
      final parsed = DateFormat("hh:mm a").parse(time);
      return DateFormat('HH:mm:ss').format(parsed);
    } catch (e) {
      return time;
    }
  }

  Future<void> fetchServiceByPhone() async {
    try {
      final response = await http.get(
        Uri.parse(
          "https://medbook-backend-1.onrender.com/api/service-bookings/service/phone/${widget.servicePhone}",
        ),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        if (data["message"] == "Service provider not found for this phone number") {
          setState(() {
            bookingAvailable = false;
            isLoading = false;
          });
        } else {
          setState(() {
            fetchedServiceId = data["userId"];
            bookingAvailable = true;
            isLoading = false;
          });
        }
      } else {
        setState(() {
          bookingAvailable = false;
          isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        bookingAvailable = false;
        isLoading = false;
      });
    }
  }

  void scrollToDetails() {
    final context = _detailsKey.currentContext;
    if (context != null) {
      Scrollable.ensureVisible(
        context,
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeInOut,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) return const Scaffold(body: AppLoadingWidget());

    if (!bookingAvailable) {
      return Scaffold(
        appBar: AppBar(
          title: const Text("Booking Unavailable"),
          backgroundColor: Colors.redAccent,
        ),
        body: const Center(
          child: Text(
            "Service Provider not registered.",
            style: TextStyle(fontSize: 18),
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text("Book Service"),
        backgroundColor: Colors.redAccent,
      ),
      body: SingleChildScrollView(
        controller: _scrollController,
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // title
            Card(
              elevation: 3,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Text(
                  widget.serviceName,
                  style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                ),
              ),
            ),

            const SizedBox(height: 24),

            // Date picker
            const Text("📅 Select Date", style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
            CalendarDatePicker(
              initialDate: selectedDate,
              firstDate: DateTime.now(),
              lastDate: DateTime.now().add(const Duration(days: 60)),
              onDateChanged: (date) {
                setState(() {
                  selectedDate = date;
                  selectedSlot = '';
                });
              },
            ),

            const SizedBox(height: 24),

            const Text("⏰ Select Time Slot", style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),

            if (!showAllSlots)
              Row(
                children: List.generate(
                  slots.length > 3 ? 3 : slots.length,
                  (i) => Expanded(child: _slotWidget(slots[i])),
                ),
              )
            else
              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: slots.length,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  childAspectRatio: 2.7,
                  crossAxisSpacing: 8,
                  mainAxisSpacing: 8,
                ),
                itemBuilder: (ctx, i) => _slotWidget(slots[i]),
              ),

            if (slots.length > 3)
              Center(
                child: TextButton(
                  child: Text(showAllSlots ? "Show Less" : "Show Timings"),
                  onPressed: () => setState(() => showAllSlots = !showAllSlots),
                ),
              ),

            const SizedBox(height: 24),

            // ---------------- FORM SECTION ----------------
            Container(
              key: _detailsKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text("👤 Customer Details",
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),

                  // Gender
                  const SizedBox(height: 10),
                  const Text("Gender"),
                  DropdownButton<String>(
                    value: customerGender,
                    onChanged: (value) => setState(() => customerGender = value!),
                    items: ["Male", "Female", "Other"]
                        .map((g) => DropdownMenuItem(value: g, child: Text(g)))
                        .toList(),
                  ),

                  const SizedBox(height: 10),
                  _input("Full Name", nameController),

                  const SizedBox(height: 10),
                  _input("Age", ageController, type: TextInputType.number),

                  const SizedBox(height: 10),
                  _input("Contact Number", contactController, type: TextInputType.phone),

                  const SizedBox(height: 10),
                  _input("Description", descriptionController, maxLines: 3),

                  const SizedBox(height: 30),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent),
                      onPressed: submitBooking,
                      child: const Text("Confirm Service Booking"),
                    ),
                  )
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _slotWidget(String slot) {
    final isSelected = selectedSlot == slot;

    return ChoiceChip(
      label: Text(slot),
      selected: isSelected,
      onSelected: (_) {
        setState(() => selectedSlot = slot);
        scrollToDetails();
      },
      selectedColor: Colors.teal,
      labelStyle: TextStyle(color: isSelected ? Colors.white : Colors.black),
    );
  }

  Widget _input(String label, TextEditingController c,
      {int maxLines = 1, TextInputType type = TextInputType.text}) {
    return TextField(
      controller: c,
      maxLines: maxLines,
      keyboardType: type,
      decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  Future<void> submitBooking() async {
    if (selectedSlot.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please select a slot")),
      );
      return;
    }

    final storage = SecureStorageService();
    final user = await storage.getUserDetails();

    final userId = user?['id'];
    final username = user?['name'];

    final serviceUserId = fetchedServiceId ?? int.tryParse(widget.serviceId) ?? 0;

    final bookingData = {
      "serviceId": serviceUserId,
      "serviceName": widget.serviceName,
      "userId": userId,
      "username": username,
      "customerName": nameController.text,
      "customerAge": ageController.text,
      "customerGender": customerGender,
      "contactNumber": contactController.text,
      "description": descriptionController.text,
      "date": DateFormat('yyyy-MM-dd').format(selectedDate),
      "time": convertTo24Hour(selectedSlot),
    };

    try {
      final res = await http.post(
        Uri.parse(
          "https://medbook-backend-1.onrender.com/api/service-bookings",
        ),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(bookingData),
      );

      if (res.statusCode == 200 || res.statusCode == 201) {
        showDialog(
          context: context,
          builder: (_) => AlertDialog(
            title: const Text("🎉 Booking Confirmed"),
            content: Text(
              "Your service booking with ${widget.serviceName} has been successfully scheduled for "
              "${DateFormat('dd MMM yyyy').format(selectedDate)} at $selectedSlot.",
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                  Navigator.pop(context);
                },
                child: const Text("OK"),
              ),
            ],
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Booking failed: ${res.body}")),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: $e")),
      );
    }
  }
}
