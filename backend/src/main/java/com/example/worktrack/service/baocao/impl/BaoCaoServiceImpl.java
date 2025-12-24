package com.example.worktrack.service.baocao.impl;

import com.example.worktrack.model.baocao.BaoCao;
import com.example.worktrack.model.chamcong.ChamCong;
import com.example.worktrack.repository.baocao.BaoCaoRepository;
import com.example.worktrack.repository.chamcong.ChamCongRepository;
import com.example.worktrack.repository.nhanvien.NhanVienRepository;
import com.example.worktrack.service.baocao.BaoCaoService;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.math.BigDecimal;
import java.math.RoundingMode;
import java.time.LocalDate;
import java.time.LocalDateTime;
import java.time.LocalTime;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.Optional;

@Service
@RequiredArgsConstructor
@Transactional
public class BaoCaoServiceImpl implements BaoCaoService {

    private final BaoCaoRepository baoCaoRepository;
    private final NhanVienRepository nhanVienRepository;
    private final ChamCongRepository chamCongRepository;

    // Giờ vào chuẩn (8:00)
    private static final LocalTime STANDARD_CHECK_IN = LocalTime.of(8, 0);
    // Giờ ra chuẩn (17:00)
    private static final LocalTime STANDARD_CHECK_OUT = LocalTime.of(17, 0);
    // Số giờ làm việc chuẩn mỗi ngày
    private static final int STANDARD_WORK_HOURS = 8;

    @Override
    @Transactional(readOnly = true)
    public List<BaoCao> getAllBaoCao() {
        return baoCaoRepository.findAll();
    }

    @Override
    @Transactional(readOnly = true)
    public Optional<BaoCao> getBaoCaoById(Integer maBaoCao) {
        return baoCaoRepository.findById(maBaoCao);
    }

    @Override
    @Transactional(readOnly = true)
    public List<BaoCao> getBaoCaoByMaNV(Integer maNV) {
        return baoCaoRepository.findByMaNV(maNV);
    }

    @Override
    @Transactional(readOnly = true)
    public List<BaoCao> getBaoCaoByMaNVAndDateRange(Integer maNV, LocalDate tuNgay, LocalDate denNgay) {
        return baoCaoRepository.findByMaNVAndDateRange(maNV, tuNgay, denNgay);
    }

    @Override
    @Transactional(readOnly = true)
    public List<BaoCao> getBaoCaoByDateRange(LocalDate tuNgay, LocalDate denNgay) {
        return baoCaoRepository.findByDateRange(tuNgay, denNgay);
    }

    @Override
    public BaoCao createBaoCao(BaoCao baoCao) {
        // Kiểm tra nhân viên có tồn tại không
        if (!nhanVienRepository.existsById(baoCao.getMaNV())) {
            throw new IllegalArgumentException("Không tìm thấy nhân viên với mã: " + baoCao.getMaNV());
        }

        // Validate ngày
        if (baoCao.getDenNgay().isBefore(baoCao.getTuNgay())) {
            throw new IllegalArgumentException("Ngày kết thúc phải sau ngày bắt đầu");
        }

        // Kiểm tra đã có báo cáo cho khoảng thời gian này chưa
        if (baoCaoRepository.existsByMaNVAndDateRange(
                baoCao.getMaNV(), baoCao.getTuNgay(), baoCao.getDenNgay())) {
            throw new IllegalArgumentException("Đã tồn tại báo cáo cho nhân viên trong khoảng thời gian này");
        }

        return baoCaoRepository.save(baoCao);
    }

    @Override
    public BaoCao updateBaoCao(Integer maBaoCao, BaoCao baoCao) {
        BaoCao existingBaoCao = baoCaoRepository.findById(maBaoCao)
                .orElseThrow(() -> new IllegalArgumentException("Không tìm thấy báo cáo với mã: " + maBaoCao));

        // Validate ngày
        LocalDate tuNgay = baoCao.getTuNgay() != null ? baoCao.getTuNgay() : existingBaoCao.getTuNgay();
        LocalDate denNgay = baoCao.getDenNgay() != null ? baoCao.getDenNgay() : existingBaoCao.getDenNgay();

        if (denNgay.isBefore(tuNgay)) {
            throw new IllegalArgumentException("Ngày kết thúc phải sau ngày bắt đầu");
        }

        // Cập nhật thông tin
        existingBaoCao.setTuNgay(tuNgay);
        existingBaoCao.setDenNgay(denNgay);
        existingBaoCao.setTongGio(baoCao.getTongGio());
        existingBaoCao.setSoNgayDiTre(baoCao.getSoNgayDiTre());
        existingBaoCao.setSoNgayVeSom(baoCao.getSoNgayVeSom());
        existingBaoCao.setGioLamThem(baoCao.getGioLamThem());
        existingBaoCao.setLuong(baoCao.getLuong());

        return baoCaoRepository.save(existingBaoCao);
    }

