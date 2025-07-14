import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../Firebaseservice.dart';
import 'animewatchlist.dart';
import 'splash_screen.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  File? _profileImage;
  String _username = "Otaku Name";
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _loadProfileData();
  }

  Future<void> _loadProfileData() async {
    final prefs = await SharedPreferences.getInstance();
    final name = prefs.getString('username') ?? "Otaku Name";
    setState(() {
      _username = name;
    });
  }

  Future<void> _pickImage() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _profileImage = File(pickedFile.path);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.deepPurpleAccent,
        title: const Text("Your Profile"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            GestureDetector(
              onTap: _pickImage,
              child: CircleAvatar(
                radius: 55,
                backgroundColor: Colors.white24,
                backgroundImage: _profileImage != null ? FileImage(_profileImage!) : null,
                child: _profileImage == null
                    ? const Icon(Icons.person, size: 50, color: Colors.deepPurpleAccent)
                    : null,
              ),
            ),
            const SizedBox(height: 12),
            Text(_username, style: const TextStyle(color: Colors.white, fontSize: 22)),
            const SizedBox(height: 30),
            const Divider(color: Colors.white24),
            ListTile(
              leading: const Icon(Icons.favorite, color: Colors.deepPurpleAccent),
              title: const Text("My Watchlist", style: TextStyle(color: Colors.white)),
              onTap: () {
                Navigator.push(context, MaterialPageRoute(builder: (_) => const WatchlistPage()));
              },
            ),
            ListTile(
              leading: const Icon(Icons.settings, color: Colors.deepPurpleAccent),
              title: const Text("Settings", style: TextStyle(color: Colors.white)),
              onTap: () {
                Navigator.push(context, MaterialPageRoute(builder: (_) => const SettingsPage()));
              },
            ),
            ListTile(
              leading: const Icon(Icons.logout, color: Colors.deepPurpleAccent),
              title: const Text("Logout", style: TextStyle(color: Colors.white)),
              onTap: () {
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (_) => const LoginPage()),
                      (route) => false,
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  bool notificationsEnabled = false;
  String _username = "";

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      notificationsEnabled = prefs.getBool('notifications') ?? false;
      _username = prefs.getString('username') ?? "Otaku Name";
    });
  }

  Future<void> _toggleNotifications(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('notifications', value);
    setState(() {
      notificationsEnabled = value;
    });
  }

  Future<void> _changeUsername() async {
    final controller = TextEditingController(text: _username);
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Change Username"),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(hintText: "Enter new username"),
        ),
        actions: [
          TextButton(
            child: const Text("Cancel"),
            onPressed: () => Navigator.pop(context),
          ),
          ElevatedButton(
            child: const Text("Save"),
            onPressed: () async {
              final prefs = await SharedPreferences.getInstance();
              await prefs.setString('username', controller.text.trim());
              setState(() => _username = controller.text.trim());
              Navigator.pop(context);
              _showMessage("Username updated");
            },
          ),
        ],
      ),
    );
  }

  Future<void> _clearWatchlist() async {
    try {
      await FirestoreService.clearWatchlist();
      _showMessage("Watchlist cleared");
    } catch (e) {
      _showMessage("Error clearing watchlist: $e");
    }
  }

  Future<void> _deleteProfileImage() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('profile_image');
    _showMessage("Profile image deleted");
  }

  Future<void> _clearAllData() async {
    final confirm = await showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Confirm"),
        content: const Text("Are you sure you want to clear all app data?"),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text("Cancel")),
          TextButton(onPressed: () => Navigator.pop(context, true), child: const Text("Yes")),
        ],
      ),
    );
    if (confirm) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.clear();
      _showMessage("All preferences cleared");
    }
  }

  void _showMessage(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text("Settings", style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.deepPurpleAccent,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const Text("Preferences", style: TextStyle(color: Colors.white70, fontSize: 18)),
          SwitchListTile(
            value: notificationsEnabled,
            onChanged: _toggleNotifications,
            title: const Text("Enable Notifications", style: TextStyle(color: Colors.white)),
            activeColor: Colors.deepPurpleAccent,
          ),
          ListTile(
            leading: const Icon(Icons.edit, color: Colors.cyan),
            title: const Text("Change Username", style: TextStyle(color: Colors.white)),
            subtitle: Text(_username, style: const TextStyle(color: Colors.white60)),
            onTap: _changeUsername,
          ),
          const Divider(color: Colors.white24),
          const Text("Data Management", style: TextStyle(color: Colors.white70, fontSize: 18)),
          ListTile(
            leading: const Icon(Icons.delete_forever, color: Colors.redAccent),
            title: const Text("Clear Watchlist", style: TextStyle(color: Colors.white)),
            onTap: _clearWatchlist,
          ),
          ListTile(
            leading: const Icon(Icons.person_remove, color: Colors.orange),
            title: const Text("Delete Profile Image", style: TextStyle(color: Colors.white)),
            onTap: _deleteProfileImage,
          ),
          ListTile(
            leading: const Icon(Icons.clear_all, color: Colors.blueGrey),
            title: const Text("Clear All App Data", style: TextStyle(color: Colors.white)),
            onTap: _clearAllData,
          ),
        ],
      ),
    );
  }
}
