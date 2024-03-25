import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:ClassMe/pages/Maps.dart';
import 'package:ClassMe/pages/quiz_play.dart';
import 'package:ClassMe/pages/welcome.dart';
import 'package:ClassMe/popup.dart';
import 'package:ClassMe/services/database.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';
import 'firebase_options.dart';
import 'package:flutter/material.dart';
import 'package:ClassMe/ThemeProvider.dart';
import 'package:ClassMe/google_signin_api.dart';
import 'package:ClassMe/my_drawer_header.dart';
import 'package:ClassMe/pages/Contact.dart';
import 'package:ClassMe/pages/about.dart';
import 'package:ClassMe/pages/calculator.dart';
import 'package:ClassMe/pages/gallery.dart';
import 'package:ClassMe/pages/settings.dart';
import 'package:flutter_blue/flutter_blue.dart';
import 'package:provider/provider.dart';
import 'package:connectivity/connectivity.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  await initNotifications();
  // Check the user's authentication status and navigate accordingly
  checkUserAuthenticationStatus();
}

Future<void> checkUserAuthenticationStatus() async {
  try {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    bool isAuthenticated = prefs.getBool('isAuthenticated') ?? false;

    if (isAuthenticated) {
      runApp(
        ChangeNotifierProvider(
          create: (context) => ThemeProvider(),
          child: MyApp(),
        ),
      );
    } else {
      runApp(
        ChangeNotifierProvider(
          create: (context) => ThemeProvider(),
          child: MyWelcomeApp(),
        ),
      );
    }
  } catch (e) {
    print('Error checking authentication status: $e');
  }
}

FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();

