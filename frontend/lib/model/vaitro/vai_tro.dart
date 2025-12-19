  class VaiTro {
  int? maVaiTro;
  String tenVaiTro;
  String? moTa;
  DateTime? ngayTao;
  bool? daXoa;

  VaiTro({
    this.maVaiTro,
    required this.tenVaiTro,
    this.moTa,
    this.ngayTao,
    this.daXoa,
  });

  // From JSON
  factory VaiTro.fromJson(Map<String, dynamic> json) {
    DateTime? ngayTao;
    try {
      if (json['ngayTao'] != null && json['ngayTao'].toString().isNotEmpty) {
        ngayTao = DateTime.tryParse(json['ngayTao'].toString());
      }
    } catch (e) {
      ngayTao = null;
    }
    return VaiTro(
      maVaiTro: json['maVaiTro'],
      tenVaiTro: json['tenVaiTro'],
      moTa: json['moTa'],
      ngayTao: ngayTao,
      daXoa: json['daXoa'],
    );
  }

  // To JSON
  Map<String, dynamic> toJson() {
    return {
      'tenVaiTro': tenVaiTro,
      'moTa': moTa,
      'daXoa': daXoa,
    };
  }
}
