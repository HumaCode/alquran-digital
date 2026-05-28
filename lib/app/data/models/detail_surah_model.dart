class DetailSurah {
  int code;
  String message;
  Data data;

  DetailSurah({required this.code, required this.message, required this.data});

  factory DetailSurah.fromJson(Map<String, dynamic> json) {
    return DetailSurah(
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
  List<Ayat> ayat;
  SuratSelanjutnya? suratSelanjutnya; // Bisa bernilai false di JSON, diparse ke null jika bukan Map
  SuratSebelumnya? suratSebelumnya;   // Bisa bernilai false di JSON, diparse ke null jika bukan Map

  Data({
    required this.nomor,
    required this.nama,
    required this.namaLatin,
    required this.jumlahAyat,
    required this.tempatTurun,
    required this.arti,
    required this.deskripsi,
    required this.audioFull,
    required this.ayat,
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
      ayat: (json['ayat'] as List<dynamic>)
          .map((e) => Ayat.fromJson(e as Map<String, dynamic>))
          .toList(),
      suratSelanjutnya: json['suratSelanjutnya'] is Map<String, dynamic>
          ? SuratSelanjutnya.fromJson(json['suratSelanjutnya'] as Map<String, dynamic>)
          : null,
      suratSebelumnya: json['suratSebelumnya'] is Map<String, dynamic>
          ? SuratSebelumnya.fromJson(json['suratSebelumnya'] as Map<String, dynamic>)
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
      'ayat': ayat.map((e) => e.toJson()).toList(),
      'suratSelanjutnya': suratSelanjutnya?.toJson(),
      'suratSebelumnya': suratSebelumnya?.toJson(),
    };
  }
}

class Ayat {
  int nomorAyat;
  String teksArab;
  String teksLatin;
  String teksIndonesia;
  Map<String, String> audio;

  Ayat({
    required this.nomorAyat,
    required this.teksArab,
    required this.teksLatin,
    required this.teksIndonesia,
    required this.audio,
  });

  factory Ayat.fromJson(Map<String, dynamic> json) {
    return Ayat(
      nomorAyat: json['nomorAyat'] as int,
      teksArab: json['teksArab'] as String,
      teksLatin: json['teksLatin'] as String,
      teksIndonesia: json['teksIndonesia'] as String,
      audio: Map<String, String>.from(json['audio'] as Map),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'nomorAyat': nomorAyat,
      'teksArab': teksArab,
      'teksLatin': teksLatin,
      'teksIndonesia': teksIndonesia,
      'audio': audio,
    };
  }
}

class SuratSelanjutnya {
  int nomor;
  String nama;
  String namaLatin;
  int jumlahAyat;

  SuratSelanjutnya({
    required this.nomor,
    required this.nama,
    required this.namaLatin,
    required this.jumlahAyat,
  });

  factory SuratSelanjutnya.fromJson(Map<String, dynamic> json) {
    return SuratSelanjutnya(
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

class SuratSebelumnya {
  int nomor;
  String nama;
  String namaLatin;
  int jumlahAyat;

  SuratSebelumnya({
    required this.nomor,
    required this.nama,
    required this.namaLatin,
    required this.jumlahAyat,
  });

  factory SuratSebelumnya.fromJson(Map<String, dynamic> json) {
    return SuratSebelumnya(
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
