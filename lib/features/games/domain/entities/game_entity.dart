import 'package:equatable/equatable.dart';

class GameEntity extends Equatable {
  final String id;
  final String title;
  final String genre;
  final double rating;
  final int metacritic;
  final String releaseDate;
  final String description;
  final String imageUrl;
  final List<String> platforms;
  final List<String> developers;
  final List<String> publishers;
  final String website;
  final String? trailerUrl;
  final String? trailerPreview;

  const GameEntity({
    required this.id,
    required this.title,
    required this.genre,
    required this.rating,
    required this.metacritic,
    required this.releaseDate,
    required this.description,
    required this.imageUrl,
    this.platforms = const [],
    this.developers = const [],
    this.publishers = const [],
    this.website = '',
    this.trailerUrl,
    this.trailerPreview,
  });

  @override
  List<Object?> get props => [
        id,
        title,
        genre,
        rating,
        metacritic,
        releaseDate,
        description,
        imageUrl,
        platforms,
        developers,
        publishers,
        website,
        trailerUrl,
        trailerPreview,
      ];
}
