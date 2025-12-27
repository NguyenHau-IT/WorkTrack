package com.example.worktrack.repository.lichlamviec;

import com.example.worktrack.model.lichlamviec.LichLamViec;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import java.time.LocalDate;
import java.util.List;

@Repository
public interface LichLamViecRepository extends JpaRepository<LichLamViec, Integer> {

    List<LichLamViec> findByMaNVAndDaXoa(Integer maNV, Boolean daXoa);

    List<LichLamViec> findByNgayLamViecAndDaXoa(LocalDate ngayLamViec, Boolean daXoa);

    @Query("SELECT l FROM LichLamViec l WHERE l.maNV = :maNV AND l.ngayLamViec BETWEEN :tuNgay AND :denNgay AND l.daXoa = false")
    List<LichLamViec> findByMaNVAndNgayLamViecBetween(
            @Param("maNV") Integer maNV,
            @Param("tuNgay") LocalDate tuNgay,
            @Param("denNgay") LocalDate denNgay);

    @Query("SELECT l FROM LichLamViec l WHERE l.ngayLamViec BETWEEN :tuNgay AND :denNgay AND l.daXoa = false")
    List<LichLamViec> findByNgayLamViecBetween(
            @Param("tuNgay") LocalDate tuNgay,
            @Param("denNgay") LocalDate denNgay);

    @Query("SELECT l FROM LichLamViec l WHERE l.maNV = :maNV AND l.ngayLamViec = :ngayLamViec AND l.daXoa = false")
    List<LichLamViec> findByMaNVAndNgayLamViec(
            @Param("maNV") Integer maNV,
            @Param("ngayLamViec") LocalDate ngayLamViec);

    List<LichLamViec> findByTrangThaiAndDaXoa(String trangThai, Boolean daXoa);
}