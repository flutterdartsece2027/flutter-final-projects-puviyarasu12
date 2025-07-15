import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../api_service.dart';
import '../models/anime.dart';
import 'animedetails.dart';

class CategoryResultsPage extends StatelessWidget {
  final String genre;

  const CategoryResultsPage({super.key, required this.genre});

  int? getGenreId() {
    const genreMap = {
      "Action": 1,
      "Adventure": 2,
      "Cars": 3,
      "Comedy": 4,
      "Dementia": 5,
      "Demons": 6,
      "Mystery": 7,
      "Drama": 8,
      "Ecchi": 9,
      "Fantasy": 10,
      "Game": 11,
      "Historical": 13,
      "Horror": 14,
      "Kids": 15,
      "Magic": 16,
      "Martial Arts": 17,
      "Mecha": 18,
      "Music": 19,
      "Samurai": 21,
      "Romance": 22,
      "School": 23,
      "Sci-Fi": 24,
      "Shoujo": 25,
      "Shoujo Ai": 26,
      "Shounen": 27,
      "Shounen Ai": 28,
      "Space": 29,
      "Sports": 30,
      "Super Power": 31,
      "Vampire": 32,
      "Yaoi": 33,
      "Yuri": 34,
      "Harem": 35,
      "Slice of Life": 36,
      "Supernatural": 37,
      "Military": 38,
      "Police": 39,
      "Psychological": 40,
      "Thriller": 41,
      "Seinen": 42,
      "Josei": 43,
    };
    return genreMap[genre];
  }

  Future<List<Anime>> fetchByGenre() async {
    final genreId = getGenreId();
    if (genreId == null) throw Exception("Invalid genre");
    return await ApiService.fetchAnimeByGenre(genreId);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.deepPurpleAccent,
        title: Text("$genre Anime"),
      ),
      body: FutureBuilder<List<Anime>>(
        future: fetchByGenre(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(
              child: Text("Error: ${snapshot.error}", style: const TextStyle(color: Colors.red)),
            );
          }

          final animeList = snapshot.data ?? [];
          if (animeList.isEmpty) {
            return const Center(
              child: Text("No anime found", style: TextStyle(color: Colors.white70)),
            );
          }

          return GridView.builder(
            padding: const EdgeInsets.all(10),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 10,
              mainAxisSpacing: 10,
              childAspectRatio: 0.65,
            ),
            itemCount: animeList.length,
            itemBuilder: (context, index) {
              final anime = animeList[index];
              return GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => AnimeDetailsPage(anime: anime),
                    ),
                  );
                },
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.deepPurple.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      ClipRRect(
                        borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
                        child: Image.network(
                          anime.imageUrl,
                          height: 180,
                          fit: BoxFit.cover,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 6),
                        child: Text(
                          anime.title,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(height: 6),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
