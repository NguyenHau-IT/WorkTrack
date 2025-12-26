class NhanVien {
  final int? maNV;
  final String hoTen;
  final String email;
  final String? dienThoai;
  final int? maVaiTro;
  final Map<String, dynamic>? vaiTro;
  final String? theNFC;
  final DateTime? ngayTao;
  final DateTime? ngayCapNhat;
  final bool daXoa;
  final String tenDangNhap;
  final String matKhau;

  NhanVien({
    this.maNV,
    required this.hoTen,
    required this.email,
    this.dienThoai,
    this.maVaiTro,
    this.vaiTro,
    this.theNFC,
    this.ngayTao,
    this.ngayCapNhat,
    this.daXoa = false,
    required this.tenDangNhap,
    required this.matKhau,
  });

  factory NhanVien.fromJson(Map<String, dynamic> json) {
    return NhanVien(
      maNV: json['maNV'],
      hoTen: json['hoTen'],
      email: json['email'],
      dienThoai: json['dienThoai'],
      maVaiTro: json['maVaiTro'],
      vaiTro: json['vaiTro'],
      theNFC: json['theNFC'],
      ngayTao: json['ngayTao'] != null ? DateTime.parse(json['ngayTao']) : null,
      ngayCapNhat: json['ngayCapNhat'] != null ? DateTime.parse(json['ngayCapNhat']) : null,
      daXoa: json['daXoa'] ?? false,
      tenDangNhap: json['tenDangNhap'],
      matKhau: json['matKhau'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'maNV': maNV,
      'hoTen': hoTen,
      'email': email,
      'dienThoai': dienThoai,
      'maVaiTro': maVaiTro,
      'vaiTro': vaiTro,
      'theNFC': theNFC,
      'ngayTao': ngayTao?.toIso8601String(),
      'ngayCapNhat': ngayCapNhat?.toIso8601String(),
      'daXoa': daXoa,
      'tenDangNhap': tenDangNhap,
      'matKhau': matKhau,
    };
  }

  // Helper method để kiểm tra quyền admin
  bool get isAdmin {
    if (vaiTro != null && vaiTro!['tenVaiTro'] != null) {
      return vaiTro!['tenVaiTro'].toString().toLowerCase() == 'admin';
    }
    return false;
  }

  // Helper method để kiểm tra quyền manager
  bool get isManager {
    if (vaiTro != null && vaiTro!['tenVaiTro'] != null) {
      String roleName = vaiTro!['tenVaiTro'].toString().toLowerCase();
      return roleName == 'manager' || roleName == 'quanly' || roleName == 'quản lý';
    }
    return false;
  }
}