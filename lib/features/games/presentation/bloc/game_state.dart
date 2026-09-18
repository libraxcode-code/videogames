import 'package:equatable/equatable.dart';
import '../../domain/entities/game_entity.dart';

abstract class GameState extends Equatable {
  const GameState();

  @override
  List<Object?> get props => [];
}

class GameInitialState extends GameState {
  const GameInitialState();
}

class GameLoadingState extends GameState {
  final bool isSearching;

  const GameLoadingState({this.isSearching = false});

  @override
  List<Object?> get props => [isSearching];
}

class GameLoadedState extends GameState {
  final List<GameEntity> games;
  final String activeQuery;
  final int currentPage;
  final bool hasReachedMax;
  final bool isLoadingMore;
  final bool isFromCache;

  const GameLoadedState({
    required this.games,
    this.activeQuery = '',
    this.currentPage = 1,
    this.hasReachedMax = false,
    this.isLoadingMore = false,
    this.isFromCache = false,
  });

  GameLoadedState copyWith({
    List<GameEntity>? games,
    String? activeQuery,
    int? currentPage,
    bool? hasReachedMax,
    bool? isLoadingMore,
    bool? isFromCache,
  }) {
    return GameLoadedState(
      games: games ?? this.games,
      activeQuery: activeQuery ?? this.activeQuery,
      currentPage: currentPage ?? this.currentPage,
      hasReachedMax: hasReachedMax ?? this.hasReachedMax,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      isFromCache: isFromCache ?? this.isFromCache,
    );
  }

  @override
  List<Object?> get props => [
        games,
        activeQuery,
        currentPage,
        hasReachedMax,
        isLoadingMore,
        isFromCache,
      ];
}

class GameErrorState extends GameState {
  final String message;
  final String activeQuery;

  const GameErrorState(this.message, {this.activeQuery = ''});

  @override
  List<Object?> get props => [message, activeQuery];
}
