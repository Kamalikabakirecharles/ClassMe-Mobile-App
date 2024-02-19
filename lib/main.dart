import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_application_2/ThemeProvider.dart';
import 'package:flutter_application_2/my_drawer_header.dart';
import 'package:flutter_application_2/pages/about.dart';
import 'package:flutter_application_2/pages/calculator.dart';
import 'package:flutter_application_2/pages/login.dart';
import 'package:flutter_application_2/pages/settings.dart';
import 'package:flutter_blue/flutter_blue.dart';
import 'package:provider/provider.dart';
import 'package:connectivity/connectivity.dart';

void main() {
  runApp(
    ChangeNotifierProvider(
      create: (context) => ThemeProvider(),
      child: const MyApp(),
    ),
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

  @override
  void initState() {
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
          SizedBox(height: 200),
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
      case "Settings":
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => SettingsPage()),
        );
        break;
      case "LogOut":
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => LoginPage()),
        );
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final showStatusIndicators = themeProvider.showStatusIndicators;

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
                    child: Icon(Icons.wifi, color: Colors.white, size: 20,),
                  ),
                if (!isOnline)
                  Padding(
                    padding: EdgeInsets.only(right: 8.0),
                    child: Icon(Icons.wifi_off, color: Colors.white, size: 20,),
                  ),
                if (isBluetoothEnabled)
                  Padding(
                    padding: EdgeInsets.only(right: 8.0),
                    child: Icon(Icons.bluetooth, color: Colors.white, size: 20),
                  ),
                if (!isBluetoothEnabled)
                  Padding(
                    padding: EdgeInsets.only(right: 8.0),
                    child: Icon(Icons.bluetooth_disabled, color: Colors.white, size: 20),
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
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const Text(
              'Welcome to the App I created',
            ),
          ],
        ),
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
      icon: Icon(Icons.palette, size: 20,),
      color: Colors.white,
      onPressed: () {
        themeProvider.toggleTheme();
      },
    );
  }
}