class CauHinhLuong {
  final int? maCauHinh;
  final double luongGio;
  final double luongLamThem;
  final DateTime? ngayTao;
  final bool daXoa;

  CauHinhLuong({
    this.maCauHinh,
    required this.luongGio,
    this.luongLamThem = 0.0,
    this.ngayTao,
    this.daXoa = false,
  });

  factory CauHinhLuong.fromJson(Map<String, dynamic> json) {
    return CauHinhLuong(
      maCauHinh: json['maCauHinh'],
      luongGio: (json['luongGio'] as num).toDouble(),
      luongLamThem: json['luongLamThem'] != null 
          ? (json['luongLamThem'] as num).toDouble() 
          : 0.0,
      ngayTao: json['ngayTao'] != null 
          ? DateTime.parse(json['ngayTao']) 
          : null,
      daXoa: json['daXoa'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'maCauHinh': maCauHinh,
      'luongGio': luongGio,
      'luongLamThem': luongLamThem,
      'ngayTao': ngayTao?.toIso8601String(),
      'daXoa': daXoa,
    };
  }

  // Copy method để tạo bản sao với một số field được cập nhật
  CauHinhLuong copyWith({
    int? maCauHinh,
    double? luongGio,
    double? luongLamThem,
    DateTime? ngayTao,
    bool? daXoa,
  }) {
    return CauHinhLuong(
      maCauHinh: maCauHinh ?? this.maCauHinh,
      luongGio: luongGio ?? this.luongGio,
      luongLamThem: luongLamThem ?? this.luongLamThem,
      ngayTao: ngayTao ?? this.ngayTao,
      daXoa: daXoa ?? this.daXoa,
    );
  }

  // Helper method để tính tổng lương (lương giờ + lương làm thêm)
  double get tongLuong => luongGio + luongLamThem;

  @override
  String toString() {
    return 'CauHinhLuong(maCauHinh: $maCauHinh, luongGio: $luongGio, luongLamThem: $luongLamThem, ngayTao: $ngayTao, daXoa: $daXoa)';
  }
}
