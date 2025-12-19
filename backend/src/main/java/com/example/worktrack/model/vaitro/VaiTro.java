package com.example.worktrack.model.vaitro;

import com.fasterxml.jackson.annotation.JsonProperty;
import jakarta.persistence.*;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.Size;
import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;
import org.hibernate.annotations.CreationTimestamp;

import java.time.LocalDateTime;

@Entity
@Table(name = "VaiTro")
@Data
@NoArgsConstructor
@AllArgsConstructor
public class VaiTro {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    @Column(name = "MaVaiTro")
    @JsonProperty(access = JsonProperty.Access.READ_ONLY)
    private Integer maVaiTro;

    @NotBlank(message = "Tên vai trò không được để trống")
    @Size(max = 50, message = "Tên vai trò không được vượt quá 50 ký tự")
    @Column(name = "TenVaiTro", nullable = false, unique = true, columnDefinition = "NVARCHAR(50)")
    private String tenVaiTro;

    @Size(max = 255, message = "Mô tả không được vượt quá 255 ký tự")
    @Column(name = "MoTa", columnDefinition = "NVARCHAR(255)")
    private String moTa;

    @CreationTimestamp
    @Column(name = "NgayTao", updatable = false)
    @JsonProperty(access = JsonProperty.Access.READ_ONLY)
    private LocalDateTime ngayTao;

    @Column(name = "DaXoa", nullable = false, columnDefinition = "BOOLEAN DEFAULT false")
    private Boolean daXoa = false;
}
