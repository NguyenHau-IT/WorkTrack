package com.example.worktrack.repository.vaitro;

import com.example.worktrack.model.vaitro.VaiTro;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.Optional;

@Repository
public interface VaiTroRepository extends JpaRepository<VaiTro, Integer> {

    /**
     * Tìm vai trò theo tên
     */
    Optional<VaiTro> findByTenVaiTro(String tenVaiTro);

    /**
     * Kiểm tra vai trò đã tồn tại chưa
     */
    boolean existsByTenVaiTro(String tenVaiTro);
}
