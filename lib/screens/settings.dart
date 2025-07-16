import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../Firebaseservice.dart';

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
    setState(() => notificationsEnabled = value);
  }

  Future<void> _changeUsername() async {
    final controller = TextEditingController(text: _username);

    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.grey[900],
        title: const Text("Change Username", style: TextStyle(color: Colors.white)),
        content: TextField(
          controller: controller,
          style: const TextStyle(color: Colors.white),
          decoration: const InputDecoration(
            hintText: "Enter new username",
            hintStyle: TextStyle(color: Colors.white38),
            enabledBorder: UnderlineInputBorder(
              borderSide: BorderSide(color: Colors.deepPurpleAccent),
            ),
          ),
        ),
        actions: [
          TextButton(
            child: const Text("Cancel"),
            onPressed: () => Navigator.pop(context),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.deepPurpleAccent,
            ),
            child: const Text("Save"),
            onPressed: () async {
              final newName = controller.text.trim();
              if (newName.isEmpty) return;

              final prefs = await SharedPreferences.getInstance();
              await prefs.setString('username', newName);
              setState(() => _username = newName); // UI instantly reflects
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
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: Colors.grey[900],
        title: const Text("Confirm", style: TextStyle(color: Colors.white)),
        content: const Text("Are you sure you want to clear all app data?", style: TextStyle(color: Colors.white70)),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text("Cancel")),
          TextButton(onPressed: () => Navigator.pop(context, true), child: const Text("Yes")),
        ],
      ),
    );

    if (confirm == true) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.clear();
      _showMessage("All app data cleared");
      setState(() {
        _username = "Otaku Name";
        notificationsEnabled = false;
      });
    }
  }

  void _showMessage(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg)),
    );
  }

  Widget _sectionTitle(IconData icon, String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        children: [
          Icon(icon, color: Colors.deepPurpleAccent),
          const SizedBox(width: 8),
          Text(title, style: const TextStyle(color: Colors.white70, fontSize: 18)),
        ],
      ),
    );
  }

  Widget _buildCard(List<Widget> children) {
    return Card(
      color: Colors.white10,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: Column(children: children),
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
          _sectionTitle(Icons.settings, "Preferences"),
          _buildCard([
            SwitchListTile(
              value: notificationsEnabled,
              onChanged: _toggleNotifications,
              title: const Text("Enable Notifications", style: TextStyle(color: Colors.white)),
              activeColor: Colors.deepPurpleAccent,
              inactiveThumbColor: Colors.grey,
            ),
            ListTile(
              leading: const Icon(Icons.edit, color: Colors.cyan),
              title: const Text("Change Username", style: TextStyle(color: Colors.white)),
              subtitle: Text(_username, style: const TextStyle(color: Colors.white60)),
              onTap: _changeUsername,
            ),
          ]),
          _sectionTitle(Icons.data_usage, "Data Management"),
          _buildCard([
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
          ]),
        ],
      ),
    );
  }
}
