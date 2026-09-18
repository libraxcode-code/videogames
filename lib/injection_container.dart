import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'core/network/dio_api_client.dart';
import 'features/games/data/datasources/game_local_datasource.dart';
import 'features/games/data/datasources/game_remote_datasource.dart';
import 'features/games/data/repositories/game_repository_impl.dart';
import 'features/games/domain/repositories/game_repository.dart';
import 'features/games/domain/usecases/get_game_detail_usecase.dart';
import 'features/games/domain/usecases/get_games_usecase.dart';
import 'features/games/presentation/bloc/game_bloc.dart';

class InjectionContainer extends StatelessWidget {
  final Widget child;

  const InjectionContainer({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return MultiRepositoryProvider(
      providers: [
        RepositoryProvider<DioApiClient>(
          create: (_) => DioApiClient(),
        ),
        RepositoryProvider<GameLocalDataSource>(
          create: (_) => GameLocalDataSourceImpl(),
        ),
        RepositoryProvider<GameRemoteDataSource>(
          create: (context) => GameRemoteDataSourceImpl(
            client: context.read<DioApiClient>(),
          ),
        ),
        RepositoryProvider<GameRepository>(
          create: (context) => GameRepositoryImpl(
            remoteDataSource: context.read<GameRemoteDataSource>(),
            localDataSource: context.read<GameLocalDataSource>(),
          ),
        ),
        RepositoryProvider<GetGamesUseCase>(
          create: (context) => GetGamesUseCase(
            context.read<GameRepository>(),
          ),
        ),
        RepositoryProvider<GetGameDetailUseCase>(
          create: (context) => GetGameDetailUseCase(
            context.read<GameRepository>(),
          ),
        ),
      ],
      child: BlocProvider<GameBloc>(
        create: (context) => GameBloc(
          getGamesUseCase: context.read<GetGamesUseCase>(),
        ),
        child: child,
      ),
    );
  }
}
