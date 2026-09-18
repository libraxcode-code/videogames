import 'package:flutter/material.dart';
import '../../domain/entities/game_entity.dart';
import '../../domain/usecases/get_game_detail_usecase.dart';
import '../widgets/game_detail_app_bar.dart';
import '../widgets/game_detail_content.dart';
import '../widgets/game_stats_row.dart';
import '../widgets/water_flow_background.dart';

class GameDetailPage extends StatefulWidget {
  final GameEntity initialGame;
  final GetGameDetailUseCase getGameDetailUseCase;

  const GameDetailPage({
    super.key,
    required this.initialGame,
    required this.getGameDetailUseCase,
  });

  @override
  State<GameDetailPage> createState() => _GameDetailPageState();
}

class _GameDetailPageState extends State<GameDetailPage> {
  late GameEntity _game;
  bool _isLoading = true;
  String? _errorMessage;
  final ScrollController _scrollController = ScrollController();
  final GlobalKey<WaterFlowBackgroundState> _waterBgKey = GlobalKey<WaterFlowBackgroundState>();

  @override
  void initState() {
    super.initState();
    _game = widget.initialGame;
    _fetchDetail();
    _scrollController.addListener(_onScroll);
  }

  void _onScroll() {
    if (!_scrollController.hasClients) return;
    _waterBgKey.currentState?.onScrollOffsetUpdate(_scrollController.offset);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _fetchDetail() async {
    final result = await widget.getGameDetailUseCase(_game.id);
    if (!mounted) return;
    result.fold(
      (failure) => setState(() {
        _isLoading = false;
        _errorMessage = failure.message;
      }),
      (detailedGame) => setState(() {
        _isLoading = false;
        _game = detailedGame;
      }),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF030712),
      body: Stack(
        children: [
          // 1. Calming Water Flow Background with Touch & Scroll Ripples
          Positioned.fill(
            child: WaterFlowBackground(
              key: _waterBgKey,
            ),
          ),

          // 2. Main Scrollable Content
          CustomScrollView(
            controller: _scrollController,
            physics: const BouncingScrollPhysics(),
            slivers: [
              // Hero Banner & App Bar
              GameDetailAppBar(game: _game),

              // Body Details
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 40),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Quick Stats (Metacritic, Rating, Release Date)
                      GameStatsRow(game: _game),
                      const SizedBox(height: 18),

                      // Game Content (Genres, Description, Publishers/Credits)
                      GameDetailContent(game: _game),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
