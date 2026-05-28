class DetailSurahResponse {
  final int code;
  final String message;
  final DetailSurah data;

  DetailSurahResponse({
    required this.code,
    required this.message,
    required this.data,
  });

  factory DetailSurahResponse.fromJson(Map<String, dynamic> json) {
    return DetailSurahResponse(
      code: json['code'] as int,
      message: json['message'] as String,
      data: DetailSurah.fromJson(json['data'] as Map<String, dynamic>),
    );
  }
}

class DetailSurah {
  final int nomor;
  final String nama;
  final String namaLatin;
  final int jumlahAyat;
  final String tempatTurun;
  final String arti;
  final String deskripsi;
  final Map<String, String> audioFull;
  final List<Ayat> ayat;
  final NavigationSurah? suratSelanjutnya;
  final NavigationSurah? suratSebelumnya;

  DetailSurah({
    required this.nomor,
    required this.nama,
    required this.namaLatin,
    required this.jumlahAyat,
    required this.tempatTurun,
    required this.arti,
    required this.deskripsi,
    required this.audioFull,
    required this.ayat,
    this.suratSelanjutnya,
    this.suratSebelumnya,
  });

  factory DetailSurah.fromJson(Map<String, dynamic> json) {
    return DetailSurah(
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
          ? NavigationSurah.fromJson(json['suratSelanjutnya'] as Map<String, dynamic>)
          : null,
      suratSebelumnya: json['suratSebelumnya'] is Map<String, dynamic>
          ? NavigationSurah.fromJson(json['suratSebelumnya'] as Map<String, dynamic>)
          : null,
    );
  }
}

class Ayat {
  final int nomorAyat;
  final String teksArab;
  final String teksLatin;
  final String teksIndonesia;
  final Map<String, String> audio;

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
}

class NavigationSurah {
  final int nomor;
  final String nama;
  final String namaLatin;
  final int jumlahAyat;

  NavigationSurah({
    required this.nomor,
    required this.nama,
    required this.namaLatin,
    required this.jumlahAyat,
  });

  factory NavigationSurah.fromJson(Map<String, dynamic> json) {
    return NavigationSurah(
      nomor: json['nomor'] as int,
      nama: json['nama'] as String,
      namaLatin: json['namaLatin'] as String,
      jumlahAyat: json['jumlahAyat'] as int,
    );
  }
}
