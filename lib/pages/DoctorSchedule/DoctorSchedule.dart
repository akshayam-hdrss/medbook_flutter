import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;
import 'package:medbook/components/common/loading_widget.dart';
import 'package:medbook/services/secure_storage_service.dart';

class DoctorSchedule extends StatefulWidget {
  final String doctorName;
  final String doctorId;
  final String doctorNo;

  const DoctorSchedule({
    super.key,
    required this.doctorName,
    required this.doctorId,
    required this.doctorNo,
  });

  @override
  State<DoctorSchedule> createState() => _DoctorScheduleState();
}

class _DoctorScheduleState extends State<DoctorSchedule> {
  DateTime selectedDate = DateTime.now();
  String selectedSlot = '';
  String appointmentFor = 'Myself';
  bool isOnlineConsultation = false;

  final nameController = TextEditingController();
  final ageController = TextEditingController();
  final descriptionController = TextEditingController();
  final contactController = TextEditingController();

  final List<String> slots = [];
  bool showAllSlots = false; // Toggle for all slots

  final ScrollController _scrollController = ScrollController();
  final GlobalKey _detailsKey = GlobalKey(); // Key for details section

  void generateTimeSlots() {
    final DateFormat formatter = DateFormat('hh:mm a');
    DateTime start = DateTime(2025, 1, 1, 9, 0);
    DateTime end = DateTime(2025, 1, 1, 18, 0);

    while (start.isBefore(end) || start.isAtSameMomentAs(end)) {
      slots.add(formatter.format(start));
      start = start.add(const Duration(minutes: 10));
    }
  }

  bool isLoading = true;
  bool bookingAvailable = true;
  int? fetchedDoctorId;

  @override
  void initState() {
    super.initState();
    fetchDoctorByPhone();
    generateTimeSlots();
  }

  String convertTo24HourFormat(String time) {
    try {
      time = time.trim();
      final parsedTime = DateFormat("hh:mm a").parse(time);
      return DateFormat('HH:mm:ss').format(parsedTime);
    } catch (e) {
      debugPrint("❌ Time parse failed for '$time': $e");
      return time;
    }
  }

