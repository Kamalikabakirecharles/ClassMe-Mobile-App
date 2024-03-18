import 'package:flutter/material.dart';
import 'package:ClassMe/ThemeProvider.dart';
import 'package:ClassMe/main.dart';
import 'package:ClassMe/my_drawer_header.dart';
import 'package:ClassMe/pages/about.dart';
import 'package:ClassMe/pages/settings.dart';
import 'package:provider/provider.dart';

void main() => runApp(CalculatorPage());

class CalculatorPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {

    final themeProvider = Provider.of<ThemeProvider>(context);

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: themeProvider.currentTheme,
      home: Calculator(),
    );
  }
}

class Calculator extends StatefulWidget {
  @override
  _CalculatorState createState() => _CalculatorState();
}


class _CalculatorState extends State<Calculator> {
  dynamic text = '0';
  double numOne = 0;
  double numTwo = 0;
  dynamic result = '';
  dynamic finalResult = '';
  dynamic opr = '';
  dynamic preOpr = '';

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
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => AboutPage()),
        );
        break;
      case "Home":
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => MyApp()),
        );
        break;
      case "Calculator":
        break;
      case "Settings":
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => SettingsPage()),
        );
        break;
      // Add more cases for other menu items as needed
    }
  }
  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        // Handle back button press
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => MyApp()),
        );
        return false; // Return false to prevent default back button behavior
      },
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          title: Text(
        'Calculator',
        style: TextStyle(color: Colors.white), // Set text color to white
      ),
      iconTheme: IconThemeData(color: Colors.white),
          backgroundColor: Theme.of(context).primaryColor,
          // Replace the back button with a drawer
          leading: Builder(
            builder: (BuildContext context) {
              return IconButton(
                icon: Icon(Icons.menu),
                onPressed: () {
                  Scaffold.of(context).openDrawer();
                },
              );
            },
          ),
        ),
        // Add a drawer to the Scaffold
        drawer: Drawer(
          child: ListView(
            padding: EdgeInsets.zero,
            children: [
               MyHeaderDrawer(),
                MyDrawerList(),
            ],
          ),
        ),
        body: Padding(
          padding: EdgeInsets.symmetric(horizontal: 5),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Padding(
                    padding: EdgeInsets.all(10.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          text,
                          textAlign: TextAlign.right,
                          style: TextStyle(color: Colors.black, fontSize: 50),
                        ),
                        Text(
                          opr,
                          textAlign: TextAlign.right,
                          style: TextStyle(color: Colors.black, fontSize: 30),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  calcbutton('AC', Colors.grey, Colors.black),
                  calcbutton('+/-', Colors.grey, Colors.black),
                  calcbutton('%', Colors.grey, Colors.black),
                  calcbutton('/', Theme.of(context).primaryColor, Colors.white),
                ],
              ),
              SizedBox(height: 10,),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  calcbutton('7', Colors.grey[850]!, Colors.white),
                  calcbutton('8', Colors.grey[850]!, Colors.white),
                  calcbutton('9', Colors.grey[850]!, Colors.white),
                  calcbutton('x', Theme.of(context).primaryColor, Colors.white),
                ],
              ),
              SizedBox(height: 10,),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  calcbutton('4', Colors.grey[850]!, Colors.white),
                  calcbutton('5', Colors.grey[850]!, Colors.white),
                  calcbutton('6', Colors.grey[850]!, Colors.white),
                  calcbutton('-', Theme.of(context).primaryColor, Colors.white),
                ],
              ),
              SizedBox(height: 10,),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  calcbutton('1', Colors.grey[850]!, Colors.white),
                  calcbutton('2', Colors.grey[850]!, Colors.white),
                  calcbutton('3', Colors.grey[850]!, Colors.white),
                  calcbutton('+', Theme.of(context).primaryColor, Colors.white),
                ],
              ),
              SizedBox(height: 10,),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  TextButton(
                    onPressed: () {
                      calculation('0');
                    },
                    style: TextButton.styleFrom(
                      shape: StadiumBorder(),
                      padding: EdgeInsets.fromLTRB(34, 20, 128, 20),
                      backgroundColor: Colors.grey[850],
                    ),
                    child: Text(
                      "0",
                      style: TextStyle(fontSize: 35, color: Colors.white),
                    ),
                  ),
                  calcbutton('.', Colors.grey[850]!, Colors.white),
                  calcbutton('=', Colors.grey[700]!, Colors.white),
                ],
              ),
              SizedBox(height: 20,), // Add space between calculator and BottomNavigationBar
              // Bottom navigation bar
              BottomNavigationBar(
                backgroundColor: Theme.of(context).bottomNavigationBarTheme.backgroundColor,
        selectedItemColor: Theme.of(context).bottomNavigationBarTheme.selectedItemColor,
        unselectedItemColor: Theme.of(context).bottomNavigationBarTheme.unselectedItemColor,
                onTap: _onItemTapped,
                currentIndex: 2, // Set the current index to 2 for Calculator
                items: [
                  BottomNavigationBarItem(icon: Icon(Icons.account_circle), label: 'About'),
                  BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
                  BottomNavigationBarItem(icon: Icon(Icons.calculate), label: 'Calculator'),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget calcbutton(String btntxt, Color btncolor, Color txtcolor) {
    return Container(
      child: ElevatedButton(
        onPressed: () {
          calculation(btntxt);
        },
        child: Text(
          btntxt,
          style: TextStyle(
            fontSize: 35,
            color: txtcolor,
          ),
        ),
        style: ElevatedButton.styleFrom(
          shape: CircleBorder(), backgroundColor: btncolor,
          padding: EdgeInsets.all(20),
        ),
      ),
    );
  }

  void calculation(btnText) {
    if (btnText == 'AC') {
      text = '0';
      numOne = 0;
      numTwo = 0;
      result = '';
      finalResult = '0';
      opr = '';
      preOpr = '';
    } else if (opr == '=' && btnText == '=') {
      if (preOpr == '+') {
        finalResult = add();
      } else if (preOpr == '-') {
        finalResult = sub();
      } else if (preOpr == 'x') {
        finalResult = mul();
      } else if (preOpr == '/') {
        finalResult = div();
      }

      opr = '';
      numTwo = 0;
    } else if (btnText == '+' || btnText == '-' || btnText == 'x' || btnText == '/' || btnText == '=') {
      if (numOne == 0) {
        numOne = double.parse(result);
      } else {
        numTwo = double.parse(result);
      }

      if (opr == '+') {
        finalResult = add();
      } else if (opr == '-') {
        finalResult = sub();
      } else if (opr == 'x') {
        finalResult = mul();
      } else if (opr == '/') {
        finalResult = div();
      }
      preOpr = opr;
      opr = btnText;
      result = '';
    } else if (btnText == '%') {
      result = numOne / 100;
      finalResult = doesContainDecimal(result);
    } else if (btnText == '.') {
      if (!result.toString().contains('.')) {
        result = result.toString() + '.';
      }
      finalResult = result;
    } else if (btnText == '+/-') {
      result.toString().startsWith('-') ? result = result.toString().substring(1) : result = '-' + result.toString();
      finalResult = result;
    } else {
      result = result + btnText;
      finalResult = result;
    }

    setState(() {
      text = finalResult;
    });
  }

  String add() {
    result = (numOne + numTwo).toString();
    numOne = double.parse(result);
    return doesContainDecimal(result);
  }

  String sub() {
    result = (numOne - numTwo).toString();
    numOne = double.parse(result);
    return doesContainDecimal(result);
  }

  String mul() {
    result = (numOne * numTwo).toString();
    numOne = double.parse(result);
    return doesContainDecimal(result);
  }

  String div() {
    result = (numOne / numTwo).toString();
    numOne = double.parse(result);
    return doesContainDecimal(result);
  }

  String doesContainDecimal(dynamic result) {
    if (result.toString().contains('.')) {
      List<String> splitDecimal = result.toString().split('.');
      if (!(int.parse(splitDecimal[1]) > 0)) return result = splitDecimal[0].toString();
    }
    return result;
  }

  void _onItemTapped(int index) {
    // Handle navigation to different pages based on index
    switch (index) {
      case 0:
        // Navigate to the About page
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => AboutPage()),
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
        // No need to navigate to the Calculator page as it's already the current page
        break;
      // Add more cases for other bottom navigation items if needed
    }
  }
}
