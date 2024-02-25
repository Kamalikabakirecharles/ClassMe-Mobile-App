import 'dart:io';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'ThemeProvider.dart';
import 'dart:typed_data';

class MyHeaderDrawer extends StatefulWidget {
  const MyHeaderDrawer({Key? key}) : super(key: key);

  @override
  State<MyHeaderDrawer> createState() => _MyHeaderDrawerState();
}

class _MyHeaderDrawerState extends State<MyHeaderDrawer> {
  Uint8List? _image;
  File? selectedImage;
  bool isLoading = true;

  Future<void> _pickProfileImage() async {
  final imagePicker = ImagePicker();
  final pickedImage = await imagePicker.pickImage(source: ImageSource.gallery);

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

  @override
  void initState() {
    super.initState();
    // Load the profile picture when the widget initializes
    loadProfilePicture();
    Future.delayed(Duration.zero, () {
      print("Initial Image: $_image");
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
          Text("Profile", style: TextStyle(color: Colors.white, fontSize: 20)),
          Text("info@email.com",
              style: TextStyle(color: Colors.grey[200], fontSize: 14)),
        ],
      ),
    );
  }
}
