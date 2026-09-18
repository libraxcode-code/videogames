import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/usecases/get_games_usecase.dart';
import 'game_event.dart';
import 'game_state.dart';

class GameBloc extends Bloc<GameEvent, GameState> {
  final GetGamesUseCase getGamesUseCase;
  Timer? _debounceTimer;

  GameBloc({required this.getGamesUseCase}) : super(const GameInitialState()) {
    on<FetchGamesEvent>(_onFetchGames);
    on<LoadMoreGamesEvent>(_onLoadMoreGames);
    on<SearchGamesEvent>(_onSearchGames);
  }

  @override
  Future<void> close() {
    _debounceTimer?.cancel();
    return super.close();
  }

  Future<void> _onFetchGames(
    FetchGamesEvent event,
    Emitter<GameState> emit,
  ) async {
    final query = event.searchQuery ?? '';

    // Show loading indicator
    emit(GameLoadingState(isSearching: query.isNotEmpty));

    final result = await getGamesUseCase(
      GetGamesParams(
        page: 1,
        forceRefresh: event.forceRefresh,
        searchQuery: query.isNotEmpty ? query : null,
      ),
    );

    result.fold(
      (failure) => emit(GameErrorState(failure.message, activeQuery: query)),
      (games) => emit(GameLoadedState(
        games: games,
        activeQuery: query,
        currentPage: 1,
        hasReachedMax: games.length < 20,
      )),
    );
  }

  Future<void> _onLoadMoreGames(
    LoadMoreGamesEvent event,
    Emitter<GameState> emit,
  ) async {
    final currentState = state;
    if (currentState is! GameLoadedState ||
        currentState.hasReachedMax ||
        currentState.isLoadingMore) {
      return;
    }

    emit(currentState.copyWith(isLoadingMore: true));

    final nextPage = currentState.currentPage + 1;
    final result = await getGamesUseCase(
      GetGamesParams(
        page: nextPage,
        searchQuery: currentState.activeQuery.isNotEmpty
            ? currentState.activeQuery
            : null,
      ),
    );

    result.fold(
      (failure) => emit(currentState.copyWith(isLoadingMore: false)),
      (newGames) {
        if (newGames.isEmpty) {
          emit(currentState.copyWith(
            hasReachedMax: true,
            isLoadingMore: false,
          ));
        } else {
          emit(currentState.copyWith(
            games: List.of(currentState.games)..addAll(newGames),
            currentPage: nextPage,
            hasReachedMax: newGames.length < 20,
            isLoadingMore: false,
          ));
        }
      },
    );
  }

  void _onSearchGames(
    SearchGamesEvent event,
    Emitter<GameState> emit,
  ) {
    _debounceTimer?.cancel();
    _debounceTimer = Timer(const Duration(milliseconds: 400), () {
      add(FetchGamesEvent(searchQuery: event.query));
    });
  }
}
