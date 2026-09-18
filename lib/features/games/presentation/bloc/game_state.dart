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
  const GameLoadingState();
}

class GameLoadedState extends GameState {
  final List<GameEntity> games;
  final bool isFromCache;

  const GameLoadedState({
    required this.games,
    this.isFromCache = false,
  });

  @override
  List<Object?> get props => [games, isFromCache];
}

class GameErrorState extends GameState {
  final String message;

  const GameErrorState(this.message);

  @override
  List<Object?> get props => [message];
}
