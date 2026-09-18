# Test Fazz Flutter Games library

Proyek Flutter yang dibangun dengan arsitektur **Clean Architecture (Lite)**, state management **BLoC**, in-memory caching untuk menghemat bandwidth, serta dioptimalkan untuk performa scrolling **120 FPS**.

---

## Struktur Direktori

```text
lib/
├── core/                                 # Fondasi bersama (Error, Network, Theme, Constants, UseCase base)
│   ├── constants/
│   ├── error/
│   ├── network/
│   ├── theme/
│   ├── usecase/
│   └── utils/
│
├── features/                             # Modul fitur (Feature-First)
│   └── games/
│       ├── domain/                       # Layer Bisnis murni
│       │   ├── entities/
│       │   ├── repositories/
│       │   └── usecases/
│       ├── data/                         # Layer Data, Caching & Integrasi API
│       │   ├── models/
│       │   ├── datasources/              # Remote & Local Cache Data Source
│       │   └── repositories/
│       └── presentation/                 # Layer UI & BLoC
│           ├── bloc/                     # GameBloc, GameEvent, GameState
│           ├── pages/
│           └── widgets/
│
├── injection_container.dart              # MultiRepositoryProvider & BlocProvider
├── app.dart                              # Konfigurasi MaterialApp
└── main.dart                             # Entry point aplikasi
```

---

## Bagaimana Aplikasi Ini Berjalan (Application Flow)

Aplikasi ini menggunakan aliran data terarah dengan **BLoC Pattern** dan **Caching Strategy**:

```
┌─────────────────────────────────────────────────────────────┐
│ 1. INITIALIZATION & INJECTION                              │
│    main.dart -> InjectionContainer -> app.dart              │
└──────────────────────────────┬──────────────────────────────┘
                               │
                               ▼
┌─────────────────────────────────────────────────────────────┐
│ 2. PRESENTATION LAYER (UI)                                  │
│    GameListPage mengirim FetchGamesEvent ke GameBloc        │
│    GameBloc memancarkan: GameLoadingState                   │
└──────────────────────────────┬──────────────────────────────┘
                               │
                               ▼ memanggil
┌─────────────────────────────────────────────────────────────┐
│ 3. DOMAIN LAYER (Business Logic)                            │
│    GetGamesUseCase(GetGamesParams(forceRefresh: ...))       │
│    Meneruskan permintaan ke GameRepository (Interface)      │
└──────────────────────────────┬──────────────────────────────┘
                               │
                               ▼ diimplementasikan oleh
┌─────────────────────────────────────────────────────────────┐
│ 4. DATA LAYER (Bandwidth-Saving Caching)                    │
│    GameRepositoryImpl memeriksa:                            │
│    - Jika forceRefresh == false & cache ada:                │
│        Langsung kembalikan Right(cachedGames) (Hemat kuota) │
│    - Jika cache kosong / forceRefresh == true:              │
│        Fetch via GameRemoteDataSource -> Simpan ke Cache    │
│    - Jika network offline tapi cache ada:                   │
│        Fallback mengembalikan data cache lokal              │
└──────────────────────────────┬──────────────────────────────┘
                               │
                               ▼ mengembalikan data
┌─────────────────────────────────────────────────────────────┐
│ 5. STATE & UI UPDATE (120 FPS Optimized)                    │
│    GameBloc menerima hasil Either:                          │
│    - Right(games) -> emit(GameLoadedState(games: games))    │
│    - Left(failure) -> emit(GameErrorState(failure.message)) │
│    BlocBuilder me-render ListView dengan RepaintBoundary &  │
│    itemExtent tetap untuk menjamin scrolling mulus 120 FPS. │
└─────────────────────────────────────────────────────────────┘
```

### Rincian Alur per Komponen:

1. **Bootstrapping & Dependency Injection** (`lib/main.dart` & `lib/injection_container.dart`):
   - Aplikasi dimulai dari `main()`.
   - `InjectionContainer` menggunakan `MultiRepositoryProvider` untuk mendaftarkan `ApiClient`, `GameLocalDataSource`, `GameRemoteDataSource`, `GameRepository`, `GetGamesUseCase`, dan membungkus tree dengan `BlocProvider<GameBloc>`.

2. **Trigger Event di UI** (`lib/features/games/presentation/pages/game_list_page.dart`):
   - Saat `GameListPage` diinisialisasi (`initState`), dikirimkan `FetchGamesEvent(forceRefresh: false)`.
   - Pengguna dapat menarik layar (Pull-to-refresh) atau menekan tombol refresh di AppBar untuk mengirim `FetchGamesEvent(forceRefresh: true)`.

3. **Manajemen State (BLoC)** (`lib/features/games/presentation/bloc/`):
   - `GameBloc` menerima `FetchGamesEvent`. Jika belum memiliki data, memancarkan `GameLoadingState`.
   - Memanggil `GetGamesUseCase` dengan parameter `forceRefresh`.

4. **Eksekusi Business Rule** (`lib/features/games/domain/usecases/get_games_usecase.dart`):
   - Meneruskan request ke kontrak `GameRepository`.

5. **Strategi Caching Hemat Bandwidth** (`lib/features/games/data/`):
   - `GameRepositoryImpl` memeriksa `GameLocalDataSource`. Jika data sudah ada di memori dan tidak meminta force refresh, data cache langsung dikembalikan tanpa request HTTP ke server.
   - Jika belum ada data atau diminta refresh, data baru diambil dari `GameRemoteDataSource` dan otomatis disimpan kembali ke `GameLocalDataSource`.
   - Jika jaringan mati saat request, repositori otomatis menggunakan cache yang ada sebagai fallback offline.

6. **Optimasi Performa 120 FPS**:
   - `ListView.builder` menggunakan properti `itemExtent: 116` sehingga Flutter tidak perlu menghitung ulang dimensi item saat scrolling cepat.
   - `BouncingScrollPhysics` memberikan sentuhan responsif pada display high-refresh-rate (90Hz / 120Hz).
   - Setiap item card dibungkus `RepaintBoundary` untuk mengisolasi area render dan mencegah repaint pada keseluruhan layar.
   - `Image.network` memanfaatkan decoding ukuran presisi (`cacheWidth` & `cacheHeight`) untuk menghemat konsumsi GPU dan RAM.

---

## Cara Menjalankan Proyek

1. Pastikan Flutter SDK telah terinstal di sistem Anda dan terdaftar di variabel sistem `PATH`.
2. Unduh dependensi:
   ```bash
   flutter pub get
   ```
3. Jalankan analisis linter:
   ```bash
   flutter analyze
   ```
4. Jalankan aplikasi:
   ```bash
   flutter run
   ```
