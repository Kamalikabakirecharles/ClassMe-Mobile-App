import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:ClassMe/ThemeProvider.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PickImage extends StatefulWidget {
  const PickImage({Key? key}) : super(key: key);

  @override
  State<PickImage> createState() => _PickImageState();
}

class _PickImageState extends State<PickImage> {
  Uint8List? _image;
  File? selectedImage;


  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    return Scaffold(
      appBar: AppBar(
        title: Text('Pick Image'),
      ),
      backgroundColor: Colors.white,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Stack(
              alignment: Alignment.bottomCenter,
              children: [
                _image != null
                    ? CircleAvatar(
                        radius: 100,
                        backgroundImage: MemoryImage(_image!),
                      )
                    : const CircleAvatar(
                        radius: 100,
                        backgroundImage: NetworkImage(
                            "https://cdn.pixabay.com/photo/2015/10/05/22/37/blank-profile-picture-973460_960_720.png"),
                      ),
                Positioned(
                  bottom: 10,
                  child: IconButton(
                    onPressed: () {
                      showImagePickerOption(context);
                    },
                    icon:  Icon(Icons.add_a_photo, color: themeProvider.currentTheme.primaryColor,),
                  ),
                ),
              ],
            ),
            ElevatedButton(
              onPressed: () {
                if (_image != null) {
                  // Set the profile picture logic here (e.g., save it to storage or update user profile)
                  // For demonstration purposes, we'll print a message.
                  print("Profile picture set!");

                  // After setting the profile picture, navigate back to MyApp
                  Navigator.pop(context);
                } else {
                  // Handle the case where no image is selected
                  print("No image selected");
                }
              },
              child: Text("Set Profile Picture"),
            ),
          ],
        ),
      ),
    );
  }

  void showImagePickerOption(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context, listen: false);

    showModalBottomSheet(
      backgroundColor: Colors.white,
      context: context,
      builder: (builder) {
        return Padding(
          padding: const EdgeInsets.all(18.0),
          child: SizedBox(
            width: MediaQuery.of(context).size.width,
            height: MediaQuery.of(context).size.height / 4.5,
            child: Row(
              children: [
                Expanded(
                  child: InkWell(
                    onTap: () {
                      _pickImageFromGallery();
                    },
                    child: SizedBox(
                      child: Column(
                        children: [
                          Icon(
                            Icons.image,
                            size: 70,
                            color: themeProvider.currentTheme.primaryColor,
                          ),
                          Text("Gallery"),
                        ],
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: InkWell(
                    onTap: () {
                      _pickImageFromCamera();
                    },
                    child: SizedBox(
                      child: Column(
                        children: [
                          Icon(
                            Icons.camera_alt,
                            size: 70,
                            color: themeProvider.currentTheme.primaryColor,
                          ),
                          Text("Camera"),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future _pickImageFromGallery() async {
    final returnImage =
        await ImagePicker().pickImage(source: ImageSource.gallery);
    if (returnImage == null) return;

    final selectedImage = File(returnImage.path);
    final imageBytes = await selectedImage.readAsBytes();

    // Save the selected image to shared preferences
    await saveProfilePicture(imageBytes);

    setState(() {
      _image = imageBytes;
    });

    Navigator.of(context).pop(); // Close the modal sheet
  }

  Future _pickImageFromCamera() async {
    final returnImage =
        await ImagePicker().pickImage(source: ImageSource.camera);
    if (returnImage == null) return;

    final selectedImage = File(returnImage.path);
    final imageBytes = await selectedImage.readAsBytes();

    // Save the selected image to shared preferences
    await saveProfilePicture(imageBytes);

    setState(() {
      _image = imageBytes;
    });

    Navigator.of(context).pop(); // Close the modal sheet
  }

// Function to save the base64-encoded image to shared preferences
  Future<void> saveProfilePicture(Uint8List? imageBytes) async {
    if (imageBytes == null || imageBytes.isEmpty) return;

    final base64String = base64Encode(imageBytes);

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('profilePicture', base64String);
  }
}
