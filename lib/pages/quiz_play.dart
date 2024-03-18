import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:ClassMe/models/question_model.dart';
import 'package:ClassMe/pages/results.dart';
import 'package:ClassMe/popup.dart';
import 'package:ClassMe/services/database.dart';
import 'package:ClassMe/quiz_play_widgets.dart';
import 'package:lottie/lottie.dart';
import 'package:uuid/uuid.dart';

class QuizPlay extends StatefulWidget {
  final String quizId;
  QuizPlay(this.quizId);

  @override
  _QuizPlayState createState() => _QuizPlayState();
}

int _correct = 0;
int _incorrect = 0;
int _notAttempted = 0;
int total = 0;

/// Stream
late StreamController<List<int>> infoStreamController;
late Stream<List<int>> infoStream;

class _QuizPlayState extends State<QuizPlay> {
  late QuerySnapshot questionSnaphot;
  late DatabaseService databaseService; // Declare the database service
  late StreamController<List<int>> infoStreamController;
  late PageController _pageController;
  int _currentPageIndex = 0;

  bool isLoading = true;
  late List<Map<String, dynamic>> questionList;

  @override
  void initState() {
    _pageController = PageController();

    // Initialize the database service with a unique ID
    databaseService = DatabaseService(uid: Uuid().v4());

    // Initialize infoStreamController
    infoStreamController = StreamController<List<int>>.broadcast();

    // Use infoStreamController.stream instead of creating a new stream
    infoStream = infoStreamController.stream;
    databaseService.getQuestionData(widget.quizId).then((value) {
      questionSnaphot = value;
      _notAttempted = questionSnaphot.docs.length;
      _correct = 0;
      _incorrect = 0;
      isLoading = false;
      total = questionSnaphot.docs.length;
      setState(() {});
      print("init don $total ${widget.quizId} ");
    });
    super.initState();
  }

  QuestionModel getQuestionModelFromDatasnapshot(
      DocumentSnapshot questionSnapshot) {
    QuestionModel questionModel = QuestionModel();

    var data = questionSnapshot.data() as Map<String, dynamic>?;

    if (data != null) {
      questionModel.question = (data["question"] as String?)!;

      // Check if question is not null before processing
      // ignore: unnecessary_null_comparison
      if (questionModel.question != null) {
        List<String> options = [
          data["option1"],
          data["option2"],
          data["option3"],
          data["option4"],
        ];
        options.shuffle();

        questionModel.option1 = options[0];
        questionModel.option2 = options[1];
        questionModel.option3 = options[2];
        questionModel.option4 = options[3];
        questionModel.correctOption = data["option1"];
        questionModel.answered = false;

        print(questionModel.correctOption.toLowerCase());
      }
    }

    return questionModel;
  }

  @override
  void dispose() {
    // Close the stream controller when disposing
    infoStreamController.close();
    _pageController.dispose();
    super.dispose();
  }

 @override
Widget build(BuildContext context) {
  return Scaffold(
    appBar: AppBar(
       title: Text(
          "Quizz",
          style: TextStyle(color: Colors.white),
        ),
      backgroundColor: Theme.of(context).primaryColor,
      iconTheme: IconThemeData(color: Colors.white),
    ),
    body: isLoading
        ? Container(
            child: Center(child: CircularProgressIndicator()),
          )
        : questionSnaphot.docs.isEmpty
            ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'No questions available.',
                      style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                    Lottie.asset(
                      'lib/json/Empty - 1710.json',
                      width: MediaQuery.of(context).size.width * 0.8,
                      height: MediaQuery.of(context).size.height * 0.8,
                      repeat: true,
                      
                    ),
                    SizedBox(height: 20),
                    
                  ],
                ),
              )
            : PageView.builder(
                controller: _pageController,
                itemCount: questionSnaphot.docs.length,
                onPageChanged: (index) {
                  setState(() {
                    _currentPageIndex = index;
                  });
                },
                itemBuilder: (context, index) {
                  return SingleChildScrollView(
                    child: Container(
                      child: Column(
                        children: [
                          InfoHeader(
                            length: questionSnaphot.docs.length,
                            correct: _correct,
                            incorrect: _incorrect,
                            notAttempted: _notAttempted,
                          ),
                          SizedBox(
                            height: 10,
                          ),
                          QuizPlayTile(
                            questionModel:
                                getQuestionModelFromDatasnapshot(
                              questionSnaphot.docs[index],
                            ),
                            index: index,
                          ),
                          SizedBox(height: 20),
                        ],
                      ),
                    ),
                  );
                },
              ),
    floatingActionButton: FloatingActionButton(
      child: Icon(Icons.check),
      onPressed: () {
        // Check if it's the last question
        if (_currentPageIndex < questionSnaphot.docs.length - 1) {
          // If there are more questions, move to the next question
          _pageController.nextPage(
            duration: Duration(milliseconds: 300),
            curve: Curves.easeInOut,
          );
        } else {
          // If it's the last question, show the popup
          showPopup(context, "End of Quiz", "You've reached the end of the quiz.")
              .then((value) {
            // Navigate to the Results page after closing the popup
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) => Results(
                  correct: _correct,
                  incorrect: _incorrect,
                  total: total,
                ),
              ),
            );
          });
        }
      },
      backgroundColor: Theme.of(context).primaryColor,
      shape: CircleBorder(),
    ),
  );
}

}

