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

    @Override
    @Transactional(readOnly = true)
    public Map<String, Object> calculateSalaryDetails(Integer maNV, LocalDate tuNgay, LocalDate denNgay,
            BigDecimal luongGio, BigDecimal luongLamThem) {
        // Kiểm tra nhân viên tồn tại
        if (!nhanVienRepository.existsById(maNV)) {
            throw new IllegalArgumentException("Không tìm thấy nhân viên với mã: " + maNV);
        }

        // Lấy dữ liệu chấm công
        LocalDateTime tuNgayTime = tuNgay.atStartOfDay();
        LocalDateTime denNgayTime = denNgay.atTime(23, 59, 59);
        List<ChamCong> chamCongList = chamCongRepository.findByMaNVAndDateRange(maNV, tuNgayTime, denNgayTime);

        // Lọc bỏ các bản ghi đã xóa
        List<ChamCong> chamCongHopLe = chamCongList.stream()
                .filter(cc -> !cc.getDaXoa())
                .toList();

        BigDecimal tongGio = BigDecimal.ZERO;
        BigDecimal gioLamChinh = BigDecimal.ZERO;
        int soNgayDiTre = 0;
        int soNgayVeSom = 0;
        int soNgayCoChamCong = 0;

        for (ChamCong cc : chamCongHopLe) {
            if (cc.getGioVao() != null && cc.getGioRa() != null) {
                // Tính số giờ làm việc trong ngày
                double durationMinutes = java.time.Duration.between(cc.getGioVao(), cc.getGioRa()).toMinutes();
                BigDecimal totalHours = BigDecimal.valueOf(durationMinutes / 60.0);
                tongGio = tongGio.add(totalHours);

                // Tính giờ làm chính (sáng 7-11h, chiều 13-17h)
                LocalDateTime gioVao = cc.getGioVao();
                LocalDateTime gioRa = cc.getGioRa();

                BigDecimal gioChinhTrongNgay = BigDecimal.ZERO;

                // Ca sáng: 7h - 11h
                LocalDateTime sang7h = LocalDateTime.of(gioVao.toLocalDate(), LocalTime.of(7, 0));
                LocalDateTime sang11h = LocalDateTime.of(gioVao.toLocalDate(), LocalTime.of(11, 0));

                LocalDateTime batDauSang = gioVao;
                LocalDateTime ketThucSang = gioRa;

                // Điều chỉnh thời gian ca sáng
                if (gioVao.getHour() >= 11 && gioVao.getHour() < 13) {
                    // Giờ vào trong giờ nghỉ trưa, bỏ qua ca sáng
                    batDauSang = LocalDateTime.of(gioVao.toLocalDate(), LocalTime.of(13, 0));
                } else if (gioVao.isBefore(sang7h)) {
                    batDauSang = sang7h;
                }

                if (gioRa.getHour() >= 11 && gioRa.getHour() < 13) {
                    ketThucSang = sang11h;
                } else if (gioRa.isAfter(sang11h)) {
                    ketThucSang = sang11h;
                }

                // Tính giờ ca sáng
                if (ketThucSang.isAfter(batDauSang) && batDauSang.isBefore(sang11h)) {
                    long minutesSang = java.time.Duration.between(batDauSang, ketThucSang).toMinutes();
                    gioChinhTrongNgay = gioChinhTrongNgay.add(BigDecimal.valueOf(minutesSang / 60.0));
                }

                // Ca chiều: 13h - 17h
                LocalDateTime chieu13h = LocalDateTime.of(gioVao.toLocalDate(), LocalTime.of(13, 0));
                LocalDateTime chieu17h = LocalDateTime.of(gioVao.toLocalDate(), LocalTime.of(17, 0));

                LocalDateTime batDauChieu = gioVao;
                LocalDateTime ketThucChieu = gioRa;

                if (gioVao.getHour() >= 11 && gioVao.getHour() < 13) {
                    batDauChieu = chieu13h;
                } else if (gioVao.isBefore(chieu13h)) {
                    batDauChieu = chieu13h;
                }

                if (gioRa.isAfter(chieu17h)) {
                    ketThucChieu = chieu17h;
                }

                // Tính giờ ca chiều
                if (ketThucChieu.isAfter(batDauChieu) && gioRa.isAfter(chieu13h)) {
                    long minutesChieu = java.time.Duration.between(batDauChieu, ketThucChieu).toMinutes();
                    gioChinhTrongNgay = gioChinhTrongNgay.add(BigDecimal.valueOf(minutesChieu / 60.0));
                }

                gioLamChinh = gioLamChinh.add(gioChinhTrongNgay);
                soNgayCoChamCong++;
            }

            // Đếm số ngày đi trễ (sau 8:00)
            if (cc.getGioVao() != null) {
                LocalTime gioVaoTime = cc.getGioVao().toLocalTime();
                if (gioVaoTime.isAfter(LocalTime.of(8, 0))) {
                    soNgayDiTre++;
                }
            }

            // Đếm số ngày về sớm (trước 17:00)
            if (cc.getGioRa() != null) {
                LocalTime gioRaTime = cc.getGioRa().toLocalTime();
                if (gioRaTime.isBefore(LocalTime.of(17, 0))) {
                    soNgayVeSom++;
                }
            }
        }

        // Tính giờ làm thêm: tổng giờ - giờ làm chính - 2 tiếng nghỉ trưa
        BigDecimal gioNghiTruaUocTinh = BigDecimal.valueOf(soNgayCoChamCong * 2.0);
        BigDecimal gioLamThem = tongGio.subtract(gioLamChinh).subtract(gioNghiTruaUocTinh);
        if (gioLamThem.compareTo(BigDecimal.ZERO) < 0) {
            gioLamThem = BigDecimal.ZERO;
        }

        // Tính lương
        BigDecimal luongChinh = gioLamChinh.multiply(luongGio);
        BigDecimal luongThem = gioLamThem.multiply(luongLamThem);
        BigDecimal tongLuong = luongChinh.add(luongThem);

        Map<String, Object> result = new HashMap<>();
        result.put("maNV", maNV);
        result.put("tuNgay", tuNgay);
        result.put("denNgay", denNgay);
        result.put("tongGio", tongGio.setScale(2, RoundingMode.HALF_UP));
        result.put("gioLamChinh", gioLamChinh.setScale(2, RoundingMode.HALF_UP));
        result.put("gioLamThem", gioLamThem.setScale(2, RoundingMode.HALF_UP));
        result.put("soNgayDiTre", soNgayDiTre);
        result.put("soNgayVeSom", soNgayVeSom);
        result.put("soNgayCoChamCong", soNgayCoChamCong);
        result.put("luongChinh", luongChinh.setScale(0, RoundingMode.HALF_UP));
        result.put("luongThem", luongThem.setScale(0, RoundingMode.HALF_UP));
        result.put("tongLuong", tongLuong.setScale(0, RoundingMode.HALF_UP));
        result.put("luongGio", luongGio);
        result.put("luongLamThem", luongLamThem);

        return result;
    }

    @Override
    @Transactional(readOnly = true)
    public Map<String, Object> validateChamCong(Integer maNV, LocalDateTime gioVao, LocalDateTime gioRa,
            String phuongThuc) {
        Map<String, Object> validation = new HashMap<>();
        validation.put("isValid", true);
        validation.put("errors", new java.util.ArrayList<String>());

        @SuppressWarnings("unchecked")
        java.util.List<String> errors = (java.util.List<String>) validation.get("errors");

        // Kiểm tra nhân viên tồn tại
        if (!nhanVienRepository.existsById(maNV)) {
            errors.add("Không tìm thấy nhân viên với mã: " + maNV);
            validation.put("isValid", false);
            return validation;
        }

        // Kiểm tra thời gian không được là tương lai
        LocalDateTime now = LocalDateTime.now();
        if (gioVao != null && gioVao.isAfter(now)) {
            errors.add("Không thể chấm công cho thời gian tương lai");
            validation.put("isValid", false);
        }

        if (gioRa != null && gioRa.isAfter(now)) {
            errors.add("Không thể chấm công ra cho thời gian tương lai");
            validation.put("isValid", false);
        }

        // Kiểm tra giờ ra phải sau giờ vào
        if (gioVao != null && gioRa != null && !gioRa.isAfter(gioVao)) {
            errors.add("Giờ ra phải sau giờ vào");
            validation.put("isValid", false);
        }

        // Kiểm tra đã chấm công trong ngày chưa
        if (gioVao != null) {
            LocalDateTime startOfDay = gioVao.toLocalDate().atStartOfDay();
            LocalDateTime endOfDay = gioVao.toLocalDate().atTime(23, 59, 59);
            List<ChamCong> existingRecords = chamCongRepository.findByMaNVAndDateRange(maNV, startOfDay, endOfDay)
                    .stream().filter(cc -> !cc.getDaXoa()).toList();

            if (!existingRecords.isEmpty()) {
                errors.add("Nhân viên đã chấm công trong ngày này");
                validation.put("isValid", false);
            }
        }

        // Validate phương thức chấm công
        if (phuongThuc == null || phuongThuc.trim().isEmpty()) {
            errors.add("Phương thức chấm công không được để trống");
            validation.put("isValid", false);
        } else {
            String[] validMethods = { "ThuCong", "VanTay", "KhuonMat", "NFC" };
            boolean isValidMethod = false;
            for (String method : validMethods) {
                if (method.equals(phuongThuc)) {
                    isValidMethod = true;
                    break;
                }
            }
            if (!isValidMethod) {
                errors.add("Phương thức chấm công không hợp lệ");
                validation.put("isValid", false);
            }
        }

        return validation;
    }

    @Override
    @Transactional(readOnly = true)
    public Map<String, Object> calculateDashboardStatistics() {
        Map<String, Object> stats = new HashMap<>();

        // Thống kê hôm nay
        LocalDate today = LocalDate.now();
        LocalDateTime startOfDay = today.atStartOfDay();
        LocalDateTime endOfDay = today.atTime(23, 59, 59);

        List<ChamCong> todayRecords = chamCongRepository.findByDateRange(startOfDay, endOfDay)
                .stream().filter(cc -> !cc.getDaXoa()).toList();

        int checkedInToday = (int) todayRecords.stream()
                .filter(cc -> cc.getGioVao() != null)
                .count();

        int checkedOutToday = (int) todayRecords.stream()
                .filter(cc -> cc.getGioRa() != null)
                .count();

        int lateToday = (int) todayRecords.stream()
                .filter(cc -> cc.getGioVao() != null &&
                        cc.getGioVao().toLocalTime().isAfter(LocalTime.of(8, 0)))
                .count();

        // Thống kê tháng này
        LocalDate startOfMonth = today.withDayOfMonth(1);
        LocalDate endOfMonth = today.withDayOfMonth(today.lengthOfMonth());

        List<BaoCao> monthlyReports = baoCaoRepository.findByDateRange(startOfMonth, endOfMonth);
        BigDecimal monthlySalary = monthlyReports.stream()
                .map(BaoCao::getLuong)
                .reduce(BigDecimal.ZERO, BigDecimal::add);

        BigDecimal monthlyHours = monthlyReports.stream()
                .map(BaoCao::getTongGio)
                .reduce(BigDecimal.ZERO, BigDecimal::add);

        stats.put("todayCheckedIn", checkedInToday);
        stats.put("todayCheckedOut", checkedOutToday);
        stats.put("todayLate", lateToday);
        stats.put("monthlySalary", monthlySalary.setScale(0, RoundingMode.HALF_UP));
        stats.put("monthlyHours", monthlyHours.setScale(2, RoundingMode.HALF_UP));
        stats.put("totalEmployees", nhanVienRepository.count());

        return stats;
    }
}
