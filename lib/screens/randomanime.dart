import 'dart:convert';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../models/anime.dart';
 import 'animedetails.dart';
import 'animewatchlist.dart';

class RandomAnimeDetailsPage extends StatefulWidget {
  const RandomAnimeDetailsPage({super.key});

  @override
  State<RandomAnimeDetailsPage> createState() => _RandomAnimeDetailsPageState();
}

class _RandomAnimeDetailsPageState extends State<RandomAnimeDetailsPage> {
  @override
  void initState() {
    super.initState();
    _loadRandomAndNavigate();
  }

  Future<void> _loadRandomAndNavigate() async {
    final anime = await fetchRandomAnime();
    if (!mounted) return;
    if (anime != null) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => AnimeDetailsPage(
            anime: anime,
            fromRandom: true, // 👈 Pass flag to show regenerate
          ),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Failed to load random anime")),
      );
      Navigator.pop(context);
    }
  }

  Future<Anime?> fetchRandomAnime() async {
    try {
      final page = Random().nextInt(10) + 1;
      final res = await http.get(Uri.parse('https://api.jikan.moe/v4/top/anime?page=$page'));

      if (res.statusCode == 200) {
        final json = jsonDecode(res.body);
        final list = (json['data'] as List).map((e) => Anime.fromJson(e)).toList();
        return list[Random().nextInt(list.length)];
      }
    } catch (e) {
      print('Error fetching anime: $e');
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    // Show a loading screen for 1 second max
    return const Scaffold(
      backgroundColor: Colors.black,
      body: Center(
        child: CircularProgressIndicator(color: Colors.purpleAccent),
      ),
    );
  }
}
