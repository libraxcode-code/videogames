import 'package:equatable/equatable.dart';

abstract class GameEvent extends Equatable {
  const GameEvent();

  @override
  List<Object?> get props => [];
}

class FetchGamesEvent extends GameEvent {
  final bool forceRefresh;

  const FetchGamesEvent({this.forceRefresh = false});

  @override
  List<Object?> get props => [forceRefresh];
}
