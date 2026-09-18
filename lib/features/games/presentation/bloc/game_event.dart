import 'package:equatable/equatable.dart';

abstract class GameEvent extends Equatable {
  const GameEvent();

  @override
  List<Object?> get props => [];
}

class FetchGamesEvent extends GameEvent {
  final bool forceRefresh;
  final String? searchQuery;

  const FetchGamesEvent({
    this.forceRefresh = false,
    this.searchQuery,
  });

  @override
  List<Object?> get props => [forceRefresh, searchQuery];
}

class LoadMoreGamesEvent extends GameEvent {
  const LoadMoreGamesEvent();
}

class SearchGamesEvent extends GameEvent {
  final String query;

  const SearchGamesEvent(this.query);

  @override
  List<Object?> get props => [query];
}
