import 'package:flutter/material.dart';
import 'package:flutter_application_2/ThemeProvider.dart';
import 'package:flutter_application_2/pages/TeacherPage.dart';
import 'package:flutter_application_2/pages/add_question.dart';
import 'package:flutter_application_2/popup.dart';
import 'package:flutter_application_2/services/database.dart';
import 'package:provider/provider.dart';
import 'package:random_string/random_string.dart';
import 'package:uuid/uuid.dart';


void main() {
  runApp(const CreateQuiz());
  // Create an instance of the Uuid class
  var uuid = Uuid();

  // Generate a random UUID
  String randomUuid = uuid.v4();
  print('Random UUID: $randomUuid');
}

class CreateQuiz extends StatelessWidget {
  const CreateQuiz({super.key});

  @override
  Widget build(BuildContext context) {

    final themeProvider = Provider.of<ThemeProvider>(context);

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter Demo',
      theme: themeProvider.currentTheme,
      home: const MyHomePage(title: 'Add Subject'), 
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int myIndex = 0;

  DatabaseService databaseService = DatabaseService(uid: Uuid().v4());

  final _formKey = GlobalKey<FormState>();
  late String quizImgUrl, quizTitle, quizDesc;
  bool isLoading = false;
  late String quizId;


  Widget menuItem(IconData icon, String title) {
    return Material(
      child: InkWell(
        child: Padding(
          padding: EdgeInsets.all(15.0),
          child: Row(
            children: [
              Expanded(
                flex: 1,
                child: Icon(icon, size: 20, color: Colors.black),
              ),
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(color: Colors.black, fontSize: 16),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  createQuiz() {
  quizId = randomAlphaNumeric(16);
  if (_formKey.currentState!.validate()) {
    setState(() {
      isLoading = true;
    });

    Map<String, String> quizData = {
      "quizImgUrl": quizImgUrl,
      "quizTitle": quizTitle,
      "quizDesc": quizDesc
    };

    databaseService.addQuizData(quizData, quizId).then((value) {
      setState(() {
        isLoading = false;
      });

      // Show the popup with success message
      showPopup(context, 'Success', 'Subject created successfully!');

      // Navigate to the AddQuestion page
      Navigator.pushReplacement( 
        context,
        MaterialPageRoute(builder: (context) => AddQuestion(quizId)),
      );
    }).catchError((error) {
      print(error);

      // Show the popup with error message
      showPopup(context, 'Error', 'Failed to create subject. Please try again.');
    });
  }
}


  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).primaryColor,
        title: Text(
          widget.title,
          style: TextStyle(color: Colors.white),
        ),
        iconTheme: IconThemeData(color: Colors.white),
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            // Navigate to the TeacherPage page
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => TeacherPage()),
            );
          },
        ),
      ),
      body: Form(
        key: _formKey,
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            children: [
              TextFormField(
                validator: (val) =>
                    val!.isEmpty ? "Enter Subject Image Url" : null,
                decoration: InputDecoration(
                  hintText: "Subject Image Url (Optional)",
                  hintStyle: TextStyle(color: Colors.grey),
                ),
                onChanged: (val) {
                  setState(() {
                    quizImgUrl = val;
                  });
                },
              ),
              SizedBox(
                height: 5,
              ),
              TextFormField(
                validator: (val) => val!.isEmpty ? "Enter Subject Title" : null,
                decoration: InputDecoration(
                  hintText: "Subject Title",
                  hintStyle: TextStyle(color: Colors.grey),
                ),
                onChanged: (val) {
                  setState(() {
                    quizTitle = val;
                  });
                },
              ),
              SizedBox(
                height: 5,
              ),
              TextFormField(
                validator: (val) =>
                    val!.isEmpty ? "Enter Subject Description" : null,
                decoration: InputDecoration(
                  hintText: "Subject Description",
                  hintStyle: TextStyle(color: Colors.grey),
                ),
                onChanged: (val) {
                  setState(() {
                    quizDesc = val;
                  });
                },
              ),
              Spacer(),
              GestureDetector(
                onTap: createQuiz,
                child: Container(
                  alignment: Alignment.center,
                  width: MediaQuery.of(context).size.width,
                  padding: EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 20,
                  ),
                  decoration: BoxDecoration(
                    color: themeProvider.currentTheme.primaryColor,
                    borderRadius: BorderRadius.circular(30),
                  ),
                  child: Text(
                    "Create Subject",
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.white,
                    ),
                  ),
                ),
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

