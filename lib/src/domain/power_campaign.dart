enum PermanentPower { cannibal, extend, enlarge, acceleration }

extension PermanentPowerDetails on PermanentPower {
  String get id => name;

  String get label => switch (this) {
    PermanentPower.cannibal => 'Kanibal',
    PermanentPower.extend => 'Memperpanjang',
    PermanentPower.enlarge => 'Memperbesar',
    PermanentPower.acceleration => 'Percepatan',
  };

  String get description => switch (this) {
    PermanentPower.cannibal =>
      'Bidak boleh menyingkirkan bidak sendiri yang menghalangi jalurnya.',
    PermanentPower.extend => 'Arena bertambah satu kolom untuk kedua pemain.',
    PermanentPower.enlarge => 'Arena bertambah satu baris dan kolom.',
    PermanentPower.acceleration => 'Waktu kedua pemain dipercepat bersama.',
  };

  String get symbol => switch (this) {
    PermanentPower.cannibal => '♟',
    PermanentPower.extend => '↔',
    PermanentPower.enlarge => '⤢',
    PermanentPower.acceleration => 'ϟ',
  };
}

enum TemporaryPower {
  extraPawn,
  kamikaze,
  extraLife,
  evolution,
  santet,
  restart,
  blackDeath,
  extraMove,
}

extension TemporaryPowerDetails on TemporaryPower {
  String get label => switch (this) {
    TemporaryPower.extraPawn => 'Pion Ekstra',
    TemporaryPower.kamikaze => 'Kamikaze',
    TemporaryPower.extraLife => 'Nyawa Ekstra',
    TemporaryPower.evolution => 'Evolusi',
    TemporaryPower.santet => 'Santet',
    TemporaryPower.restart => 'Restart',
    TemporaryPower.blackDeath => 'Black Death',
    TemporaryPower.extraMove => 'Gerakan Ekstra',
  };

  String get description => switch (this) {
    TemporaryPower.extraPawn => 'Tambahkan sepasang pion di petak awal kosong.',
    TemporaryPower.kamikaze => 'Capture berikutnya juga mengorbankan bidakmu.',
    TemporaryPower.extraLife => 'Hidupkan kembali sepasang bidak yang gugur.',
    TemporaryPower.evolution =>
      'Evolusikan sepasang pion menjadi buah pilihan.',
    TemporaryPower.santet => 'Korbankan buahmu untuk menghapus pasangannya.',
    TemporaryPower.restart => 'Kembalikan buah hidup ke posisi awal.',
    TemporaryPower.blackDeath => 'Hapus buah di petak hitam untuk kedua sisi.',
    TemporaryPower.extraMove => 'Satu buah mendapat dua gerakan berurutan.',
  };

  bool get isWaiting =>
      this == TemporaryPower.kamikaze || this == TemporaryPower.extraMove;
}

class CampaignLevelDefinition {
  const CampaignLevelDefinition({
    required this.number,
    required this.title,
    required this.objective,
  });

  final int number;
  final String title;
  final String objective;

  TemporaryPower get reward => TemporaryPower.values[number - 1];

  List<TemporaryPower> get availablePowers =>
      TemporaryPower.values.take(number).toList(growable: false);
}

class PowerCampaign {
  const PowerCampaign({
    required this.id,
    required this.power,
    required this.subtitle,
    required this.levelTitles,
    required this.objectives,
  });

  final String id;
  final PermanentPower power;
  final String subtitle;
  final List<String> levelTitles;
  final List<String> objectives;

  List<CampaignLevelDefinition> get levels => List.generate(
    8,
    (index) => CampaignLevelDefinition(
      number: index + 1,
      title: levelTitles[index],
      objective: objectives[index],
    ),
    growable: false,
  );

