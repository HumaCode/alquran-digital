class Doa {
  String status;
  int total;
  List<DataDoa> data;

  Doa({required this.status, required this.total, required this.data});

  factory Doa.fromJson(Map<String, dynamic> json) {
    return Doa(
      status: json['status'] ?? '',
      total: json['total'] ?? 0,
      data: (json['data'] as List? ?? [])
          .map((e) => DataDoa.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'status': status,
      'total': total,
      'data': data.map((e) => e.toJson()).toList(),
    };
  }
}

class DataDoa {
  int id;
  String grup;
  String nama;
  String ar;
  String tr;
  String idn;
  String tentang;
  List<String> tag;

  DataDoa({
    required this.id,
    required this.grup,
    required this.nama,
    required this.ar,
    required this.tr,
    required this.idn,
    required this.tentang,
    required this.tag,
  });

  factory DataDoa.fromJson(Map<String, dynamic> json) {
    return DataDoa(
      id: json['id'] ?? 0,
      grup: json['grup'] ?? '',
      nama: json['nama'] ?? '',
      ar: json['ar'] ?? '',
      tr: json['tr'] ?? '',
      idn: json['idn'] ?? '',
      tentang: json['tentang'] ?? '',
      tag: (json['tag'] as List? ?? []).map((e) => e.toString()).toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'grup': grup,
      'nama': nama,
      'ar': ar,
      'tr': tr,
      'idn': idn,
      'tentang': tentang,
      'tag': tag,
    };
  }
}
