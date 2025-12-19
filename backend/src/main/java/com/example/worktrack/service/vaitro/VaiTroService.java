package com.example.worktrack.service.vaitro;

import com.example.worktrack.model.vaitro.VaiTro;

import java.util.List;
import java.util.Optional;

public interface VaiTroService {

    /**
     * Lấy tất cả vai trò
     */
    List<VaiTro> getAllVaiTro();

    /**
     * Lấy vai trò theo mã
     */
    Optional<VaiTro> getVaiTroById(Integer maVaiTro);

    /**
     * Lấy vai trò theo tên
     */
    Optional<VaiTro> getVaiTroByTen(String tenVaiTro);

    /**
     * Tạo mới vai trò
     */
    VaiTro createVaiTro(VaiTro vaiTro);

    /**
     * Cập nhật vai trò
     */
    VaiTro updateVaiTro(Integer maVaiTro, VaiTro vaiTro);

    /**
     * Xóa vai trò
     */
    void deleteVaiTro(Integer maVaiTro);

    /**
     * Kiểm tra vai trò đã tồn tại
     */
    boolean isVaiTroExists(String tenVaiTro);
}