Future<void> initNotifications() async {
  final AndroidInitializationSettings initializationSettingsAndroid =
      const AndroidInitializationSettings('classme');

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

class MyApp extends StatelessWidget {
  const MyApp({Key? key});

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter Demo',
      theme: themeProvider.currentTheme,
      home: const MyHomePage(title: 'Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int myIndex = 0;
  bool isOnline = false;
  bool isBluetoothEnabled = false;

  late Timer refreshTimer;
  bool showStatusIndicators = true;

  // late Stream quizStream; // Declare the stream variable as late
  late Stream<QuerySnapshot<Map<String, dynamic>>>
      quizStream; // Specify the correct type
  late DatabaseService databaseService; // Declare the database service

  Widget quizList() {
    return Container(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 16.0),
        child: StreamBuilder(
          stream: quizStream,
          builder: (context,
              AsyncSnapshot<QuerySnapshot<Map<String, dynamic>>> snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              // Display a loader while data is being fetched
              return Center(
                child: CircularProgressIndicator(),
              );
            }

            return snapshot.data == null
                ? Container()
                : ListView.builder(
                    shrinkWrap: true,
                    physics: ClampingScrollPhysics(),
                    itemExtent: 180,
                    itemCount: snapshot.data!.docs.length,
                    itemBuilder: (context, index) {
                      return Column(
                        children: [
                          Container(
                            margin: EdgeInsets.only(bottom: 16.0),
                            child: QuizTile(
                              noOfQuestions: snapshot.data!.docs.length,
                              imageUrl: snapshot.data!.docs[index]
                                  .data()['quizImgUrl'],
                              title: snapshot.data!.docs[index]
                                  .data()['quizTitle'],
                              description:
                                  snapshot.data!.docs[index].data()['quizDesc'],
                              id: snapshot.data!.docs[index].id,
                            ),
                          ),
                          Divider(
                            color: Theme.of(context).primaryColor,
                            thickness: 2.0,
                            height: 2,
                          ),
                        ],
                      );
                    },
                  );
          },
        ),
      ),
      decoration: BoxDecoration(
        boxShadow: [
          BoxShadow(
            color: Theme.of(context).primaryColor.withOpacity(0.5),
            spreadRadius: 5,
            blurRadius: 10,
            offset: Offset(0, 3),
          ),
        ],
      ),
    );
  }

  @override
  void initState() {
    // Initialize the database service with a unique ID
    databaseService = DatabaseService(uid: Uuid().v4());

    // Initialize quizStream with an empty stream
    quizStream = Stream.empty();

    // Show a notification when the page loads
    showWelcomeNotification();

    // Load quiz data into quizStream
    databaseService.getQuizData().then((value) {
      setState(() {
        quizStream = value;
      });
    });
    super.initState();

    // Check for internet connectivity
    checkInternetConnectivity().then((result) {
      setState(() {
        isOnline = result;
      });
    });

    // Check for Bluetooth status
    checkBluetoothStatus().then((value) {
      setState(() {
        isBluetoothEnabled = value;
      });
    });

    // Set up periodic timer for refreshing every 1 minute
    refreshTimer = Timer.periodic(Duration(seconds: 2), (Timer timer) {
      refreshStatus();
    });
  }

  Future<void> showWelcomeNotification() async {
    // Define the notification details
    const AndroidNotificationDetails androidPlatformChannelSpecifics =
        AndroidNotificationDetails(
      'quiz_channel', // ID for the notification channel
      'Quiz Notifications', // Name of the notification channel
      importance: Importance.max,
      priority: Priority.high,
    );

    const NotificationDetails platformChannelSpecifics =
        NotificationDetails(android: androidPlatformChannelSpecifics);

    // Show the notification
    await flutterLocalNotificationsPlugin.show(
      0, // Notification ID
      'Welcome back!', // Notification title
      'We have more quiz for you today.', // Notification body
      platformChannelSpecifics,
      payload: 'quiz_notification', // Optional payload
    );
  }

  @override
  void dispose() {
    // Cancel the timer when the widget is disposed
    refreshTimer.cancel();
    super.dispose();
  }

  void refreshStatus() {
    // Check and update the status of internet connectivity and Bluetooth
    checkInternetConnectivity().then((result) {
      setState(() {
        isOnline = result;
      });
    });

    checkBluetoothStatus().then((value) {
      setState(() {
        isBluetoothEnabled = value;
      });
    });
  }

  Future<bool> checkInternetConnectivity() async {
    var connectivityResult = await Connectivity().checkConnectivity();
    return connectivityResult != ConnectivityResult.none;
  }

  Future<bool> checkBluetoothStatus() async {
    try {
      FlutterBlue flutterBlue = FlutterBlue.instance;

      // Create a Completer to handle the async operation
      Completer<bool> completer = Completer<bool>();

      // Initialize the subscription variable
      late StreamSubscription<BluetoothState> subscription;

      // Listen to the first event emitted by the Bluetooth state stream
      subscription = flutterBlue.state.listen((BluetoothState bluetoothState) {
        // Check the Bluetooth state and complete the Future
        completer.complete(bluetoothState == BluetoothState.on);

        // Cancel the subscription after the first event
        subscription.cancel();
      });

      return await completer.future; // Wait for the Future to complete
    } catch (e, stackTrace) {
      print('Error in checkBluetoothStatus: $e\n$stackTrace');
      return false;
    }
  }

  void _onItemTapped(int index) {
    // Handle navigation to different pages based on index
    switch (index) {
      case 0:
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => AboutPage()),
        );
        break;
      case 1:
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => MyApp()),
        );
        break;
      case 2:
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => CalculatorPage()),
        );
        break;
    }
  }

  Widget MyDrawerList() {
    return Container(
      padding: EdgeInsets.only(top: 15),
      child: Column(
        // list of menu items
        children: [
          menuItem(Icons.home, "Home"),
          menuItem(Icons.calculate, "Calculator"),
          menuItem(Icons.account_circle, "About"),
          menuItem(Icons.contact_phone_rounded, "Contact"),
          menuItem(Icons.image_rounded, "Gallery"),
          menuItem(Icons.map_outlined, "Map"),
          SizedBox(height: 230),
          menuItem(Icons.settings_applications_sharp, "Settings"),
          menuItem(Icons.login, "LogOut"),
          // Add more menu items as needed
        ],
      ),
    );
  }

  Widget menuItem(IconData icon, String title) {
    return Material(
      child: InkWell(
        onTap: () {
          _onMenuItemSelected(title);
        },
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

  void _onMenuItemSelected(String title) {
    switch (title) {
      case "Home":
        break;
      case "Calculator":
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => CalculatorPage()),
        );
        break;
      case "About":
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => AboutPage()),
        );
        break;
      case "Contact":
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => ContactPage()),
        );
        break;
      case "Gallery":
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => PickImage()),
        );
        break;
      case "Map":
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => MapPage()),
        );
        break;
      case "Settings":
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => SettingsPage()),
        );
        break;
      case "LogOut":
        logout(context);
        break;
    }
  }

  Future<void> logout(BuildContext context) async {
    try {
      await GoogleSignInApi.logout();
      await FirebaseAuth.instance.signOut();

      // Clear the user authentication status
      await clearUserAuthenticationStatus();

      // Navigate to the login page and replace the current screen
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => MyWelcomeApp()),
      );

      // Show a success message
      showPopup(context, 'Success', 'Successfully Logged Out!');
    } catch (e) {
      print('Error logging out: $e');

      // Show an error message
      showPopup(context, 'Error', 'Failed to log out. Please try again.');
    }
  }

