package com.example.worktrack.service.nhanvien;

import java.util.List;
import java.util.Optional;

import com.example.worktrack.model.nhanvien.NhanVien;

public interface NhanVienService {

    /**
     * Lấy tất cả nhân viên
     */
    List<NhanVien> getAllNhanVien();

    /**
     * Lấy nhân viên theo mã
     */
    Optional<NhanVien> getNhanVienById(Integer maNV);

    /**
     * Lấy nhân viên theo email
     */
    Optional<NhanVien> getNhanVienByEmail(String email);

    /**
     * Lấy nhân viên theo thẻ NFC
     */
    Optional<NhanVien> getNhanVienByTheNFC(String theNFC);

    /**
     * Tạo mới nhân viên
     */
    NhanVien createNhanVien(NhanVien nhanVien);

    /**
     * Cập nhật thông tin nhân viên
     */
    NhanVien updateNhanVien(Integer maNV, NhanVien nhanVien);

    /**
     * Xóa nhân viên
     */
    void deleteNhanVien(Integer maNV);

    /**
     * Tìm kiếm nhân viên theo tên
     */
    List<NhanVien> searchNhanVienByName(String keyword);

    /**
     * Lấy danh sách nhân viên theo mã vai trò
     */
    List<NhanVien> getNhanVienByMaVaiTro(Integer maVaiTro);

    /**
     * Kiểm tra email đã tồn tại
     */
    boolean isEmailExists(String email);

    /**
     * Kiểm tra thẻ NFC đã tồn tại
     */
    boolean isTheNFCExists(String theNFC);

    /**
     * Cập nhật vân tay cho nhân viên
     */
    NhanVien updateVanTay(Integer maNV, byte[] vanTay);

    /**
     * Cập nhật khuôn mặt cho nhân viên
     */
    NhanVien updateKhuonMat(Integer maNV, byte[] khuonMat);

    /**
     * Cập nhật thẻ NFC cho nhân viên
     */
    NhanVien updateTheNFC(Integer maNV, String theNFC);

    /**
     * Lấy nhân viên theo tên đăng nhập
     */
    Optional<NhanVien> getNhanVienByTenDangNhap(String tenDangNhap);

    /**
     * Kiểm tra tên đăng nhập đã tồn tại
     */
    boolean isTenDangNhapExists(String tenDangNhap);
}
