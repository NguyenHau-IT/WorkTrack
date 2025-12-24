class BaoCao {
  final int? maBaoCao;
  final int maNV;
  final String? tenNhanVien;
  final DateTime tuNgay;
  final DateTime denNgay;
  final double tongGio;
  final int soNgayDiTre;
  final int soNgayVeSom;
  final double gioLamThem;
  final double luong;
  final DateTime? ngayTao;
  final bool daXoa;

  BaoCao({
    this.maBaoCao,
    required this.maNV,
    this.tenNhanVien,
    required this.tuNgay,
    required this.denNgay,
    this.tongGio = 0.0,
    this.soNgayDiTre = 0,
    this.soNgayVeSom = 0,
    this.gioLamThem = 0.0,
    this.luong = 0.0,
    this.ngayTao,
    this.daXoa = false,
  });

  factory BaoCao.fromJson(Map<String, dynamic> json) {
    return BaoCao(
      maBaoCao: json['maBaoCao'],
      maNV: json['maNV'],
      tenNhanVien: json['nhanVien'] != null ? json['nhanVien']['tenNV'] : null,
      tuNgay: DateTime.parse(json['tuNgay']),
      denNgay: DateTime.parse(json['denNgay']),
      tongGio: json['tongGio'] != null ? (json['tongGio'] as num).toDouble() : 0.0,
      soNgayDiTre: json['soNgayDiTre'] ?? 0,
      soNgayVeSom: json['soNgayVeSom'] ?? 0,
      gioLamThem: json['gioLamThem'] != null ? (json['gioLamThem'] as num).toDouble() : 0.0,
      luong: json['luong'] != null ? (json['luong'] as num).toDouble() : 0.0,
      ngayTao: json['ngayTao'] != null ? DateTime.parse(json['ngayTao']) : null,
      daXoa: json['daXoa'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'maBaoCao': maBaoCao,
      'maNV': maNV,
      'tuNgay': tuNgay.toIso8601String().split('T')[0],
      'denNgay': denNgay.toIso8601String().split('T')[0],
      'tongGio': tongGio,
      'soNgayDiTre': soNgayDiTre,
      'soNgayVeSom': soNgayVeSom,
      'gioLamThem': gioLamThem,
      'luong': luong,
      'ngayTao': ngayTao?.toIso8601String(),
      'daXoa': daXoa,
    };
  }

  BaoCao copyWith({
    int? maBaoCao,
    int? maNV,
    String? tenNhanVien,
    DateTime? tuNgay,
    DateTime? denNgay,
    double? tongGio,
    int? soNgayDiTre,
    int? soNgayVeSom,
    double? gioLamThem,
    double? luong,
    DateTime? ngayTao,
    bool? daXoa,
  }) {
    return BaoCao(
      maBaoCao: maBaoCao ?? this.maBaoCao,
      maNV: maNV ?? this.maNV,
      tenNhanVien: tenNhanVien ?? this.tenNhanVien,
      tuNgay: tuNgay ?? this.tuNgay,
      denNgay: denNgay ?? this.denNgay,
      tongGio: tongGio ?? this.tongGio,
      soNgayDiTre: soNgayDiTre ?? this.soNgayDiTre,
      soNgayVeSom: soNgayVeSom ?? this.soNgayVeSom,
      gioLamThem: gioLamThem ?? this.gioLamThem,
      luong: luong ?? this.luong,
      ngayTao: ngayTao ?? this.ngayTao,
      daXoa: daXoa ?? this.daXoa,
    );
  }

  @override
  String toString() {
    return 'BaoCao(maBaoCao: $maBaoCao, maNV: $maNV, tenNhanVien: $tenNhanVien, tuNgay: $tuNgay, denNgay: $denNgay, tongGio: $tongGio, soNgayDiTre: $soNgayDiTre, soNgayVeSom: $soNgayVeSom, gioLamThem: $gioLamThem, luong: $luong, ngayTao: $ngayTao, daXoa: $daXoa)';
  }
}
