class ChamCong {
  int? maChamCong;
  int? maNV;
  NhanVienInfo? nhanVien;
  DateTime? gioVao;
  DateTime? gioRa;
  String? phuongThuc; // 'VanTay', 'KhuonMat', 'NFC', 'ThuCong'
  String? ghiChu;
  DateTime? ngayTao;
  bool daXoa;

  ChamCong({
    this.maChamCong,
    this.maNV,
    this.nhanVien,
    this.gioVao,
    this.gioRa,
    this.phuongThuc = 'ThuCong',
    this.ghiChu,
    this.ngayTao,
    this.daXoa = false,
  });

  /// Tính số giờ làm việc (giữa GioVao và GioRa)
  double? get thoiGianLamViec {
    if (gioVao != null && gioRa != null) {
      final duration = gioRa!.difference(gioVao!);
      return duration.inMinutes / 60.0;
    }
    return null;
  }

  factory ChamCong.fromJson(Map<String, dynamic> json) {
    return ChamCong(
      maChamCong: json['maChamCong'],
      maNV: json['maNV'],
      nhanVien: json['nhanVien'] != null
          ? NhanVienInfo.fromJson(json['nhanVien'])
          : null,
      gioVao: json['gioVao'] != null ? DateTime.parse(json['gioVao']) : null,
      gioRa: json['gioRa'] != null ? DateTime.parse(json['gioRa']) : null,
      phuongThuc: json['phuongThuc'] ?? 'ThuCong',
      ghiChu: json['ghiChu'],
      ngayTao: json['ngayTao'] != null ? DateTime.parse(json['ngayTao']) : null,
      daXoa: json['daXoa'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'maChamCong': maChamCong,
      'maNV': maNV,
      'nhanVien': nhanVien?.toJson(),
      'gioVao': gioVao?.toIso8601String(),
      'gioRa': gioRa?.toIso8601String(),
      'phuongThuc': phuongThuc,
      'ghiChu': ghiChu,
      'ngayTao': ngayTao?.toIso8601String(),
      'daXoa': daXoa,
    };
  }

  ChamCong copyWith({
    int? maChamCong,
    int? maNV,
    NhanVienInfo? nhanVien,
    DateTime? gioVao,
    DateTime? gioRa,
    String? phuongThuc,
    String? ghiChu,
    DateTime? ngayTao,
    bool? daXoa,
  }) {
    return ChamCong(
      maChamCong: maChamCong ?? this.maChamCong,
      maNV: maNV ?? this.maNV,
      nhanVien: nhanVien ?? this.nhanVien,
      gioVao: gioVao ?? this.gioVao,
      gioRa: gioRa ?? this.gioRa,
      phuongThuc: phuongThuc ?? this.phuongThuc,
      ghiChu: ghiChu ?? this.ghiChu,
      ngayTao: ngayTao ?? this.ngayTao,
      daXoa: daXoa ?? this.daXoa,
    );
  }
}

/// Thông tin cơ bản của nhân viên (để tránh tải toàn bộ đối tượng NhanVien)
class NhanVienInfo {
  int? maNV;
  String? hoTen;
  String? email;
  String? sdt;

  NhanVienInfo({
    this.maNV,
    this.hoTen,
    this.email,
    this.sdt,
  });

  factory NhanVienInfo.fromJson(Map<String, dynamic> json) {
    return NhanVienInfo(
      maNV: json['maNV'],
      hoTen: json['hoTen'],
      email: json['email'],
      sdt: json['sdt'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'maNV': maNV,
      'hoTen': hoTen,
      'email': email,
      'sdt': sdt,
    };
  }
}
