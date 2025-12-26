package com.example.worktrack.controller.baocao;

import com.example.worktrack.model.baocao.BaoCao;
import com.example.worktrack.service.baocao.BaoCaoService;

import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.tags.Tag;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.format.annotation.DateTimeFormat;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.math.BigDecimal;
import java.time.LocalDate;
import java.util.List;
import java.util.Map;
import java.util.Optional;

@RestController
@RequestMapping("/api/v1/baocao")
@RequiredArgsConstructor
@CrossOrigin(origins = "*")
@Tag(name = "Báo Cáo", description = "API quản lý báo cáo")
public class BaoCaoController {

    private final BaoCaoService baoCaoService;

    /**
     * Lấy tất cả báo cáo
     */
    @GetMapping
    @Operation(summary = "Lấy tất cả báo cáo")
    public ResponseEntity<List<BaoCao>> getAllBaoCao() {
        List<BaoCao> baoCaos = baoCaoService.getAllBaoCao();
        return ResponseEntity.ok(baoCaos);
    }

    /**
     * Lấy báo cáo theo ID
     */
    @GetMapping("/{maBaoCao}")
    @Operation(summary = "Lấy báo cáo theo mã")
    public ResponseEntity<?> getBaoCaoById(@PathVariable Integer maBaoCao) {
        Optional<BaoCao> baoCaoOpt = baoCaoService.getBaoCaoById(maBaoCao);

        if (baoCaoOpt.isPresent()) {
            return ResponseEntity.ok(baoCaoOpt.get());
        } else {
            return ResponseEntity.status(HttpStatus.NOT_FOUND)
                    .body(Map.of("message", "Không tìm thấy báo cáo với mã: " + maBaoCao));
        }
    }

    /**
     * Lấy báo cáo của nhân viên
     */
    @GetMapping("/nhanvien/{maNV}")
    @Operation(summary = "Lấy báo cáo của nhân viên")
    public ResponseEntity<List<BaoCao>> getBaoCaoByNhanVien(@PathVariable Integer maNV) {
        List<BaoCao> baoCaos = baoCaoService.getBaoCaoByMaNV(maNV);
        return ResponseEntity.ok(baoCaos);
    }

    /**
     * Lấy báo cáo của nhân viên theo khoảng thời gian
     */
    @GetMapping("/nhanvien/{maNV}/daterange")
    @Operation(summary = "Lấy báo cáo của nhân viên theo khoảng thời gian")
    public ResponseEntity<List<BaoCao>> getBaoCaoByNhanVienAndDateRange(
            @PathVariable Integer maNV,
            @RequestParam @DateTimeFormat(iso = DateTimeFormat.ISO.DATE) LocalDate tuNgay,
            @RequestParam @DateTimeFormat(iso = DateTimeFormat.ISO.DATE) LocalDate denNgay) {
        List<BaoCao> baoCaos = baoCaoService.getBaoCaoByMaNVAndDateRange(maNV, tuNgay, denNgay);
        return ResponseEntity.ok(baoCaos);
    }

    /**
     * Lấy báo cáo theo khoảng thời gian
     */
    @GetMapping("/daterange")
    @Operation(summary = "Lấy báo cáo theo khoảng thời gian")
    public ResponseEntity<List<BaoCao>> getBaoCaoByDateRange(
            @RequestParam @DateTimeFormat(iso = DateTimeFormat.ISO.DATE) LocalDate tuNgay,
            @RequestParam @DateTimeFormat(iso = DateTimeFormat.ISO.DATE) LocalDate denNgay) {
        List<BaoCao> baoCaos = baoCaoService.getBaoCaoByDateRange(tuNgay, denNgay);
        return ResponseEntity.ok(baoCaos);
    }

    /**
     * Lấy báo cáo của nhân viên theo tháng
     */
    @GetMapping("/nhanvien/{maNV}/thang")
    @Operation(summary = "Lấy báo cáo của nhân viên theo tháng")
    public ResponseEntity<List<BaoCao>> getBaoCaoByMonth(
            @PathVariable Integer maNV,
            @RequestParam int nam,
            @RequestParam int thang) {
        List<BaoCao> baoCaos = baoCaoService.getBaoCaoByMonth(maNV, nam, thang);
        return ResponseEntity.ok(baoCaos);
    }

    /**
     * Lấy báo cáo theo năm
     */
    @GetMapping("/nam/{nam}")
    @Operation(summary = "Lấy báo cáo theo năm")
    public ResponseEntity<List<BaoCao>> getBaoCaoByYear(@PathVariable int nam) {
        List<BaoCao> baoCaos = baoCaoService.getBaoCaoByYear(nam);
        return ResponseEntity.ok(baoCaos);
    }

    /**
     * Tạo báo cáo thủ công
     */
    @PostMapping
    @Operation(summary = "Tạo mới báo cáo")
    public ResponseEntity<?> createBaoCao(@Valid @RequestBody BaoCao baoCao) {
        try {
            BaoCao createdBaoCao = baoCaoService.createBaoCao(baoCao);
            return ResponseEntity.status(HttpStatus.CREATED).body(createdBaoCao);
        } catch (IllegalArgumentException e) {
            return ResponseEntity.status(HttpStatus.BAD_REQUEST)
                    .body(Map.of("message", e.getMessage()));
        }
    }

