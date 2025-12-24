package com.example.worktrack.controller.chamcong;

import com.example.worktrack.model.chamcong.ChamCong;
import com.example.worktrack.service.chamcong.ChamCongService;

import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.tags.Tag;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.format.annotation.DateTimeFormat;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.time.LocalDate;
import java.time.LocalDateTime;
import java.util.List;
import java.util.Map;
import java.util.Optional;

@RestController
@RequestMapping("/api/v1/chamcong")
@RequiredArgsConstructor
@CrossOrigin(origins = "*")
@Tag(name = "Chấm Công", description = "API quản lý chấm công")
public class ChamCongController {

    private final ChamCongService chamCongService;

    /**
     * Lấy tất cả bản ghi chấm công
     */
    @GetMapping
    @Operation(summary = "Lấy tất cả bản ghi chấm công")
    public ResponseEntity<List<ChamCong>> getAllChamCong() {
        List<ChamCong> chamCongs = chamCongService.getAllChamCong();
        return ResponseEntity.ok(chamCongs);
    }

    /**
     * Lấy bản ghi chấm công theo ID
     */
    @GetMapping("/{maChamCong}")
    @Operation(summary = "Lấy bản ghi chấm công theo mã")
    public ResponseEntity<?> getChamCongById(@PathVariable Integer maChamCong) {
        // 1. Lấy dữ liệu từ Service (Trả về Optional)
        Optional<ChamCong> chamCongOpt = chamCongService.getChamCongById(maChamCong);

        // 2. Kiểm tra nếu có dữ liệu
        if (chamCongOpt.isPresent()) {
            return ResponseEntity.ok(chamCongOpt.get());
        }

        // 3. Nếu không tìm thấy, trả về lỗi 404 và thông báo
        Map<String, String> error = Map.of(
                "message", "Không tìm thấy bản ghi chấm công với mã: " + maChamCong);

        return ResponseEntity.status(HttpStatus.NOT_FOUND).body(error);
    }

    /**
     * Lấy bản ghi chấm công của nhân viên
     */
    @GetMapping("/nhanvien/{maNV}")
    @Operation(summary = "Lấy bản ghi chấm công của nhân viên")
    public ResponseEntity<List<ChamCong>> getChamCongByNhanVien(@PathVariable Integer maNV) {
        List<ChamCong> chamCongs = chamCongService.getChamCongByMaNV(maNV);
        return ResponseEntity.ok(chamCongs);
    }

    /**
     * Lấy bản ghi chấm công của nhân viên theo khoảng thời gian
     */
    @GetMapping("/nhanvien/{maNV}/range")
    @Operation(summary = "Lấy bản ghi chấm công của nhân viên theo khoảng thời gian")
    public ResponseEntity<List<ChamCong>> getChamCongByNhanVienAndDateRange(
            @PathVariable Integer maNV,
            @RequestParam @DateTimeFormat(iso = DateTimeFormat.ISO.DATE) LocalDate startDate,
            @RequestParam @DateTimeFormat(iso = DateTimeFormat.ISO.DATE) LocalDate endDate) {
        LocalDateTime tuNgay = startDate.atStartOfDay();
        LocalDateTime denNgay = endDate.atTime(23, 59, 59);
        List<ChamCong> chamCongs = chamCongService.getChamCongByMaNVAndDateRange(maNV, tuNgay, denNgay);
        return ResponseEntity.ok(chamCongs);
    }

    /**
     * Lấy bản ghi chấm công theo khoảng thời gian
     */
    @GetMapping("/daterange")
    @Operation(summary = "Lấy bản ghi chấm công theo khoảng thời gian")
    public ResponseEntity<List<ChamCong>> getChamCongByDateRange(
            @RequestParam @DateTimeFormat(iso = DateTimeFormat.ISO.DATE_TIME) LocalDateTime tuNgay,
            @RequestParam @DateTimeFormat(iso = DateTimeFormat.ISO.DATE_TIME) LocalDateTime denNgay) {
        List<ChamCong> chamCongs = chamCongService.getChamCongByDateRange(tuNgay, denNgay);
        return ResponseEntity.ok(chamCongs);
    }

    /**
     * Check-in (Chấm công vào)
     */
    @PostMapping("/checkin")
    @Operation(summary = "Check-in (Chấm công vào)")
    public ResponseEntity<?> checkIn(@RequestBody Map<String, Object> request) {
        try {
            Integer maNV = (Integer) request.get("maNV");
            String phuongThuc = (String) request.get("phuongThuc");
            String ghiChu = (String) request.get("ghiChu");

            ChamCong chamCong = chamCongService.checkIn(maNV, phuongThuc, ghiChu);
            return ResponseEntity.status(HttpStatus.CREATED).body(chamCong);
        } catch (IllegalArgumentException | IllegalStateException e) {
            return ResponseEntity.status(HttpStatus.BAD_REQUEST)
                    .body(Map.of("message", e.getMessage()));
        }
    }

    /**
     * Check-out (Chấm công ra)
     */
    @PostMapping("/checkout")
    @Operation(summary = "Check-out (Chấm công ra)")
    public ResponseEntity<?> checkOut(@RequestBody Map<String, Object> request) {
        try {
            Integer maNV = (Integer) request.get("maNV");
            String ghiChu = (String) request.get("ghiChu");

            ChamCong chamCong = chamCongService.checkOut(maNV, ghiChu);
            return ResponseEntity.ok(chamCong);
        } catch (IllegalStateException | IllegalArgumentException e) {
            return ResponseEntity.status(HttpStatus.BAD_REQUEST)
                    .body(Map.of("message", e.getMessage()));
        }
    }

