import 'package:flutter/material.dart';
import 'package:contacts_service/contacts_service.dart';
import 'package:ClassMe/ThemeProvider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

class ContactPage extends StatefulWidget {
  const ContactPage({Key? key}) : super(key: key);

  @override
  _ContactPageState createState() => _ContactPageState();
}

class _ContactPageState extends State<ContactPage> {
  List<Contact> _contacts = [];

  @override
  void initState() {
    super.initState();
    _fetchContacts();
  }

  Future<void> _fetchContacts() async {
    if (await Permission.contacts.request().isGranted) {
      // Get all contacts
      final Iterable<Contact> contacts = await ContactsService.getContacts();
      setState(() {
        _contacts = contacts.toList();
      });
    } else {
      // Handle the case when permission is denied
      print("Contacts permission denied");
    }
  }

  void _callContact(Contact contact) async {
    final phoneNumber = contact.phones?.first.value;

    if (phoneNumber != null && await canLaunch("tel:$phoneNumber")) {
      await launch("tel:$phoneNumber");
    } else {
      print("Could not launch phone call");
    }
  }

  void _sendMessageToContact(Contact contact) async {
    final phoneNumber = contact.phones?.first.value;

    if (phoneNumber != null) {
      final message = "Your SMS message here";
      final uri = Uri.encodeFull("sms:$phoneNumber?body=$message");

      try {
        await launch(uri);
      } catch (e) {
        print("Error launching messaging app: $e");
      }
    } else {
      print("Phone number not available");
    }
  }

  void _sortContacts() {
  _contacts.sort((a, b) => a.displayName!.compareTo(b.displayName!));
  setState(() {
    // Show a SnackBar indicating that contacts have been sorted
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Contacts sorted A-Z'),
        duration: Duration(seconds: 2),
      ),
    );
  });
}


  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Contact Page'),
        actions: [
          IconButton(
            icon: Icon(Icons.sort),
            onPressed: _sortContacts,
          ),
        ],
      ),
      body: ListView.builder(
        itemCount: _contacts.length,
        itemBuilder: (context, index) {
          final contact = _contacts[index];
          return ListTile(
            leading: CircleAvatar(
              child: Text(
                contact.displayName![0], // Get the first letter of the contact's name
                style: TextStyle(
                  color: Colors.white,
                ),
              ),
              backgroundColor: themeProvider.currentTheme.primaryColor, // Customize the color of the circle
            ),
            title: Text(contact.displayName ?? ''),
            subtitle: Text(contact.phones?.isNotEmpty == true
                ? contact.phones!.first.value!
                : 'No phone number'),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: Icon(Icons.phone),
                  onPressed: () => _callContact(contact),
                ),
                IconButton(
                  icon: Icon(Icons.message),
                  onPressed: () => _sendMessageToContact(contact),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
