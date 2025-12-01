// StagePage.dart
import 'package:flutter/material.dart';
import 'package:medbook/components/footer.dart';
import 'package:medbook/pages/Quiz/Quiz_page.dart';
import 'package:shared_preferences/shared_preferences.dart';

class StagePage extends StatefulWidget {
  @override
  _StagePageState createState() => _StagePageState();
}

class _StagePageState extends State<StagePage> {
  final List<int> stageIds = [1, 2, 3, 4, 5, 6];
  List<bool> completedStages = [false, false, false, false, false, false];
  int currentUnlockedStage = 1;

  @override
  void initState() {
    super.initState();
    _loadCompletionStatus();
  }

  _loadCompletionStatus() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    setState(() {
      for (int i = 0; i < stageIds.length; i++) {
        completedStages[i] = prefs.getBool('stage_${stageIds[i]}') ?? false;
      }

      for (int i = 0; i < completedStages.length; i++) {
        if (completedStages[i]) {
          currentUnlockedStage = stageIds[i] + 1;
        } else {
          break;
        }
      }

      if (currentUnlockedStage > stageIds.length) {
        currentUnlockedStage = stageIds.length;
      }
    });
  }

  _saveCompletionStatus(int stageId, bool completed) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setBool('stage_$stageId', completed);
  }

  bool isStageAccessible(int stageIndex) {
    if (stageIndex == 0) return true;
    return completedStages[stageIndex - 1] && !completedStages[stageIndex];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
    appBar: AppBar(
  iconTheme: const IconThemeData(
    color: Colors.white, // <-- Back arrow color
  ),
  title: const Text(
    'Select Stage',
    style: TextStyle(
      color: Colors.white,
      fontWeight: FontWeight.bold,
      fontSize: 20,
    ),
  ),
  backgroundColor: Color.fromARGB(255, 233, 61, 61),
),
  bottomNavigationBar:Footer(title: ""),



      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: GridView.builder(
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
          ),
          itemCount: stageIds.length,
          itemBuilder: (context, index) {
            bool isCompleted = completedStages[index];
            bool isAccessible = isStageAccessible(index);
            bool isLocked = !isCompleted && !isAccessible;

            // 🔥 HIDE COMPLETED STAGES
            if (isCompleted) return SizedBox.shrink();

            return GestureDetector(
              onTap: isLocked
                  ? null
                  : () async {
                      final result = await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              QuizPage(stageId: stageIds[index]),
                        ),
                      );

                      if (result != null && result["completed"] == true) {
                        setState(() {
                          completedStages[index] = true;

                          if (index < stageIds.length - 1) {
                            currentUnlockedStage = stageIds[index] + 1;
                          }
                        });

                        _saveCompletionStatus(stageIds[index], true);
                      }
                    },
              child: AnimatedContainer(
                duration: Duration(milliseconds: 300),
                decoration: BoxDecoration(
                  color: isLocked ? Colors.grey : Color.fromARGB(255, 169, 30, 46),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: isLocked
                        ? Colors.grey.withOpacity(0.5)
                        : Colors.white.withOpacity(0.3),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.2),
                      blurRadius: 8,
                      offset: Offset(0, 4),
                    ),
                  ],
                ),
                child: Center(
                  child: Text(
                    'Stage ${index + 1}',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w500,
                      color: isLocked ? Colors.white54 : Colors.white,
                    ),
                  ),
                ),
              ),
            );
            
          },
          
        ),
      ),
    );
  }
}
