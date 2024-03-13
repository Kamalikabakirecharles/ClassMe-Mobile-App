import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_application_2/ThemeProvider.dart';
import 'package:flutter_application_2/pages/TeacherPage.dart';
import 'package:flutter_application_2/popup.dart';
import 'package:flutter_application_2/services/database.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';

class AddQuestion extends StatefulWidget {
  final String quizId;
  AddQuestion(this.quizId);

  @override
  _AddQuestionState createState() => _AddQuestionState();
}

class _AddQuestionState extends State<AddQuestion> {
  DatabaseService databaseService = DatabaseService(uid: Uuid().v4());

  final _formKey = GlobalKey<FormState>();
  bool isLoading = false;
  String question = "", option1 = "", option2 = "", option3 = "", option4 = "";

  uploadQuizData() {
  if (_formKey.currentState!.validate()) {
    setState(() {
      isLoading = true;
    });

    Map<String, String> questionMap = {
      "question": question,
      "option1": option1,
      "option2": option2,
      "option3": option3,
      "option4": option4
    };

    print("${widget.quizId}");
    databaseService.addQuestionData(questionMap, widget.quizId).then((value) {
      question = "";
      option1 = "";
      option2 = "";
      option3 = "";
      option4 = "";
      setState(() {
        isLoading = false;
      });

      // Show the popup with success message
      showPopup(context, 'Success', 'Question added successfully!');
    }).catchError((e) {
      print(e);

      // Show the popup with error message
      showPopup(context, 'Error', 'Failed to add question. Please try again.');
    });
  } else {
    print("error is happening ");
  }
}


  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        leading: BackButton(
          color: Colors.white,
        ),
        title: Text(
          "Add Questions", // Add this line to set the title
          style: TextStyle(color: Colors.white),
        ),
        elevation: 0.0,
        backgroundColor: Theme.of(context).primaryColor,
        systemOverlayStyle: SystemUiOverlayStyle.dark,
      ),
      body: isLoading
          ? Container(
              child: Center(child: CircularProgressIndicator()),
            )
          : Form(
              key: _formKey,
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  children: [
                    TextFormField(
                      validator: (val) =>
                          val!.isEmpty ? "Enter Question" : null,
                      decoration: InputDecoration(
                        hintText: "Question",
                        hintStyle: TextStyle(
                            color: Colors.grey), // Set hint text color to grey
                      ),
                      onChanged: (val) {
                        question = val;
                      },
                    ),
                    SizedBox(
                      height: 5,
                    ),
                    TextFormField(
                      validator: (val) => val!.isEmpty ? "Option1 " : null,
                      decoration: InputDecoration(
                        hintText: "Option1 (Correct Answer)",
                        hintStyle: TextStyle(
                            color: Colors.grey), // Set hint text color to grey
                      ),
                      onChanged: (val) {
                        option1 = val;
                      },
                    ),
                    SizedBox(
                      height: 8,
                    ),
                    TextFormField(
                      validator: (val) => val!.isEmpty ? "Option2 " : null,
                      decoration: InputDecoration(
                        hintText: "Option2",
                        hintStyle: TextStyle(
                            color: Colors.grey), // Set hint text color to grey
                      ),
                      onChanged: (val) {
                        option2 = val;
                      },
                    ),
                    SizedBox(
                      height: 8,
                    ),
                    TextFormField(
                      validator: (val) => val!.isEmpty ? "Option3 " : null,
                      decoration: InputDecoration(
                        hintText: "Option3",
                        hintStyle: TextStyle(
                            color: Colors.grey), // Set hint text color to grey
                      ),
                      onChanged: (val) {
                        option3 = val;
                      },
                    ),
                    SizedBox(
                      height: 8,
                    ),
                    TextFormField(
                      validator: (val) => val!.isEmpty ? "Option4 " : null,
                      decoration: InputDecoration(
                        hintText: "Option4",
                        hintStyle: TextStyle(
                            color: Colors.grey), // Set hint text color to grey
                      ),
                      onChanged: (val) {
                        option4 = val;
                      },
                    ),
                    SizedBox(
                      height: 8,
                    ),
                    Spacer(),
                    Row(
                      children: [
                        GestureDetector(
                          onTap: () {
                            Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => TeacherPage()),
                            );
                          },
                          child: Container(
                            alignment: Alignment.center,
                            width: MediaQuery.of(context).size.width / 2 - 20,
                            padding: EdgeInsets.symmetric(
                                horizontal: 24, vertical: 20),
                            decoration: BoxDecoration(
                              color: themeProvider.currentTheme.primaryColor,
                              borderRadius: BorderRadius.circular(30),
                            ),
                            child: Text(
                              "Submit",
                              style:
                                  TextStyle(fontSize: 16, color: Colors.white),
                            ),
                          ),
                        ),
                        SizedBox(
                          width: 8,
                        ),
                        GestureDetector(
                          onTap: () {
                            uploadQuizData();
                          },
                          child: Container(
                            alignment: Alignment.center,
                            width: MediaQuery.of(context).size.width / 2 - 40,
                            padding: EdgeInsets.symmetric(
                                horizontal: 24, vertical: 20),
                            decoration: BoxDecoration(
                              color: themeProvider.currentTheme.primaryColor,
                              borderRadius: BorderRadius.circular(30),
                            ),
                            child: Text(
                              "Add Question",
                              style:
                                  TextStyle(fontSize: 16, color: Colors.white),
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(
                      height: 60,
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}
