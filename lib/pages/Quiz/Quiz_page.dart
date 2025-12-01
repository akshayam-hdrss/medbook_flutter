// QuizPage.dart
// QuizPage.dart
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:medbook/components/Footer.dart';
import 'package:medbook/services/secure_storage_service.dart';

class QuizPage extends StatefulWidget {
  final int stageId;

  const QuizPage({required this.stageId});

  @override
  _QuizPageState createState() => _QuizPageState();
}

class _QuizPageState extends State<QuizPage> {
  late Future<List<dynamic>> _quizData;
  List<int> selectedAnswers = [];
  bool _isSubmitting = false;

  // 🔥 USER DETAILS
  int? _userId;
  String? _userName;

  @override
  void initState() {
    super.initState();
    _quizData = fetchQuizData(widget.stageId);
    _loadUserDetails();
  }

  // 🔥 FETCH USER DETAILS FROM SECURE STORAGE
  Future<void> _loadUserDetails() async {
    final storage = SecureStorageService();
    final details = await storage.getUserDetails();

    if (details != null) {
      setState(() {
        _userId = details["id"]; // make sure your login saves "id"
        _userName = details["name"]; // and "name"
      });
    }
  }

  Future<List<dynamic>> fetchQuizData(int stageId) async {
    final response = await http.get(
      Uri.parse(
        'https://medbook-backend-1.onrender.com/api/quiz?stage=$stageId',
      ),
    );

    if (response.statusCode == 200) {
      var data = json.decode(response.body);
      return data['questions'];
    } else {
      throw Exception('Failed to load quiz data');
    }
  }

  void _handleAnswerSelection(int i, int a) {
    setState(() {
      selectedAnswers[i] = a;
    });
  }

  Future<void> submitStageData({
    required int userId,
    required String userName,
    required int stage,
    required int marks,
    required Map<String, dynamic> extraInfo,
  }) async {
    final url = Uri.parse(
      "https://medbook-backend-1.onrender.com/api/quiz-userdata",
    );

    final body = jsonEncode({
      "userId": userId,
      "userName": userName,
      "stageNumber": stage,
      "marks": marks,
      "extraInfo": extraInfo,
    });

    final response = await http.post(
      url,
      headers: {"Content-Type": "application/json"},
      body: body,
    );

    print("Response: ${response.body}");
  }

