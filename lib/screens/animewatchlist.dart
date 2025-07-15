import 'package:flutter/material.dart';
import '../models/anime.dart';
import '../Firebaseservice.dart';
import '../api_service.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:shimmer/shimmer.dart';

import 'animedetails.dart';


class WatchlistPage extends StatefulWidget {
  const WatchlistPage({super.key});

  @override
  State<WatchlistPage> createState() => _WatchlistPageState();
}

class _WatchlistPageState extends State<WatchlistPage> {
  late Future<List<Anime>> _animeFuture;
  final List<String> validStatuses = ['Watching', 'Completed', 'Plan to Watch'];

  @override
  void initState() {
    super.initState();
    _animeFuture = fetchWatchlistAnimes();
  }

  Future<List<Anime>> fetchWatchlistAnimes() async {
    final malIds = await FirestoreService.getWatchlistAnimeIds();
    List<Anime> animes = [];
    for (var id in malIds) {
      try {
        final anime = await ApiService.fetchAnimeById(id);
        final userStatus = await FirestoreService.getWatchlistStatus(id);
        anime.userStatus = validStatuses.contains(userStatus) ? userStatus : validStatuses.first;
        animes.add(anime);
      } catch (_) {}
    }
    return animes;
  }

  Future<void> _deleteFromWatchlist(int malId) async {
    await FirestoreService.deleteAnimeFromWatchlist(malId);
    setState(() {
      _animeFuture = fetchWatchlistAnimes();
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Removed from Watchlist")),
    );
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
        future: _animeFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return ListView.builder(
              itemCount: 6,
              itemBuilder: (context, index) => Shimmer.fromColors(
                baseColor: Colors.grey[800]!,
                highlightColor: Colors.grey[700]!,
                child: Card(
                  color: Colors.grey[900],
                  margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                  child: ListTile(
                    leading: Container(width: 60, height: 80, color: Colors.white),
                    title: Container(height: 14, width: 100, color: Colors.white),
                    subtitle: Container(height: 10, width: 60, color: Colors.white),
                  ),
                ),
              ),
            );
          }

          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(
              child: Text("Your watchlist is empty.", style: TextStyle(color: Colors.white70)),
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
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => AnimeDetailsPage(anime: anime, fromRandom: false),
                      ),
                    );
                  },
                  contentPadding: const EdgeInsets.all(8),
                  leading: ClipRRect(
                    borderRadius: BorderRadius.circular(6),
                    child: Image.network(anime.imageUrl, width: 60, height: 80, fit: BoxFit.cover),
                  ),
                  title: Text(anime.title,
                      style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("⭐ ${anime.score}", style: const TextStyle(color: Colors.white70)),
                      DropdownButton<String>(
                        value: validStatuses.contains(anime.userStatus)
                            ? anime.userStatus
                            : validStatuses.first,
                        dropdownColor: Colors.black87,
                        iconEnabledColor: Colors.white,
                        items: validStatuses.map((status) {
                          return DropdownMenuItem(
                            value: status,
                            child: Text(status, style: const TextStyle(color: Colors.white)),
                          );
                        }).toList(),
                        onChanged: (newStatus) async {
                          if (newStatus != null) {
                            await FirestoreService.updateWatchlistStatus(anime.malId, newStatus);
                            setState(() {
                              anime.userStatus = newStatus;
                            });
                          }
                        },
                      ),
                    ],
                  ),
                  trailing: IconButton(
                    icon: const Icon(Icons.delete, color: Colors.redAccent),
                    onPressed: () => _deleteFromWatchlist(anime.malId),
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
