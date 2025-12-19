package com.example.worktrack.service.cauhinhluong.impl;

import com.example.worktrack.model.cauhinhluong.CauHinhLuong;
import com.example.worktrack.repository.cauhinhluong.CauHinhLuongRepository;
import com.example.worktrack.service.cauhinhluong.CauHinhLuongService;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;
import java.util.Optional;

@Service
@RequiredArgsConstructor
@Transactional
public class CauHinhLuongServiceImpl implements CauHinhLuongService {

    private final CauHinhLuongRepository cauHinhLuongRepository;

    @Override
    @Transactional(readOnly = true)
    public List<CauHinhLuong> getAllCauHinhLuong() {
        return cauHinhLuongRepository.findAll();
    }

    @Override
    @Transactional(readOnly = true)
    public Optional<CauHinhLuong> getCauHinhLuongById(Integer maCauHinh) {
        return cauHinhLuongRepository.findById(maCauHinh);
    }

    @Override
    @Transactional(readOnly = true)
    public Optional<CauHinhLuong> getActiveCauHinhLuong() {
        return cauHinhLuongRepository.findTopByOrderByNgayTaoDesc();
    }

    @Override
    public CauHinhLuong createCauHinhLuong(CauHinhLuong cauHinhLuong) {
        // Validate lương giờ
        if (cauHinhLuong.getLuongGio() == null
                || cauHinhLuong.getLuongGio().compareTo(java.math.BigDecimal.ZERO) <= 0) {
            throw new IllegalArgumentException("Lương giờ phải lớn hơn 0");
        }

        // Validate lương làm thêm
        if (cauHinhLuong.getLuongLamThem() != null &&
                cauHinhLuong.getLuongLamThem().compareTo(java.math.BigDecimal.ZERO) < 0) {
            throw new IllegalArgumentException("Lương làm thêm phải lớn hơn hoặc bằng 0");
        }

        // Đặt giá trị mặc định cho lương làm thêm nếu chưa có
        if (cauHinhLuong.getLuongLamThem() == null) {
            cauHinhLuong.setLuongLamThem(java.math.BigDecimal.ZERO);
        }

        return cauHinhLuongRepository.save(cauHinhLuong);
    }

    @Override
    public CauHinhLuong updateCauHinhLuong(Integer maCauHinh, CauHinhLuong cauHinhLuong) {
        CauHinhLuong existingCauHinh = cauHinhLuongRepository.findById(maCauHinh)
                .orElseThrow(() -> new IllegalArgumentException("Không tìm thấy cấu hình lương với mã: " + maCauHinh));

        // Validate lương giờ
        if (cauHinhLuong.getLuongGio() != null) {
            if (cauHinhLuong.getLuongGio().compareTo(java.math.BigDecimal.ZERO) <= 0) {
                throw new IllegalArgumentException("Lương giờ phải lớn hơn 0");
            }
            existingCauHinh.setLuongGio(cauHinhLuong.getLuongGio());
        }

        // Validate lương làm thêm
        if (cauHinhLuong.getLuongLamThem() != null) {
            if (cauHinhLuong.getLuongLamThem().compareTo(java.math.BigDecimal.ZERO) < 0) {
                throw new IllegalArgumentException("Lương làm thêm phải lớn hơn hoặc bằng 0");
            }
            existingCauHinh.setLuongLamThem(cauHinhLuong.getLuongLamThem());
        }

        return cauHinhLuongRepository.save(existingCauHinh);
    }

    @Override
    public void deleteCauHinhLuong(Integer maCauHinh) {
        CauHinhLuong cauHinhLuong = cauHinhLuongRepository.findById(maCauHinh)
                .orElseThrow(() -> new IllegalArgumentException("Không tìm thấy cấu hình lương với mã: " + maCauHinh));
        cauHinhLuong.setDaXoa(true);
        cauHinhLuongRepository.save(cauHinhLuong);
    }
}
