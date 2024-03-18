import 'package:flutter/material.dart';
import 'package:ClassMe/ThemeProvider.dart';
import 'package:ClassMe/pages/TeacherPage.dart';
import 'package:ClassMe/pages/add_question.dart';
import 'package:ClassMe/popup.dart';
import 'package:ClassMe/services/database.dart';
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
  String? imageUrlPreview; // Variable to store the URL pasted by the user.
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

 void createQuiz() {
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

      showPopup(context, 'Success', 'Subject created successfully!');

      // Navigate to the AddQuestion page with the quiz ID
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => AddQuestion(
            quizId: quizId, // Pass the quiz ID to AddQuestion page
            databaseService: databaseService,
          ),
        ),
      );
    }).catchError((error) {
      print(error);

      // Navigate to the AddQuestion page with the quiz ID even if there's an error
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => AddQuestion(
            quizId: quizId, // Pass the quiz ID to AddQuestion page
            databaseService: databaseService,
          ),
        ),
      );
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
              Text(
                "Preview",
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
              SizedBox(height: 7),
              // Image preview container with border
              if (imageUrlPreview != null) // Display only if URL is provided
                Container(
                  width: double.infinity,
                  height: 130,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                        color: themeProvider.currentTheme
                            .primaryColor), // Add border with theme color
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: Image.network(
                      imageUrlPreview!, // Display the image preview
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
              SizedBox(height: 10), // Add some spacing

              // TextFormField for entering image URL
              TextFormField(
                validator: (val) =>
                    val!.isEmpty ? "Enter Subject Image Url" : null,
                decoration: InputDecoration(
                  hintText: "Subject Image Url (Optional)",
                  hintStyle: TextStyle(color: Colors.grey),
                  
                ),
                onChanged: (val) {
                  setState(() {
                    imageUrlPreview =
                        val; // Update the URL preview when user types
                    quizImgUrl = val; // Store the URL in quizImgUrl variable
                  });
                },
              ),
              SizedBox(height: 5),
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
              SizedBox(height: 5),
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
              SizedBox(height: 60),
            ],
          ),
        ),
      ),
    );
  }
}