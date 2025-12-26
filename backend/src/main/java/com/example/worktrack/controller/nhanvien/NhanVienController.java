package com.example.worktrack.controller.nhanvien;

import com.example.worktrack.model.nhanvien.NhanVien;
import com.example.worktrack.security.JwtUtil;
import com.example.worktrack.service.nhanvien.NhanVienService;

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
@RequestMapping("/api/v1/nhanvien")
@RequiredArgsConstructor
@CrossOrigin(origins = "*")
@Tag(name = "Nhân Viên", description = "API quản lý nhân viên")
public class NhanVienController {

    private final NhanVienService nhanVienService;
    private final JwtUtil jwtUtil;

    /**
     * Lấy tất cả nhân viên
     */
    @GetMapping
    @Operation(summary = "Lấy danh sách tất cả nhân viên")
    public ResponseEntity<List<NhanVien>> getAllNhanVien() {
        List<NhanVien> nhanViens = nhanVienService.getAllNhanVien();
        return ResponseEntity.ok(nhanViens);
    }

    /**
     * Lấy nhân viên theo ID
     */
    @GetMapping("/{maNV}")
    @Operation(summary = "Lấy nhân viên theo mã")
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
    @Operation(summary = "Lấy nhân viên theo email")
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
    @Operation(summary = "Lấy nhân viên theo thẻ NFC")
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
    @Operation(summary = "Tìm kiếm nhân viên theo tên")
    public ResponseEntity<List<NhanVien>> searchNhanVien(@RequestParam String keyword) {
        List<NhanVien> nhanViens = nhanVienService.searchNhanVienByName(keyword);
        return ResponseEntity.ok(nhanViens);
    }

    /**
     * Lấy nhân viên theo mã vai trò
     */
    @GetMapping("/vaitro/{maVaiTro}")
    @Operation(summary = "Lấy nhân viên theo mã vai trò")
    public ResponseEntity<List<NhanVien>> getNhanVienByVaiTro(@PathVariable Integer maVaiTro) {
        List<NhanVien> nhanViens = nhanVienService.getNhanVienByMaVaiTro(maVaiTro);
        return ResponseEntity.ok(nhanViens);
    }

    /**
     * Tạo mới nhân viên
     */
    @PostMapping
    @Operation(summary = "Tạo mới nhân viên")
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
    @Operation(summary = "Cập nhật thông tin nhân viên")
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
    @Operation(summary = "Xóa nhân viên")
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
     * Khôi phục nhân viên
     */
    @PutMapping("/restore/{maNV}")
    @Operation(summary = "Khôi phục nhân viên")
    public ResponseEntity<?> restoreNhanVien(@PathVariable Integer maNV) {
        try {
            nhanVienService.restoreNhanVien(maNV);
            return ResponseEntity.ok(Map.of("message", "Khôi phục nhân viên thành công"));
        } catch (IllegalArgumentException e) {
            return ResponseEntity.status(HttpStatus.NOT_FOUND)
                    .body(Map.of("message", e.getMessage()));
        }
    }

    /**
     * Xóa cứng nhân viên (xóa vĩnh viễn)
     */
    @DeleteMapping("/{maNV}/hard")
    @Operation(summary = "Xóa cứng nhân viên (xóa vĩnh viễn)")
    public ResponseEntity<?> hardDeleteNhanVien(@PathVariable Integer maNV) {
        try {
            nhanVienService.hardDeleteNhanVien(maNV);
            return ResponseEntity.ok(Map.of("message", "Xóa vĩnh viễn nhân viên thành công"));
        } catch (IllegalArgumentException e) {
            return ResponseEntity.status(HttpStatus.NOT_FOUND)
                    .body(Map.of("message", e.getMessage()));
        }
    }

    /**
     * Kiểm tra email đã tồn tại
     */
    @GetMapping("/check-email/{email}")
    @Operation(summary = "Kiểm tra email đã tồn tại")
    public ResponseEntity<Map<String, Boolean>> checkEmailExists(@PathVariable String email) {
        boolean exists = nhanVienService.isEmailExists(email);
        return ResponseEntity.ok(Map.of("exists", exists));
    }

    /**
     * Kiểm tra thẻ NFC đã tồn tại
     */
    @GetMapping("/check-nfc/{theNFC}")
    @Operation(summary = "Kiểm tra thẻ NFC đã tồn tại")
    public ResponseEntity<Map<String, Boolean>> checkTheNFCExists(@PathVariable String theNFC) {
        boolean exists = nhanVienService.isTheNFCExists(theNFC);
        return ResponseEntity.ok(Map.of("exists", exists));
    }

    /**
     * Cập nhật thẻ NFC
     */
    @PatchMapping("/{maNV}/nfc")
    @Operation(summary = "Cập nhật thẻ NFC")
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
    @Operation(summary = "Cập nhật vân tay")
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
    @Operation(summary = "Cập nhật khuôn mặt")
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

