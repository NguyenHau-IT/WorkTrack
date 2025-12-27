package com.example.worktrack.model.nghiphep;

import com.fasterxml.jackson.annotation.JsonFormat;
import jakarta.persistence.*;
import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.time.LocalDate;
import java.time.LocalDateTime;

@Entity
@Table(name = "nghi_phep")
@Data
@NoArgsConstructor
@AllArgsConstructor
public class NghiPhep {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    @Column(name = "ma_nghi_phep")
    private Integer maNghiPhep;

    // Mã nhân viên - khóa ngoại đến bảng nhan_vien
    @Column(name = "manv", nullable = false)
    private Integer maNV;

    @Column(name = "tu_ngay", nullable = false)
    @JsonFormat(pattern = "yyyy-MM-dd")
    private LocalDate tuNgay;

    @Column(name = "den_ngay", nullable = false)
    @JsonFormat(pattern = "yyyy-MM-dd")
    private LocalDate denNgay;

    @Column(name = "so_ngay", nullable = false)
    private Integer soNgay;

    @Column(name = "loai_nghi", length = 50, nullable = false)
    private String loaiNghi; // PHEP_NAM, PHEP_OM, PHEP_THAI_SAN, PHEP_LE

    @Column(name = "ly_do", columnDefinition = "TEXT")
    private String lyDo;

    @Column(name = "trang_thai", length = 20, nullable = false)
    private String trangThai = "CHO_DUYET"; // CHO_DUYET, DA_DUYET, TU_CHOI

    @Column(name = "nguoi_duyet")
    private Integer nguoiDuyet;

    @Column(name = "ngay_duyet")
    @JsonFormat(pattern = "yyyy-MM-dd HH:mm:ss")
    private LocalDateTime ngayDuyet;

    @Column(name = "ghi_chu_duyet", columnDefinition = "TEXT")
    private String ghiChuDuyet;

    @Column(name = "ngay_gui", nullable = false)
    @JsonFormat(pattern = "yyyy-MM-dd HH:mm:ss")
    private LocalDateTime ngayGui;

    @Column(name = "ngay_cap_nhat")
    @JsonFormat(pattern = "yyyy-MM-dd HH:mm:ss")
    private LocalDateTime ngayCapNhat;

    @Column(name = "da_xoa", nullable = false)
    private Boolean daXoa = false;

    @PrePersist
    protected void onCreate() {
        ngayGui = LocalDateTime.now();
        ngayCapNhat = LocalDateTime.now();
    }

    @PreUpdate
    protected void onUpdate() {
        ngayCapNhat = LocalDateTime.now();
    }
}