import 'package:flutter/material.dart';
import '../models/anime.dart';
import '../Firebaseservice.dart';
import '../api_service.dart';
import 'package:url_launcher/url_launcher.dart';

class AnimeDetailsPage extends StatelessWidget {
  final Anime anime;
  final bool fromRandom;

  const AnimeDetailsPage({
    super.key,
    required this.anime,
    this.fromRandom = false,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: Text(anime.title, style: const TextStyle(color: Colors.white)),
        backgroundColor: Colors.black,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: Image.network(
                anime.imageUrl,
                width: double.infinity,
                height: 300,
                fit: BoxFit.cover,
              ),
            ),
            const SizedBox(height: 20),
            Text(
              anime.title,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 26, fontWeight: FontWeight.bold, color: Colors.white),
            ),
            const SizedBox(height: 10),
            Text(
              "⭐ ${anime.score}  |  ${anime.type}  |  ${anime.episodes} episodes",
              style: const TextStyle(color: Colors.white70, fontSize: 14),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            Divider(color: Colors.white24),
            const SizedBox(height: 8),
            _sectionTitle("Synopsis"),
            const SizedBox(height: 6),
            Text(
              anime.synopsis,
              style: const TextStyle(color: Colors.white70, height: 1.5),
              textAlign: TextAlign.justify,
            ),
            const SizedBox(height: 20),
            Divider(color: Colors.white24),
            const SizedBox(height: 8),
            _sectionTitle("Details"),
            const SizedBox(height: 6),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey.shade900,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                children: [
                  infoRow("Year", anime.year?.toString()),
                  infoRow("Status", anime.status),
                  infoRow("Rank", "#${anime.rank}"),
                  infoRow("Popularity", "#${anime.popularity}"),
                  infoRow("Members", anime.members.toString()),
                  infoRow("Rating", anime.rating),
                  infoRow("Duration", anime.duration),
                  infoRow("Studios", anime.studios.join(", ")),
                  infoRow("Genres", anime.genres.join(", ")),
                  infoRow("Aired", "${anime.airedFrom ?? 'Unknown'} → ${anime.airedTo ?? 'Unknown'}"),
                ],
              ),
            ),
            const SizedBox(height: 20),
            if (anime.trailerUrl != null)
              ElevatedButton.icon(
                onPressed: () {
                  launchUrl(Uri.parse(anime.trailerUrl!));
                },
                icon: const Icon(Icons.play_circle_fill),
                label: const Text("Watch Trailer"),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.redAccent,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                ),
              ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: () async {
                try {
                  await FirestoreService.addAnimeToWatchlist(anime.malId);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("Added to Watchlist!")),
                  );
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text("Error: $e")),
                  );
                }
              },
              icon: const Icon(Icons.bookmark_add),
              label: const Text("Add to Watchlist"),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.deepPurple,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
              ),
            ),
            const SizedBox(height: 16),
            if (fromRandom)
              ElevatedButton.icon(
                onPressed: () async {
                  final newAnime = await ApiService.fetchRandomAnime();
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder: (_) => AnimeDetailsPage(anime: newAnime, fromRandom: true),
                    ),
                  );
                },
                icon: const Icon(Icons.refresh),
                label: const Text("Another Random Anime"),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.teal,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                ),
              ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget infoRow(String label, String? value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "$label: ",
            style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
          ),
          Expanded(
            child: Text(
              value ?? "N/A",
              style: const TextStyle(color: Colors.white70),
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  Widget _sectionTitle(String title) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Text(
        title,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 18,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}


class WatchlistPage extends StatelessWidget {
  const WatchlistPage({super.key});

  Future<List<Anime>> fetchWatchlistAnimes() async {
    final malIds = await FirestoreService.getWatchlistAnimeIds();

    List<Anime> animes = [];
    for (var id in malIds) {
      try {
        final anime = await ApiService.fetchAnimeById(id);
        animes.add(anime);
      } catch (_) {}
    }

    return animes;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text("Watchlist", style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.black,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: FutureBuilder<List<Anime>>(
        future: fetchWatchlistAnimes(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(
              child: Text("Your watchlist is empty.",
                  style: TextStyle(color: Colors.white70)),
            );
          }

          final animes = snapshot.data!;
          return ListView.builder(
            padding: const EdgeInsets.all(12),
            itemCount: animes.length,
            itemBuilder: (context, index) {
              final anime = animes[index];
              return Card(
                color: Colors.grey[900],
                margin: const EdgeInsets.symmetric(vertical: 8),
                child: ListTile(
                  leading: ClipRRect(
                    borderRadius: BorderRadius.circular(6),
                    child: Image.network(anime.imageUrl, width: 60),
                  ),
                  title: Text(anime.title,
                      style: const TextStyle(
                          color: Colors.white, fontWeight: FontWeight.bold)),
                  subtitle: Text("⭐ ${anime.score}",
                      style: const TextStyle(color: Colors.white70)),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) =>
                            AnimeDetailsPage(anime: anime, fromRandom: false),
                      ),
                    );
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }
}