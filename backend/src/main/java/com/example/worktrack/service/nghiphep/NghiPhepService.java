package com.example.worktrack.service.nghiphep;

import com.example.worktrack.model.nghiphep.NghiPhep;
import com.example.worktrack.repository.nghiphep.NghiPhepRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;

import java.time.LocalDate;
import java.time.LocalDateTime;
import java.time.temporal.ChronoUnit;
import java.util.List;
import java.util.Optional;

@Service
@RequiredArgsConstructor
public class NghiPhepService {

    private final NghiPhepRepository nghiPhepRepository;

    public List<NghiPhep> getAllNghiPhep() {
        return nghiPhepRepository.findAll();
    }

    public Optional<NghiPhep> getNghiPhepById(Integer maNghiPhep) {
        return nghiPhepRepository.findById(maNghiPhep);
    }

    public List<NghiPhep> getNghiPhepByNhanVien(Integer maNV) {
        return nghiPhepRepository.findByMaNVAndDaXoa(maNV, false);
    }

    public List<NghiPhep> getNghiPhepByTrangThai(String trangThai) {
        return nghiPhepRepository.findByTrangThaiAndDaXoa(trangThai, false);
    }

    public List<NghiPhep> getNghiPhepByNhanVienAndKhoangThoiGian(
            Integer maNV, LocalDate tuNgay, LocalDate denNgay) {
        return nghiPhepRepository.findByMaNVAndTuNgayBetween(maNV, tuNgay, denNgay);
    }

    public List<NghiPhep> getNghiPhepByKhoangThoiGian(LocalDate tuNgay, LocalDate denNgay) {
        return nghiPhepRepository.findByTuNgayBetween(tuNgay, denNgay);
    }

    public List<NghiPhep> getNghiPhepByNhanVienAndLoai(Integer maNV, String loaiNghi) {
        return nghiPhepRepository.findByMaNVAndLoaiNghi(maNV, loaiNghi);
    }

    public List<NghiPhep> getNghiPhepChoDuyet(Integer nguoiDuyet) {
        return nghiPhepRepository.findByNguoiDuyetAndTrangThai(nguoiDuyet, "CHO_DUYET");
    }

    public NghiPhep createNghiPhep(NghiPhep nghiPhep) {
        nghiPhep.setDaXoa(false);
        nghiPhep.setTrangThai("CHO_DUYET");

        // Tính số ngày nghỉ
        long soNgay = ChronoUnit.DAYS.between(nghiPhep.getTuNgay(), nghiPhep.getDenNgay()) + 1;
        nghiPhep.setSoNgay((int) soNgay);

        return nghiPhepRepository.save(nghiPhep);
    }

    public NghiPhep updateNghiPhep(Integer maNghiPhep, NghiPhep nghiPhep) {
        Optional<NghiPhep> existingNghiPhep = nghiPhepRepository.findById(maNghiPhep);
        if (existingNghiPhep.isPresent()) {
            NghiPhep nghiPhepEntity = existingNghiPhep.get();
            nghiPhepEntity.setMaNV(nghiPhep.getMaNV());
            nghiPhepEntity.setTuNgay(nghiPhep.getTuNgay());
            nghiPhepEntity.setDenNgay(nghiPhep.getDenNgay());
            nghiPhepEntity.setLoaiNghi(nghiPhep.getLoaiNghi());
            nghiPhepEntity.setLyDo(nghiPhep.getLyDo());

            // Tính lại số ngày
            long soNgay = ChronoUnit.DAYS.between(nghiPhep.getTuNgay(), nghiPhep.getDenNgay()) + 1;
            nghiPhepEntity.setSoNgay((int) soNgay);

            return nghiPhepRepository.save(nghiPhepEntity);
        }
        throw new RuntimeException("Không tìm thấy đơn nghỉ phép với mã: " + maNghiPhep);
    }

    public void deleteNghiPhep(Integer maNghiPhep) {
        Optional<NghiPhep> nghiPhep = nghiPhepRepository.findById(maNghiPhep);
        if (nghiPhep.isPresent()) {
            NghiPhep nghiPhepEntity = nghiPhep.get();
            nghiPhepEntity.setDaXoa(true);
            nghiPhepRepository.save(nghiPhepEntity);
        } else {
            throw new RuntimeException("Không tìm thấy đơn nghỉ phép với mã: " + maNghiPhep);
        }
    }

    public NghiPhep duyetNghiPhep(Integer maNghiPhep, Integer nguoiDuyet, boolean duyet, String ghiChu) {
        Optional<NghiPhep> existingNghiPhep = nghiPhepRepository.findById(maNghiPhep);
        if (existingNghiPhep.isPresent()) {
            NghiPhep nghiPhep = existingNghiPhep.get();
            nghiPhep.setNguoiDuyet(nguoiDuyet);
            nghiPhep.setNgayDuyet(LocalDateTime.now());
            nghiPhep.setTrangThai(duyet ? "DA_DUYET" : "TU_CHOI");
            nghiPhep.setGhiChuDuyet(ghiChu);
            return nghiPhepRepository.save(nghiPhep);
        }
        throw new RuntimeException("Không tìm thấy đơn nghỉ phép với mã: " + maNghiPhep);
    }
}