package com.example.worktrack.repository.nhanvien;

import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import com.example.worktrack.model.nhanvien.NhanVien;

import java.util.List;
import java.util.Optional;

@Repository
public interface NhanVienRepository extends JpaRepository<NhanVien, Integer> {

    /**
     * Tìm nhân viên theo email
     */
    Optional<NhanVien> findByEmail(String email);

    /**
     * Kiểm tra email đã tồn tại chưa
     */
    boolean existsByEmail(String email);

    /**
     * Tìm nhân viên theo thẻ NFC
     */
    Optional<NhanVien> findByTheNFC(String theNFC);

    /**
     * Tìm nhân viên theo mã vai trò
     */
    List<NhanVien> findByMaVaiTro(Integer maVaiTro);

    /**
     * Tìm kiếm nhân viên theo tên (tìm kiếm gần đúng)
     */
    @Query("SELECT n FROM NhanVien n WHERE LOWER(n.hoTen) LIKE LOWER(CONCAT('%', :keyword, '%'))")
    List<NhanVien> searchByHoTen(@Param("keyword") String keyword);

    /**
     * Tìm nhân viên theo số điện thoại
     */
    Optional<NhanVien> findByDienThoai(String dienThoai);

    /**
     * Kiểm tra thẻ NFC đã tồn tại chưa
     */
    boolean existsByTheNFC(String theNFC);

    /**
     * Tìm nhân viên theo tên đăng nhập
     */
    Optional<NhanVien> findByTenDangNhap(String tenDangNhap);

    /**
     * Kiểm tra tên đăng nhập đã tồn tại chưa
     */
    boolean existsByTenDangNhap(String tenDangNhap);
}
