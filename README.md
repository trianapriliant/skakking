# Catur Mate

Aplikasi catur Flutter untuk bermain offline melawan komputer atau teman di satu perangkat. Aturan legal, giliran, skakmat, remis, rokade, en passant, dan promosi ditangani oleh pustaka aturan catur; game dan setiap langkah disimpan di SQLite.

## Power Gift Campaign

Mode campaign menyediakan empat jalur—Kanibal, Memperpanjang, Memperbesar, dan Percepatan—dengan delapan level per jalur. Progres tersimpan lokal di SQLite; menang membuka level selanjutnya. Tiap level membuka daftar Temporary Power secara bertahap. Pemain dapat memilih maksimal dua power yang berbeda dari daftar tersebut, sedangkan Permanent Power ditetapkan oleh campaign.

Saat ini pertandingan campaign masih berjalan pada papan catur klasik 8×8. Pilihan loadout dan progres campaign sudah tersimpan, tetapi efek Power Gift—termasuk perubahan ukuran arena dan aksi khusus—belum dijalankan oleh engine. Engine `chess` yang dipakai menyediakan aturan catur standar; efek ini memerlukan engine aturan khusus agar dapat menjaga legalitas raja, undo, penyimpanan, dan lawan komputer secara konsisten.

## Menjalankan

```sh
./skakking menu
```

`./skakking` tanpa argumen juga membuka menu. Shortcut tersedia untuk menjalankan aplikasi, mengecek perangkat, menganalisis kode, mengelola dependency dan kode Drift, serta membuat build.

```sh
./skakking ios                    # pilih iPhone aktif, atau boot iPhone tersedia
./skakking ios "iPhone 18 Pro"    # pilih simulator berdasarkan nama
./skakking run ios                # alias eksplisit
./skakking android
./skakking devices
./skakking analyze
./skakking generate
./skakking build apk
./skakking build appbundle
./skakking build ios-sim
./skakking help
```

Untuk menjalankan iOS diperlukan macOS, Xcode, dan runtime iOS Simulator. Saat `./skakking ios` dipanggil, launcher memakai iPhone yang sudah aktif; bila belum ada, launcher memilih iPhone tersedia pada runtime iOS terbaru, menyalakannya, lalu menjalankan Flutter ke simulator tersebut. Gunakan `./skakking devices` untuk melihat simulator yang tersedia dan `./skakking ios --list` untuk hanya melihat daftar simulator.

Flutter 3.44.6 mengalami crash saat parsing native assets jika path proyek mengandung tanda kurung. Karena itu, shortcut iOS menyinkronkan source ke `/private/tmp/catur-mate-ios` sebelum build. Jalankan ulang `./skakking ios` setelah mengubah source agar salinan tersebut diperbarui.

Target awal aplikasi adalah Android dan iOS. SQLite tersimpan lokal di perangkat. Beranda dan papan menggunakan Material 3, sementara pilihan mode, warna, dan kesulitan dipisahkan agar tema dan aturan baru mudah ditambahkan.

## Struktur

- `lib/src/ui/` — layar beranda, papan, daftar langkah, dan tema.
- `lib/src/application/` — Riverpod providers dan controller alur permainan.
- `lib/src/application/chess_opponent.dart` — batas engine yang dapat diganti tanpa mengubah layar atau aturan UI.
- `lib/src/domain/` — model permainan dan lawan komputer alpha-beta.
- `lib/src/data/` — repository serta skema/migrasi Drift SQLite.
- `lib/src/routing/` — rute aplikasi dengan `go_router`.

Lawan komputer memakai alpha-beta minimax dengan penilaian material, posisi buah, dan pasangan gajah. Tingkat Sedang mencari tiga ply. Ini adalah lawan offline ringan untuk permainan kasual; bukan pengganti kekuatan analisis Stockfish.

## Pilihan teknologi

- Flutter merekomendasikan pemisahan UI dan data, repository sebagai sumber data, dan UI MVVM untuk aplikasi yang mudah dikembangkan: [Flutter app architecture](https://docs.flutter.dev/app-architecture/recommendations).
- [Riverpod](https://pub.dev/packages/flutter_riverpod) mengelola state dan dependency injection.
- [Drift](https://pub.dev/packages/drift) memberi akses SQLite bertipe, transaksi, stream query, dan skema yang dapat dimigrasikan.
- [chess](https://pub.dev/packages/chess) memvalidasi aturan standar dan menyediakan notasi FEN/SAN/PGN; lisensinya MIT/BSD.
- [go_router](https://pub.dev/packages/go_router) mengelola navigasi deklaratif Flutter.
