package com.example.worktrack.repository.baocao;

import com.example.worktrack.model.baocao.BaoCao;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import java.math.BigDecimal;
import java.time.LocalDate;
import java.util.List;
import java.util.Optional;

@Repository
public interface BaoCaoRepository extends JpaRepository<BaoCao, Integer> {

    /**
     * Lấy tất cả báo cáo của một nhân viên
     */
    List<BaoCao> findByMaNV(Integer maNV);

    /**
     * Lấy báo cáo của nhân viên theo khoảng thời gian
     */
    @Query("SELECT b FROM BaoCao b WHERE b.maNV = :maNV AND b.tuNgay >= :tuNgay AND b.denNgay <= :denNgay ORDER BY b.tuNgay DESC")
    List<BaoCao> findByMaNVAndDateRange(
            @Param("maNV") Integer maNV,
            @Param("tuNgay") LocalDate tuNgay,
            @Param("denNgay") LocalDate denNgay);

    /**
     * Lấy báo cáo theo khoảng thời gian
     */
    @Query("SELECT b FROM BaoCao b WHERE b.tuNgay >= :tuNgay AND b.denNgay <= :denNgay ORDER BY b.tuNgay DESC")
    List<BaoCao> findByDateRange(
            @Param("tuNgay") LocalDate tuNgay,
            @Param("denNgay") LocalDate denNgay);

    /**
     * Kiểm tra xem đã có báo cáo cho nhân viên trong khoảng thời gian chưa
     */
    @Query("SELECT COUNT(b) > 0 FROM BaoCao b WHERE b.maNV = :maNV AND b.tuNgay = :tuNgay AND b.denNgay = :denNgay")
    boolean existsByMaNVAndDateRange(
            @Param("maNV") Integer maNV,
            @Param("tuNgay") LocalDate tuNgay,
            @Param("denNgay") LocalDate denNgay);

    /**
     * Tìm báo cáo của nhân viên trong khoảng thời gian cụ thể
     */
    Optional<BaoCao> findByMaNVAndTuNgayAndDenNgay(Integer maNV, LocalDate tuNgay, LocalDate denNgay);

    /**
     * Lấy báo cáo mới nhất của nhân viên
     */
    Optional<BaoCao> findTopByMaNVOrderByNgayTaoDesc(Integer maNV);

    /**
     * Lấy báo cáo của nhân viên theo tháng
     */
    @Query("SELECT b FROM BaoCao b WHERE b.maNV = :maNV AND YEAR(b.tuNgay) = :nam AND MONTH(b.tuNgay) = :thang")
    List<BaoCao> findByMaNVAndMonth(@Param("maNV") Integer maNV, @Param("nam") int nam, @Param("thang") int thang);

    /**
     * Lấy báo cáo theo năm
     */
    @Query("SELECT b FROM BaoCao b WHERE YEAR(b.tuNgay) = :nam ORDER BY b.tuNgay DESC")
    List<BaoCao> findByYear(@Param("nam") int nam);

    /**
     * Lấy tổng lương của nhân viên trong năm
     */
    @Query("SELECT SUM(b.luong) FROM BaoCao b WHERE b.maNV = :maNV AND YEAR(b.tuNgay) = :nam")
    BigDecimal getTotalSalaryByYear(@Param("maNV") Integer maNV, @Param("nam") int nam);

    /**
     * Lấy tổng giờ làm của nhân viên trong năm
     */
    @Query("SELECT SUM(b.tongGio) FROM BaoCao b WHERE b.maNV = :maNV AND YEAR(b.tuNgay) = :nam")
    BigDecimal getTotalHoursByYear(@Param("maNV") Integer maNV, @Param("nam") int nam);
}