  static const all = <PowerCampaign>[
    PowerCampaign(
      id: 'kanibal',
      power: PermanentPower.cannibal,
      subtitle: 'Buka jalur, kuasai ruang, dan manfaatkan pengorbanan.',
      levelTitles: [
        'Pion yang Hilang',
        'Jalur Terbuka',
        'Koridor Kuda',
        'Tekanan Gajah',
        'Rokade Rapuh',
        'Benteng Menyapu',
        'Ratu Tanpa Jalan',
        'Papan Terakhir',
      ],
      objectives: [
        'Pelajari nilai posisi dan bidak yang saling menghalangi.',
        'Bangun serangan dengan membuka jalur buah.',
        'Kembangkan kuda sebelum memulai serangan.',
        'Kuasai diagonal panjang dan lindungi raja.',
        'Amankan raja sebelum pertukaran besar.',
        'Gunakan lajur terbuka untuk menekan lawan.',
        'Buat ancaman ganda dengan buah berat.',
        'Menangkan pertandingan melawan penjaga Kanibal.',
      ],
    ),
    PowerCampaign(
      id: 'memperpanjang',
      power: PermanentPower.extend,
      subtitle: 'Rencanakan pion dan serangan dalam arena yang lebih panjang.',
      levelTitles: [
        'Langkah Pertama',
        'Pion Pengelana',
        'Sayap Terbuka',
        'Diagonal Jauh',
        'Benteng Berbaris',
        'Kejar Sang Raja',
        'Jarak dan Tempo',
        'Ujung Arena',
      ],
      objectives: [
        'Kenali tempo ketika garis serang menjadi lebih panjang.',
        'Dorong pion dengan tetap menjaga perlindungan.',
        'Pilih sayap serangan sebelum membuka posisi.',
        'Manfaatkan diagonal gajah dari jarak jauh.',
        'Hubungkan benteng dan rebut lajur terbuka.',
        'Jangan biarkan raja terjebak di tengah.',
        'Seimbangkan jarak, tempo, dan keamanan raja.',
        'Menangkan pertandingan di arena yang terbentang.',
      ],
    ),
    PowerCampaign(
      id: 'memperbesar',
      power: PermanentPower.enlarge,
      subtitle: 'Kelola ruang dua dimensi dan perluas pilihan manuver.',
      levelTitles: [
        'Ruang Baru',
        'Sayap Tambahan',
        'Formasi Terbuka',
        'Kuda Pengintai',
        'Benteng Menyilang',
        'Diagonal Ganda',
        'Pusat yang Luas',
        'Arsitek Arena',
      ],
      objectives: [
        'Atur buah dengan disiplin saat ruang permainan bertambah.',
        'Pilih sisi papan yang aman untuk mengembangkan pion.',
        'Buka jalur tanpa meninggalkan buah yang tak terlindungi.',
        'Gunakan kuda untuk menyerang petak penting.',
        'Temukan lajur yang memberi benteng ruang bergerak.',
        'Serang dari dua diagonal secara bersamaan.',
        'Kuasai pusat dan siapkan serangan akhir.',
        'Menangkan pertandingan dengan kendali ruang.',
      ],
    ),
    PowerCampaign(
      id: 'percepatan',
      power: PermanentPower.acceleration,
      subtitle: 'Ambil keputusan tepat saat waktu kedua pihak terus menipis.',
      levelTitles: [
        'Waktu Berjalan',
        'Tempo Cepat',
        'Tanpa Ragu',
        'Hitung Sekilas',
        'Ancaman Ganda',
        'Akhir Permainan',
        'Detik Menentukan',
        'Sang Juara',
      ],
      objectives: [
        'Latih kebiasaan memeriksa ancaman sebelum bergerak.',
        'Kembangkan buah dengan tempo dan hindari langkah sia-sia.',
        'Pilih rencana sederhana yang mudah dijalankan.',
        'Hitung capture dan balasan paling kuat.',
        'Cari ancaman ganda tanpa mengorbankan raja.',
        'Sederhanakan posisi ketika unggul material.',
        'Pertahankan ketenangan dalam posisi yang rumit.',
        'Taklukkan lawan terakhir di bawah tekanan waktu.',
      ],
    ),
  ];

  static PowerCampaign byId(String id) =>
      all.firstWhere((campaign) => campaign.id == id);
}

class CampaignProgress {
  const CampaignProgress({
    required this.campaignId,
    this.unlockedLevel = 1,
    this.completedLevel = 0,
  });

  final String campaignId;
  final int unlockedLevel;
  final int completedLevel;

  bool isUnlocked(int level) => level <= unlockedLevel;
}

class CampaignGameConfig {
  const CampaignGameConfig({
    required this.campaignId,
    required this.level,
    required this.temporaryPowers,
  });

  final String campaignId;
  final int level;
  final List<TemporaryPower> temporaryPowers;

  PowerCampaign get campaign => PowerCampaign.byId(campaignId);
  List<TemporaryPower> get unlockedPowers =>
      campaign.levels[level - 1].availablePowers;
}
