package com.example.worktrack.model.nhanvien;

import com.example.worktrack.model.vaitro.VaiTro;
import com.fasterxml.jackson.annotation.JsonProperty;
import jakarta.persistence.*;
import jakarta.validation.constraints.Email;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.Size;
import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;
import org.hibernate.annotations.CreationTimestamp;
import org.hibernate.annotations.UpdateTimestamp;

import java.time.LocalDateTime;

@Entity
@Table(name = "NhanVien")
@Data
@NoArgsConstructor
@AllArgsConstructor
public class NhanVien {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    @Column(name = "MaNV")
    @JsonProperty(access = JsonProperty.Access.READ_ONLY)
    private Integer maNV;

    @NotBlank(message = "Họ tên không được để trống")
    @Size(max = 100, message = "Họ tên không được vượt quá 100 ký tự")
    @Column(name = "HoTen", nullable = false, length = 100)
    private String hoTen;

    @NotBlank(message = "Email không được để trống")
    @Email(message = "Email không hợp lệ")
    @Size(max = 100, message = "Email không được vượt quá 100 ký tự")
    @Column(name = "Email", nullable = false, unique = true, length = 100)
    private String email;

    @Size(max = 20, message = "Số điện thoại không được vượt quá 20 ký tự")
    @Column(name = "DienThoai", length = 20)
    private String dienThoai;

    @Column(name = "MaVaiTro")
    private Integer maVaiTro;

    @ManyToOne(fetch = FetchType.EAGER)
    @JoinColumn(name = "MaVaiTro", insertable = false, updatable = false)
    private VaiTro vaiTro;

    @Lob
    @Column(name = "VanTay", columnDefinition = "VARBINARY(MAX)")
    private byte[] vanTay;

    @Lob
    @Column(name = "KhuonMat", columnDefinition = "VARBINARY(MAX)")
    private byte[] khuonMat;

    @Size(max = 50, message = "ID thẻ NFC không được vượt quá 50 ký tự")
    @Column(name = "TheNFC", length = 50)
    private String theNFC;

    @CreationTimestamp
    @Column(name = "NgayTao", updatable = false)
    private LocalDateTime ngayTao;

    @UpdateTimestamp
    @Column(name = "NgayCapNhat")
    private LocalDateTime ngayCapNhat;

    @Column(name = "DaXoa", nullable = false , columnDefinition = "BOOLEAN DEFAULT false")
    private Boolean daXoa = false;
}