  Future<void> fetchDoctorByPhone() async {
    try {
      final response = await http.get(
        Uri.parse(
          "https://medbook-backend-1.onrender.com/api/bookings/doctor/phone/${widget.doctorNo}",
        ),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        if (data["message"] == "Doctor not found for this phone number") {
          setState(() {
            bookingAvailable = false;
            isLoading = false;
          });
        } else {
          setState(() {
            fetchedDoctorId = data["userId"];
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
      debugPrint("❌ Error fetching doctor: $e");
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
            iconTheme: const IconThemeData(
              color: Color.fromARGB(255, 255, 255, 255),
            ),
            title: const Text(
              'Booking Unavailable',
              style: TextStyle(color: Colors.white),
            ),
            backgroundColor: Colors.transparent,
            elevation: 0,
            centerTitle: true,
          ),
        ),
      ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 80, color: Colors.red),
              const SizedBox(height: 20),
              const Text(
                "This is a demo data, Doctor not registered.",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () => Navigator.pop(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.redAccent,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 12,
                  ),
                ),
                child: const Text("Back"),
              ),
            ],
          ),
        ),
      );
    }

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
            iconTheme: const IconThemeData(
              color: Color.fromARGB(255, 255, 255, 255),
            ),
            title: const Text(
              'Book Appointment',
              style: TextStyle(color: Colors.white),
            ),
            backgroundColor: Colors.transparent,
            elevation: 0,
            centerTitle: true,
          ),
        ),
      ),
      
      body: SingleChildScrollView(
        controller: _scrollController,
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Card(
              elevation: 3,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Text(
                  widget.doctorName,
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),

            const SizedBox(height: 24),
            const Text(
              "📅 Select Date",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 10),
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey.shade300),
              ),
              child: CalendarDatePicker(
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
            ),

            const SizedBox(height: 24),
            const Text(
              "⏰ Available Slots",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 10),

            // Slots
            if (!showAllSlots)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: Row(
                  children: List.generate(slots.length > 3 ? 3 : slots.length, (
                    index,
                  ) {
                    return Expanded(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 4),
                        child: _buildSlotChip(slots[index], scrollToDetails),
                      ),
                    );
                  }),
                ),
              )
            else
              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                padding: const EdgeInsets.only(top: 10),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  childAspectRatio: 2.8,
                  crossAxisSpacing: 8,
                  mainAxisSpacing: 8,
                ),
                itemCount: slots.length,
                itemBuilder: (context, index) {
                  return _buildSlotChip(slots[index], scrollToDetails);
                },
              ),

            // Show All / Show Less button
            if (slots.length > 3)
              Padding(
                padding: const EdgeInsets.only(top: 10),
                child: Center(
                  child: TextButton(
                    onPressed: () {
                      setState(() {
                        showAllSlots = !showAllSlots;
                      });
                    },
                    child: Text(
                      showAllSlots ? "Show Less" : "Show Timings",
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFFFF5252),
                      ),
                    ),
                  ),
                ),
              ),

            // ---------------------- DETAILS SECTION ----------------------
            const SizedBox(height: 24),
            Container(
              key: _detailsKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "👤 Appointment For",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                  ),
                  Row(
                    children: [
                      Radio<String>(
                        value: 'Myself',
                        groupValue: appointmentFor,
                        onChanged: (value) =>
                            setState(() => appointmentFor = value!),
                      ),
                      const Text("Myself"),
                      Radio<String>(
                        value: 'Others',
                        groupValue: appointmentFor,
                        onChanged: (value) =>
                            setState(() => appointmentFor = value!),
                      ),
                      const Text("Others"),
                    ],
                  ),

                  const SizedBox(height: 20),
                  const Text(
                    "💻 Consultation Type",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                  ),
                  SwitchListTile(
                    value: isOnlineConsultation,
                    onChanged: (value) {
                      setState(() {
                        isOnlineConsultation = value;
                      });
                    },
                    title: Text(
                      "Online Consultation",
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    activeColor: Colors.teal,
                    inactiveThumbColor: Colors.redAccent,
                    inactiveTrackColor: Colors.grey.shade300,
                  ),

                  const SizedBox(height: 20),
                  buildInputField("Patient Name", nameController),
                  const SizedBox(height: 10),
                  buildInputField(
                    "Patient Age",
                    ageController,
                    keyboardType: TextInputType.number,
                  ),
                  const SizedBox(height: 10),
                  buildInputField(
                    "Description",
                    descriptionController,
                    maxLines: 3,
                  ),
                  const SizedBox(height: 10),
                  buildInputField(
                    "Contact Number",
                    contactController,
                    keyboardType: TextInputType.phone,
                  ),

                  const SizedBox(height: 30),
                  Divider(height: 1, thickness: 1),
                  const SizedBox(height: 20),

                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      icon: const Icon(Icons.check_circle_outline),
                      label: const Text("Confirm Booking"),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.redAccent,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        textStyle: const TextStyle(fontSize: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      onPressed: () async {
                        if (selectedSlot.isEmpty) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text("Please select a slot"),
                            ),
                          );
                          return;
                        }

                        final storage = SecureStorageService();
                        final userDetails = await storage.getUserDetails();
                        final userId = userDetails?['id'];
                        final username = userDetails?['name'];

                        final doctorId =
                            fetchedDoctorId ??
                            int.tryParse(widget.doctorId) ??
                            0;

                        final convertedTime = convertTo24HourFormat(
                          selectedSlot,
                        );

                        final appointmentData = {
                          "doctorId": doctorId,
                          "doctorName": widget.doctorName,
                          "userId": userId,
                          "username": username,
                          "date": DateFormat('yyyy-MM-dd').format(selectedDate),
                          "time": convertedTime,
                          "patientName": nameController.text,
                          "patientAge": int.tryParse(ageController.text) ?? 0,
                          "contactNumber": contactController.text,
                          "description": descriptionController.text,
                          "consultationType": isOnlineConsultation
                              ? "Online"
                              : "In-Person",
                          "isOnline": isOnlineConsultation,
                        };

                        debugPrint(
                          "📤 Sending appointmentData: $appointmentData",
                        );

                        try {
                          final response = await http.post(
                            Uri.parse(
                              'https://medbook-backend-1.onrender.com/api/bookings',
                            ),
                            headers: {"Content-Type": "application/json"},
                            body: jsonEncode(appointmentData),
                          );

                          if (response.statusCode == 200 ||
                              response.statusCode == 201) {
                            showDialog(
                              context: context,
                              builder: (_) => AlertDialog(
                                title: const Text("✅ Appointment Confirmed"),
                                content: Text(
                                  "Your ${isOnlineConsultation ? "online consultation" : "in-person visit"} with ${widget.doctorName} on ${DateFormat('dd MMM yyyy').format(selectedDate)} at $convertedTime has been successfully booked.",
                                ),
                                actions: [
                                  TextButton(
                                    onPressed: () {
                                      Navigator.pop(context); // close dialog
                                      Navigator.pop(
                                        context,
                                      ); // back to Doctor Page
                                    },
                                    child: const Text("OK"),
                                  ),
                                ],
                              ),
                            );
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  "Failed to book appointment: ${response.body}",
                                ),
                              ),
                            );
                          }
                        } catch (e) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text("An error occurred: $e")),
                          );
                        }
                      },
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSlotChip(String slot, VoidCallback scrollCallback) {
    final isSelected = selectedSlot == slot;
    return ChoiceChip(
      label: Text(slot),
      selected: isSelected,
      onSelected: (_) {
        setState(() => selectedSlot = slot);
        scrollCallback(); // Scroll to details when slot tapped
      },
      selectedColor: Colors.teal,
      labelStyle: TextStyle(color: isSelected ? Colors.white : Colors.black),
      backgroundColor: Colors.grey.shade200,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      elevation: isSelected ? 2 : 0,
    );
  }

  Widget buildInputField(
    String label,
    TextEditingController controller, {
    int maxLines = 1,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return TextField(
      controller: controller,
      maxLines: maxLines,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 14,
        ),
      ),
    );
  }
}
