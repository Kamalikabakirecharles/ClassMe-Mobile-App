import 'package:flutter/material.dart';
import 'package:ClassMe/main.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:lottie/lottie.dart';
import 'package:shared_preferences/shared_preferences.dart';

FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initNotifications(); // Initialize notifications
  runApp(
    MaterialApp(
      home: Results(
        incorrect: 0,
        total: 10,
        correct: 10,
        userName:
            await loadUserName(), // Load user name from shared preferences
      ),
    ),
  );
}

// Function to load user name from shared preferences
Future<String?> loadUserName() async {
  final prefs = await SharedPreferences.getInstance();
  return prefs.getString('userName');
}

Future<void> initNotifications() async {
  const AndroidInitializationSettings initializationSettingsAndroid =
      AndroidInitializationSettings('classme'); // Replace with your app icon

  final InitializationSettings initializationSettings = InitializationSettings(
    android: initializationSettingsAndroid,
  );

  await flutterLocalNotificationsPlugin.initialize(
    initializationSettings,
    onSelectNotification: (String? payload) async {
      // Handle notification tap
    },
  );
}

class Results extends StatefulWidget {
  final int total, correct, incorrect;
  final String? userName;
  Results({
    required this.incorrect,
    required this.total,
    required this.correct,
    this.userName,
  });

  @override
  _ResultsState createState() => _ResultsState();
}

class _ResultsState extends State<Results> {
  @override
  void initState() {
    super.initState();

    // Call sendNotification when the page loads
    sendNotification();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
         title: Text(
          "Results",
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Theme.of(context).primaryColor,
        iconTheme: IconThemeData(color: Colors.white),
      ),
      body: Stack(
        children: [
          Lottie.asset(
            'lib/json/Animation_Win - 1710279144207.json',
            width: MediaQuery.of(context).size.width,
            height: MediaQuery.of(context).size.height,
            repeat: true,
          ),
          Container(
            padding: EdgeInsets.all(16.0),
            child: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Lottie.asset(
                    'lib/json/Animation_Result - 1710280667277.json',
                    width: 200,
                    height: 200,
                    repeat: true,
                  ),
                  SizedBox(height: 10),
                  Text(
                    "${widget.correct}/ ${widget.total}",
                    style: TextStyle(fontSize: 25),
                  ),
                  SizedBox(
                    height: 5,
                  ),
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 24),
                    child: Text(
                      "you answered ${widget.correct} answers correctly and ${widget.incorrect} answers incorrectly",
                      textAlign: TextAlign.center,
                    ),
                  ),
                  SizedBox(
                    height: 24,
                  ),
                  GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => MyApp()),
                      );
                    },
                    child: Container(
                      padding:
                          EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                      decoration: BoxDecoration(
                        color: Theme.of(context)
                            .primaryColor, // Use theme color here
                        borderRadius: BorderRadius.circular(30),
                      ),
                      child: Text(
                        "Go to home",
                        style: TextStyle(color: Colors.white, fontSize: 19),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> sendNotification() async {
    const AndroidNotificationDetails androidPlatformChannelSpecifics =
        AndroidNotificationDetails(
      'quiz_channel', // Replace with your own channel ID
      'Quiz Notifications', // Replace with your own channel name
      importance: Importance.max,
      priority: Priority.high,
    );
    const NotificationDetails platformChannelSpecifics =
        NotificationDetails(android: androidPlatformChannelSpecifics);

    final userName =
        widget.userName ?? '';

    await flutterLocalNotificationsPlugin.show(
      0,
      'Well Done! $userName',
      'Congratulations on completing the quiz!',
      platformChannelSpecifics,
    );
  }
}
