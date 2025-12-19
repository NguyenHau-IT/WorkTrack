package com.example.worktrack.service.baocao;

import com.example.worktrack.model.baocao.BaoCao;

import java.math.BigDecimal;
import java.time.LocalDate;
import java.util.List;
import java.util.Map;
import java.util.Optional;

public interface BaoCaoService {

    /**
     * Lấy tất cả báo cáo
     */
    List<BaoCao> getAllBaoCao();

    /**
     * Lấy báo cáo theo mã
     */
    Optional<BaoCao> getBaoCaoById(Integer maBaoCao);

    /**
     * Lấy báo cáo của nhân viên
     */
    List<BaoCao> getBaoCaoByMaNV(Integer maNV);

    /**
     * Lấy báo cáo của nhân viên theo khoảng thời gian
     */
    List<BaoCao> getBaoCaoByMaNVAndDateRange(Integer maNV, LocalDate tuNgay, LocalDate denNgay);

    /**
     * Lấy báo cáo theo khoảng thời gian
     */
    List<BaoCao> getBaoCaoByDateRange(LocalDate tuNgay, LocalDate denNgay);

    /**
     * Tạo mới báo cáo
     */
    BaoCao createBaoCao(BaoCao baoCao);

    /**
     * Cập nhật báo cáo
     */
    BaoCao updateBaoCao(Integer maBaoCao, BaoCao baoCao);

    /**
     * Xóa báo cáo
     */
    void deleteBaoCao(Integer maBaoCao);

    /**
     * Tự động tạo báo cáo cho nhân viên dựa trên dữ liệu chấm công
     */
    BaoCao generateBaoCao(Integer maNV, LocalDate tuNgay, LocalDate denNgay);

    /**
     * Tính lương cho báo cáo
     */
    BaoCao calculateLuong(Integer maBaoCao, BigDecimal luongCoBan, BigDecimal luongLamThem);

    /**
     * Lấy báo cáo của nhân viên theo tháng
     */
    List<BaoCao> getBaoCaoByMonth(Integer maNV, int nam, int thang);

    /**
     * Lấy báo cáo theo năm
     */
    List<BaoCao> getBaoCaoByYear(int nam);

    /**
     * Lấy tổng lương của nhân viên trong năm
     */
    BigDecimal getTotalSalaryByYear(Integer maNV, int nam);

    /**
     * Lấy tổng giờ làm của nhân viên trong năm
     */
    BigDecimal getTotalHoursByYear(Integer maNV, int nam);

    /**
     * Lấy báo cáo mới nhất của nhân viên
     */
    Optional<BaoCao> getLatestBaoCao(Integer maNV);

    /**
     * Lấy thống kê tổng quan của tất cả nhân viên trong khoảng thời gian
     */
    Map<String, Object> getOverallStatistics(LocalDate tuNgay, LocalDate denNgay);
}
