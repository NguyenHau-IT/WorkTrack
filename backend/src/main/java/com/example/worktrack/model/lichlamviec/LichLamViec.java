package com.example.worktrack.model.lichlamviec;

import com.fasterxml.jackson.annotation.JsonFormat;
import jakarta.persistence.*;
import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.time.LocalDate;
import java.time.LocalDateTime;
import java.time.LocalTime;

@Entity
@Table(name = "lich_lam_viec")
@Data
@NoArgsConstructor
@AllArgsConstructor
public class LichLamViec {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    @Column(name = "ma_lich")
    private Integer maLich;

    @Column(name = "ma_nv", nullable = false)
    private Integer maNV;

    @Column(name = "ngay_lam_viec", nullable = false)
    @JsonFormat(pattern = "yyyy-MM-dd")
    private LocalDate ngayLamViec;

    @Column(name = "gio_bat_dau")
    @JsonFormat(pattern = "HH:mm:ss")
    private LocalTime gioBatDau;

    @Column(name = "gio_ket_thuc")
    @JsonFormat(pattern = "HH:mm:ss")
    private LocalTime gioKetThuc;

    @Column(name = "ca_lam_viec", length = 50)
    private String caLamViec; // Sáng, Chiều, Tối

    @Column(name = "loai_ca", length = 50)
    private String loaiCa; // Bình thường, Tăng ca, Làm thêm

    @Column(name = "ghi_chu", columnDefinition = "TEXT")
    private String ghiChu;

    @Column(name = "trang_thai", length = 20, nullable = false)
    private String trangThai = "KICH_HOAT"; // KICH_HOAT, HUY

    @Column(name = "ngay_tao", nullable = false)
    @JsonFormat(pattern = "yyyy-MM-dd HH:mm:ss")
    private LocalDateTime ngayTao;

    @Column(name = "ngay_cap_nhat")
    @JsonFormat(pattern = "yyyy-MM-dd HH:mm:ss")
    private LocalDateTime ngayCapNhat;

    @Column(name = "nguoi_tao")
    private String nguoiTao;

    @Column(name = "da_xoa", nullable = false)
    private Boolean daXoa = false;

    @PrePersist
    protected void onCreate() {
        ngayTao = LocalDateTime.now();
        ngayCapNhat = LocalDateTime.now();
    }

    @PreUpdate
    protected void onUpdate() {
        ngayCapNhat = LocalDateTime.now();
    }
}