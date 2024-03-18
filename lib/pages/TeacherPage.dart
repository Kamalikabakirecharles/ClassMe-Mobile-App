import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:ClassMe/pages/ModifyQuiz.dart';
import 'package:ClassMe/pages/create_quiz.dart';
import 'package:ClassMe/pages/welcome.dart';
import 'package:ClassMe/popup.dart';
import 'package:flutter/material.dart';
import 'package:ClassMe/ThemeProvider.dart';
import 'package:ClassMe/google_signin_api.dart';
import 'package:ClassMe/my_drawer_header.dart';
import 'package:ClassMe/pages/Contact.dart';
import 'package:ClassMe/pages/about.dart';
import 'package:ClassMe/pages/calculator.dart';
import 'package:ClassMe/pages/gallery.dart';
import 'package:ClassMe/pages/settings.dart';
import 'package:ClassMe/services/database.dart';
import 'package:flutter_blue/flutter_blue.dart';
import 'package:provider/provider.dart';
import 'package:connectivity/connectivity.dart';
import 'package:uuid/uuid.dart';

class TeacherPage extends StatelessWidget {
  const TeacherPage({Key? key});

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter Demo',
      theme: themeProvider.currentTheme,
      home: const MyHomePage(title: 'Teacher Home Page'),
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
  bool isFABExpanded = false;

  late Timer refreshTimer;
  bool showStatusIndicators = true;
  late Stream<QuerySnapshot<Map<String, dynamic>>> quizStream;

  late DatabaseService databaseService;

  Widget quizList() {
    return Container(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 16.0),
        child: StreamBuilder(
          stream: quizStream,
          builder: (context,
              AsyncSnapshot<QuerySnapshot<Map<String, dynamic>>> snapshot) {
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
                            color: Theme.of(context)
                                .primaryColor, // Use the color of your theme
                            thickness: 2.0, // Adjust the thickness as needed
                            height: 2, // Use 0 to get a full line
                          ),
                        ],
                      );
                    },
                  );
          },
        ),
      ),
    );
  }

  @override
  void initState() {
    databaseService = DatabaseService(uid: Uuid().v4());
    quizStream = Stream.empty();

    databaseService.getQuizData().then((value) {
      setState(() {
        quizStream = value;
      });
    });
    super.initState();

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

    refreshTimer = Timer.periodic(Duration(seconds: 2), (Timer timer) {
      refreshStatus();
    });

    databaseService.getQuizData().then((value) {
      quizStream = value;
      setState(() {});
    });
  }

  @override
  void dispose() {
    refreshTimer.cancel();
    super.dispose();
  }

  void refreshStatus() {
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
      Completer<bool> completer = Completer<bool>();
      late StreamSubscription<BluetoothState> subscription;

      subscription = flutterBlue.state.listen((BluetoothState bluetoothState) {
        completer.complete(bluetoothState == BluetoothState.on);
        subscription.cancel();
      });

      return await completer.future;
    } catch (e, stackTrace) {
      print('Error in checkBluetoothStatus: $e\n$stackTrace');
      return false;
    }
  }

  Widget MyDrawerList() {
    return Container(
      padding: EdgeInsets.only(top: 15),
      child: Column(
        children: [
          menuItem(Icons.home, "Home"),
          menuItem(Icons.calculate, "Calculator"),
          menuItem(Icons.account_circle, "About"),
          menuItem(Icons.contact_phone_rounded, "Contact"),
          menuItem(Icons.image_rounded, "Gallery"),
          SizedBox(height: 200),
          menuItem(Icons.settings_applications_sharp, "Settings"),
          menuItem(Icons.login, "LogOut"),
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
      case "Settings":
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => SettingsPage()),
        );
        break;
      case "LogOut":
        logout();
        break;
    }
  }

  Future<void> logout() async {
    try {
      await GoogleSignInApi.logout();
      FirebaseAuth.instance.signOut();

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => MyWelcomeApp()),
      );

      showPopup(context, 'Success', 'Successfully Logged Out!');
    } catch (e) {
      print('Error logging out: $e');

      showPopup(context, 'Error', 'Failed to log out. Please try again.');
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
                ToggleThemeButton(),
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
          style: TextStyle(color: Colors.white),
        ),
        iconTheme: IconThemeData(color: Colors.white),
      ),
      body: GestureDetector(
        onTap: () {
          setState(() {
            isFABVisible = !isFABVisible;
          });
        },
        child: quizList(),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endDocked,
      floatingActionButton: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Visibility(
            visible: isFABExpanded,
            child: FloatingActionButton.extended(
              onPressed: () async {
                // Add functionality for the first FloatingActionButton

                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => CreateQuiz()),
                );
              },
              icon: Icon(
                Icons.border_color_outlined,
                color: Colors.white,
              ),
              label: Text(
                'Add Question',
                style: TextStyle(color: Colors.white),
              ), // Add text label here
              backgroundColor: Theme.of(context).primaryColor,
            ),
          ),
          SizedBox(height: 16),
          Visibility(
            visible: isFABExpanded,
            child: FloatingActionButton.extended(
              onPressed: () async {
                // Add functionality for the second FloatingActionButton
                bool isOnline = await checkInternetConnectivity();

                if (isOnline) {
                  // Device is online, proceed to CreateQuiz page
                  // Navigator.push(
                  //   context,
                  //   MaterialPageRoute(builder: (context) => ModifyQuizPage()),
                  // );
                } else {
                  // Device is offline, show a popup message
                  showPopup(
                    context,
                    'OPPs',
                    'You are offline. Cannot Edit subject.',
                  );
                }
              },
              icon: Icon(
                Icons.edit_document,
                color: Colors.white,
              ),
              label: Text(
                'Edit Quiz',
                style: TextStyle(color: Colors.white),
              ), // Add text label here
              backgroundColor: Theme.of(context).primaryColor,
            ),
          ),
          SizedBox(height: 16),
          FloatingActionButton(
            onPressed: () {
              setState(() {
                isFABExpanded = !isFABExpanded;
              });
            },
            child: Icon(
              isFABExpanded ? Icons.close : Icons.add,
              color: Colors.white,
            ),
            backgroundColor: Theme.of(context).primaryColor,
          ),
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
      onTap: () async {
        // Device is online, proceed to AddQuestion page
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ModifyQuizPage(
              quizId: '$id',
            ),
          ),
        );
      },
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 24),
        height: 150,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: Stack(
            children: [
              Image.network(
                imageUrl ??
                    "lib/images/photo-1606.png", // Use a default value if imageUrl is null
                fit: BoxFit.cover,
                width: MediaQuery.of(context).size.width,
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
