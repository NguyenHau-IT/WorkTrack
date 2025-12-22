package com.example.worktrack.model.chamcong;

import com.example.worktrack.model.nhanvien.NhanVien;
import jakarta.persistence.*;
import jakarta.validation.constraints.NotNull;
import jakarta.validation.constraints.Size;
import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;
import org.hibernate.annotations.CreationTimestamp;

import java.time.LocalDateTime;

@Entity
@Table(name = "cham_cong")
@Data
@NoArgsConstructor
@AllArgsConstructor
public class ChamCong {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    @Column(name = "MaChamCong")
    private Integer maChamCong;

    @NotNull(message = "Mã nhân viên không được để trống")
    @Column(name = "MaNV", nullable = false)
    private Integer maNV;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "MaNV", insertable = false, updatable = false)
    private NhanVien nhanVien;

    @Column(name = "GioVao")
    private LocalDateTime gioVao;

    @Column(name = "GioRa")
    private LocalDateTime gioRa;

    @Column(name = "PhuongThuc", length = 20, columnDefinition = "NVARCHAR(20) DEFAULT 'ThuCong'")
    private String phuongThuc = "ThuCong"; // 'VanTay', 'KhuonMat', 'NFC', 'ThuCong'

    @Size(max = 255, message = "Ghi chú không được vượt quá 255 ký tự")
    @Column(name = "GhiChu", length = 255)
    private String ghiChu;

    @CreationTimestamp
    @Column(name = "NgayTao", updatable = false)
    private LocalDateTime ngayTao;

    @Column(name = "DaXoa", nullable = false , columnDefinition = "bit DEFAULT 0")
    private Boolean daXoa = false;

    /**
     * Tính số giờ làm việc (giữa GioVao và GioRa)
     */
    public Double getThoiGianLamViec() {
        if (gioVao != null && gioRa != null) {
            long minutes = java.time.Duration.between(gioVao, gioRa).toMinutes();
            return minutes / 60.0;
        }
        return null;
    }
}
