package com.example.worktrack.service.nhanvien.impl;

import com.example.worktrack.model.nhanvien.NhanVien;
import com.example.worktrack.repository.nhanvien.NhanVienRepository;
import com.example.worktrack.service.nhanvien.NhanVienService;

import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;
import java.util.Optional;

@Service
@RequiredArgsConstructor
@Transactional
public class NhanVienServiceImpl implements NhanVienService {

    private final NhanVienRepository nhanVienRepository;

    @Override
    @Transactional(readOnly = true)
    public List<NhanVien> getAllNhanVien() {
        return nhanVienRepository.findAll();
    }

    @Override
    @Transactional(readOnly = true)
    public Optional<NhanVien> getNhanVienById(Integer maNV) {
        return nhanVienRepository.findById(maNV);
    }

    @Override
    @Transactional(readOnly = true)
    public Optional<NhanVien> getNhanVienByEmail(String email) {
        return nhanVienRepository.findByEmail(email);
    }

    @Override
    @Transactional(readOnly = true)
    public Optional<NhanVien> getNhanVienByTheNFC(String theNFC) {
        return nhanVienRepository.findByTheNFC(theNFC);
    }

    @Override
    public NhanVien createNhanVien(NhanVien nhanVien) {
        // QUAN TRỌNG: Đặt ID = null để đảm bảo đây là entity mới
        nhanVien.setMaNV(null);

        // Kiểm tra email đã tồn tại
        if (nhanVienRepository.existsByEmail(nhanVien.getEmail())) {
            throw new IllegalArgumentException("Email đã tồn tại trong hệ thống");
        }

        // Kiểm tra thẻ NFC đã tồn tại (nếu có)
        if (nhanVien.getTheNFC() != null && !nhanVien.getTheNFC().isEmpty()) {
            if (nhanVienRepository.existsByTheNFC(nhanVien.getTheNFC())) {
                throw new IllegalArgumentException("Thẻ NFC đã được sử dụng");
            }
        }

        return nhanVienRepository.save(nhanVien);
    }

    @Override
    public NhanVien updateNhanVien(Integer maNV, NhanVien nhanVien) {
        NhanVien existingNhanVien = nhanVienRepository.findById(maNV)
                .orElseThrow(() -> new IllegalArgumentException("Không tìm thấy nhân viên với mã: " + maNV));

        // Kiểm tra email nếu thay đổi
        if (!existingNhanVien.getEmail().equals(nhanVien.getEmail())) {
            if (nhanVienRepository.existsByEmail(nhanVien.getEmail())) {
                throw new IllegalArgumentException("Email đã tồn tại trong hệ thống");
            }
            existingNhanVien.setEmail(nhanVien.getEmail());
        }

        // Kiểm tra thẻ NFC nếu thay đổi
        if (nhanVien.getTheNFC() != null &&
                !nhanVien.getTheNFC().equals(existingNhanVien.getTheNFC())) {
            if (nhanVienRepository.existsByTheNFC(nhanVien.getTheNFC())) {
                throw new IllegalArgumentException("Thẻ NFC đã được sử dụng");
            }
            existingNhanVien.setTheNFC(nhanVien.getTheNFC());
        }

        // Cập nhật các trường khác
        existingNhanVien.setHoTen(nhanVien.getHoTen());
        existingNhanVien.setDienThoai(nhanVien.getDienThoai());
        existingNhanVien.setMaVaiTro(nhanVien.getMaVaiTro());

        // Chỉ cập nhật vân tay, khuôn mặt nếu có dữ liệu mới
        if (nhanVien.getVanTay() != null) {
            existingNhanVien.setVanTay(nhanVien.getVanTay());
        }
        if (nhanVien.getKhuonMat() != null) {
            existingNhanVien.setKhuonMat(nhanVien.getKhuonMat());
        }

        return nhanVienRepository.save(existingNhanVien);
    }

    @Override
    public void deleteNhanVien(Integer maNV) {
        NhanVien nhanVien = nhanVienRepository.findById(maNV)
                .orElseThrow(() -> new IllegalArgumentException("Không tìm thấy nhân viên với mã: " + maNV));
        nhanVien.setDaXoa(true);
        nhanVienRepository.save(nhanVien);
    }

    @Override
    public void restoreNhanVien(Integer maNV) {
        NhanVien nhanVien = nhanVienRepository.findById(maNV)
                .orElseThrow(() -> new IllegalArgumentException("Không tìm thấy nhân viên với mã: " + maNV));
        nhanVien.setDaXoa(false);
        nhanVienRepository.save(nhanVien);
    }

    @Override
    public void hardDeleteNhanVien(Integer maNV) {
        if (!nhanVienRepository.existsById(maNV)) {
            throw new IllegalArgumentException("Không tìm thấy nhân viên với mã: " + maNV);
        }
        nhanVienRepository.deleteById(maNV);
    }

    @Override
    @Transactional(readOnly = true)
    public List<NhanVien> searchNhanVienByName(String keyword) {
        return nhanVienRepository.searchByHoTen(keyword);
    }

    @Override
    @Transactional(readOnly = true)
    public List<NhanVien> getNhanVienByMaVaiTro(Integer maVaiTro) {
        return nhanVienRepository.findByMaVaiTro(maVaiTro);
    }

    @Override
    @Transactional(readOnly = true)
    public boolean isEmailExists(String email) {
        return nhanVienRepository.existsByEmail(email);
    }

    @Override
    @Transactional(readOnly = true)
    public boolean isTheNFCExists(String theNFC) {
        return nhanVienRepository.existsByTheNFC(theNFC);
    }

    @Override
    @Transactional(readOnly = true)
    public boolean isTenDangNhapExists(String tenDangNhap) {
        return nhanVienRepository.existsByTenDangNhap(tenDangNhap);
    }

    @Override
    @Transactional(readOnly = true)
    public Optional<NhanVien> getNhanVienByTenDangNhap(String tenDangNhap) {
        return nhanVienRepository.findByTenDangNhap(tenDangNhap);
    }

    @Override
    public NhanVien updateVanTay(Integer maNV, byte[] vanTay) {
        NhanVien nhanVien = nhanVienRepository.findById(maNV)
                .orElseThrow(() -> new IllegalArgumentException("Không tìm thấy nhân viên với mã: " + maNV));

        nhanVien.setVanTay(vanTay);
        return nhanVienRepository.save(nhanVien);
    }

    @Override
    public NhanVien updateKhuonMat(Integer maNV, byte[] khuonMat) {
        NhanVien nhanVien = nhanVienRepository.findById(maNV)
                .orElseThrow(() -> new IllegalArgumentException("Không tìm thấy nhân viên với mã: " + maNV));

        nhanVien.setKhuonMat(khuonMat);
        return nhanVienRepository.save(nhanVien);
    }

    @Override
    public NhanVien updateTheNFC(Integer maNV, String theNFC) {
        NhanVien nhanVien = nhanVienRepository.findById(maNV)
                .orElseThrow(() -> new IllegalArgumentException("Không tìm thấy nhân viên với mã: " + maNV));

        // Kiểm tra thẻ NFC đã tồn tại
        if (nhanVienRepository.existsByTheNFC(theNFC)) {
            throw new IllegalArgumentException("Thẻ NFC đã được sử dụng");
        }

        nhanVien.setTheNFC(theNFC);
        return nhanVienRepository.save(nhanVien);
    }
}
