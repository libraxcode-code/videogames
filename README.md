<p align="center">
  <video src="sample.mp4" width="300" controls>
    Your browser does not support the video tag.
  </video>
</p>

# PlayStation 5 Games Vault - Mobile App

A Flutter application built with Clean Architecture and BLoC State Management to browse the latest released PlayStation 5 games, view comprehensive game details, and provide an interactive modern visual experience.

---

## Direct Download APK

Download the latest production release APK for Android directly from the GitHub Continuous Delivery pipeline:

- [Download Release APK (ARM64 ~19MB - Recommended for modern smartphones)](https://github.com/libraxcode-code/videogames/releases/latest/download/app-arm64-v8a-release.apk)
- [Download Universal Release APK (~52MB - All architectures)](https://github.com/libraxcode-code/videogames/releases/latest/download/app-release.apk)
- [View All Releases and Changelogs](https://github.com/libraxcode-code/videogames/releases)

---

## Technical Assessment Requirements and Status Matrix

| Number | Requirement | Implementation Status | Evidence / Location |
|---|---|---|---|
| 1 | Built using Flutter | Complete | Flutter 3.x, Android SDK 34+ |
| 2 | Game List of latest PS5 releases | Complete | lib/features/games/presentation/widgets/list/ |
| 2.1 | - Name | Complete | GameCardWidget title |
| 2.2 | - Release Date | Complete | GameCardWidget release date |
| 2.3 | - Background Image | Complete | Exact 100x100 aspect ratio fill cover |
| 2.4 | - Metacritic Score | Complete | Dynamic color-coded score badge |
| 3 | Pagination: Auto-load page 2+ at bottom | Complete | GameBloc.onLoadMoreGames (20 items/page) |
| 4 | Game Detail Page | Complete | GameDetailPage (lib/features/games/presentation/pages/) |
| 4.1 | - Description | Complete | GameDetailContent (Full RAWG description) |
| 4.2 | - Genres | Complete | Glassmorphism chips |
| 4.3 | - Extra Info | Complete | Developers, Publishers, Rating (/5), Metascore, Release Date |
| 5 | Git Version Control and Commits | Complete | Clean commit history on GitHub origin/main |
| 6 | README Documentation | Complete | Complete setup, architecture, compile, debug, and test guide |
| 7 | RAWG API Integration | Complete | https://api.rawg.io/api/games (PS5 platform 187, 1-year window, -released) |

---

## Architectural Highlights and Design Patterns

1. Clean Architecture (Separation of Concerns):
   - Domain Layer: Independent business models (GameEntity), repository contracts, and use cases (GetGamesUseCase, GetGameDetailUseCase). Zero external dependencies.
   - Data Layer: Models (GameModel), remote datasource with dynamic 1-year time windows, Dio HTTP client, SSL pinning verification.
   - Presentation Layer: BLoC pattern (GameBloc, GameEvent, GameState), modular component breakdown (background/, list/, detail/).
2. State Management:
   - Built on official flutter_bloc with debounce-enabled real-time search and infinite pagination.
3. Interactive Visual Experience (Cyberpunk Glassmorphism and Neon Fluid):
   - Single-unified glass containers avoiding nested border artifacts.
   - Harmonic neon liquid background (WaterFlowBackground) with global touch-droplet physics and scroll displacement.
4. Security:
   - Production-ready DioApiClient with SSL certificate pinning capabilities for api.rawg.io.

---

## Project Structure

```text
lib/
|-- core/                                 # Shared foundation
|   |-- constants/                        # AppColors, typography, dimensions
|   |-- error/                            # Failure & Exception definitions
|   |-- network/                          # Dio client with SSL Pinning
|   |-- theme/                            # Cyberpunk dark & light themes
|   |-- usecase/                          # Generic UseCase contract
|   |-- widgets/                          # GlassContainer, GlassSearchBar, Skeletons
|
|-- features/games/                       # Games Feature (Clean Architecture)
|   |-- domain/                           # Pure business logic layer
|   |   |-- entities/                     # GameEntity
|   |   |-- repositories/                 # GameRepository interface
|   |   |-- usecases/                     # GetGamesUseCase, GetGameDetailUseCase
|   |-- data/                             # Data layer & API integration
|   |   |-- datasources/                  # GameRemoteDataSource, GameLocalDataSource
|   |   |-- models/                       # GameModel (JSON serializer)
|   |   |-- repositories/                 # GameRepositoryImpl
|   |-- presentation/                     # UI & State layer
|       |-- bloc/                         # GameBloc, GameEvent, GameState
|       |-- pages/                        # GameListPage, GameDetailPage
|       |-- widgets/                      # Modular UI components
|           |-- background/               # WaterFlowBackground
|           |-- list/                     # GameCardWidget, GameListHeader, GameListView, Empty/Error Views
|           |-- detail/                   # GameDetailAppBar, GameStatsRow, GameDetailContent, Trailer components
|
|-- injection_container.dart              # Dependency Injection setup
|-- app.dart                              # MaterialApp & Global Providers
|-- main.dart                             # Application entrypoint
```

---

## Prerequisites

- Flutter SDK: >= 3.10.0
- Dart SDK: >= 3.0.0 < 4.0.0
- Java Development Kit (JDK): Java 17 LTS
- Android Studio / SDK Platform: API 34+
- RAWG API Key: Get a free API key at https://rawg.io/apidocs

---

## How to Run and Debug

### 1. Clone and Fetch Dependencies
```bash
git clone https://github.com/libraxcode-code/videogames.git
cd videogames
flutter pub get
```

### 2. Verify Code Quality and Run Tests
```bash
# Run static code analysis
flutter analyze

# Run unit tests and widget tests
flutter test
```

### 3. Run on Connected Device or Emulator
```bash
# List available devices
flutter devices

# Run on default connected device
flutter run

# Run with specific device ID
flutter run -d <DEVICE_ID>
```

### 4. Interactive Debugging
- Press r in the terminal for Hot Reload.
- Press R in the terminal for Hot Restart.
- Press p to toggle the visual debug painting.
