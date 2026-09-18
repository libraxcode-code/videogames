import '../../domain/entities/game_entity.dart';

class GameModel extends GameEntity {
  const GameModel({
    required super.id,
    required super.title,
    required super.genre,
    required super.rating,
    required super.metacritic,
    required super.releaseDate,
    required super.description,
    required super.imageUrl,
    super.platforms = const [],
    super.developers = const [],
    super.publishers = const [],
    super.website = '',
    super.trailerUrl,
    super.trailerPreview,
  });

  factory GameModel.fromJson(Map<String, dynamic> json) {
    final id = json['id']?.toString() ?? '';
    final title = json['name'] as String? ?? json['title'] as String? ?? 'Untitled Game';

    // Parse genres from RAWG array format
    String genre = '';
    if (json['genres'] is List && (json['genres'] as List).isNotEmpty) {
      genre = (json['genres'] as List)
          .map((g) => g['name']?.toString() ?? '')
          .where((name) => name.isNotEmpty)
          .take(2)
          .join(' • ');
    } else if (json['genre'] is String) {
      genre = json['genre'] as String;
    }

    final rating = (json['rating'] as num?)?.toDouble() ?? 0.0;
    final metacritic = (json['metacritic'] as num?)?.toInt() ?? 0;
    final releaseDate = json['released'] as String? ?? 'TBA';

    // Parse description
    String description = json['description_raw'] as String? ??
        json['description'] as String? ??
        '';
    if (description.isEmpty) {
      description = 'PlayStation 5 release with next-gen ray tracing, ultra high-speed SSD, and haptic feedback immersion.';
    }

    final imageUrl = json['background_image'] as String? ??
        json['imageUrl'] as String? ??
        '';

    // Parse platforms
    List<String> platforms = [];
    if (json['platforms'] is List) {
      platforms = (json['platforms'] as List)
          .map((p) => p['platform']?['name']?.toString() ?? '')
          .where((p) => p.isNotEmpty)
          .toList();
    }

    // Parse developers
    List<String> developers = [];
    if (json['developers'] is List) {
      developers = (json['developers'] as List)
          .map((d) => d['name']?.toString() ?? '')
          .where((d) => d.isNotEmpty)
          .toList();
    }

    // Parse publishers
    List<String> publishers = [];
    if (json['publishers'] is List) {
      publishers = (json['publishers'] as List)
          .map((pub) => pub['name']?.toString() ?? '')
          .where((pub) => pub.isNotEmpty)
          .toList();
    }

    final website = json['website'] as String? ?? '';
    final trailerUrl = json['trailer_url'] as String?;
    final trailerPreview = json['trailer_preview'] as String?;

    return GameModel(
      id: id,
      title: title,
      genre: genre.isNotEmpty ? genre : 'Action / Adventure',
      rating: rating,
      metacritic: metacritic,
      releaseDate: releaseDate,
      description: description,
      imageUrl: imageUrl,
      platforms: platforms,
      developers: developers,
      publishers: publishers,
      website: website,
      trailerUrl: trailerUrl,
      trailerPreview: trailerPreview,
    );
  }

  GameModel copyWithTrailer({
    String? trailerUrl,
    String? trailerPreview,
  }) {
    return GameModel(
      id: id,
      title: title,
      genre: genre,
      rating: rating,
      metacritic: metacritic,
      releaseDate: releaseDate,
      description: description,
      imageUrl: imageUrl,
      platforms: platforms,
      developers: developers,
      publishers: publishers,
      website: website,
      trailerUrl: trailerUrl ?? this.trailerUrl,
      trailerPreview: trailerPreview ?? this.trailerPreview,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'genre': genre,
      'rating': rating,
      'metacritic': metacritic,
      'released': releaseDate,
      'description': description,
      'background_image': imageUrl,
      'platforms': platforms.map((p) => {'platform': {'name': p}}).toList(),
      'developers': developers.map((d) => {'name': d}).toList(),
      'publishers': publishers.map((p) => {'name': p}).toList(),
      'website': website,
    };
  }
}
