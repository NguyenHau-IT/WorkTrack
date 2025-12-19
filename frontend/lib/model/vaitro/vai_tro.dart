class VaiTro {
  int? maVaiTro;
  String tenVaiTro;
  String? moTa;
  DateTime? ngayTao;

  VaiTro({
    this.maVaiTro,
    required this.tenVaiTro,
    this.moTa,
    this.ngayTao,
  });

  // From JSON
  factory VaiTro.fromJson(Map<String, dynamic> json) {
    return VaiTro(
      maVaiTro: json['maVaiTro'],
      tenVaiTro: json['tenVaiTro'],
      moTa: json['moTa'],
      ngayTao: json['ngayTao'] != null 
          ? DateTime.parse(json['ngayTao']) 
          : null,
    );
  }

  // To JSON
  Map<String, dynamic> toJson() {
    return {
      'tenVaiTro': tenVaiTro,
      'moTa': moTa,
    };
  }
}
