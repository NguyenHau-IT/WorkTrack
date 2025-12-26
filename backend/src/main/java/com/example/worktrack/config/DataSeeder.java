package com.example.worktrack.config;

import com.example.worktrack.model.nhanvien.NhanVien;
import com.example.worktrack.model.vaitro.VaiTro;
import com.example.worktrack.repository.nhanvien.NhanVienRepository;
import com.example.worktrack.repository.vaitro.VaiTroRepository;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.boot.CommandLineRunner;
import org.springframework.stereotype.Component;

@Component
@RequiredArgsConstructor
@Slf4j
public class DataSeeder implements CommandLineRunner {

    private final VaiTroRepository vaiTroRepository;
    private final NhanVienRepository nhanVienRepository;

    @Override
    public void run(String... args) throws Exception {
        seedVaiTro();
        seedNhanVien();
    }

    private void seedVaiTro() {
        // Kiểm tra nếu đã có dữ liệu thì không seed nữa
        if (vaiTroRepository.count() > 0) {
            log.info("Vai trò đã tồn tại, bỏ qua seed data");
            return;
        }

        // Tạo vai trò Admin
        VaiTro admin = new VaiTro();
        admin.setTenVaiTro("Admin");
        admin.setMoTa("Quản trị viên hệ thống, có toàn quyền truy cập và quản lý");
        admin.setDaXoa(false);
        vaiTroRepository.save(admin);
        log.info("✓ Đã tạo vai trò: Admin");

        // Tạo vai trò Nhân viên
        VaiTro nhanVien = new VaiTro();
        nhanVien.setTenVaiTro("Nhân viên");
        nhanVien.setMoTa("Nhân viên thường, có quyền truy cập hạn chế");
        nhanVien.setDaXoa(false);
        vaiTroRepository.save(nhanVien);
        log.info("✓ Đã tạo vai trò: Nhân viên");

        // Tạo vai trò Quản lý
        VaiTro quanly = new VaiTro();
        quanly.setTenVaiTro("Quản lý");
        quanly.setMoTa("Quản lý cấp trung, có quyền truy cập và quản lý nhân viên");
        quanly.setDaXoa(false);
        vaiTroRepository.save(quanly);
        log.info("✓ Đã tạo vai trò: Quản lý");
    }

    private void seedNhanVien() {
        // Kiểm tra nếu đã có dữ liệu thì không seed nữa
        if (nhanVienRepository.count() > 0) {
            log.info("Nhân viên đã tồn tại, bỏ qua seed data");
            return;
        }

        // Lấy vai trò Admin
        VaiTro adminRole = vaiTroRepository.findByTenVaiTro("Admin")
                .orElseThrow(() -> new RuntimeException("Không tìm thấy vai trò Admin"));

        VaiTro nhanVienRole = vaiTroRepository.findByTenVaiTro("Nhân viên")
                .orElseThrow(() -> new RuntimeException("Không tìm thấy vai trò Nhân viên"));

        VaiTro quanlyRole = vaiTroRepository.findByTenVaiTro("Quản lý")
                .orElseThrow(() -> new RuntimeException("Không tìm thấy vai trò Quản lý"));
        // Tạo nhân viên Admin mặc định
        NhanVien admin = new NhanVien();
        admin.setHoTen("Administrator");
        admin.setEmail("admin@worktrack.com");
        admin.setDienThoai("0123456789");
        admin.setMaVaiTro(adminRole.getMaVaiTro());
        admin.setTenDangNhap("admin");
        admin.setMatKhau("admin123"); // Trong thực tế nên mã hóa mật khẩu
        admin.setDaXoa(false);
        nhanVienRepository.save(admin);
        log.info("✓ Đã tạo nhân viên Admin:");
        log.info("  - Tên đăng nhập: admin");
        log.info("  - Mật khẩu: admin123");
        log.info("  - Email: admin@worktrack.com");
        // Tạo nhân viên thường mặc định
        NhanVien nhanVien = new NhanVien();
        nhanVien.setHoTen("Nhan Vien");
        nhanVien.setEmail("nhanvien@worktrack.com");
        nhanVien.setDienThoai("0987654321");
        nhanVien.setMaVaiTro(nhanVienRole.getMaVaiTro());
        nhanVien.setTenDangNhap("nhanvien");
        nhanVien.setMatKhau("nhanvien123"); // Trong thực tế nên mã hóa mật khẩu
        nhanVien.setDaXoa(false);
        nhanVienRepository.save(nhanVien);
        log.info("✓ Đã tạo nhân viên Thường:");
        log.info("  - Tên đăng nhập: nhanvien");
        log.info("  - Mật khẩu: nhanvien123");
        log.info("  - Email: nhanvien@worktrack.com");
        // Tạo nhân viên Quản lý mặc định
        NhanVien quanly = new NhanVien();
        quanly.setHoTen("Quan Ly");
        quanly.setEmail("quanly@worktrack.com");
        quanly.setDienThoai("0112233445");
        quanly.setMaVaiTro(quanlyRole.getMaVaiTro());
        quanly.setTenDangNhap("quanly");
        quanly.setMatKhau("quanly123"); // Trong thực tế nên mã hóa mật khẩu
        quanly.setDaXoa(false);
        nhanVienRepository.save(quanly);
        log.info("✓ Đã tạo nhân viên Quản lý:");
        log.info("  - Tên đăng nhập: quanly");
        log.info("  - Mật khẩu: quanly123");
        log.info("  - Email: quanly@worktrack.com");
    }
}