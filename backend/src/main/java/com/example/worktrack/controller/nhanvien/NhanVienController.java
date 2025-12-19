package com.example.worktrack.controller.nhanvien;

import com.example.worktrack.model.nhanvien.NhanVien;
import com.example.worktrack.service.nhanvien.NhanVienService;

import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;
import java.util.Map;
import java.util.Optional;

@RestController
@RequestMapping("/api/v1/nhanvien")
@RequiredArgsConstructor
@CrossOrigin(origins = "*")
public class NhanVienController {

    private final NhanVienService nhanVienService;

    /**
     * Lấy tất cả nhân viên
     */
    @GetMapping
    public ResponseEntity<List<NhanVien>> getAllNhanVien() {
        List<NhanVien> nhanViens = nhanVienService.getAllNhanVien();
        return ResponseEntity.ok(nhanViens);
    }

    /**
     * Lấy nhân viên theo ID
     */
    @GetMapping("/{maNV}")
    public ResponseEntity<?> getNhanVienById(@PathVariable Integer maNV) {
        Optional<NhanVien> nhanVienOpt = nhanVienService.getNhanVienById(maNV);

        if (nhanVienOpt.isPresent()) {
            return ResponseEntity.ok(nhanVienOpt.get());
        }

        return ResponseEntity.status(HttpStatus.NOT_FOUND)
                .body(Map.of("message", "Không tìm thấy nhân viên với mã: " + maNV));
    }

    /**
     * Lấy nhân viên theo email
     */
    @GetMapping("/email/{email}")
    public ResponseEntity<?> getNhanVienByEmail(@PathVariable String email) {
        Optional<NhanVien> nhanVienOpt = nhanVienService.getNhanVienByEmail(email);

        if (nhanVienOpt.isPresent()) {
            return ResponseEntity.ok(nhanVienOpt.get());
        }

        return ResponseEntity.status(HttpStatus.NOT_FOUND)
                .body(Map.of("message", "Không tìm thấy nhân viên với email: " + email));
    }

    /**
     * Lấy nhân viên theo thẻ NFC
     */
    @GetMapping("/nfc/{theNFC}")
    public ResponseEntity<?> getNhanVienByTheNFC(@PathVariable String theNFC) {
        Optional<NhanVien> nhanVienOpt = nhanVienService.getNhanVienByTheNFC(theNFC);

        if (nhanVienOpt.isPresent()) {
            return ResponseEntity.ok(nhanVienOpt.get());
        }

        return ResponseEntity.status(HttpStatus.NOT_FOUND)
                .body(Map.of("message", "Không tìm thấy nhân viên với thẻ NFC: " + theNFC));
    }

    /**
     * Tìm kiếm nhân viên theo tên
     */
    @GetMapping("/search")
    public ResponseEntity<List<NhanVien>> searchNhanVien(@RequestParam String keyword) {
        List<NhanVien> nhanViens = nhanVienService.searchNhanVienByName(keyword);
        return ResponseEntity.ok(nhanViens);
    }

    /**
     * Lấy nhân viên theo mã vai trò
     */
    @GetMapping("/vaitro/{maVaiTro}")
    public ResponseEntity<List<NhanVien>> getNhanVienByVaiTro(@PathVariable Integer maVaiTro) {
        List<NhanVien> nhanViens = nhanVienService.getNhanVienByMaVaiTro(maVaiTro);
        return ResponseEntity.ok(nhanViens);
    }

    /**
     * Tạo mới nhân viên
     */
    @PostMapping
    public ResponseEntity<?> createNhanVien(@Valid @RequestBody NhanVien nhanVien) {
        try {
            NhanVien createdNhanVien = nhanVienService.createNhanVien(nhanVien);
            return ResponseEntity.status(HttpStatus.CREATED).body(createdNhanVien);
        } catch (IllegalArgumentException e) {
            return ResponseEntity.status(HttpStatus.BAD_REQUEST)
                    .body(Map.of("message", e.getMessage()));
        }
    }

