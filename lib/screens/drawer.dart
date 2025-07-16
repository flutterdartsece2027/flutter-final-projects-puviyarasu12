
import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'animenews.dart';
import 'categoriesresult.dart';
import 'randomanime.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';

class CustomDrawer extends StatefulWidget {
  const CustomDrawer({super.key});

  @override
  State<CustomDrawer> createState() => _CustomDrawerState();
}

class _CustomDrawerState extends State<CustomDrawer> {
  String _username = "Otaku";
  String? _profileImagePath;
  final user = FirebaseAuth.instance.currentUser;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }
  Future<void> _loadUserData() async {
    final prefs = await SharedPreferences.getInstance();
    final base64Image = prefs.getString('profile_image');

    File? imageFile;
    if (base64Image != null) {
      final bytes = base64Decode(base64Image);
      final tempDir = Directory.systemTemp;
      imageFile = await File('${tempDir.path}/drawer_profile_image.png').writeAsBytes(bytes);
    }

    setState(() {
      _username = prefs.getString('username') ?? "Otaku";
      _profileImagePath = imageFile?.path;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: Colors.grey[900],
      child: SafeArea(
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              color: Colors.deepPurpleAccent,
              width: double.infinity,
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 30,
                    backgroundColor: Colors.white24,
                    backgroundImage: _profileImagePath != null
                        ? FileImage(File(_profileImagePath!))
                        : null,
                    child: _profileImagePath == null
                        ? const Icon(Icons.person, color: Colors.white, size: 30)
                        : null,
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text("Welcome,", style: TextStyle(color: Colors.white70, fontSize: 14)),
                        Text(
                          _username,
                          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
                        ),
                        if (user?.email != null)
                          Text(user!.email!, style: const TextStyle(color: Colors.white70, fontSize: 12)),
                      ],
                    ),
                  )
                ],
              ),
            ),
            const SizedBox(height: 12),

            // Categories Tile
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              child: Material(
                color: Colors.white10,
                borderRadius: BorderRadius.circular(12),
                child: ListTile(
                  leading: const Icon(Icons.category, color: Colors.deepPurpleAccent),
                  title: const Text('Categories', style: TextStyle(color: Colors.white)),
                  onTap: () {
                    Navigator.push(context, MaterialPageRoute(builder: (_) => const CategoriesPage()));
                  },
                ),
              ),
            ),

            // Anime News Tile
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              child: Material(
                color: Colors.white10,
                borderRadius: BorderRadius.circular(12),
                child: ListTile(
                  leading: const Icon(Icons.newspaper, color: Colors.deepPurpleAccent),
                  title: const Text('Anime News', style: TextStyle(color: Colors.white)),
                  onTap: () {
                    Navigator.push(context, MaterialPageRoute(builder: (_) => const AnimeNewsPage()));
                  },
                ),
              ),
            ),

            // Random Anime Tile
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              child: Material(
                color: Colors.white10,
                borderRadius: BorderRadius.circular(12),
                child: ListTile(
                  leading: const Icon(Icons.shuffle, color: Colors.deepPurpleAccent),
                  title: const Text('Random Anime', style: TextStyle(color: Colors.white)),
                  onTap: () {
                    Navigator.push(context, MaterialPageRoute(builder: (_) => const RandomAnimeDetailsPage()));
                  },
                ),
              ),
            ),

            const Divider(color: Colors.white24, thickness: 1),

            // About Tile
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              child: Material(
                color: Colors.white10,
                borderRadius: BorderRadius.circular(12),
                child: ListTile(
                  leading: const Icon(Icons.info_outline, color: Colors.deepPurpleAccent),
                  title: const Text('About', style: TextStyle(color: Colors.white)),
                  onTap: () {
                    Navigator.push(context, MaterialPageRoute(builder: (_) => const AboutPage()));
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class CategoriesPage extends StatelessWidget {
  const CategoriesPage({super.key});

  final List<String> categories = const [
    "Action",
    "Adventure",
    "Cars",
    "Comedy",
    "Dementia",
    "Demons",
    "Drama",
    "Ecchi",
    "Fantasy",
    "Game",
    "Historical",
    "Horror",
    "Kids",
    "Magic",
    "Martial Arts",
    "Mecha",
    "Music",
    "Mystery",
    "Romance",
    "School",
    "Sci-Fi",
    "Shoujo",
    "Shoujo Ai",
    "Shounen",
    "Shounen Ai",
    "Space",
    "Sports",
    "Super Power",
    "Vampire",
    "Yaoi",
    "Yuri",
    "Harem",
    "Slice of Life",
    "Supernatural",
    "Military",
    "Police",
    "Psychological",
    "Thriller",
    "Seinen",
    "Josei",
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.deepPurpleAccent,
        title: const Text("Categories"),
      ),
      backgroundColor: Colors.black,
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: GridView.builder(
          itemCount: categories.length,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            childAspectRatio: 2.5,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
          ),
          itemBuilder: (context, index) {
            final genre = categories[index];
            return ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => CategoryResultsPage(genre: genre),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white12,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Text(
                genre,
                style: const TextStyle(color: Colors.white),
              ),
            );
          },
        ),
      ),
    );
  }
}

class AboutPage extends StatelessWidget {
  const AboutPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text("About AniVerse"),
        backgroundColor: Colors.deepPurpleAccent,
        iconTheme: const IconThemeData(color: Colors.white),
        titleTextStyle: const TextStyle(color: Colors.white, fontSize: 20),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: const [
            Text(
              "AniVerse",
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: Colors.deepPurpleAccent,
              ),
            ),
            SizedBox(height: 10),
            Text(
              "AniVerse is your one-stop anime companion app. Discover trending anime, stay updated with the latest news, manage your watchlist, and explore randomly selected gems!",
              style: TextStyle(color: Colors.white70, fontSize: 16),
            ),
            SizedBox(height: 20),
            Text(
              "Features:",
              style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18),
            ),
            SizedBox(height: 8),
            Text("• Browse anime categories", style: TextStyle(color: Colors.white70)),
            Text("• Stay updated with anime news", style: TextStyle(color: Colors.white70)),
            Text("• Manage your watchlist", style: TextStyle(color: Colors.white70)),
            Text("• Explore random anime suggestions", style: TextStyle(color: Colors.white70)),
            SizedBox(height: 20),
            Text(
              "Made with ❤️ using Flutter & Firebase",
              style: TextStyle(color: Colors.white60, fontStyle: FontStyle.italic),
            ),
          ],
        ),
      ),
    );
  }
}
