package com.example.worktrack.model.baocao;

import com.example.worktrack.model.nhanvien.NhanVien;
import jakarta.persistence.*;
import jakarta.validation.constraints.NotNull;
import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;
import org.hibernate.annotations.CreationTimestamp;

import java.math.BigDecimal;
import java.time.LocalDate;
import java.time.LocalDateTime;

@Entity
@Table(name = "BaoCao")
@Data
@NoArgsConstructor
@AllArgsConstructor
public class BaoCao {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    @Column(name = "MaBaoCao")
    private Integer maBaoCao;

    @NotNull(message = "Mã nhân viên không được để trống")
    @Column(name = "MaNV", nullable = false)
    private Integer maNV;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "MaNV", insertable = false, updatable = false)
    private NhanVien nhanVien;

    @NotNull(message = "Ngày bắt đầu không được để trống")
    @Column(name = "TuNgay", nullable = false)
    private LocalDate tuNgay;

    @NotNull(message = "Ngày kết thúc không được để trống")
    @Column(name = "DenNgay", nullable = false)
    private LocalDate denNgay;

    @Column(name = "TongGio", precision = 5, scale = 2, columnDefinition = "DECIMAL(5,2) DEFAULT 0")
    private BigDecimal tongGio = BigDecimal.ZERO;

    @Column(name = "SoNgayDiTre", columnDefinition = "INT DEFAULT 0")
    private Integer soNgayDiTre = 0;

    @Column(name = "SoNgayVeSom", columnDefinition = "INT DEFAULT 0")
    private Integer soNgayVeSom = 0;

    @Column(name = "GioLamThem", precision = 5, scale = 2, columnDefinition = "DECIMAL(5,2) DEFAULT 0")
    private BigDecimal gioLamThem = BigDecimal.ZERO;

    @Column(name = "Luong", precision = 10, scale = 2, columnDefinition = "DECIMAL(10,2) DEFAULT 0")
    private BigDecimal luong = BigDecimal.ZERO;

    @CreationTimestamp
    @Column(name = "NgayTao", updatable = false)
    private LocalDateTime ngayTao;

    @Column(name = "DaXoa", nullable = false, columnDefinition = "BOOLEAN DEFAULT false")
    private Boolean daXoa = false;
}
