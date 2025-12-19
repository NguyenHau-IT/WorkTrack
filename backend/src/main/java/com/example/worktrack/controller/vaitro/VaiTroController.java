package com.example.worktrack.controller.vaitro;

import com.example.worktrack.model.vaitro.VaiTro;
import com.example.worktrack.service.vaitro.VaiTroService;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.tags.Tag;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;
import java.util.Map;

@RestController
@RequestMapping("/api/v1/vaitro")
@RequiredArgsConstructor
@CrossOrigin(origins = "*")
@Tag(name = "Vai Trò", description = "API quản lý vai trò của nhân viên")
public class VaiTroController {

    private final VaiTroService vaiTroService;

    /**
     * Lấy tất cả vai trò
     */
    @GetMapping
    @Operation(summary = "Lấy danh sách tất cả vai trò")
    public ResponseEntity<List<VaiTro>> getAllVaiTro() {
        List<VaiTro> vaiTros = vaiTroService.getAllVaiTro();
        return ResponseEntity.ok(vaiTros);
    }

    /**
     * Lấy tất cả vai trò chưa bị xóa
     */
    @GetMapping("/chua-xoa")
    @Operation(summary = "Lấy danh sách tất cả vai trò chưa bị xóa")
    public ResponseEntity<List<VaiTro>> getAllVaiTroChuaXoa() {
        List<VaiTro> vaiTros = vaiTroService.getAllVaiTroChuaXoa();
        return ResponseEntity.ok(vaiTros);
    }

    /**
     * Lấy vai trò theo ID
     */
    @GetMapping("/{maVaiTro}")
    @Operation(summary = "Lấy vai trò theo mã")
    public ResponseEntity<?> getVaiTroById(@PathVariable Integer maVaiTro) {
        return vaiTroService.getVaiTroById(maVaiTro)
                .<ResponseEntity<?>>map(ResponseEntity::ok)
                .orElseGet(() -> ResponseEntity.status(HttpStatus.NOT_FOUND)
                        .body(Map.of("message", "Không tìm thấy vai trò với mã: " + maVaiTro)));
    }

    /**
     * Lấy vai trò theo tên
     */
    @GetMapping("/ten/{tenVaiTro}")
    @Operation(summary = "Lấy vai trò theo tên")
    public ResponseEntity<?> getVaiTroByTen(@PathVariable String tenVaiTro) {
        return vaiTroService.getVaiTroByTen(tenVaiTro)
                .<ResponseEntity<?>>map(ResponseEntity::ok)
                .orElseGet(() -> ResponseEntity.status(HttpStatus.NOT_FOUND)
                        .body(Map.of("message", "Không tìm thấy vai trò: " + tenVaiTro)));
    }

    /**
     * Tạo vai trò mới
     */
    @PostMapping
    @Operation(summary = "Tạo vai trò mới")
    public ResponseEntity<?> createVaiTro(@Valid @RequestBody VaiTro vaiTro) {
        try {
            VaiTro createdVaiTro = vaiTroService.createVaiTro(vaiTro);
            return ResponseEntity.status(HttpStatus.CREATED).body(createdVaiTro);
        } catch (IllegalArgumentException e) {
            return ResponseEntity.status(HttpStatus.BAD_REQUEST)
                    .body(Map.of("message", e.getMessage()));
        }
    }

    /**
     * Cập nhật vai trò
     */
    @PutMapping("/{maVaiTro}")
    @Operation(summary = "Cập nhật vai trò")
    public ResponseEntity<?> updateVaiTro(
            @PathVariable Integer maVaiTro,
            @Valid @RequestBody VaiTro vaiTro) {
        try {
            VaiTro updatedVaiTro = vaiTroService.updateVaiTro(maVaiTro, vaiTro);
            return ResponseEntity.ok(updatedVaiTro);
        } catch (IllegalArgumentException e) {
            return ResponseEntity.status(HttpStatus.BAD_REQUEST)
                    .body(Map.of("message", e.getMessage()));
        }
    }

    /**
     * Xóa vai trò
     */
    @DeleteMapping("/{maVaiTro}")
    @Operation(summary = "Xóa vai trò")
    public ResponseEntity<?> deleteVaiTro(@PathVariable Integer maVaiTro) {
        try {
            vaiTroService.deleteVaiTro(maVaiTro);
            return ResponseEntity.ok(Map.of("message", "Xóa vai trò thành công"));
        } catch (IllegalArgumentException e) {
            return ResponseEntity.status(HttpStatus.NOT_FOUND)
                    .body(Map.of("message", e.getMessage()));
        }
    }

    /**
     * Khôi phục vai trò
     */
    @PutMapping("/restore/{maVaiTro}")
    @Operation(summary = "Khôi phục vai trò")
    public ResponseEntity<?> restoreVaiTro(@PathVariable Integer maVaiTro) {
        try {
            vaiTroService.restoreVaiTro(maVaiTro);
            return ResponseEntity.ok(Map.of("message", "Khôi phục vai trò thành công"));
        } catch (IllegalArgumentException e) {
            return ResponseEntity.status(HttpStatus.NOT_FOUND)
                    .body(Map.of("message", e.getMessage()));
        }
    }

    /**
     * Kiểm tra vai trò đã tồn tại
     */
    @GetMapping("/check/{tenVaiTro}")
    @Operation(summary = "Kiểm tra vai trò đã tồn tại")
    public ResponseEntity<Map<String, Boolean>> checkVaiTroExists(@PathVariable String tenVaiTro) {
        boolean exists = vaiTroService.isVaiTroExists(tenVaiTro);
        return ResponseEntity.ok(Map.of("exists", exists));
    }
}