// Method to clear the user's authentication status
  Future<void> clearUserAuthenticationStatus() async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.setBool('isAuthenticated', false);
    } catch (e) {
      print('Error clearing authentication status: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final showStatusIndicators = themeProvider.showStatusIndicators;
    bool isFABVisible = true;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: themeProvider.currentTheme.primaryColor,
        actions: [
          if (showStatusIndicators)
            Row(
              children: [
                ToggleThemeButton(), // Add the theme toggle button to the AppBar
                if (isOnline)
                  Padding(
                    padding: EdgeInsets.only(right: 8.0),
                    child: Icon(
                      Icons.wifi,
                      color: Colors.white,
                      size: 20,
                    ),
                  ),
                if (!isOnline)
                  Padding(
                    padding: EdgeInsets.only(right: 8.0),
                    child: Icon(
                      Icons.wifi_off,
                      color: Colors.white,
                      size: 20,
                    ),
                  ),
                if (isBluetoothEnabled)
                  Padding(
                    padding: EdgeInsets.only(right: 8.0),
                    child: Icon(Icons.bluetooth, color: Colors.white, size: 20),
                  ),
                if (!isBluetoothEnabled)
                  Padding(
                    padding: EdgeInsets.only(right: 8.0),
                    child: Icon(Icons.bluetooth_disabled,
                        color: Colors.white, size: 20),
                  ),
              ],
            ),
          IconButton(
            icon: Icon(Icons.chevron_left),
            onPressed: () {
              setState(() {
                themeProvider.showStatusIndicators = !showStatusIndicators;
              });

              // Show a text notification
              if (showStatusIndicators) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Icons are now visible'),
                    duration: Duration(seconds: 2),
                  ),
                );
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Icons are now hidden'),
                    duration: Duration(seconds: 2),
                  ),
                );
              }
            },
          ),
        ],
        title: Text(
          widget.title,
          style: TextStyle(color: Colors.white), // Set text color to white
        ),
        iconTheme: IconThemeData(color: Colors.white),
      ),
      body: GestureDetector(
        onTap: () {
          // Toggle the visibility of FloatingActionButton on screen tap
          setState(() {
            isFABVisible = !isFABVisible;
          });
        },
        child: quizList(),
      ),
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor:
            themeProvider.currentTheme.bottomNavigationBarTheme.backgroundColor,
        selectedItemColor: themeProvider
            .currentTheme.bottomNavigationBarTheme.selectedItemColor,
        unselectedItemColor: themeProvider
            .currentTheme.bottomNavigationBarTheme.unselectedItemColor,
        onTap: _onItemTapped,
        currentIndex: 1,
        items: [
          BottomNavigationBarItem(
              icon: Icon(Icons.account_circle), label: 'About'),
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(
              icon: Icon(Icons.calculate), label: 'Calculate'),
        ],
      ),
      drawer: Drawer(
        child: SingleChildScrollView(
          child: Container(
            child: Column(
              children: [
                MyHeaderDrawer(),
                MyDrawerList(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class ToggleThemeButton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);

    return IconButton(
      icon: Icon(
        Icons.palette,
        size: 20,
      ),
      color: Colors.white,
      onPressed: () {
        themeProvider.toggleTheme();
      },
    );
  }
}

class QuizTile extends StatelessWidget {
  final String? imageUrl, title, id, description;
  final int noOfQuestions;

  QuizTile({
    required this.title,
    required this.imageUrl,
    required this.description,
    required this.id,
    required this.noOfQuestions,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => QuizPlay(id ?? ""),
            ));
      },
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 24),
        height: 150,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: Stack(
            children: [
              Image.network(
                imageUrl ?? "", // Use a default value if imageUrl is null
                fit: BoxFit.cover,
                width: MediaQuery.of(context).size.width,
              ),
              Positioned(
                bottom: 8, // Adjust the position as needed
                right: 8, // Adjust the position as needed
                child: Container(
                  padding: EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.8),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    'Start Quiz',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              Container(
                color: Colors.black26,
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        title ?? "", // Use a default value if title is null
                        style: TextStyle(
                          fontSize: 18,
                          color: Colors.white,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      SizedBox(
                        height: 4,
                      ),
                      Text(
                        description ??
                            "", // Use a default value if description is null
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.white,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
