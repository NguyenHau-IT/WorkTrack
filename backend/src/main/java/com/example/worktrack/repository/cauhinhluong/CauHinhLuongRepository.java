package com.example.worktrack.repository.cauhinhluong;

import com.example.worktrack.model.cauhinhluong.CauHinhLuong;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.stereotype.Repository;

import java.util.Optional;

@Repository
public interface CauHinhLuongRepository extends JpaRepository<CauHinhLuong, Integer> {

    /**
     * Lấy cấu hình lương mới nhất
     */
    Optional<CauHinhLuong> findTopByOrderByNgayTaoDesc();

    /**
     * Lấy cấu hình lương đang active (mới nhất)
     */
    @Query("SELECT c FROM CauHinhLuong c ORDER BY c.ngayTao DESC LIMIT 1")
    Optional<CauHinhLuong> findActiveConfig();
}
