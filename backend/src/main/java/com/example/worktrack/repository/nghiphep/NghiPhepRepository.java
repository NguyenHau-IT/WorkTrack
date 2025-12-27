package com.example.worktrack.repository.nghiphep;

import com.example.worktrack.model.nghiphep.NghiPhep;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import java.time.LocalDate;
import java.util.List;

@Repository
public interface NghiPhepRepository extends JpaRepository<NghiPhep, Integer> {

    List<NghiPhep> findByMaNVAndDaXoa(Integer maNV, Boolean daXoa);

    List<NghiPhep> findByTrangThaiAndDaXoa(String trangThai, Boolean daXoa);

    @Query("SELECT n FROM NghiPhep n WHERE n.maNV = :maNV AND n.tuNgay BETWEEN :tuNgay AND :denNgay AND n.daXoa = false")
    List<NghiPhep> findByMaNVAndTuNgayBetween(
            @Param("maNV") Integer maNV,
            @Param("tuNgay") LocalDate tuNgay,
            @Param("denNgay") LocalDate denNgay);

    @Query("SELECT n FROM NghiPhep n WHERE n.tuNgay BETWEEN :tuNgay AND :denNgay AND n.daXoa = false")
    List<NghiPhep> findByTuNgayBetween(
            @Param("tuNgay") LocalDate tuNgay,
            @Param("denNgay") LocalDate denNgay);

    @Query("SELECT n FROM NghiPhep n WHERE n.maNV = :maNV AND n.loaiNghi = :loaiNghi AND n.daXoa = false")
    List<NghiPhep> findByMaNVAndLoaiNghi(
            @Param("maNV") Integer maNV,
            @Param("loaiNghi") String loaiNghi);

    @Query("SELECT n FROM NghiPhep n WHERE n.nguoiDuyet = :nguoiDuyet AND n.trangThai = :trangThai AND n.daXoa = false")
    List<NghiPhep> findByNguoiDuyetAndTrangThai(
            @Param("nguoiDuyet") Integer nguoiDuyet,
            @Param("trangThai") String trangThai);
}