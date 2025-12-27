package com.example.worktrack.controller.nghiphep;

import com.example.worktrack.model.nghiphep.NghiPhep;
import com.example.worktrack.service.nghiphep.NghiPhepService;
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
@RequestMapping("/api/v1/nghiphep")
@RequiredArgsConstructor
@CrossOrigin(origins = "*")
@Tag(name = "Nghỉ Phép", description = "API quản lý nghỉ phép")
public class NghiPhepController {

    private final NghiPhepService nghiPhepService;

    @GetMapping
    @Operation(summary = "Lấy tất cả đơn nghỉ phép")
    public ResponseEntity<List<NghiPhep>> getAllNghiPhep() {
        List<NghiPhep> nghiPheps = nghiPhepService.getAllNghiPhep();
        return ResponseEntity.ok(nghiPheps);
    }

    @GetMapping("/{maNghiPhep}")
    @Operation(summary = "Lấy đơn nghỉ phép theo mã")
    public ResponseEntity<?> getNghiPhepById(@PathVariable Integer maNghiPhep) {
        Optional<NghiPhep> nghiPhepOpt = nghiPhepService.getNghiPhepById(maNghiPhep);

        if (nghiPhepOpt.isPresent()) {
            return ResponseEntity.ok(nghiPhepOpt.get());
        }

        Map<String, String> error = Map.of(
                "message", "Không tìm thấy đơn nghỉ phép với mã: " + maNghiPhep);
        return ResponseEntity.status(HttpStatus.NOT_FOUND).body(error);
    }

    @GetMapping("/nhanvien/{maNV}")
    @Operation(summary = "Lấy đơn nghỉ phép theo nhân viên")
    public ResponseEntity<List<NghiPhep>> getNghiPhepByNhanVien(@PathVariable Integer maNV) {
        List<NghiPhep> nghiPheps = nghiPhepService.getNghiPhepByNhanVien(maNV);
        return ResponseEntity.ok(nghiPheps);
    }

    @GetMapping("/trangthai/{trangThai}")
    @Operation(summary = "Lấy đơn nghỉ phép theo trạng thái")
    public ResponseEntity<List<NghiPhep>> getNghiPhepByTrangThai(@PathVariable String trangThai) {
        List<NghiPhep> nghiPheps = nghiPhepService.getNghiPhepByTrangThai(trangThai);
        return ResponseEntity.ok(nghiPheps);
    }

    @GetMapping("/nhanvien/{maNV}/khoangthoi")
    @Operation(summary = "Lấy đơn nghỉ phép theo nhân viên và khoảng thời gian")
    public ResponseEntity<List<NghiPhep>> getNghiPhepByNhanVienAndKhoangThoiGian(
            @PathVariable Integer maNV,
            @RequestParam @DateTimeFormat(iso = DateTimeFormat.ISO.DATE) LocalDate tuNgay,
            @RequestParam @DateTimeFormat(iso = DateTimeFormat.ISO.DATE) LocalDate denNgay) {
        List<NghiPhep> nghiPheps = nghiPhepService.getNghiPhepByNhanVienAndKhoangThoiGian(maNV, tuNgay, denNgay);
        return ResponseEntity.ok(nghiPheps);
    }

    @GetMapping("/khoangthoi")
    @Operation(summary = "Lấy đơn nghỉ phép theo khoảng thời gian")
    public ResponseEntity<List<NghiPhep>> getNghiPhepByKhoangThoiGian(
            @RequestParam @DateTimeFormat(iso = DateTimeFormat.ISO.DATE) LocalDate tuNgay,
            @RequestParam @DateTimeFormat(iso = DateTimeFormat.ISO.DATE) LocalDate denNgay) {
        List<NghiPhep> nghiPheps = nghiPhepService.getNghiPhepByKhoangThoiGian(tuNgay, denNgay);
        return ResponseEntity.ok(nghiPheps);
    }

