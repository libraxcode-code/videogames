import 'package:flutter/material.dart';
import '../../domain/entities/game_entity.dart';
import '../../domain/usecases/get_game_detail_usecase.dart';
import '../widgets/game_detail_app_bar.dart';
import '../widgets/game_detail_content.dart';
import '../widgets/game_stats_row.dart';
import '../widgets/living_cyber_background.dart';

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

class _GameDetailPageState extends State<GameDetailPage>
    with SingleTickerProviderStateMixin {
  late GameEntity _game;
  bool _isLoading = true;
  String? _errorMessage;
  late AnimationController _motionController;
  late Animation<double> _pulseAnimation;
  late Animation<double> _driftAnimation;

  @override
  void initState() {
    super.initState();
    _game = widget.initialGame;
    _fetchDetail();

    // 120 FPS high-refresh atmospheric motion controller
    _motionController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    )..repeat(reverse: true);

    _pulseAnimation = Tween<double>(begin: 0.75, end: 1.25).animate(
      CurvedAnimation(parent: _motionController, curve: Curves.easeInOutQuad),
    );

    _driftAnimation = Tween<double>(begin: -30.0, end: 30.0).animate(
      CurvedAnimation(parent: _motionController, curve: Curves.easeInOutQuad),
    );
  }

  @override
  void dispose() {
    _motionController.dispose();
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
      backgroundColor: const Color(0xFF060910),
      body: Stack(
        children: [
          // 1. Moving Cyberpunk Living Background & Grid
          LivingCyberBackground(
            motionController: _motionController,
            pulseAnimation: _pulseAnimation,
            driftAnimation: _driftAnimation,
          ),

          // 2. Main Scrollable Content
          CustomScrollView(
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