    /**
     * Cập nhật thông tin nhân viên
     */
    @PutMapping("/{maNV}")
    public ResponseEntity<?> updateNhanVien(
            @PathVariable Integer maNV,
            @Valid @RequestBody NhanVien nhanVien) {
        try {
            NhanVien updatedNhanVien = nhanVienService.updateNhanVien(maNV, nhanVien);
            return ResponseEntity.ok(updatedNhanVien);
        } catch (IllegalArgumentException e) {
            return ResponseEntity.status(HttpStatus.BAD_REQUEST)
                    .body(Map.of("message", e.getMessage()));
        }
    }

    /**
     * Xóa nhân viên
     */
    @DeleteMapping("/{maNV}")
    public ResponseEntity<?> deleteNhanVien(@PathVariable Integer maNV) {
        try {
            nhanVienService.deleteNhanVien(maNV);
            return ResponseEntity.ok(Map.of("message", "Xóa nhân viên thành công"));
        } catch (IllegalArgumentException e) {
            return ResponseEntity.status(HttpStatus.NOT_FOUND)
                    .body(Map.of("message", e.getMessage()));
        }
    }

    /**
     * Kiểm tra email đã tồn tại
     */
    @GetMapping("/check-email/{email}")
    public ResponseEntity<Map<String, Boolean>> checkEmailExists(@PathVariable String email) {
        boolean exists = nhanVienService.isEmailExists(email);
        return ResponseEntity.ok(Map.of("exists", exists));
    }

    /**
     * Kiểm tra thẻ NFC đã tồn tại
     */
    @GetMapping("/check-nfc/{theNFC}")
    public ResponseEntity<Map<String, Boolean>> checkTheNFCExists(@PathVariable String theNFC) {
        boolean exists = nhanVienService.isTheNFCExists(theNFC);
        return ResponseEntity.ok(Map.of("exists", exists));
    }

    /**
     * Cập nhật thẻ NFC
     */
    @PatchMapping("/{maNV}/nfc")
    public ResponseEntity<?> updateTheNFC(
            @PathVariable Integer maNV,
            @RequestBody Map<String, String> request) {
        try {
            String theNFC = request.get("theNFC");
            NhanVien updatedNhanVien = nhanVienService.updateTheNFC(maNV, theNFC);
            return ResponseEntity.ok(updatedNhanVien);
        } catch (IllegalArgumentException e) {
            return ResponseEntity.status(HttpStatus.BAD_REQUEST)
                    .body(Map.of("message", e.getMessage()));
        }
    }

    /**
     * Cập nhật vân tay (Base64)
     * Endpoint này nhận dữ liệu vân tay dưới dạng Base64 string
     */
    @PatchMapping("/{maNV}/vantay")
    public ResponseEntity<?> updateVanTay(
            @PathVariable Integer maNV,
            @RequestBody Map<String, String> request) {
        try {
            String vanTayBase64 = request.get("vanTay");
            byte[] vanTay = java.util.Base64.getDecoder().decode(vanTayBase64);
            NhanVien updatedNhanVien = nhanVienService.updateVanTay(maNV, vanTay);
            return ResponseEntity.ok(updatedNhanVien);
        } catch (IllegalArgumentException e) {
            return ResponseEntity.status(HttpStatus.BAD_REQUEST)
                    .body(Map.of("message", e.getMessage()));
        }
    }

    /**
     * Cập nhật khuôn mặt (Base64)
     * Endpoint này nhận dữ liệu khuôn mặt dưới dạng Base64 string
     */
    @PatchMapping("/{maNV}/khuonmat")
    public ResponseEntity<?> updateKhuonMat(
            @PathVariable Integer maNV,
            @RequestBody Map<String, String> request) {
        try {
            String khuonMatBase64 = request.get("khuonMat");
            byte[] khuonMat = java.util.Base64.getDecoder().decode(khuonMatBase64);
            NhanVien updatedNhanVien = nhanVienService.updateKhuonMat(maNV, khuonMat);
            return ResponseEntity.ok(updatedNhanVien);
        } catch (IllegalArgumentException e) {
            return ResponseEntity.status(HttpStatus.BAD_REQUEST)
                    .body(Map.of("message", e.getMessage()));
        }
    }
}
