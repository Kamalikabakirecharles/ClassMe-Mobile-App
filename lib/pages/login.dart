import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:ClassMe/ThemeProvider.dart';
import 'package:ClassMe/auth_page.dart';
import 'package:ClassMe/google_signin_api.dart';
import 'package:ClassMe/main.dart';
import 'package:ClassMe/my_button.dart';
import 'package:ClassMe/my_textfield.dart';
import 'package:ClassMe/pages/TeacherPage.dart';
import 'package:ClassMe/square_tile.dart';
import 'package:ClassMe/pages/signup.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LoginPage extends StatelessWidget {
  LoginPage({super.key});

  // text editing controllers
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  // sign user in method
  void signUserIn(BuildContext context) async {
    try {
      String email = emailController.text;
      String password = passwordController.text;

      // Check if the email is "kmlcharles@gmail.com"
      if (email == 'kmlcharles@gmail.com') {
        // Redirect to a specific page for the user with this email
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (context) => TeacherPage(),
          ),
        );
        return;
      }

      // If not the special email, proceed with regular sign-in logic
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      // After successful login, save the authentication status
      await saveUserAuthenticationStatus();

      // Navigate to the home page after successful login
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (context) => AuthPage(),
        ),
      );
    } catch (e) {
      // Handle login errors here
      print('Error logging in: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error logging in. Please try again.'),
        ),
      );
    }
  }

  // Method to save the user's authentication status
Future<void> saveUserAuthenticationStatus() async {
  try {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isAuthenticated', true);
  } catch (e) {
    print('Error saving authentication status: $e');
  }
}

  // navigate to signup page
  void goToSignupPage(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => SignupPage()),
    );
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    return Scaffold(
      backgroundColor: themeProvider.currentTheme.backgroundColor,
      appBar: AppBar(
        backgroundColor: themeProvider.currentTheme.primaryColor,
        title: Text(
          'Login',
          style: TextStyle(
              color: themeProvider.currentTheme.scaffoldBackgroundColor),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.only(bottom: 20.0),
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const SizedBox(height: 20),

                  // logo
                  Icon(
                    Icons.account_circle_rounded,
                    size: 80,
                    color: themeProvider.currentTheme.primaryColor,
                  ),

                  const SizedBox(height: 20),

                  // welcome back, you've been missed!
                  Text(
                    'LogIn',
                    style: TextStyle(
                      color: themeProvider.currentTheme.primaryColor,
                      fontSize: 16,
                    ),
                  ),

                  const SizedBox(height: 15),

                  // Email textfield
                  MyTextField(
                    controller: emailController,
                    hintText: 'Email',
                    obscureText: false,
                  ),

                  const SizedBox(height: 10),

                  // password textfield
                  MyTextField(
                    controller: passwordController,
                    hintText: 'Password',
                    obscureText: true,
                  ),

                  const SizedBox(height: 10),

                  // forgot password?
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 25.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Text(
                          'Forgot Password?',
                          style: TextStyle(
                            color: themeProvider.currentTheme.primaryColor,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 20),

                  // sign in button
                  MyButton(
                    onTap: () => signUserIn(context),
                  ),

                  const SizedBox(height: 30),

                  // or continue with
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 25.0),
                    child: Row(
                      children: [
                        Expanded(
                          child: Divider(
                            thickness: 0.5,
                            color: themeProvider.currentTheme.dividerColor,
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 10.0),
                          child: GestureDetector(
                            onTap: () => goToSignupPage(context),
                            child: Text(
                              'Or continue with',
                              style: TextStyle(
                                color: themeProvider.currentTheme.primaryColor,
                              ),
                            ),
                          ),
                        ),
                        Expanded(
                          child: Divider(
                            thickness: 0.5,
                            color: themeProvider.currentTheme.dividerColor,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 20),

                  // google + apple sign in buttons
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // google button
                      GestureDetector(
                        onTap: () async {
                          final user = await GoogleSignInApi.login();
                          if (user == null) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('Sign in failed'),
                              ),
                            );
                          } else {
                            Navigator.of(context).pushReplacement(
                              MaterialPageRoute(
                                builder: (context) => MyApp(),
                              ),
                            );
                          }
                        },
                        child: SquareTile(imagePath: 'lib/images/google.png'),
                      ),
                      SizedBox(width: 25),

                      // apple button
                      SquareTile(imagePath: 'lib/images/apple.png'),
                    ],
                  ),

                  const SizedBox(height: 30),

                  // not a member? register now
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Not a member?',
                        style: TextStyle(
                          color: Colors.black,
                        ),
                      ),
                      const SizedBox(width: 4),
                      GestureDetector(
                        onTap: () => goToSignupPage(context),
                        child: Text(
                          'Register now',
                          style: TextStyle(
                            color: themeProvider.currentTheme.primaryColor,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  )
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
