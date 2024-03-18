import 'package:flutter/material.dart';
import 'package:ClassMe/ThemeProvider.dart';
import 'package:ClassMe/main.dart';
import 'package:ClassMe/my_drawer_header.dart';
import 'package:provider/provider.dart';
import 'calculator.dart';

void main() {
  runApp(const SettingsPage());
}

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter Demo',
      theme: themeProvider.currentTheme,
      home: const MyHomePage(title: 'Settings Page'),
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

  void _onItemTapped(int index) {
    // Handle navigation to different pages based on index
    switch (index) {
      case 0:
        // Navigate to the Settings page
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => SettingsPage()),
        );
        break;
      case 1:
        // Navigate to the Home page
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => MyApp()),
        );
        break;
      case 2:
        // Navigate to the Calculator page
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => CalculatorPage()),
        );
        break;

      // Add more cases for other bottom navigation items if needed
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
          SizedBox(height: 350),
          menuItem(Icons.settings_applications_sharp, "Settings"),
          // Add more menu items as needed
        ],
      ),
    );
  }

  Widget menuItem(IconData icon, String title) {
    return Material(
      child: InkWell(
        onTap: () {
          // Add functionality for the menu item here
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
    // Handle navigation or perform actions based on the selected menu item
    switch (title) {
      case "About":
        break;
      case "Home":
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => MyApp()),
        );
        break;
      case "Calculator":
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => CalculatorPage()),
        );
        break;
      case "settings":
        break;
      // Add more cases for other menu items as needed
    }
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final showStatusIndicators = themeProvider.showStatusIndicators;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).primaryColor,
        title: Text(
          widget.title,
          style: TextStyle(color: Colors.white), // Set text color to white
        ),
        iconTheme: IconThemeData(
            color: Colors.white), // Set drawer icon color to white
      ),
      body: Column(
        children: [
          SizedBox(height: 20),
          Text(
            'Appearance',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Theme.of(context).primaryColor,
            ),
          ),
          SizedBox(height: 20),
          Divider(),
          SwitchListTile(
            title: Text('Show Status Indicators'),
            value: showStatusIndicators,
            onChanged: (value) {
              themeProvider.showStatusIndicators = value;
            },
            activeColor: Theme.of(context)
                .primaryColor, // Use primary color as the active color
            activeTrackColor: Theme.of(context)
                .primaryColorLight, // Customize the active track color if needed
          ),

          SizedBox(height: 20),
          Divider(),
          SizedBox(height: 20),
          Text('Select the Theme Color'),
          ColorThemeSelector(),
          SizedBox(height: 20),
          Divider(),
          // ... other settings options
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor:
            Theme.of(context).bottomNavigationBarTheme.backgroundColor,
        selectedItemColor:
            Theme.of(context).bottomNavigationBarTheme.selectedItemColor,
        unselectedItemColor:
            Theme.of(context).bottomNavigationBarTheme.unselectedItemColor,
        onTap: _onItemTapped,
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

class ColorThemeSelector extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        for (final themeData in ThemeProvider.availableThemes)
          InkWell(
            onTap: () {
              themeProvider.setTheme(themeData);
            },
            child: Container(
              width: 40,
              height: 40,
              margin: EdgeInsets.all(8),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: themeData.primaryColor,
              ),
            ),
          ),
      ],
    );
  }
}
