package com.example.worktrack.controller.lichlamviec;

import com.example.worktrack.model.lichlamviec.LichLamViec;
import com.example.worktrack.service.lichlamviec.LichLamViecService;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.tags.Tag;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.format.annotation.DateTimeFormat;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.time.LocalDate;
import java.util.List;
import java.util.Map;
import java.util.Optional;

@RestController
@RequestMapping("/api/v1/lichlamviec")
@RequiredArgsConstructor
@CrossOrigin(origins = "*")
@Tag(name = "Lịch Làm Việc", description = "API quản lý lịch làm việc")
public class LichLamViecController {

    private final LichLamViecService lichLamViecService;

    @GetMapping
    @Operation(summary = "Lấy tất cả lịch làm việc")
    public ResponseEntity<List<LichLamViec>> getAllLichLamViec() {
        List<LichLamViec> lichLamViecs = lichLamViecService.getAllLichLamViec();
        return ResponseEntity.ok(lichLamViecs);
    }

    @GetMapping("/{maLich}")
    @Operation(summary = "Lấy lịch làm việc theo mã")
    public ResponseEntity<?> getLichLamViecById(@PathVariable Integer maLich) {
        Optional<LichLamViec> lichLamViecOpt = lichLamViecService.getLichLamViecById(maLich);

        if (lichLamViecOpt.isPresent()) {
            return ResponseEntity.ok(lichLamViecOpt.get());
        }

        Map<String, String> error = Map.of(
                "message", "Không tìm thấy lịch làm việc với mã: " + maLich);
        return ResponseEntity.status(HttpStatus.NOT_FOUND).body(error);
    }

    @GetMapping("/nhanvien/{maNV}")
    @Operation(summary = "Lấy lịch làm việc theo nhân viên")
    public ResponseEntity<List<LichLamViec>> getLichLamViecByNhanVien(@PathVariable Integer maNV) {
        List<LichLamViec> lichLamViecs = lichLamViecService.getLichLamViecByNhanVien(maNV);
        return ResponseEntity.ok(lichLamViecs);
    }

    @GetMapping("/ngay/{ngayLamViec}")
    @Operation(summary = "Lấy lịch làm việc theo ngày")
    public ResponseEntity<List<LichLamViec>> getLichLamViecByNgay(
            @PathVariable @DateTimeFormat(iso = DateTimeFormat.ISO.DATE) LocalDate ngayLamViec) {
        List<LichLamViec> lichLamViecs = lichLamViecService.getLichLamViecByNgay(ngayLamViec);
        return ResponseEntity.ok(lichLamViecs);
    }

    @GetMapping("/nhanvien/{maNV}/khoangthoi")
    @Operation(summary = "Lấy lịch làm việc theo nhân viên và khoảng thời gian")
    public ResponseEntity<List<LichLamViec>> getLichLamViecByNhanVienAndKhoangThoiGian(
            @PathVariable Integer maNV,
            @RequestParam @DateTimeFormat(iso = DateTimeFormat.ISO.DATE) LocalDate tuNgay,
            @RequestParam @DateTimeFormat(iso = DateTimeFormat.ISO.DATE) LocalDate denNgay) {
        List<LichLamViec> lichLamViecs = lichLamViecService.getLichLamViecByNhanVienAndKhoangThoiGian(maNV, tuNgay,
                denNgay);
        return ResponseEntity.ok(lichLamViecs);
    }

    @GetMapping("/khoangthoi")
    @Operation(summary = "Lấy lịch làm việc theo khoảng thời gian")
    public ResponseEntity<List<LichLamViec>> getLichLamViecByKhoangThoiGian(
            @RequestParam @DateTimeFormat(iso = DateTimeFormat.ISO.DATE) LocalDate tuNgay,
            @RequestParam @DateTimeFormat(iso = DateTimeFormat.ISO.DATE) LocalDate denNgay) {
        List<LichLamViec> lichLamViecs = lichLamViecService.getLichLamViecByKhoangThoiGian(tuNgay, denNgay);
        return ResponseEntity.ok(lichLamViecs);
    }

    @PostMapping
    @Operation(summary = "Tạo lịch làm việc mới")
    public ResponseEntity<?> createLichLamViec(@Valid @RequestBody LichLamViec lichLamViec) {
        try {
            LichLamViec savedLichLamViec = lichLamViecService.createLichLamViec(lichLamViec);
            return ResponseEntity.status(HttpStatus.CREATED).body(savedLichLamViec);
        } catch (Exception e) {
            return ResponseEntity.status(HttpStatus.BAD_REQUEST)
                    .body(Map.of("message", "Lỗi tạo lịch làm việc: " + e.getMessage()));
        }
    }

    @PutMapping("/{maLich}")
    @Operation(summary = "Cập nhật lịch làm việc")
    public ResponseEntity<?> updateLichLamViec(
            @PathVariable Integer maLich,
            @Valid @RequestBody LichLamViec lichLamViec) {
        try {
            LichLamViec updatedLichLamViec = lichLamViecService.updateLichLamViec(maLich, lichLamViec);
            return ResponseEntity.ok(updatedLichLamViec);
        } catch (RuntimeException e) {
            return ResponseEntity.status(HttpStatus.NOT_FOUND)
                    .body(Map.of("message", e.getMessage()));
        } catch (Exception e) {
            return ResponseEntity.status(HttpStatus.BAD_REQUEST)
                    .body(Map.of("message", "Lỗi cập nhật lịch làm việc: " + e.getMessage()));
        }
    }

    @DeleteMapping("/{maLich}")
    @Operation(summary = "Xóa lịch làm việc")
    public ResponseEntity<?> deleteLichLamViec(@PathVariable Integer maLich) {
        try {
            lichLamViecService.deleteLichLamViec(maLich);
            return ResponseEntity.ok(Map.of("message", "Xóa lịch làm việc thành công"));
        } catch (RuntimeException e) {
            return ResponseEntity.status(HttpStatus.NOT_FOUND)
                    .body(Map.of("message", e.getMessage()));
        }
    }

    @GetMapping("/trangthai/{trangThai}")
    @Operation(summary = "Lấy lịch làm việc theo trạng thái")
    public ResponseEntity<List<LichLamViec>> getLichLamViecByTrangThai(@PathVariable String trangThai) {
        List<LichLamViec> lichLamViecs = lichLamViecService.getLichLamViecByTrangThai(trangThai);
        return ResponseEntity.ok(lichLamViecs);
    }
}