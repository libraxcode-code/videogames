import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/widgets/glass_search_bar.dart';
import '../../../../core/widgets/glass_skeleton_loading.dart';
import '../../domain/entities/game_entity.dart';
import '../../domain/usecases/get_game_detail_usecase.dart';
import '../bloc/game_bloc.dart';
import '../bloc/game_event.dart';
import '../bloc/game_state.dart';
import '../widgets/game_list_empty_error_views.dart';
import '../widgets/game_list_header.dart';
import '../widgets/game_list_view.dart';
import '../widgets/water_flow_background.dart';
import 'game_detail_page.dart';

class GameListPage extends StatefulWidget {
  const GameListPage({super.key});

  @override
  State<GameListPage> createState() => _GameListPageState();
}

class _GameListPageState extends State<GameListPage> {
  final ScrollController _scrollController = ScrollController();
  final TextEditingController _searchController = TextEditingController();
  final GlobalKey<WaterFlowBackgroundState> _waterBgKey = GlobalKey<WaterFlowBackgroundState>();

  @override
  void initState() {
    super.initState();
    context.read<GameBloc>().add(const FetchGamesEvent());
    _scrollController.addListener(_onScroll);
  }

  void _onScroll() {
    if (!_scrollController.hasClients) return;
    final maxScroll = _scrollController.position.maxScrollExtent;
    final currentScroll = _scrollController.offset;

    // Reactively trigger water flow motion on scroll
    _waterBgKey.currentState?.onScrollOffsetUpdate(currentScroll);

    // Trigger infinite scroll pagination 250px before bottom
    if (currentScroll >= (maxScroll - 250)) {
      final state = context.read<GameBloc>().state;
      if (state is GameLoadedState && !state.isLoadingMore && !state.hasReachedMax) {
        context.read<GameBloc>().add(const LoadMoreGamesEvent());
      }
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  void _navigateToDetail(GameEntity game) {
    Navigator.of(context).push(
      PageRouteBuilder<void>(
        transitionDuration: const Duration(milliseconds: 400),
        pageBuilder: (context, animation, secondaryAnimation) => GameDetailPage(
          initialGame: game,
          getGameDetailUseCase: context.read<GetGameDetailUseCase>(),
        ),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(
            opacity: animation,
            child: child,
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF030712),
      body: WaterFlowBackground(
        key: _waterBgKey,
        child: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 1. Header with branding & refresh
              GameListHeader(
                onRefresh: () {
                  context.read<GameBloc>().add(
                        FetchGamesEvent(
                          forceRefresh: true,
                          searchQuery: _searchController.text.trim(),
                        ),
                      );
                },
              ),

              // 2. Search Bar connected to BLoC
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                child: GlassSearchBar(
                  controller: _searchController,
                  hintText: 'Search PlayStation 5 games...',
                  onChanged: (query) {
                    context.read<GameBloc>().add(SearchGamesEvent(query));
                  },
                  onClear: () {
                    context.read<GameBloc>().add(const SearchGamesEvent(''));
                  },
                ),
              ),

              const SizedBox(height: 6),

              // 3. Main Content with BLoC state management
              Expanded(
                child: BlocBuilder<GameBloc, GameState>(
                  builder: (context, state) {
                    if (state is GameLoadingState) {
                      return ListView.builder(
                        physics: const NeverScrollableScrollPhysics(),
                        padding: const EdgeInsets.only(top: 4, bottom: 20),
                        itemCount: 6,
                        itemBuilder: (context, index) => const GameCardSkeletonWidget(),
                      );
                    }

                    if (state is GameErrorState) {
                      return GameListErrorView(
                        message: state.message,
                        onRetry: () {
                          context.read<GameBloc>().add(
                                FetchGamesEvent(
                                  forceRefresh: true,
                                  searchQuery: state.activeQuery,
                                ),
                              );
                        },
                      );
                    }

                    if (state is GameLoadedState) {
                      if (state.games.isEmpty) {
                        return GameListEmptyView(activeQuery: state.activeQuery);
                      }

                      return GameListView(
                        games: state.games,
                        hasReachedMax: state.hasReachedMax,
                        scrollController: _scrollController,
                        onRefresh: () async {
                          context.read<GameBloc>().add(
                                FetchGamesEvent(
                                  forceRefresh: true,
                                  searchQuery: state.activeQuery,
                                ),
                              );
                        },
                        onGameTap: _navigateToDetail,
                      );
                    }

                    return const SizedBox.shrink();
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
