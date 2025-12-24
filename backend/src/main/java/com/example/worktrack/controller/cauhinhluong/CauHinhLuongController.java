package com.example.worktrack.controller.cauhinhluong;

import com.example.worktrack.model.cauhinhluong.CauHinhLuong;
import com.example.worktrack.service.cauhinhluong.CauHinhLuongService;

import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.tags.Tag;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;
import java.util.Map;
import java.util.Optional;

@RestController
@RequestMapping("/api/v1/cauhinhluong")
@RequiredArgsConstructor
@CrossOrigin(origins = "*")
@Tag(name = "Cấu Hình Lương", description = "API quản lý cấu hình lương")
public class CauHinhLuongController {

    private final CauHinhLuongService cauHinhLuongService;

    /**
     * Lấy tất cả cấu hình lương
     */
    @GetMapping
    @Operation(summary = "Lấy tất cả cấu hình lương")
    public ResponseEntity<List<CauHinhLuong>> getAllCauHinhLuong() {
        List<CauHinhLuong> cauHinhLuongs = cauHinhLuongService.getAllCauHinhLuong();
        return ResponseEntity.ok(cauHinhLuongs);
    }

    /**
     * Lấy cấu hình lương theo ID
     */
    @GetMapping("/{maCauHinh}")
    @Operation(summary = "Lấy cấu hình lương theo mã")
    public ResponseEntity<?> getCauHinhLuongById(@PathVariable Integer maCauHinh) {
        Optional<CauHinhLuong> cauHinhOpt = cauHinhLuongService.getCauHinhLuongById(maCauHinh);

        if (cauHinhOpt.isPresent()) {
            return ResponseEntity.ok(cauHinhOpt.get());
        }

        Map<String, String> errorResponse = Map.of(
                "message", "Không tìm thấy cấu hình lương với mã: " + maCauHinh);
        return ResponseEntity.status(HttpStatus.NOT_FOUND).body(errorResponse);
    }

    @GetMapping("/active")
    @Operation(summary = "Lấy cấu hình lương đang hoạt động (mới nhất)")
    public ResponseEntity<?> getActiveCauHinhLuong() {
        Optional<CauHinhLuong> activeCauHinh = cauHinhLuongService.getActiveCauHinhLuong();

        if (activeCauHinh.isPresent()) {
            return ResponseEntity.ok(activeCauHinh.get());
        }

        Map<String, String> errorResponse = Map.of(
                "message", "Chưa có cấu hình lương nào đang hoạt động");
        return ResponseEntity.status(HttpStatus.NOT_FOUND).body(errorResponse);
    }

    /**
     * Tạo cấu hình lương mới
     */
    @PostMapping
    @Operation(summary = "Tạo cấu hình lương mới")
    public ResponseEntity<?> createCauHinhLuong(@Valid @RequestBody CauHinhLuong cauHinhLuong) {
        try {
            CauHinhLuong createdCauHinh = cauHinhLuongService.createCauHinhLuong(cauHinhLuong);
            return ResponseEntity.status(HttpStatus.CREATED).body(createdCauHinh);
        } catch (IllegalArgumentException e) {
            return ResponseEntity.status(HttpStatus.BAD_REQUEST)
                    .body(Map.of("message", e.getMessage()));
        }
    }

    /**
     * Cập nhật cấu hình lương
     */
    @PutMapping("/{maCauHinh}")
    @Operation(summary = "Cập nhật cấu hình lương")
    public ResponseEntity<?> updateCauHinhLuong(
            @PathVariable Integer maCauHinh,
            @Valid @RequestBody CauHinhLuong cauHinhLuong) {
        try {
            CauHinhLuong updatedCauHinh = cauHinhLuongService.updateCauHinhLuong(maCauHinh, cauHinhLuong);
            return ResponseEntity.ok(updatedCauHinh);
        } catch (IllegalArgumentException e) {
            return ResponseEntity.status(HttpStatus.BAD_REQUEST)
                    .body(Map.of("message", e.getMessage()));
        }
    }

    /**
     * Xóa cấu hình lương
     */
    @DeleteMapping("/{maCauHinh}")
    @Operation(summary = "Xóa cấu hình lương")
    public ResponseEntity<?> deleteCauHinhLuong(@PathVariable Integer maCauHinh) {
        try {
            cauHinhLuongService.deleteCauHinhLuong(maCauHinh);
            return ResponseEntity.ok(Map.of("message", "Xóa cấu hình lương thành công"));
        } catch (IllegalArgumentException e) {
            return ResponseEntity.status(HttpStatus.NOT_FOUND)
                    .body(Map.of("message", e.getMessage()));
        }
    }

    /**
     * Khôi phục cấu hình lương đã xóa
     */
    @PutMapping("/{maCauHinh}/restore")
    @Operation(summary = "Khôi phục cấu hình lương đã xóa")
    public ResponseEntity<?> restoreCauHinhLuong(@PathVariable Integer maCauHinh) {
        try {
            CauHinhLuong restoredCauHinh = cauHinhLuongService.restoreCauHinhLuong(maCauHinh);
            return ResponseEntity.ok(restoredCauHinh);
        } catch (IllegalArgumentException e) {
            return ResponseEntity.status(HttpStatus.BAD_REQUEST)
                    .body(Map.of("message", e.getMessage()));
        }
    }

    /**
     * Xóa cứng cấu hình lương (xóa vĩnh viễn)
     */
    @DeleteMapping("/{maCauHinh}/hard")
    @Operation(summary = "Xóa cứng cấu hình lương (xóa vĩnh viễn)")
    public ResponseEntity<?> hardDeleteCauHinhLuong(@PathVariable Integer maCauHinh) {
        try {
            cauHinhLuongService.hardDeleteCauHinhLuong(maCauHinh);
            return ResponseEntity.ok(Map.of("message", "Xóa vĩnh viễn cấu hình lương thành công"));
        } catch (IllegalArgumentException e) {
            return ResponseEntity.status(HttpStatus.NOT_FOUND)
                    .body(Map.of("message", e.getMessage()));
        }
    }
}
