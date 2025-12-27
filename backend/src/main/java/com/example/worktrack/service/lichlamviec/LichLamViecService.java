package com.example.worktrack.service.lichlamviec;

import com.example.worktrack.model.lichlamviec.LichLamViec;
import com.example.worktrack.repository.lichlamviec.LichLamViecRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;

import java.time.LocalDate;
import java.util.List;
import java.util.Optional;

@Service
@RequiredArgsConstructor
public class LichLamViecService {

    private final LichLamViecRepository lichLamViecRepository;

    public List<LichLamViec> getAllLichLamViec() {
        return lichLamViecRepository.findAll();
    }

    public Optional<LichLamViec> getLichLamViecById(Integer maLich) {
        return lichLamViecRepository.findById(maLich);
    }

    public List<LichLamViec> getLichLamViecByNhanVien(Integer maNV) {
        return lichLamViecRepository.findByMaNVAndDaXoa(maNV, false);
    }

    public List<LichLamViec> getLichLamViecByNgay(LocalDate ngayLamViec) {
        return lichLamViecRepository.findByNgayLamViecAndDaXoa(ngayLamViec, false);
    }

    public List<LichLamViec> getLichLamViecByNhanVienAndKhoangThoiGian(
            Integer maNV, LocalDate tuNgay, LocalDate denNgay) {
        return lichLamViecRepository.findByMaNVAndNgayLamViecBetween(maNV, tuNgay, denNgay);
    }

    public List<LichLamViec> getLichLamViecByKhoangThoiGian(LocalDate tuNgay, LocalDate denNgay) {
        return lichLamViecRepository.findByNgayLamViecBetween(tuNgay, denNgay);
    }

    public List<LichLamViec> getLichLamViecByNhanVienAndNgay(Integer maNV, LocalDate ngayLamViec) {
        return lichLamViecRepository.findByMaNVAndNgayLamViec(maNV, ngayLamViec);
    }

    public LichLamViec createLichLamViec(LichLamViec lichLamViec) {
        lichLamViec.setDaXoa(false);
        return lichLamViecRepository.save(lichLamViec);
    }

    public LichLamViec updateLichLamViec(Integer maLich, LichLamViec lichLamViec) {
        Optional<LichLamViec> existingLich = lichLamViecRepository.findById(maLich);
        if (existingLich.isPresent()) {
            LichLamViec lich = existingLich.get();
            lich.setMaNV(lichLamViec.getMaNV());
            lich.setNgayLamViec(lichLamViec.getNgayLamViec());
            lich.setGioBatDau(lichLamViec.getGioBatDau());
            lich.setGioKetThuc(lichLamViec.getGioKetThuc());
            lich.setCaLamViec(lichLamViec.getCaLamViec());
            lich.setLoaiCa(lichLamViec.getLoaiCa());
            lich.setGhiChu(lichLamViec.getGhiChu());
            lich.setTrangThai(lichLamViec.getTrangThai());
            lich.setNguoiTao(lichLamViec.getNguoiTao());
            return lichLamViecRepository.save(lich);
        }
        throw new RuntimeException("Không tìm thấy lịch làm việc với mã: " + maLich);
    }

    public void deleteLichLamViec(Integer maLich) {
        Optional<LichLamViec> lich = lichLamViecRepository.findById(maLich);
        if (lich.isPresent()) {
            LichLamViec lichLamViec = lich.get();
            lichLamViec.setDaXoa(true);
            lichLamViecRepository.save(lichLamViec);
        } else {
            throw new RuntimeException("Không tìm thấy lịch làm việc với mã: " + maLich);
        }
    }

    public List<LichLamViec> getLichLamViecByTrangThai(String trangThai) {
        return lichLamViecRepository.findByTrangThaiAndDaXoa(trangThai, false);
    }
}