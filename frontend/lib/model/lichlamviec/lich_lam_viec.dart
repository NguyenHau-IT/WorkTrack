class LichLamViec {
  final int? maLich;
  final int maNV;
  final String ngayLamViec; // yyyy-MM-dd
  final String? gioBatDau; // HH:mm:ss
  final String? gioKetThuc; // HH:mm:ss
  final String? caLamViec; // Sáng, Chiều, Tối
  final String? loaiCa; // Bình thường, Tăng ca, Làm thêm
  final String? ghiChu;
  final String trangThai; // KICH_HOAT, HUY
  final String? ngayTao; // yyyy-MM-dd HH:mm:ss
  final String? ngayCapNhat; // yyyy-MM-dd HH:mm:ss
  final String? nguoiTao;
  final bool daXoa;

  LichLamViec({
    this.maLich,
    required this.maNV,
    required this.ngayLamViec,
    this.gioBatDau,
    this.gioKetThuc,
    this.caLamViec,
    this.loaiCa,
    this.ghiChu,
    this.trangThai = 'KICH_HOAT',
    this.ngayTao,
    this.ngayCapNhat,
    this.nguoiTao,
    this.daXoa = false,
  });

  factory LichLamViec.fromJson(Map<String, dynamic> json) {
    return LichLamViec(
      maLich: json['maLich'],
      maNV: json['maNV'],
      ngayLamViec: json['ngayLamViec'],
      gioBatDau: json['gioBatDau'],
      gioKetThuc: json['gioKetThuc'],
      caLamViec: json['caLamViec'],
      loaiCa: json['loaiCa'],
      ghiChu: json['ghiChu'],
      trangThai: json['trangThai'] ?? 'KICH_HOAT',
      ngayTao: json['ngayTao'],
      ngayCapNhat: json['ngayCapNhat'],
      nguoiTao: json['nguoiTao'],
      daXoa: json['daXoa'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'maLich': maLich,
      'maNV': maNV,
      'ngayLamViec': ngayLamViec,
      'gioBatDau': gioBatDau,
      'gioKetThuc': gioKetThuc,
      'caLamViec': caLamViec,
      'loaiCa': loaiCa,
      'ghiChu': ghiChu,
      'trangThai': trangThai,
      'ngayTao': ngayTao,
      'ngayCapNhat': ngayCapNhat,
      'nguoiTao': nguoiTao,
      'daXoa': daXoa,
    };
  }

  // Helper methods
  DateTime get ngayLamViecAsDateTime => DateTime.parse(ngayLamViec);

  DateTime? get gioBatDauAsTime {
    if (gioBatDau == null) return null;
    final parts = gioBatDau!.split(':');
    return DateTime(2000, 1, 1, int.parse(parts[0]), int.parse(parts[1]), int.parse(parts[2]));
  }

  DateTime? get gioKetThucAsTime {
    if (gioKetThuc == null) return null;
    final parts = gioKetThuc!.split(':');
    return DateTime(2000, 1, 1, int.parse(parts[0]), int.parse(parts[1]), int.parse(parts[2]));
  }

  String get caLamViecDisplay {
    switch (caLamViec) {
      case 'SANG':
        return 'Ca Sáng';
      case 'CHIEU':
        return 'Ca Chiều';
      case 'TOI':
        return 'Ca Tối';
      default:
        return caLamViec ?? '';
    }
  }

  String get loaiCaDisplay {
    switch (loaiCa) {
      case 'BINH_THUONG':
        return 'Bình thường';
      case 'TANG_CA':
        return 'Tăng ca';
      case 'LAM_THEM':
        return 'Làm thêm';
      default:
        return loaiCa ?? '';
    }
  }

  String get trangThaiDisplay {
    switch (trangThai) {
      case 'KICH_HOAT':
        return 'Kích hoạt';
      case 'HUY':
        return 'Hủy';
      default:
        return trangThai;
    }
  }

  LichLamViec copyWith({
    int? maLich,
    int? maNV,
    String? ngayLamViec,
    String? gioBatDau,
    String? gioKetThuc,
    String? caLamViec,
    String? loaiCa,
    String? ghiChu,
    String? trangThai,
    String? ngayTao,
    String? ngayCapNhat,
    String? nguoiTao,
    bool? daXoa,
  }) {
    return LichLamViec(
      maLich: maLich ?? this.maLich,
      maNV: maNV ?? this.maNV,
      ngayLamViec: ngayLamViec ?? this.ngayLamViec,
      gioBatDau: gioBatDau ?? this.gioBatDau,
      gioKetThuc: gioKetThuc ?? this.gioKetThuc,
      caLamViec: caLamViec ?? this.caLamViec,
      loaiCa: loaiCa ?? this.loaiCa,
      ghiChu: ghiChu ?? this.ghiChu,
      trangThai: trangThai ?? this.trangThai,
      ngayTao: ngayTao ?? this.ngayTao,
      ngayCapNhat: ngayCapNhat ?? this.ngayCapNhat,
      nguoiTao: nguoiTao ?? this.nguoiTao,
      daXoa: daXoa ?? this.daXoa,
    );
  }
}