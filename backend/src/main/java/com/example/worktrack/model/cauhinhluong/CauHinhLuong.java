package com.example.worktrack.model.cauhinhluong;

import jakarta.persistence.*;
import jakarta.validation.constraints.DecimalMin;
import jakarta.validation.constraints.NotNull;
import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;
import org.hibernate.annotations.CreationTimestamp;

import java.math.BigDecimal;
import java.time.LocalDateTime;

@Entity
@Table(name = "cau_hinh_luong")
@Data
@NoArgsConstructor
@AllArgsConstructor
public class CauHinhLuong {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    @Column(name = "MaCauHinh")
    private Integer maCauHinh;

    @NotNull(message = "Lương giờ không được để trống")
    @DecimalMin(value = "0.0", inclusive = false, message = "Lương giờ phải lớn hơn 0")
    @Column(name = "LuongGio", nullable = false, precision = 10, scale = 2)
    private BigDecimal luongGio;

    @DecimalMin(value = "0.0", message = "Lương làm thêm phải lớn hơn hoặc bằng 0")
    @Column(name = "LuongLamThem", precision = 10, scale = 2, columnDefinition = "DECIMAL(10,2) DEFAULT 0")
    private BigDecimal luongLamThem = BigDecimal.ZERO;

    @CreationTimestamp
    @Column(name = "NgayTao", updatable = false)
    private LocalDateTime ngayTao;

    @Column(name = "DaXoa", nullable = false, columnDefinition = "bit DEFAULT 0")
    private Boolean daXoa = false;
}