    @Override
    public void deleteBaoCao(Integer maBaoCao) {
        if (!baoCaoRepository.existsById(maBaoCao)) {
            throw new IllegalArgumentException("Không tìm thấy báo cáo với mã: " + maBaoCao);
        }
        BaoCao baoCao = baoCaoRepository.findById(maBaoCao)
                .orElseThrow(() -> new IllegalArgumentException("Không tìm thấy báo cáo với mã: " + maBaoCao));
        baoCao.setDaXoa(true);
        baoCaoRepository.save(baoCao);
    }

    @Override
    public void restoreBaoCao(Integer maBaoCao) {
        BaoCao baoCao = baoCaoRepository.findById(maBaoCao)
                .orElseThrow(() -> new IllegalArgumentException("Không tìm thấy báo cáo với mã: " + maBaoCao));
        baoCao.setDaXoa(false);
        baoCaoRepository.save(baoCao);
    }

    @Override
    public void hardDeleteBaoCao(Integer maBaoCao) {
        if (!baoCaoRepository.existsById(maBaoCao)) {
            throw new IllegalArgumentException("Không tìm thấy báo cáo với mã: " + maBaoCao);
        }
        baoCaoRepository.deleteById(maBaoCao);
    }

    @Override
    public BaoCao generateBaoCao(Integer maNV, LocalDate tuNgay, LocalDate denNgay) {
        // Kiểm tra nhân viên có tồn tại không
        if (!nhanVienRepository.existsById(maNV)) {
            throw new IllegalArgumentException("Không tìm thấy nhân viên với mã: " + maNV);
        }

        // Validate ngày
        if (denNgay.isBefore(tuNgay)) {
            throw new IllegalArgumentException("Ngày kết thúc phải sau ngày bắt đầu");
        }

        // Kiểm tra đã có báo cáo chưa
        if (baoCaoRepository.existsByMaNVAndDateRange(maNV, tuNgay, denNgay)) {
            throw new IllegalArgumentException("Đã tồn tại báo cáo cho nhân viên trong khoảng thời gian này");
        }

        // Lấy dữ liệu chấm công
        LocalDateTime startDateTime = tuNgay.atStartOfDay();
        LocalDateTime endDateTime = denNgay.atTime(LocalTime.MAX);
        List<ChamCong> chamCongs = chamCongRepository.findByMaNVAndDateRange(maNV, startDateTime, endDateTime);

        // Tính toán các thống kê
        BigDecimal tongGio = BigDecimal.ZERO;
        int soNgayDiTre = 0;
        int soNgayVeSom = 0;
        BigDecimal gioLamThem = BigDecimal.ZERO;

        for (ChamCong chamCong : chamCongs) {
            if (chamCong.getGioVao() != null && chamCong.getGioRa() != null) {
                // Tính tổng giờ làm
                Double hours = chamCong.getThoiGianLamViec();
                if (hours != null) {
                    tongGio = tongGio.add(BigDecimal.valueOf(hours));

                    // Tính giờ làm thêm (> 8 giờ)
                    if (hours > STANDARD_WORK_HOURS) {
                        gioLamThem = gioLamThem.add(
                                BigDecimal.valueOf(hours - STANDARD_WORK_HOURS));
                    }
                }

                // Kiểm tra đi trễ (sau 8:00)
                LocalTime gioVao = chamCong.getGioVao().toLocalTime();
                if (gioVao.isAfter(STANDARD_CHECK_IN)) {
                    soNgayDiTre++;
                }

                // Kiểm tra về sớm (trước 17:00)
                LocalTime gioRa = chamCong.getGioRa().toLocalTime();
                if (gioRa.isBefore(STANDARD_CHECK_OUT)) {
                    soNgayVeSom++;
                }
            }
        }

        // Tạo báo cáo
        BaoCao baoCao = new BaoCao();
        baoCao.setMaNV(maNV);
        baoCao.setTuNgay(tuNgay);
        baoCao.setDenNgay(denNgay);
        baoCao.setTongGio(tongGio.setScale(2, RoundingMode.HALF_UP));
        baoCao.setSoNgayDiTre(soNgayDiTre);
        baoCao.setSoNgayVeSom(soNgayVeSom);
        baoCao.setGioLamThem(gioLamThem.setScale(2, RoundingMode.HALF_UP));
        baoCao.setLuong(BigDecimal.ZERO); // Lương sẽ được tính riêng

        return baoCaoRepository.save(baoCao);
    }

