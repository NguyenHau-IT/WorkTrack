class NghiPhep {
  final int? maNghiPhep;
  final int maNV;
  final String tuNgay; // yyyy-MM-dd
  final String denNgay; // yyyy-MM-dd
  final int? soNgay;
  final String loaiNghi; // PHEP_NAM, PHEP_OM, PHEP_THAI_SAN, PHEP_LE
  final String? lyDo;
  final String trangThai; // CHO_DUYET, DA_DUYET, TU_CHOI
  final int? nguoiDuyet;
  final String? ngayDuyet; // yyyy-MM-dd HH:mm:ss
  final String? ghiChuDuyet;
  final String? ngayGui; // yyyy-MM-dd HH:mm:ss
  final String? ngayCapNhat; // yyyy-MM-dd HH:mm:ss
  final bool daXoa;

  NghiPhep({
    this.maNghiPhep,
    required this.maNV,
    required this.tuNgay,
    required this.denNgay,
    this.soNgay,
    required this.loaiNghi,
    this.lyDo,
    this.trangThai = 'CHO_DUYET',
    this.nguoiDuyet,
    this.ngayDuyet,
    this.ghiChuDuyet,
    this.ngayGui,
    this.ngayCapNhat,
    this.daXoa = false,
  });

  factory NghiPhep.fromJson(Map<String, dynamic> json) {
    return NghiPhep(
      maNghiPhep: json['maNghiPhep'],
      maNV: json['maNV'],
      tuNgay: json['tuNgay'],
      denNgay: json['denNgay'],
      soNgay: json['soNgay'],
      loaiNghi: json['loaiNghi'],
      lyDo: json['lyDo'],
      trangThai: json['trangThai'] ?? 'CHO_DUYET',
      nguoiDuyet: json['nguoiDuyet'],
      ngayDuyet: json['ngayDuyet'],
      ghiChuDuyet: json['ghiChuDuyet'],
      ngayGui: json['ngayGui'],
      ngayCapNhat: json['ngayCapNhat'],
      daXoa: json['daXoa'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'maNghiPhep': maNghiPhep,
      'maNV': maNV,
      'tuNgay': tuNgay,
      'denNgay': denNgay,
      'soNgay': soNgay,
      'loaiNghi': loaiNghi,
      'lyDo': lyDo,
      'trangThai': trangThai,
      'nguoiDuyet': nguoiDuyet,
      'ngayDuyet': ngayDuyet,
      'ghiChuDuyet': ghiChuDuyet,
      'ngayGui': ngayGui,
      'ngayCapNhat': ngayCapNhat,
      'daXoa': daXoa,
    };
  }

  // Helper methods
  DateTime get tuNgayAsDateTime => DateTime.parse(tuNgay);
  DateTime get denNgayAsDateTime => DateTime.parse(denNgay);

  DateTime? get ngayDuyetAsDateTime {
    if (ngayDuyet == null) return null;
    return DateTime.parse(ngayDuyet!);
  }

  DateTime? get ngayGuiAsDateTime {
    if (ngayGui == null) return null;
    return DateTime.parse(ngayGui!);
  }

  String get loaiNghiDisplay {
    switch (loaiNghi) {
      case 'PHEP_NAM':
        return 'Phép năm';
      case 'PHEP_OM':
        return 'Phép ốm';
      case 'PHEP_THAI_SAN':
        return 'Phép thai sản';
      case 'PHEP_LE':
        return 'Phép lễ';
      default:
        return loaiNghi;
    }
  }

  String get trangThaiDisplay {
    switch (trangThai) {
      case 'CHO_DUYET':
        return 'Chờ duyệt';
      case 'DA_DUYET':
        return 'Đã duyệt';
      case 'TU_CHOI':
        return 'Từ chối';
      default:
        return trangThai;
    }
  }

  int get soNgayTinhToan {
    return denNgayAsDateTime.difference(tuNgayAsDateTime).inDays + 1;
  }

  bool get isDuocDuyet => trangThai == 'DA_DUYET';
  bool get isBiTuChoi => trangThai == 'TU_CHOI';
  bool get isChoDuyet => trangThai == 'CHO_DUYET';

  NghiPhep copyWith({
    int? maNghiPhep,
    int? maNV,
    String? tuNgay,
    String? denNgay,
    int? soNgay,
    String? loaiNghi,
    String? lyDo,
    String? trangThai,
    int? nguoiDuyet,
    String? ngayDuyet,
    String? ghiChuDuyet,
    String? ngayGui,
    String? ngayCapNhat,
    bool? daXoa,
  }) {
    return NghiPhep(
      maNghiPhep: maNghiPhep ?? this.maNghiPhep,
      maNV: maNV ?? this.maNV,
      tuNgay: tuNgay ?? this.tuNgay,
      denNgay: denNgay ?? this.denNgay,
      soNgay: soNgay ?? this.soNgay,
      loaiNghi: loaiNghi ?? this.loaiNghi,
      lyDo: lyDo ?? this.lyDo,
      trangThai: trangThai ?? this.trangThai,
      nguoiDuyet: nguoiDuyet ?? this.nguoiDuyet,
      ngayDuyet: ngayDuyet ?? this.ngayDuyet,
      ghiChuDuyet: ghiChuDuyet ?? this.ghiChuDuyet,
      ngayGui: ngayGui ?? this.ngayGui,
      ngayCapNhat: ngayCapNhat ?? this.ngayCapNhat,
      daXoa: daXoa ?? this.daXoa,
    );
  }
}