    /**
     * Tự động tạo báo cáo từ dữ liệu chấm công
     */
    @PostMapping("/generate")
    @Operation(summary = "Tự động tạo báo cáo từ dữ liệu chấm công")
    public ResponseEntity<?> generateBaoCao(@RequestBody Map<String, Object> request) {
        try {
            Integer maNV = (Integer) request.get("maNV");
            LocalDate tuNgay = LocalDate.parse((String) request.get("tuNgay"));
            LocalDate denNgay = LocalDate.parse((String) request.get("denNgay"));

            BaoCao baoCao = baoCaoService.generateBaoCao(maNV, tuNgay, denNgay);
            return ResponseEntity.status(HttpStatus.CREATED).body(baoCao);
        } catch (IllegalArgumentException e) {
            return ResponseEntity.status(HttpStatus.BAD_REQUEST)
                    .body(Map.of("message", e.getMessage()));
        } catch (Exception e) {
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR)
                    .body(Map.of("message", "Lỗi khi tạo báo cáo: " + e.getMessage()));
        }
    }

    /**
     * Cập nhật báo cáo
     */
    @PutMapping("/{maBaoCao}")
    @Operation(summary = "Cập nhật báo cáo")
    public ResponseEntity<?> updateBaoCao(
            @PathVariable Integer maBaoCao,
            @Valid @RequestBody BaoCao baoCao) {
        try {
            BaoCao updatedBaoCao = baoCaoService.updateBaoCao(maBaoCao, baoCao);
            return ResponseEntity.ok(updatedBaoCao);
        } catch (IllegalArgumentException e) {
            return ResponseEntity.status(HttpStatus.BAD_REQUEST)
                    .body(Map.of("message", e.getMessage()));
        }
    }

    /**
     * Xóa báo cáo
     */
    @DeleteMapping("/{maBaoCao}")
    @Operation(summary = "Xóa báo cáo")
    public ResponseEntity<?> deleteBaoCao(@PathVariable Integer maBaoCao) {
        try {
            baoCaoService.deleteBaoCao(maBaoCao);
            return ResponseEntity.ok(Map.of("message", "Xóa báo cáo thành công"));
        } catch (IllegalArgumentException e) {
            return ResponseEntity.status(HttpStatus.NOT_FOUND)
                    .body(Map.of("message", e.getMessage()));
        }
    }

    /**
     * Khôi phục báo cáo
     */
    @PutMapping("/restore/{maBaoCao}")
    @Operation(summary = "Khôi phục báo cáo")
    public ResponseEntity<?> restoreBaoCao(@PathVariable Integer maBaoCao) {
        try {
            baoCaoService.restoreBaoCao(maBaoCao);
            return ResponseEntity.ok(Map.of("message", "Khôi phục báo cáo thành công"));
        } catch (IllegalArgumentException e) {
            return ResponseEntity.status(HttpStatus.NOT_FOUND)
                    .body(Map.of("message", e.getMessage()));
        }
    }

    /**
     * Xóa cứng báo cáo (xóa vĩnh viễn)
     */
    @DeleteMapping("/{maBaoCao}/hard")
    @Operation(summary = "Xóa cứng báo cáo (xóa vĩnh viễn)")
    public ResponseEntity<?> hardDeleteBaoCao(@PathVariable Integer maBaoCao) {
        try {
            baoCaoService.hardDeleteBaoCao(maBaoCao);
            return ResponseEntity.ok(Map.of("message", "Xóa vĩnh viễn báo cáo thành công"));
        } catch (IllegalArgumentException e) {
            return ResponseEntity.status(HttpStatus.NOT_FOUND)
                    .body(Map.of("message", e.getMessage()));
        }
    }

    /**
     * Tính lương cho báo cáo
     */
    @PatchMapping("/{maBaoCao}/luong")
    @Operation(summary = "Tính lương cho báo cáo")
    public ResponseEntity<?> calculateLuong(
            @PathVariable Integer maBaoCao,
            @RequestBody Map<String, Object> request) {
        try {
            BigDecimal luongCoBan = new BigDecimal(request.get("luongCoBan").toString());
            BigDecimal luongLamThem = new BigDecimal(request.get("luongLamThem").toString());

            BaoCao updatedBaoCao = baoCaoService.calculateLuong(maBaoCao, luongCoBan, luongLamThem);
            return ResponseEntity.ok(updatedBaoCao);
        } catch (IllegalArgumentException e) {
            return ResponseEntity.status(HttpStatus.BAD_REQUEST)
                    .body(Map.of("message", e.getMessage()));
        } catch (Exception e) {
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR)
                    .body(Map.of("message", "Lỗi khi tính lương: " + e.getMessage()));
        }
    }

    /**
     * Lấy tổng lương của nhân viên trong năm
     */
    @GetMapping("/nhanvien/{maNV}/tongluong")
    @Operation(summary = "Lấy tổng lương của nhân viên trong năm")
    public ResponseEntity<Map<String, Object>> getTotalSalaryByYear(
            @PathVariable Integer maNV,
            @RequestParam int nam) {
        BigDecimal tongLuong = baoCaoService.getTotalSalaryByYear(maNV, nam);
        return ResponseEntity.ok(Map.of(
                "maNV", maNV,
                "nam", nam,
                "tongLuong", tongLuong));
    }

    /**
     * Lấy tổng giờ làm của nhân viên trong năm
     */
    @GetMapping("/nhanvien/{maNV}/tonggio")
    @Operation(summary = "Lấy tổng giờ làm của nhân viên trong năm")
    public ResponseEntity<Map<String, Object>> getTotalHoursByYear(
            @PathVariable Integer maNV,
            @RequestParam int nam) {
        BigDecimal tongGio = baoCaoService.getTotalHoursByYear(maNV, nam);
        return ResponseEntity.ok(Map.of(
                "maNV", maNV,
                "nam", nam,
                "tongGio", tongGio));
    }

    /**
     * Lấy báo cáo mới nhất của nhân viên
     */
    @GetMapping("/nhanvien/{maNV}/latest")
    @Operation(summary = "Lấy báo cáo mới nhất của nhân viên")
    public ResponseEntity<?> getLatestBaoCao(@PathVariable Integer maNV) {
        return baoCaoService.getLatestBaoCao(maNV)
                .<ResponseEntity<?>>map(ResponseEntity::ok)
                .orElseGet(() -> ResponseEntity.status(HttpStatus.NOT_FOUND)
                        .body(Map.of("message", "Không tìm thấy báo cáo của nhân viên")));
    }

    /**
     * Lấy thống kê tổng quan
     */
    @GetMapping("/thongke")
    @Operation(summary = "Lấy thống kê tổng quan")
    public ResponseEntity<Map<String, Object>> getOverallStatistics(
            @RequestParam @DateTimeFormat(iso = DateTimeFormat.ISO.DATE) LocalDate tuNgay,
            @RequestParam @DateTimeFormat(iso = DateTimeFormat.ISO.DATE) LocalDate denNgay) {
        Map<String, Object> statistics = baoCaoService.getOverallStatistics(tuNgay, denNgay);
        return ResponseEntity.ok(statistics);
    }

    /**
     * Tính toán lương chi tiết cho nhân viên
     */
    @PostMapping("/calculate-salary")
    @Operation(summary = "Tính toán lương chi tiết cho nhân viên")
    public ResponseEntity<?> calculateSalaryDetails(@RequestBody Map<String, Object> request) {
        try {
            Integer maNV = (Integer) request.get("maNV");
            LocalDate tuNgay = LocalDate.parse((String) request.get("tuNgay"));
            LocalDate denNgay = LocalDate.parse((String) request.get("denNgay"));
            BigDecimal luongGio = new BigDecimal(request.get("luongGio").toString());
            BigDecimal luongLamThem = new BigDecimal(request.get("luongLamThem").toString());

            Map<String, Object> result = baoCaoService.calculateSalaryDetails(maNV, tuNgay, denNgay, luongGio,
                    luongLamThem);
            return ResponseEntity.ok(result);
        } catch (IllegalArgumentException e) {
            return ResponseEntity.status(HttpStatus.BAD_REQUEST)
                    .body(Map.of("message", e.getMessage()));
        } catch (Exception e) {
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR)
                    .body(Map.of("message", "Lỗi tính toán lương: " + e.getMessage()));
        }
    }

    /**
     * Validate dữ liệu chấm công
     */
    @PostMapping("/validate-chamcong")
    @Operation(summary = "Validate dữ liệu chấm công")
    public ResponseEntity<Map<String, Object>> validateChamCong(@RequestBody Map<String, Object> request) {
        try {
            Integer maNV = (Integer) request.get("maNV");
            java.time.LocalDateTime gioVao = null;
            java.time.LocalDateTime gioRa = null;

            if (request.get("gioVao") != null) {
                gioVao = java.time.LocalDateTime.parse((String) request.get("gioVao"));
            }
            if (request.get("gioRa") != null) {
                gioRa = java.time.LocalDateTime.parse((String) request.get("gioRa"));
            }

            String phuongThuc = (String) request.get("phuongThuc");

            Map<String, Object> validation = baoCaoService.validateChamCong(maNV, gioVao, gioRa, phuongThuc);
            return ResponseEntity.ok(validation);
        } catch (Exception e) {
            return ResponseEntity.status(HttpStatus.BAD_REQUEST)
                    .body(Map.of("isValid", false, "errors", List.of("Lỗi validation: " + e.getMessage())));
        }
    }

    /**
     * Lấy thống kê dashboard
     */
    @GetMapping("/dashboard-stats")
    @Operation(summary = "Lấy thống kê cho dashboard")
    public ResponseEntity<Map<String, Object>> getDashboardStatistics() {
        Map<String, Object> stats = baoCaoService.calculateDashboardStatistics();
        return ResponseEntity.ok(stats);
    }
}
