# Test Fazz Flutter Games library

 

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
│       ├── data/                         # Layer Data & Integrasi API
│       │   ├── models/
│       │   ├── datasources/
│       │   └── repositories/
│       └── presentation/                 # Layer UI & State
│           ├── controllers/
│           ├── pages/
│           └── widgets/
│
├── injection_container.dart              # Dependency Injection
├── app.dart                              # Konfigurasi MaterialApp
└── main.dart                             # Entry point aplikasi
```

---

## Bagaimana Aplikasi Ini Berjalan (Application Flow)

Aplikasi ini menggunakan aliran data satu arah (**Unidirectional Data Flow**) dengan batasan dependensi yang jelas antar-layer (Clean Architecture):

```
┌─────────────────────────────────────────────────────────────┐
│ 1. INITIALIZATION & INJECTION                              │
│    main.dart -> injection_container.dart -> app.dart        │
└──────────────────────────────┬──────────────────────────────┘
                               │
                               ▼
┌─────────────────────────────────────────────────────────────┐
│ 2. PRESENTATION LAYER (UI)                                  │
│    GameListPage meminta data melalui GameController         │
│    Controller mengubah status ke: GameStateStatus.loading   │
└──────────────────────────────┬──────────────────────────────┘
                               │
                               ▼ memanggil
┌─────────────────────────────────────────────────────────────┐
│ 3. DOMAIN LAYER (Business Logic)                            │
│    GetGamesUseCase(NoParams()) dieksekusi                   │
│    Meneruskan permintaan ke GameRepository (Interface)      │
└──────────────────────────────┬──────────────────────────────┘
                               │
                               ▼ diimplementasikan oleh
┌─────────────────────────────────────────────────────────────┐
│ 4. DATA LAYER (Data Fetching & Mapping)                     │
│    GameRepositoryImpl memanggil GameRemoteDataSource        │
│    DataSource mengambil data via ApiClient / REST Endpoint   │
│    JSON mentah diparsing menjadi GameModel                  │
│    Repository menangkap Exception dan mengubahnya menjadi   │
│    Either<Failure, List<GameEntity>>                        │
└──────────────────────────────┬──────────────────────────────┘
                               │
                               ▼ mengembalikan data