    @Override
    public BaoCao calculateLuong(Integer maBaoCao, BigDecimal luongCoBan, BigDecimal luongLamThem) {
        BaoCao baoCao = baoCaoRepository.findById(maBaoCao)
                .orElseThrow(() -> new IllegalArgumentException("Không tìm thấy báo cáo với mã: " + maBaoCao));

        // Tính lương = (tổng giờ * lương cơ bản) + (giờ làm thêm * lương làm thêm)
        BigDecimal luongChinh = baoCao.getTongGio().multiply(luongCoBan);
        BigDecimal luongThem = baoCao.getGioLamThem().multiply(luongLamThem);
        BigDecimal tongLuong = luongChinh.add(luongThem);

        baoCao.setLuong(tongLuong.setScale(2, RoundingMode.HALF_UP));
        return baoCaoRepository.save(baoCao);
    }

    @Override
    @Transactional(readOnly = true)
    public List<BaoCao> getBaoCaoByMonth(Integer maNV, int nam, int thang) {
        return baoCaoRepository.findByMaNVAndMonth(maNV, nam, thang);
    }

    @Override
    @Transactional(readOnly = true)
    public List<BaoCao> getBaoCaoByYear(int nam) {
        return baoCaoRepository.findByYear(nam);
    }

    @Override
    @Transactional(readOnly = true)
    public BigDecimal getTotalSalaryByYear(Integer maNV, int nam) {
        BigDecimal total = baoCaoRepository.getTotalSalaryByYear(maNV, nam);
        return total != null ? total : BigDecimal.ZERO;
    }

    @Override
    @Transactional(readOnly = true)
    public BigDecimal getTotalHoursByYear(Integer maNV, int nam) {
        BigDecimal total = baoCaoRepository.getTotalHoursByYear(maNV, nam);
        return total != null ? total : BigDecimal.ZERO;
    }

    @Override
    @Transactional(readOnly = true)
    public Optional<BaoCao> getLatestBaoCao(Integer maNV) {
        return baoCaoRepository.findTopByMaNVOrderByNgayTaoDesc(maNV);
    }

    @Override
    @Transactional(readOnly = true)
    public Map<String, Object> getOverallStatistics(LocalDate tuNgay, LocalDate denNgay) {
        List<BaoCao> baoCaos = baoCaoRepository.findByDateRange(tuNgay, denNgay);

        BigDecimal tongGioLamViec = baoCaos.stream()
                .map(BaoCao::getTongGio)
                .reduce(BigDecimal.ZERO, BigDecimal::add);

        BigDecimal tongLuong = baoCaos.stream()
                .map(BaoCao::getLuong)
                .reduce(BigDecimal.ZERO, BigDecimal::add);

        int tongSoNgayDiTre = baoCaos.stream()
                .mapToInt(BaoCao::getSoNgayDiTre)
                .sum();

        int tongSoNgayVeSom = baoCaos.stream()
                .mapToInt(BaoCao::getSoNgayVeSom)
                .sum();

        BigDecimal tongGioLamThem = baoCaos.stream()
                .map(BaoCao::getGioLamThem)
                .reduce(BigDecimal.ZERO, BigDecimal::add);

        long soNhanVien = baoCaos.stream()
                .map(BaoCao::getMaNV)
                .distinct()
                .count();

        Map<String, Object> statistics = new HashMap<>();
        statistics.put("tuNgay", tuNgay);
        statistics.put("denNgay", denNgay);
        statistics.put("soNhanVien", soNhanVien);
        statistics.put("soBaoCao", baoCaos.size());
        statistics.put("tongGioLamViec", tongGioLamViec.setScale(2, RoundingMode.HALF_UP));
        statistics.put("tongLuong", tongLuong.setScale(2, RoundingMode.HALF_UP));
        statistics.put("tongSoNgayDiTre", tongSoNgayDiTre);
        statistics.put("tongSoNgayVeSom", tongSoNgayVeSom);
        statistics.put("tongGioLamThem", tongGioLamThem.setScale(2, RoundingMode.HALF_UP));

        return statistics;
    }
}