  void _showResultDialog(List<dynamic> questions) async {
    int score = 0;

    for (int i = 0; i < selectedAnswers.length; i++) {
      var correctAnswer = questions[i]['answer'];
      var options = questions[i]['options'];
      if (options[selectedAnswers[i]] == correctAnswer) score++;
    }

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) {
        TextEditingController infoController = TextEditingController();

        String label = "";
        if (widget.stageId == 1) label = "Email";
        if (widget.stageId == 2) label = "Aadhaar Number";
        if (widget.stageId == 3) label = "PAN Number";
        if (widget.stageId == 4) label = "Phone Number";
        if (widget.stageId == 5) label = "Address";
        if (widget.stageId == 6) label = "Final Stage Extra Info";

        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
            left: 20,
            right: 20,
            top: 20,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Your Score: $score",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 15),

              TextField(
                controller: infoController,
                decoration: InputDecoration(
                  labelText: label,
                  border: OutlineInputBorder(),
                ),
              ),
              SizedBox(height: 20),

              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  minimumSize: Size(double.infinity, 50),
                ),
                onPressed: () async {
                  if (_userId == null || _userName == null) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text("User not logged in!")),
                    );
                    return;
                  }

                  setState(() => _isSubmitting = true);

                  await submitStageData(
                    userId: _userId!,
                    userName: _userName!,
                    stage: widget.stageId,
                    marks: score,
                    extraInfo: {label: infoController.text},
                  );

                  setState(() => _isSubmitting = false);

                  Navigator.of(context).pop(); // close bottom sheet
                  Navigator.of(
                    context,
                  ).pop({"completed": true}); // return to StagePage
                },
                child: Text("Submit Stage"),
              ),
              SizedBox(height: 20),
            ],
          ),
        );
      },
    );
  }

  @override
 Widget build(BuildContext context) {
  return Scaffold(
    appBar: AppBar(
        iconTheme: const IconThemeData(
    color: Colors.white,     // <-- Back Arrow Color
    size: 28,
  ),
      title: Text(
        'Stage ${widget.stageId} Quiz',
        style: TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.bold,
          fontSize: 22,
        ),
      ),
      centerTitle: true,
      flexibleSpace: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Color.fromARGB(255, 233, 61, 61),
              Color.fromARGB(255, 233, 61, 61),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          
        ),
        
      ),
      
      elevation: 6,
      
    ),
        bottomNavigationBar: Footer(title: ""),
    

    body: FutureBuilder<List<dynamic>>(
      future: _quizData,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return Center(child: Text("Error: ${snapshot.error}"));
        }

        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return Center(child: Text("No questions available"));
        }

        List<dynamic> questions = snapshot.data!;
        if (selectedAnswers.isEmpty) {
          selectedAnswers = List.filled(questions.length, -1);
        }

        int answeredCount =
            selectedAnswers.where((a) => a != -1).length;

        return Column(
          children: [
            /// 🔥 TOP STATS BAR (Game style)
            Container(
              padding: EdgeInsets.symmetric(vertical: 14, horizontal: 16),
              decoration: BoxDecoration(
               gradient: LinearGradient(
              colors: [
                Color(0xFFE91E63),
                Color(0xFF9C27B0),
              ],
            ),

              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _statBox(
                      "Questions", "${questions.length}", Icons.list_alt),
                  _statBox(
                      "Answered", "$answeredCount", Icons.check_circle),
                ],
              ),
            ),

            /// 🔥 PROGRESS BAR
            Padding(
              padding: EdgeInsets.all(16),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: LinearProgressIndicator(
                  value: answeredCount / questions.length,
                  minHeight: 12,
                  backgroundColor: Colors.grey[300],
                  valueColor: AlwaysStoppedAnimation(Color(0xFF0084FF)),
                ),
              ),
            ),

            /// 🔥 QUESTIONS LIST
            Expanded(
              child: ListView.builder(
                itemCount: questions.length,
                itemBuilder: (context, index) {
                  var question = questions[index];
                  var options = question['options'];

                  return AnimatedContainer(
                    duration: Duration(milliseconds: 300),
                    curve: Curves.easeOut,
                    margin: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                    padding: EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(18),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black12,
                          blurRadius: 10,
                          offset: Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Question ${index + 1}",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.blueAccent,
                            fontSize: 16,
                          ),
                        ),
                        SizedBox(height: 8),

                        Text(
                          question['question'],
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        SizedBox(height: 12),

                        /// OPTIONS UI
                        Column(
                          children: List.generate(options.length, (i) {
                            bool isSelected =
                                selectedAnswers[index] == i;

                            return GestureDetector(
                              onTap: () => _handleAnswerSelection(index, i),
                              child: AnimatedContainer(
                                duration: Duration(milliseconds: 200),
                                padding: EdgeInsets.all(14),
                                margin: EdgeInsets.only(bottom: 10),
                                decoration: BoxDecoration(
                                  color: isSelected
                                      ? Color(0xFF34A853)
                                      : Color(0xFF007BFF),
                                  borderRadius: BorderRadius.circular(12),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.1),
                                      blurRadius: 6,
                                      offset: Offset(0, 3),
                                    ),
                                  ],
                                ),
                                child: Row(
                                  children: [
                                    Icon(
                                      isSelected
                                          ? Icons.check_circle
                                          : Icons.circle_outlined,
                                      color: Colors.white,
                                    ),
                                    SizedBox(width: 12),
                                    Expanded(
                                      child: Text(
                                        options[i],
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 16,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          }),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),

            /// 🔥 SUBMIT BUTTON
            Padding(
              padding: EdgeInsets.all(20),
              child: Container(
                width: double.infinity,
                height: 55,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Color(0xFF00B4DB), Color(0xFF0083B0)],
                  ),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: ElevatedButton(
                  onPressed: _isSubmitting
                      ? null
                      : () {
                          setState(() => _isSubmitting = true);
                          _showResultDialog(questions);
                        },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.transparent,
                    shadowColor: Colors.transparent,
                  ),
                  child: _isSubmitting
                      ? CircularProgressIndicator(color: Colors.white)
                      : Text(
                          "Submit Quiz",
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                ),
                
              ),
            ),
            
          ],
          
        );
        
      },
      
    ),
    
  );
  
}

/// 🔥 STAT BOX WIDGET
Widget _statBox(String title, String value, IconData icon) {
  return Row(
    children: [
      Icon(icon, color: Colors.white),
      SizedBox(width: 6),
      Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: TextStyle(color: Colors.white70)),
          Text(
            value,
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      )
    ],
    
  );
             

  
}


}