    @GetMapping("/nhanvien/{maNV}/loai/{loaiNghi}")
    @Operation(summary = "Lấy đơn nghỉ phép theo nhân viên và loại nghỉ")
    public ResponseEntity<List<NghiPhep>> getNghiPhepByNhanVienAndLoai(
            @PathVariable Integer maNV,
            @PathVariable String loaiNghi) {
        List<NghiPhep> nghiPheps = nghiPhepService.getNghiPhepByNhanVienAndLoai(maNV, loaiNghi);
        return ResponseEntity.ok(nghiPheps);
    }

    @GetMapping("/choduyet/{nguoiDuyet}")
    @Operation(summary = "Lấy đơn nghỉ phép chờ duyệt theo người duyệt")
    public ResponseEntity<List<NghiPhep>> getNghiPhepChoDuyet(@PathVariable Integer nguoiDuyet) {
        List<NghiPhep> nghiPheps = nghiPhepService.getNghiPhepChoDuyet(nguoiDuyet);
        return ResponseEntity.ok(nghiPheps);
    }

    @PostMapping
    @Operation(summary = "Tạo đơn nghỉ phép mới")
    public ResponseEntity<?> createNghiPhep(@Valid @RequestBody NghiPhep nghiPhep) {
        try {
            NghiPhep savedNghiPhep = nghiPhepService.createNghiPhep(nghiPhep);
            return ResponseEntity.status(HttpStatus.CREATED).body(savedNghiPhep);
        } catch (Exception e) {
            return ResponseEntity.status(HttpStatus.BAD_REQUEST)
                    .body(Map.of("message", "Lỗi tạo đơn nghỉ phép: " + e.getMessage()));
        }
    }

    @PutMapping("/{maNghiPhep}")
    @Operation(summary = "Cập nhật đơn nghỉ phép")
    public ResponseEntity<?> updateNghiPhep(
            @PathVariable Integer maNghiPhep,
            @Valid @RequestBody NghiPhep nghiPhep) {
        try {
            NghiPhep updatedNghiPhep = nghiPhepService.updateNghiPhep(maNghiPhep, nghiPhep);
            return ResponseEntity.ok(updatedNghiPhep);
        } catch (RuntimeException e) {
            return ResponseEntity.status(HttpStatus.NOT_FOUND)
                    .body(Map.of("message", e.getMessage()));
        } catch (Exception e) {
            return ResponseEntity.status(HttpStatus.BAD_REQUEST)
                    .body(Map.of("message", "Lỗi cập nhật đơn nghỉ phép: " + e.getMessage()));
        }
    }

    @DeleteMapping("/{maNghiPhep}")
    @Operation(summary = "Xóa đơn nghỉ phép")
    public ResponseEntity<?> deleteNghiPhep(@PathVariable Integer maNghiPhep) {
        try {
            nghiPhepService.deleteNghiPhep(maNghiPhep);
            return ResponseEntity.ok(Map.of("message", "Xóa đơn nghỉ phép thành công"));
        } catch (RuntimeException e) {
            return ResponseEntity.status(HttpStatus.NOT_FOUND)
                    .body(Map.of("message", e.getMessage()));
        }
    }

    @PutMapping("/{maNghiPhep}/duyet")
    @Operation(summary = "Duyệt đơn nghỉ phép")
    public ResponseEntity<?> duyetNghiPhep(
            @PathVariable Integer maNghiPhep,
            @RequestBody Map<String, Object> request) {
        try {
            Integer nguoiDuyet = (Integer) request.get("nguoiDuyet");
            Boolean duyet = (Boolean) request.get("duyet");
            String ghiChu = (String) request.get("ghiChu");

            NghiPhep duyetedNghiPhep = nghiPhepService.duyetNghiPhep(maNghiPhep, nguoiDuyet, duyet, ghiChu);
            return ResponseEntity.ok(duyetedNghiPhep);
        } catch (RuntimeException e) {
            return ResponseEntity.status(HttpStatus.NOT_FOUND)
                    .body(Map.of("message", e.getMessage()));
        } catch (Exception e) {
            return ResponseEntity.status(HttpStatus.BAD_REQUEST)
                    .body(Map.of("message", "Lỗi duyệt đơn nghỉ phép: " + e.getMessage()));
        }
    }
}