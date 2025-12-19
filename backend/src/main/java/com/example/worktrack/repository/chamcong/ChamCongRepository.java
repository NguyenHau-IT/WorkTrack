package com.example.worktrack.repository.chamcong;

import com.example.worktrack.model.chamcong.ChamCong;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import java.time.LocalDateTime;
import java.util.List;
import java.util.Optional;

@Repository
public interface ChamCongRepository extends JpaRepository<ChamCong, Integer> {

    /**
     * Lấy tất cả bản ghi chấm công của một nhân viên
     */
    List<ChamCong> findByMaNV(Integer maNV);

    /**
     * Lấy bản ghi chấm công của nhân viên trong khoảng thời gian
     */
    @Query("SELECT c FROM ChamCong c WHERE c.maNV = :maNV AND c.gioVao >= :tuNgay AND c.gioVao <= :denNgay ORDER BY c.gioVao DESC")
    List<ChamCong> findByMaNVAndDateRange(
            @Param("maNV") Integer maNV,
            @Param("tuNgay") LocalDateTime tuNgay,
            @Param("denNgay") LocalDateTime denNgay);

    /**
     * Lấy tất cả bản ghi chấm công trong khoảng thời gian
     */
    @Query("SELECT c FROM ChamCong c WHERE c.gioVao >= :tuNgay AND c.gioVao <= :denNgay ORDER BY c.gioVao DESC")
    List<ChamCong> findByDateRange(
            @Param("tuNgay") LocalDateTime tuNgay,
            @Param("denNgay") LocalDateTime denNgay);

    /**
     * Lấy bản ghi chấm công theo phương thức
     */
    List<ChamCong> findByPhuongThuc(String phuongThuc);

    /**
     * Lấy bản ghi chấm công của nhân viên theo phương thức
     */
    List<ChamCong> findByMaNVAndPhuongThuc(Integer maNV, String phuongThuc);

    /**
     * Tìm bản ghi chấm công chưa checkout (chưa có GioRa)
     */
    @Query("SELECT c FROM ChamCong c WHERE c.maNV = :maNV AND c.gioRa IS NULL ORDER BY c.gioVao DESC")
    Optional<ChamCong> findActiveCheckin(@Param("maNV") Integer maNV);

    /**
     * Đếm số lần chấm công của nhân viên trong khoảng thời gian
     */
    @Query("SELECT COUNT(c) FROM ChamCong c WHERE c.maNV = :maNV AND c.gioVao >= :tuNgay AND c.gioVao <= :denNgay")
    Long countByMaNVAndDateRange(
            @Param("maNV") Integer maNV,
            @Param("tuNgay") LocalDateTime tuNgay,
            @Param("denNgay") LocalDateTime denNgay);

    /**
     * Lấy bản ghi chấm công mới nhất của nhân viên
     */
    Optional<ChamCong> findTopByMaNVOrderByGioVaoDesc(Integer maNV);

    /**
     * Lấy danh sách nhân viên đã chấm công trong ngày
     */
    @Query("SELECT DISTINCT c.maNV FROM ChamCong c WHERE c.gioVao >= :startOfDay AND c.gioVao < :endOfDay")
    List<Integer> findEmployeesCheckedInToday(
            @Param("startOfDay") LocalDateTime startOfDay,
            @Param("endOfDay") LocalDateTime endOfDay);
}
