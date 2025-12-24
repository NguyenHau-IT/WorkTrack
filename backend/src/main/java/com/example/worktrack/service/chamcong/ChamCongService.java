package com.example.worktrack.service.chamcong;

import com.example.worktrack.model.chamcong.ChamCong;

import java.time.LocalDate;
import java.time.LocalDateTime;
import java.util.List;
import java.util.Map;
import java.util.Optional;

public interface ChamCongService {

    /**
     * Lấy tất cả bản ghi chấm công
     */
    List<ChamCong> getAllChamCong();

    /**
     * Lấy bản ghi chấm công theo mã
     */
    Optional<ChamCong> getChamCongById(Integer maChamCong);

    /**
     * Lấy bản ghi chấm công của nhân viên
     */
    List<ChamCong> getChamCongByMaNV(Integer maNV);

    /**
     * Lấy bản ghi chấm công của nhân viên trong khoảng thời gian
     */
    List<ChamCong> getChamCongByMaNVAndDateRange(Integer maNV, LocalDateTime tuNgay, LocalDateTime denNgay);

    /**
     * Lấy bản ghi chấm công trong khoảng thời gian
     */
    List<ChamCong> getChamCongByDateRange(LocalDateTime tuNgay, LocalDateTime denNgay);

    /**
     * Check-in (Chấm công vào)
     */
    ChamCong checkIn(Integer maNV, String phuongThuc, String ghiChu);

    /**
     * Check-out (Chấm công ra)
     */
    ChamCong checkOut(Integer maNV, String ghiChu);

    /**
     * Tạo mới bản ghi chấm công (thủ công)
     */
    ChamCong createChamCong(ChamCong chamCong);

    /**
     * Cập nhật bản ghi chấm công
     */
    ChamCong updateChamCong(Integer maChamCong, ChamCong chamCong);

    /**
     * Xóa bản ghi chấm công
     */
    void deleteChamCong(Integer maChamCong);

    /**
     * Khôi phục bản ghi chấm công đã xóa
     */
    ChamCong restoreChamCong(Integer maChamCong);

    /**
     * Xóa vĩnh viễn bản ghi chấm công (hard delete)
     */
    void hardDeleteChamCong(Integer maChamCong);

    /**
     * Lấy bản ghi chấm công đang active (chưa checkout)
     */
    Optional<ChamCong> getActiveChamCong(Integer maNV);

    /**
     * Lấy bản ghi chấm công mới nhất của nhân viên
     */
    Optional<ChamCong> getLatestChamCong(Integer maNV);

    /**
     * Đếm số lần chấm công trong khoảng thời gian
     */
    Long countChamCong(Integer maNV, LocalDateTime tuNgay, LocalDateTime denNgay);

    /**
     * Lấy thống kê chấm công theo ngày
     */
    Map<String, Object> getStatisticsByDate(LocalDate ngay);

    /**
     * Lấy thống kê chấm công của nhân viên theo tháng
     */
    Map<String, Object> getEmployeeStatisticsByMonth(Integer maNV, int nam, int thang);

    /**
     * Lấy danh sách nhân viên đã chấm công hôm nay
     */
    List<Integer> getEmployeesCheckedInToday();
}
