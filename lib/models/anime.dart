

class Anime {
  final int malId;
  final String title;
  final String imageUrl;
  final String synopsis;
  final String type;
  final int episodes;
  late final String status;
  final int rank;
  final int popularity;
  final int members;
  final double score;
  final List<String> genres;
  final int? year;
  final List<String> studios;
  final String? duration;
  final String? rating;
  final String? trailerUrl;
  String? userStatus; // maps to Firestore field "userwatchliststatus"
  final String? backgroundImage;
  final String? airedFrom;
  final String? airedTo;

  Anime({
    required this.malId,
    required this.title,
    required this.imageUrl,
    required this.synopsis,
    required this.type,
    required this.episodes,
    required this.status,
    required this.rank,
    required this.popularity,
    required this.members,
    required this.score,
    required this.genres,
    required this.year,
    required this.studios,
    this.duration,
    this.rating,
    this.trailerUrl,
    this.userStatus,
    this.backgroundImage,
    this.airedFrom,
    this.airedTo,
  });

  factory Anime.fromJson(Map<String, dynamic> json, {String? userwatchliststatus}) {
    final aired = json['aired'];
    final trailer = json['trailer'];

    return Anime(
      malId: json['mal_id'] ?? 0,
      title: json['title'] ?? 'Unknown Title',
      imageUrl: json['images']?['jpg']?['image_url'] ?? 'https://via.placeholder.com/150',
      synopsis: json['synopsis'] ?? 'No synopsis available',
      type: json['type'] ?? 'Unknown',
      episodes: json['episodes'] ?? 0,
      status: json['status'] ?? 'Unknown',
      rank: json['rank'] ?? 0,
      popularity: json['popularity'] ?? 0,
      members: json['members'] ?? 0,
      score: (json['score'] ?? 0).toDouble(),
      genres: (json['genres'] as List<dynamic>? ?? [])
          .map((genre) => genre['name'] as String? ?? 'Unknown')
          .toList(),
      year: json['year'],
      studios: (json['studios'] as List<dynamic>? ?? [])
          .map((studio) => studio['name'] as String? ?? 'Unknown')
          .toList(),
      duration: json['duration'],
      rating: json['rating'],
      trailerUrl: trailer?['url'],
      backgroundImage: json['images']?['jpg']?['large_image_url'],
      airedFrom: aired?['from'],
      airedTo: aired?['to'],
      userStatus: userwatchliststatus,
    );
  }
}

class NewsArticle {
  final String title;
  final String description;
  final String url;
  final String urlToImage;
  final DateTime publishedAt;
  final String source;
  final String author;
  final String content;

  const NewsArticle({
    required this.title,
    required this.description,
    required this.url,
    required this.urlToImage,
    required this.publishedAt,
    required this.source,
    required this.author,
    required this.content,
  });

  factory NewsArticle.fromJson(Map<String, dynamic> json) {
    return NewsArticle(
      title: json['title'] ?? 'No Title',
      description: json['description'] ?? 'No description',
      url: json['url'] ?? '',
      urlToImage: json['urlToImage'] ?? 'https://c4.wallpaperflare.com/wallpaper/923/720/848/anime-one-piece-monkey-d-luffy-nami-one-piece-wallpaper-preview.jpg',
      publishedAt: DateTime.tryParse(json['publishedAt'] ?? '') ?? DateTime.now(),
      source: json['source']?['name'] ?? 'Unknown Source',
      author: json['author'] ?? 'Anonymous',
      content: json['content'] ?? 'No content available',
    );
  }
}
