import 'package:equatable/equatable.dart';

class GameEntity extends Equatable {
  final String id;
  final String title;
  final String genre;
  final double rating;
  final String description;
  final String imageUrl;

  const GameEntity({
    required this.id,
    required this.title,
    required this.genre,
    required this.rating,
    required this.description,
    required this.imageUrl,
  });

  @override
  List<Object?> get props => [id, title, genre, rating, description, imageUrl];
}