    /**
     * Tạo bản ghi chấm công thủ công
     */
    @PostMapping
    @Operation(summary = "Tạo bản ghi chấm công thủ công")
    public ResponseEntity<?> createChamCong(@Valid @RequestBody ChamCong chamCong) {
        try {
            ChamCong createdChamCong = chamCongService.createChamCong(chamCong);
            return ResponseEntity.status(HttpStatus.CREATED).body(createdChamCong);
        } catch (IllegalArgumentException e) {
            return ResponseEntity.status(HttpStatus.BAD_REQUEST)
                    .body(Map.of("message", e.getMessage()));
        }
    }

    /**
     * Cập nhật bản ghi chấm công
     */
    @PutMapping("/{maChamCong}")
    @Operation(summary = "Cập nhật bản ghi chấm công")
    public ResponseEntity<?> updateChamCong(
            @PathVariable Integer maChamCong,
            @Valid @RequestBody ChamCong chamCong) {
        try {
            ChamCong updatedChamCong = chamCongService.updateChamCong(maChamCong, chamCong);
            return ResponseEntity.ok(updatedChamCong);
        } catch (IllegalArgumentException e) {
            return ResponseEntity.status(HttpStatus.BAD_REQUEST)
                    .body(Map.of("message", e.getMessage()));
        }
    }

    /**
     * Xóa bản ghi chấm công
     */
    @DeleteMapping("/{maChamCong}")
    @Operation(summary = "Xóa bản ghi chấm công")
    public ResponseEntity<?> deleteChamCong(@PathVariable Integer maChamCong) {
        try {
            chamCongService.deleteChamCong(maChamCong);
            return ResponseEntity.ok(Map.of("message", "Xóa bản ghi chấm công thành công"));
        } catch (IllegalArgumentException e) {
            return ResponseEntity.status(HttpStatus.NOT_FOUND)
                    .body(Map.of("message", e.getMessage()));
        }
    }

    /**
     * Lấy trạng thái chấm công hiện tại của nhân viên
     */
    @GetMapping("/nhanvien/{maNV}/status")
    @Operation(summary = "Lấy trạng thái chấm công hiện tại của nhân viên")
    public ResponseEntity<?> getEmployeeStatus(@PathVariable Integer maNV) {
        return chamCongService.getActiveChamCong(maNV)
                .map(chamCong -> ResponseEntity.ok(Map.of(
                        "status", "checked-in",
                        "chamCong", chamCong)))
                .orElse(ResponseEntity.ok(Map.of("status", "not-checked-in")));
    }

    /**
     * Lấy bản ghi chấm công mới nhất của nhân viên
     */
    @GetMapping("/nhanvien/{maNV}/latest")
    @Operation(summary = "Lấy bản ghi chấm công mới nhất của nhân viên")
    public ResponseEntity<?> getLatestChamCong(@PathVariable Integer maNV) {
        // 1. Gọi Service lấy bản ghi mới nhất (trả về Optional)
        Optional<ChamCong> latestOpt = chamCongService.getLatestChamCong(maNV);

        // 2. Kiểm tra dữ liệu có tồn tại không
        if (latestOpt.isPresent()) {
            // Trả về 200 OK kèm dữ liệu
            return ResponseEntity.ok(latestOpt.get());
        }

        // 3. Xử lý khi không có dữ liệu (404 Not Found)
        Map<String, String> errorResponse = Map.of(
                "message", "Không tìm thấy bản ghi chấm công cho nhân viên mã: " + maNV);

        return ResponseEntity.status(HttpStatus.NOT_FOUND).body(errorResponse);
    }

    /**
     * Lấy thống kê chấm công theo ngày
     */
    @GetMapping("/thongke/ngay")
    @Operation(summary = "Lấy thống kê chấm công theo ngày")
    public ResponseEntity<Map<String, Object>> getStatisticsByDate(
            @RequestParam @DateTimeFormat(iso = DateTimeFormat.ISO.DATE) LocalDate ngay) {
        Map<String, Object> statistics = chamCongService.getStatisticsByDate(ngay);
        return ResponseEntity.ok(statistics);
    }

    /**
     * Lấy thống kê chấm công hôm nay
     */
    @GetMapping("/thongke/homnay")
    @Operation(summary = "Lấy thống kê chấm công hôm nay")
    public ResponseEntity<Map<String, Object>> getTodayStatistics() {
        Map<String, Object> statistics = chamCongService.getStatisticsByDate(LocalDate.now());
        return ResponseEntity.ok(statistics);
    }

    /**
     * Lấy thống kê chấm công của nhân viên theo tháng
     */
    @GetMapping("/thongke/nhanvien/{maNV}/thang")
    @Operation(summary = "Lấy thống kê chấm công của nhân viên theo tháng")
    public ResponseEntity<Map<String, Object>> getEmployeeStatisticsByMonth(
            @PathVariable Integer maNV,
            @RequestParam int nam,
            @RequestParam int thang) {
        Map<String, Object> statistics = chamCongService.getEmployeeStatisticsByMonth(maNV, nam, thang);
        return ResponseEntity.ok(statistics);
    }

    /**
     * Lấy danh sách nhân viên đã chấm công hôm nay
     */
    @GetMapping("/homnay/nhanvien")
    @Operation(summary = "Lấy danh sách nhân viên đã chấm công hôm nay")
    public ResponseEntity<List<Integer>> getEmployeesCheckedInToday() {
        List<Integer> maNVs = chamCongService.getEmployeesCheckedInToday();
        return ResponseEntity.ok(maNVs);
    }
}