    /**
     * Đăng nhập nhân viên
     */
    @PostMapping("/login")
    @Operation(summary = "Đăng nhập nhân viên")
    public ResponseEntity<?> login(@RequestBody Map<String, String> loginRequest) {
        String tenDangNhap = loginRequest.get("tenDangNhap");
        String matKhau = loginRequest.get("matKhau");

        Optional<NhanVien> nhanVienOpt = nhanVienService.getNhanVienByTenDangNhap(tenDangNhap);

        if (nhanVienOpt.isPresent()) {
            NhanVien nhanVien = nhanVienOpt.get();

            // Kiểm tra nếu nhân viên đã bị xóa
            if (nhanVien.getDaXoa()) {
                return ResponseEntity.status(HttpStatus.FORBIDDEN)
                        .body(Map.of("message", "Tài khoản đã bị vô hiệu hóa"));
            }

            if (nhanVien.getMatKhau().equals(matKhau)) {
                // Lấy tên vai trò
                String tenVaiTro = nhanVien.getVaiTro() != null ? nhanVien.getVaiTro().getTenVaiTro() : "USER";

                // Generate JWT token
                String token = jwtUtil.generateToken(
                        tenDangNhap,
                        nhanVien.getMaNV(),
                        tenVaiTro);

                return ResponseEntity.ok(Map.of(
                        "message", "Đăng nhập thành công",
                        "token", token,
                        "nhanVien", nhanVien));
            } else {
                return ResponseEntity.status(HttpStatus.UNAUTHORIZED)
                        .body(Map.of("message", "Mật khẩu không chính xác"));
            }
        }

        return ResponseEntity.status(HttpStatus.NOT_FOUND)
                .body(Map.of("message", "Tên đăng nhập không tồn tại"));
    }

    /**
     * Đổi mật khẩu nhân viên
     */
    @PutMapping("/change-password")
    @Operation(summary = "Đổi mật khẩu nhân viên")
    public ResponseEntity<?> changePassword(@RequestParam String tenDangNhap, @RequestParam String oldPassword,
            @RequestParam String newPassword) {
        Optional<NhanVien> nhanVienOpt = nhanVienService.getNhanVienByTenDangNhap(tenDangNhap);

        if (nhanVienOpt.isPresent()) {
            NhanVien nhanVien = nhanVienOpt.get();
            if (nhanVien.getMatKhau().equals(oldPassword)) {
                nhanVien.setMatKhau(newPassword);
                nhanVienService.updateNhanVien(nhanVien.getMaNV(), nhanVien);
                return ResponseEntity.ok(Map.of("message", "Đổi mật khẩu thành công"));
            } else {
                return ResponseEntity.status(HttpStatus.UNAUTHORIZED)
                        .body(Map.of("message", "Mật khẩu cũ không chính xác"));
            }
        }

        return ResponseEntity.status(HttpStatus.NOT_FOUND)
                .body(Map.of("message", "Tên đăng nhập không tồn tại"));
    }

    /**
     * Quên mật khẩu nhân viên
     */
    @PostMapping("/forgot-password")
    @Operation(summary = "Quên mật khẩu nhân viên")
    public ResponseEntity<?> forgotPassword(@RequestParam String email, @RequestParam String newPassword) {
        Optional<NhanVien> nhanVienOpt = nhanVienService.getNhanVienByEmail(email);

        if (nhanVienOpt.isPresent()) {
            NhanVien nhanVien = nhanVienOpt.get();
            nhanVien.setMatKhau(newPassword);
            nhanVienService.updateNhanVien(nhanVien.getMaNV(), nhanVien);
            return ResponseEntity.ok(Map.of("message", "Mật khẩu đã được cập nhật"));
        }

        return ResponseEntity.status(HttpStatus.NOT_FOUND)
                .body(Map.of("message", "Email không tồn tại"));
    }

    /**
     * Đăng xuất nhân viên
     */
    @PostMapping("/logout")
    @Operation(summary = "Đăng xuất nhân viên")
    public ResponseEntity<?> logout() {
        // Logic for logout can be implemented here, e.g., invalidating tokens or
        // sessions
        return ResponseEntity.ok(Map.of("message", "Đăng xuất thành công"));
    }

    /**
     * Validate thông tin nhân viên
     */
    @PostMapping("/validate")
    @Operation(summary = "Validate thông tin nhân viên")
    public ResponseEntity<Map<String, Object>> validateNhanVien(
            @RequestBody NhanVien nhanVien,
            @RequestParam(required = false) Integer existingMaNV) {
        Map<String, Object> validation = nhanVienService.validateNhanVien(nhanVien, existingMaNV);
        return ResponseEntity.ok(validation);
    }

    /**
     * Validate định dạng email
     */
    @GetMapping("/validate-email/{email}")
    @Operation(summary = "Validate định dạng email")
    public ResponseEntity<Map<String, Object>> validateEmail(@PathVariable String email) {
        boolean isValid = nhanVienService.isValidEmail(email);
        Map<String, Object> result = new java.util.HashMap<>();
        result.put("isValid", isValid);
        if (!isValid) {
            result.put("message", "Định dạng email không hợp lệ");
        }
        return ResponseEntity.ok(result);
    }

    /**
     * Validate số điện thoại
     */
    @GetMapping("/validate-phone/{phoneNumber}")
    @Operation(summary = "Validate số điện thoại")
    public ResponseEntity<Map<String, Object>> validatePhoneNumber(@PathVariable String phoneNumber) {
        boolean isValid = nhanVienService.isValidPhoneNumber(phoneNumber);
        Map<String, Object> result = new java.util.HashMap<>();
        result.put("isValid", isValid);
        if (!isValid) {
            result.put("message", "Số điện thoại không hợp lệ (chỉ chấp nhận 10-11 chữ số)");
        }
        return ResponseEntity.ok(result);
    }
}