┌─────────────────────────────────────────────────────────────┐
│ 5. STATE & UI UPDATE                                        │
│    GameController menerima Either:                          │
│    - Right(data) -> status = loaded, notifyListeners()      │
│    - Left(failure) -> status = error, notifyListeners()     │
│    GameListPage me-render GameCardWidget sesuai status      │
└─────────────────────────────────────────────────────────────┘
```

### Rincian Alur per Komponen:

1. **Bootstrapping & Dependency Injection** (`lib/main.dart` & `lib/injection_container.dart`):
   - Aplikasi dimulai dari `main()`.
   - `injection_container.dart` mendaftarkan dependensi dari layer paling bawah ke atas: `ApiClient` ➔ `GameRemoteDataSource` ➔ `GameRepository` ➔ `GetGamesUseCase` ➔ `GameController`.
   - `app.dart` membungkus aplikasi dengan `MultiProvider` agar Controller dan service dapat diakses di seluruh widget tree.

2. **Trigger Data di Halaman UI** (`lib/features/games/presentation/pages/game_list_page.dart`):
   - Saat `GameListPage` pertama kali dibuka (`initState`), memanggil `context.read<GameController>().fetchGames()`.

3. **Manajemen State** (`lib/features/games/presentation/controllers/game_controller.dart`):
   - `fetchGames()` mengeset `_status = GameStateStatus.loading` lalu memanggil `notifyListeners()`.
   - Halaman UI merespons perubahan ini dengan menampilkan widget loading indicator.

4. **Eksekusi Business Rule** (`lib/features/games/domain/usecases/get_games_usecase.dart`):
   - Controller mengeksekusi `GetGamesUseCase`.
   - UseCase hanya mengetahui kontrak interface `GameRepository` di Domain layer, sehingga logika bisnis tidak terikat pada framework atau library network apapun.

5. **Pengambilan Data & Pemetaan Error** (`lib/features/games/data/`):
   - `GameRepositoryImpl` memanggil `GameRemoteDataSource.fetchGames()`.
   - Raw JSON diubah menjadi `GameModel` (turunan dari `GameEntity`).
   - Jika koneksi terputus atau server error, DataSource melempar exception (`NetworkException` / `ServerException`).
   - `GameRepositoryImpl` menangkap exception tersebut dan mengemasnya dalam `Left(Failure)`, atau `Right(games)` jika sukses.

6. **Render Ulang Tampilan (UI Re-render)**:
   - Controller memeriksa hasil menggunakan method `.fold(...)`:
     - **Jika Gagal**: `status = error`, `errorMessage` diisi pesan kegagalan, dan UI menampilkan pesan error beserta tombol coba lagi.
     - **Jika Berhasil**: `status = loaded`, list data disimpan, dan UI merender daftar game melalui `ListView` dan `GameCardWidget`.

---

## Prasyarat Lingkungan (Prerequisites)

Sebelum menjalankan atau melakukan debugging pada platform Android, pastikan lingkungan pengembangan memenuhi syarat berikut:

1. **Flutter SDK**: Versi `3.10+` (Direkomendasikan `3.24+` / `3.27+` / `3.47+`).
2. **Java Development Kit (JDK)**: **Java 17 (LTS)**.
   > *Catatan*: Hindari penggunaan Java 25+ bawaan Android Studio terbaru karena sering terjadi ketidakcocokan versi Gradle/Crash `sdkmanager`. Gunakan OpenJDK 17:
   ```bash
   flutter config --jdk-dir="C:\Program Files\Microsoft\jdk-17.0.20.101-hotspot"
   ```
3. **Android Studio & SDK**:
   - **Android SDK Platform** (API 34, 35, atau 36).
   - **Android SDK Command-line Tools (latest)**: Wajib dicentang via *Android Studio > Settings > Languages & Frameworks > Android SDK > SDK Tools*.
   - **Android NDK**: Versi `27.0.12077973` (atau sesuai konfigurasi di `android/app/build.gradle.kts`).
4. **Android Licenses**:
   ```bash
   flutter doctor --android-licenses
   ```

---

## Konfigurasi Perangkat (Device Setup)

### A. Menggunakan Perangkat Fisik (Real Device / HP Android)
1. Aktifkan **Developer Options (Opsi Pengembang)**:
   - Masuk ke *Settings > About Phone*, lalu ketuk **Build Number** sebanyak 7 kali.
2. Aktifkan **USB Debugging**:
   - Masuk ke *Settings > Additional Settings / System > Developer Options > USB Debugging*.
3. **Khusus HP Xiaomi / POCO / Redmi (Penting)**:
   - Aktifkan **`Install via USB`** di menu *Developer Options* (memerlukan akun Mi & kartu SIM).
   - *(Opsional)* Aktifkan **`USB debugging (Security settings)`**.
   - Saat proses instalasi pertama kali, konfirmasi pop-up **"Allow / Install"** yang muncul di layar HP.

### B. Menggunakan Emulator Android
- Buat Virtual Device di **Android Studio Device Manager** dengan arsitektur **`x86_64`** (rekomendasi API 34 atau API 35).
- *Catatan*: Hindari emulator dengan arsitektur `x86` (32-bit legacy) karena berstatus `unsupported` pada rilis Flutter modern.

---

## Cara Menjalankan Proyek

1. Pastikan semua dependensi dan perangkat telah terhubung:
   ```bash
   flutter doctor
   flutter devices
   ```
2. Unduh dependensi Flutter:
   ```bash
   flutter pub get
   ```
3. Jalankan analisis kode (linter):
   ```bash
   flutter analyze
   ```
4. Jalankan aplikasi ke perangkat yang dipilih:
   ```bash
   # Otomatis memilih perangkat yang aktif
   flutter run

   # Atau spesifik ke ID perangkat (misal HP fisik)
   flutter run -d <DEVICE_ID>
   ```

