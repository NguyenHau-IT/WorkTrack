package com.example.worktrack.service.cauhinhluong;

import com.example.worktrack.model.cauhinhluong.CauHinhLuong;

import java.util.List;
import java.util.Optional;

public interface CauHinhLuongService {

    /**
     * Lấy tất cả cấu hình lương
     */
    List<CauHinhLuong> getAllCauHinhLuong();

    /**
     * Lấy cấu hình lương theo mã
     */
    Optional<CauHinhLuong> getCauHinhLuongById(Integer maCauHinh);

    /**
     * Lấy cấu hình lương đang active (mới nhất)
     */
    Optional<CauHinhLuong> getActiveCauHinhLuong();

    /**
     * Tạo mới cấu hình lương
     */
    CauHinhLuong createCauHinhLuong(CauHinhLuong cauHinhLuong);

    /**
     * Cập nhật cấu hình lương
     */
    CauHinhLuong updateCauHinhLuong(Integer maCauHinh, CauHinhLuong cauHinhLuong);

    /**
     * Xóa cấu hình lương
     */
    void deleteCauHinhLuong(Integer maCauHinh);

    /**
     * Khôi phục cấu hình lương đã xóa
     */
    CauHinhLuong restoreCauHinhLuong(Integer maCauHinh);

    /**
     * Xóa cứng cấu hình lương (xóa vĩnh viễn)
     */
    void hardDeleteCauHinhLuong(Integer maCauHinh);
}
