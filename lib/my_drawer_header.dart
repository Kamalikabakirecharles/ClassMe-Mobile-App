import 'dart:io';
import 'dart:convert';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'ThemeProvider.dart';
import 'dart:typed_data';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:http/http.dart' as http;

class MyHeaderDrawer extends StatefulWidget {
  const MyHeaderDrawer({Key? key}) : super(key: key);

  @override
  State<MyHeaderDrawer> createState() => _MyHeaderDrawerState();
}

class _MyHeaderDrawerState extends State<MyHeaderDrawer> {
  Uint8List? _image;
  bool isLoading = true;
  String? userEmail;
  String? userName;

  Future<void> _pickProfileImage() async {
    final imagePicker = ImagePicker();
    final pickedImage =
        await imagePicker.pickImage(source: ImageSource.gallery);

    if (pickedImage == null) return;

    final pickedImageFile = File(pickedImage.path);
    final imageBytes = await pickedImageFile.readAsBytes();

    // Save the selected image to shared preferences
    await saveProfilePicture(imageBytes as String);

    setState(() {
      _image = imageBytes;
    });
  }

  // Function to save the base64-encoded string to shared preferences
  Future<void> saveProfilePicture(String base64String) async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setString('profilePicture', base64String);
  }

  // Function to load the profile picture from shared preferences
  Future<void> loadProfilePicture() async {
    final prefs = await SharedPreferences.getInstance();
    final base64String = prefs.getString('profilePicture');

    if (base64String != null) {
      // Decode the base64 string to Uint8List
      final imageBytes = base64Decode(base64String);

      setState(() {
        _image = imageBytes;
      });
    }

    // Set isLoading to false after loading the profile picture
    setState(() {
      isLoading = false;
    });
  }

  // Function to save user information to shared preferences
  Future<void> saveUserInfo(String? name, String? email) async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setString('userName', name ?? "Your Name");
    prefs.setString('userEmail', email ?? "Your Email");
  }

// Function to load user information from GoogleSignIn or Firebase
  Future<void> loadUserInfo() async {
    final prefs = await SharedPreferences.getInstance();
    final savedUserName = prefs.getString('userName');
    final savedUserEmail = prefs.getString('userEmail');

    // Set userName variable
    setState(() {
      userName = savedUserName;
    });

    final googleSignIn = GoogleSignIn();
    final googleSignInAccount = await googleSignIn.signInSilently();

    // Check if the user is signed in with Google
    if (googleSignInAccount != null) {
      // Set userName and userEmail using Google Sign-In account
      setState(() {
        userName = googleSignInAccount.displayName;
        userEmail = googleSignInAccount.email;
      });

      // Fetch the user's profile picture using Google People API
      await fetchProfilePicture(googleSignInAccount.id);
    }

    // Check if the user is signed in with Firebase
    else {
      final firebaseUser = FirebaseAuth.instance.currentUser;
      if (firebaseUser != null) {
        setState(() {
          userName = firebaseUser.displayName ?? "Hello!";
          userEmail = firebaseUser.email ?? "Your Email";
        });

        // Use a default profile picture (modify as needed)
        setState(() {
          _image = null;
        });
      }
    }
  }

  // Function to fetch the user's profile picture using Google People API
  Future<void> fetchProfilePicture(String userId) async {
    try {
      final GoogleSignInAccount? currentUser =
          await GoogleSignIn().signInSilently();

      if (currentUser != null) {
        final GoogleSignInAuthentication authentication =
            await currentUser.authentication;

        print('Access Token: ${authentication.accessToken}');

        final response = await http.get(
          Uri.parse(
              'https://people.googleapis.com/v1/people/$userId?personFields=photos'),
          headers: {
            'Authorization': 'Bearer ${authentication.accessToken}',
          },
        );

        print('API Response Code: ${response.statusCode}');

        if (response.statusCode == 200) {
          final Map<String, dynamic> data = json.decode(response.body);
          print('API Response Data: $data');

          final String? photoUrl = data['photos']?.first['url'];

          if (photoUrl != null) {
            final http.Response imageResponse =
                await http.get(Uri.parse(photoUrl));
            final Uint8List imageBytes = imageResponse.bodyBytes;

            // Save the fetched profile picture to shared preferences
            await saveProfilePicture(base64Encode(imageBytes));
            await saveUserInfo(currentUser.displayName, currentUser.email);

            setState(() {
              _image = imageBytes;
            });
          }
        }
      }
    } catch (e) {
      print('Error fetching profile picture: $e');
      // Handle the error or add appropriate logic here
    }
  }

  @override
  void initState() {
    super.initState();
    // Load the profile picture when the widget initializes
    loadProfilePicture().then((_) {
      // After loading the profile picture, load user information
      loadUserInfo();
    });
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);

    return Container(
      color: themeProvider.currentTheme.primaryColor,
      width: double.infinity,
      height: 200,
      padding: EdgeInsets.only(top: 20.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          GestureDetector(
            onTap: () => _pickProfileImage(),
            child: CircleAvatar(
              radius: 35,
              backgroundImage: isLoading
                  ? null
                  : (_image != null && _image!.isNotEmpty
                          ? MemoryImage(_image!)
                          : AssetImage("lib/images/default_profile_image.png"))
                      as ImageProvider<Object>?,
            ),
          ),
          SizedBox(height: 10),
          if (isLoading)
            CircularProgressIndicator() // Show loading indicator
          else
            Column(
              children: [
                Text(
                  userName ?? "Hello!",
                  style: TextStyle(color: Colors.white, fontSize: 20),
                ),
                Text(
                  userEmail ?? "Kmlcharles@gmail.com",
                  style: TextStyle(color: Colors.grey[200], fontSize: 14),
                ),
              ],
            ),
        ],
      ),
    );
  }
}