class InfoHeader extends StatefulWidget {
  final int length;
  final int correct;
  final int incorrect;
  final int notAttempted;

  InfoHeader({
    required this.length,
    required this.correct,
    required this.incorrect,
    required this.notAttempted,
  });

  @override
  _InfoHeaderState createState() => _InfoHeaderState();
}

class _InfoHeaderState extends State<InfoHeader> {
  @override
  Widget build(BuildContext context) {
    return Container(
      height: 40,
      margin: EdgeInsets.only(left: 14),
      child: ListView(
        scrollDirection: Axis.horizontal,
        shrinkWrap: true,
        children: <Widget>[
          NoOfQuestionTile(
            text: "Total",
            number: widget.length,
          ),
          NoOfQuestionTile(
            text: "Correct",
            number: widget.correct,
          ),
          NoOfQuestionTile(
            text: "Incorrect",
            number: widget.incorrect,
          ),
          NoOfQuestionTile(
            text: "NotAttempted",
            number: widget.notAttempted,
          ),
        ],
      ),
    );
  }
}

class QuizPlayTile extends StatefulWidget {
  final QuestionModel questionModel;
  final int index;

  QuizPlayTile({required this.questionModel, required this.index});

  @override
  _QuizPlayTileState createState() => _QuizPlayTileState();
}

class _QuizPlayTileState extends State<QuizPlayTile> {
  String optionSelected = "";

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(height: 20), // Add this SizedBox to move the question down
          Container(
            margin: EdgeInsets.symmetric(horizontal: 20),
            child: Text(
              "Q${widget.index + 1} ${widget.questionModel.question}",
              style:
                  TextStyle(fontSize: 18, color: Colors.black.withOpacity(0.8)),
            ),
          ),
          SizedBox(
            height: 12,
          ),
          GestureDetector(
            onTap: () {
              if (!widget.questionModel.answered) {
                setState(() {
                  if (widget.questionModel.option1 ==
                      widget.questionModel.correctOption) {
                    optionSelected = widget.questionModel.option1;
                    _correct = _correct + 1;
                  } else {
                    optionSelected = widget.questionModel.option1;
                    _incorrect = _incorrect + 1;
                  }
                  widget.questionModel.answered = true;
                  _notAttempted = _notAttempted - 1;
                });
                infoStreamController.add([_correct, _incorrect, _notAttempted]);
              }
            },
            child: OptionTile(
              option: "A",
              description: "${widget.questionModel.option1}",
              correctAnswer: widget.questionModel.correctOption,
              optionSelected: optionSelected,
            ),
          ),
          SizedBox(
            height: 4,
          ),
          GestureDetector(
            onTap: () {
              if (!widget.questionModel.answered) {
                if (widget.questionModel.option2 ==
                    widget.questionModel.correctOption) {
                  setState(() {
                    optionSelected = widget.questionModel.option2;
                    widget.questionModel.answered = true;
                    _correct = _correct + 1;
                  });
                } else {
                  setState(() {
                    optionSelected = widget.questionModel.option2;
                    widget.questionModel.answered = true;
                    _incorrect = _incorrect + 1;
                  });
                }
                setState(() {
                  _notAttempted = _notAttempted - 1;
                });
              }
            },
            child: OptionTile(
              option: "B",
              description: "${widget.questionModel.option2}",
              correctAnswer: widget.questionModel.correctOption,
              optionSelected: optionSelected,
            ),
          ),
          SizedBox(
            height: 4,
          ),
          GestureDetector(
            onTap: () {
              if (!widget.questionModel.answered) {
                if (widget.questionModel.option3 ==
                    widget.questionModel.correctOption) {
                  setState(() {
                    optionSelected = widget.questionModel.option3;
                    widget.questionModel.answered = true;
                    _correct = _correct + 1;
                  });
                } else {
                  setState(() {
                    optionSelected = widget.questionModel.option3;
                    widget.questionModel.answered = true;
                    _incorrect = _incorrect + 1;
                  });
                }
                setState(() {
                  _notAttempted = _notAttempted - 1;
                });
              }
            },
            child: OptionTile(
              option: "C",
              description: "${widget.questionModel.option3}",
              correctAnswer: widget.questionModel.correctOption,
              optionSelected: optionSelected,
            ),
          ),
          SizedBox(
            height: 4,
          ),
          GestureDetector(
            onTap: () {
              if (!widget.questionModel.answered) {
                if (widget.questionModel.option4 ==
                    widget.questionModel.correctOption) {
                  setState(() {
                    optionSelected = widget.questionModel.option4;
                    widget.questionModel.answered = true;
                    _correct = _correct + 1;
                  });
                } else {
                  setState(() {
                    optionSelected = widget.questionModel.option4;
                    widget.questionModel.answered = true;
                    _incorrect = _incorrect + 1;
                  });
                }
                setState(() {
                  _notAttempted = _notAttempted - 1;
                });
              }
            },
            child: OptionTile(
              option: "D",
              description: "${widget.questionModel.option4}",
              correctAnswer: widget.questionModel.correctOption,
              optionSelected: optionSelected,
            ),
          ),
          SizedBox(
            height: 20,
          ),
        ],
      ),
    );
  }
}
