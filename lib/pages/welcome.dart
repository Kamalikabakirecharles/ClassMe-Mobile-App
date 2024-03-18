import 'package:flutter/material.dart';
import 'package:ClassMe/pages/login.dart';
import 'package:ClassMe/pages/signup.dart';
import 'package:lottie/lottie.dart';

class MyWelcomeApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  bool isLoginActive = true; // Variable to track the active button

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                Text(
                  'WELCOME TO',
                  style: TextStyle(
                    fontSize: 45,
                    fontWeight: FontWeight.bold,
                    color: Colors.blue,
                  ),
                ),
                Text(
                  'ClassMe',
                  style: TextStyle(
                    fontSize: 42,
                    fontWeight: FontWeight.bold,
                    color: Colors.blue,
                  ),
                ),
                SizedBox(height: 20),
                Text(
                  'Where great things happen!',
                  style: TextStyle(
                    fontSize: 20,
                    color: Colors.black54,
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 20),
          Container(
            child: Center(
              child: Lottie.asset('lib/json/old_town_walk.json'),
            ),
          ),
          SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ElevatedButton(
                onPressed: () {
                  setState(() {
                    isLoginActive = true;
                  });
                  // Add your login button logic here
                  Navigator.of(context).pushReplacement(
                    MaterialPageRoute(
                      builder: (context) => LoginPage(),
                    ),
                  );
                },
                style: isLoginActive
                    ? ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue,
                      )
                    : null,
                child: Text('Login'),
              ),
              SizedBox(width: 20),
              ElevatedButton(
                onPressed: () {
                  setState(() {
                    isLoginActive = false;
                  });
                  // Add your signup button logic here
                  Navigator.of(context).pushReplacement(
                    MaterialPageRoute(
                      builder: (context) => SignupPage(),
                    ),
                  );
                },
                style: !isLoginActive
                    ? ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue,
                      )
                    : null,
                child: Text('Signup'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
