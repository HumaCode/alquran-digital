class TafsirSurah {
  int code;
  String message;
  Data data;

  TafsirSurah({required this.code, required this.message, required this.data});

  factory TafsirSurah.fromJson(Map<String, dynamic> json) {
    return TafsirSurah(
      code: json['code'] as int,
      message: json['message'] as String,
      data: Data.fromJson(json['data'] as Map<String, dynamic>),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'code': code,
      'message': message,
      'data': data.toJson(),
    };
  }
}

class Data {
  int nomor;
  String nama;
  String namaLatin;
  int jumlahAyat;
  String tempatTurun;
  String arti;
  String deskripsi;
  Map<String, String> audioFull;
  List<Tafsir> tafsir;
  SuratSenya? suratSelanjutnya;
  SuratSenya? suratSebelumnya;

  Data({
    required this.nomor,
    required this.nama,
    required this.namaLatin,
    required this.jumlahAyat,
    required this.tempatTurun,
    required this.arti,
    required this.deskripsi,
    required this.audioFull,
    required this.tafsir,
    required this.suratSelanjutnya,
    required this.suratSebelumnya,
  });

  factory Data.fromJson(Map<String, dynamic> json) {
    return Data(
      nomor: json['nomor'] as int,
      nama: json['nama'] as String,
      namaLatin: json['namaLatin'] as String,
      jumlahAyat: json['jumlahAyat'] as int,
      tempatTurun: json['tempatTurun'] as String,
      arti: json['arti'] as String,
      deskripsi: json['deskripsi'] as String,
      audioFull: Map<String, String>.from(json['audioFull'] as Map),
      tafsir: (json['tafsir'] as List<dynamic>)
          .map((e) => Tafsir.fromJson(e as Map<String, dynamic>))
          .toList(),
      suratSelanjutnya: json['suratSelanjutnya'] is Map<String, dynamic>
          ? SuratSenya.fromJson(json['suratSelanjutnya'] as Map<String, dynamic>)
          : null,
      suratSebelumnya: json['suratSebelumnya'] is Map<String, dynamic>
          ? SuratSenya.fromJson(json['suratSebelumnya'] as Map<String, dynamic>)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'nomor': nomor,
      'nama': nama,
      'namaLatin': namaLatin,
      'jumlahAyat': jumlahAyat,
      'tempatTurun': tempatTurun,
      'arti': arti,
      'deskripsi': deskripsi,
      'audioFull': audioFull,
      'tafsir': tafsir.map((e) => e.toJson()).toList(),
      'suratSelanjutnya': suratSelanjutnya?.toJson(),
      'suratSebelumnya': suratSebelumnya?.toJson(),
    };
  }
}

class SuratSenya {
  int nomor;
  String nama;
  String namaLatin;
  int jumlahAyat;

  SuratSenya({
    required this.nomor,
    required this.nama,
    required this.namaLatin,
    required this.jumlahAyat,
  });

  factory SuratSenya.fromJson(Map<String, dynamic> json) {
    return SuratSenya(
      nomor: json['nomor'] as int,
      nama: json['nama'] as String,
      namaLatin: json['namaLatin'] as String,
      jumlahAyat: json['jumlahAyat'] as int,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'nomor': nomor,
      'nama': nama,
      'namaLatin': namaLatin,
      'jumlahAyat': jumlahAyat,
    };
  }
}

class Tafsir {
  int ayat;
  String teks;

  Tafsir({required this.ayat, required this.teks});

  factory Tafsir.fromJson(Map<String, dynamic> json) {
    return Tafsir(
      ayat: json['ayat'] as int,
      teks: json['teks'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'ayat': ayat,
      'teks': teks,
    };
  }
}
