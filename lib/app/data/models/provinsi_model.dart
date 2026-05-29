class Provinsi {
  int code;
  String message;
  List<String> data;

  Provinsi({required this.code, required this.message, required this.data});

  factory Provinsi.fromJson(Map<String, dynamic> json) {
    return Provinsi(
      code: json['code'] as int,
      message: json['message'] as String,
      data: List<String>.from(json['data'] as List),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'code': code,
      'message': message,
      'data': data,
    };
  }
}
