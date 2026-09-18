import '../../../../core/network/api_client.dart';
import '../models/game_model.dart';

abstract class GameRemoteDataSource {
  Future<List<GameModel>> fetchGames();
}

class GameRemoteDataSourceImpl implements GameRemoteDataSource {
  final ApiClient client;

  GameRemoteDataSourceImpl({required this.client});

  @override
  Future<List<GameModel>> fetchGames() async {
    await Future.delayed(const Duration(milliseconds: 500));

    final mockResponse = [
      {
        'id': '1',
        'title': 'The Legend of Zelda: Tears of the Kingdom',
        'genre': 'Action / Adventure',
        'rating': 4.9,
        'description': 'An epic adventure across the land and skies of Hyrule.',
        'imageUrl': 'https://images.unsplash.com/photo-1550745165-9bc0b252726f?w=600&auto=format&fit=crop',
      },
      {
        'id': '2',
        'title': 'Elden Ring',
        'genre': 'Action RPG',
        'rating': 4.8,
        'description': 'Rise, Tarnished, and be guided by grace to brandish the power of the Elden Ring.',
        'imageUrl': 'https://images.unsplash.com/photo-1542751371-adc38448a05e?w=600&auto=format&fit=crop',
      },
      {
        'id': '3',
        'title': 'Cyberpunk 2077: Phantom Liberty',
        'genre': 'Open World RPG',
        'rating': 4.7,
        'description': 'A spy-thriller expansion for open-world action-adventure RPG Cyberpunk 2077.',
        'imageUrl': 'https://images.unsplash.com/photo-1511512578047-dfb367046420?w=600&auto=format&fit=crop',
      },
      {
        'id': '4',
        'title': 'Hollow Knight: Silksong',
        'genre': 'Metroidvania',
        'rating': 4.9,
        'description': 'Discover a vast, haunted kingdom in Hollow Knight: Silksong.',
        'imageUrl': 'https://images.unsplash.com/photo-1579373903781-fd5c0c30c4cd?w=600&auto=format&fit=crop',
      },
    ];

    return mockResponse.map((json) => GameModel.fromJson(json)).toList();
  }
}
