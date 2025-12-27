package com.example.worktrack.service.chamcong.impl;

import com.example.worktrack.model.chamcong.ChamCong;
import com.example.worktrack.repository.chamcong.ChamCongRepository;
import com.example.worktrack.repository.nhanvien.NhanVienRepository;
import com.example.worktrack.service.chamcong.ChamCongService;
import com.example.worktrack.util.RoleUtil;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.LocalDate;
import java.time.LocalDateTime;
import java.time.LocalTime;
import java.time.YearMonth;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.Optional;

@Service
@RequiredArgsConstructor
@Transactional
public class ChamCongServiceImpl implements ChamCongService {

    private final ChamCongRepository chamCongRepository;
    private final NhanVienRepository nhanVienRepository;

    @Override
    @Transactional(readOnly = true)
    public List<ChamCong> getAllChamCong() {
        List<ChamCong> allChamCong = chamCongRepository.findAll();

        // Chỉ admin mới được xem dữ liệu đã xóa mềm
        if (!RoleUtil.canViewSoftDeletedData()) {
            return allChamCong.stream()
                    .filter(chamCong -> !Boolean.TRUE.equals(chamCong.getDaXoa()))
                    .toList();
        }

        return allChamCong;
    }

    @Override
    @Transactional(readOnly = true)
    public Optional<ChamCong> getChamCongById(Integer maChamCong) {
        return chamCongRepository.findById(maChamCong);
    }

    @Override
    @Transactional(readOnly = true)
    public List<ChamCong> getChamCongByMaNV(Integer maNV) {
        return chamCongRepository.findByMaNV(maNV);
    }

    @Override
    @Transactional(readOnly = true)
    public List<ChamCong> getChamCongByMaNVAndDateRange(Integer maNV, LocalDateTime tuNgay, LocalDateTime denNgay) {
        return chamCongRepository.findByMaNVAndDateRange(maNV, tuNgay, denNgay);
    }

    @Override
    @Transactional(readOnly = true)
    public List<ChamCong> getChamCongByDateRange(LocalDateTime tuNgay, LocalDateTime denNgay) {
        return chamCongRepository.findByDateRange(tuNgay, denNgay);
    }

    @Override
    public ChamCong checkIn(Integer maNV, String phuongThuc, String ghiChu) {
        // Kiểm tra nhân viên có tồn tại không
        if (!nhanVienRepository.existsById(maNV)) {
            throw new IllegalArgumentException("Không tìm thấy nhân viên với mã: " + maNV);
        }

        // Kiểm tra xem nhân viên đã check-in chưa checkout chưa
        Optional<ChamCong> activeChamCong = chamCongRepository.findActiveCheckin(maNV);
        if (activeChamCong.isPresent()) {
            throw new IllegalStateException("Nhân viên đã check-in và chưa check-out");
        }

        // Tạo bản ghi chấm công mới
        ChamCong chamCong = new ChamCong();
        chamCong.setMaNV(maNV);
        chamCong.setGioVao(LocalDateTime.now());
        chamCong.setPhuongThuc(phuongThuc != null ? phuongThuc : "ThuCong");
        chamCong.setGhiChu(ghiChu);

        return chamCongRepository.save(chamCong);
    }

    @Override
    public ChamCong checkOut(Integer maNV, String ghiChu) {
        // Tìm bản ghi chấm công đang active
        ChamCong chamCong = chamCongRepository.findActiveCheckin(maNV)
                .orElseThrow(() -> new IllegalStateException("Không tìm thấy bản ghi check-in của nhân viên"));

        // Cập nhật thời gian ra
        chamCong.setGioRa(LocalDateTime.now());
        if (ghiChu != null && !ghiChu.isEmpty()) {
            chamCong.setGhiChu(ghiChu);
        }

        return chamCongRepository.save(chamCong);
    }

    @Override
    public ChamCong createChamCong(ChamCong chamCong) {
        // Kiểm tra nhân viên có tồn tại không
        if (!nhanVienRepository.existsById(chamCong.getMaNV())) {
            throw new IllegalArgumentException("Không tìm thấy nhân viên với mã: " + chamCong.getMaNV());
        }

        // Validate thời gian
        if (chamCong.getGioVao() != null && chamCong.getGioRa() != null) {
            if (chamCong.getGioRa().isBefore(chamCong.getGioVao())) {
                throw new IllegalArgumentException("Giờ ra phải sau giờ vào");
            }
        }

        // Đặt phương thức mặc định nếu chưa có
        if (chamCong.getPhuongThuc() == null || chamCong.getPhuongThuc().isEmpty()) {
            chamCong.setPhuongThuc("ThuCong");
        }

        return chamCongRepository.save(chamCong);
    }

    @Override
    public ChamCong updateChamCong(Integer maChamCong, ChamCong chamCong) {
        ChamCong existingChamCong = chamCongRepository.findById(maChamCong)
                .orElseThrow(
                        () -> new IllegalArgumentException("Không tìm thấy bản ghi chấm công với mã: " + maChamCong));

        // Validate thời gian
        LocalDateTime gioVao = chamCong.getGioVao() != null ? chamCong.getGioVao() : existingChamCong.getGioVao();
        LocalDateTime gioRa = chamCong.getGioRa() != null ? chamCong.getGioRa() : existingChamCong.getGioRa();

        if (gioVao != null && gioRa != null && gioRa.isBefore(gioVao)) {
            throw new IllegalArgumentException("Giờ ra phải sau giờ vào");
        }

        // Cập nhật thông tin
        existingChamCong.setGioVao(chamCong.getGioVao());
        existingChamCong.setGioRa(chamCong.getGioRa());
        existingChamCong.setPhuongThuc(chamCong.getPhuongThuc());
        existingChamCong.setGhiChu(chamCong.getGhiChu());

        return chamCongRepository.save(existingChamCong);
    }

    @Override
    public void deleteChamCong(Integer maChamCong) {
        if (!chamCongRepository.existsById(maChamCong)) {
            throw new IllegalArgumentException("Không tìm thấy bản ghi chấm công với mã: " + maChamCong);
        }
        ChamCong chamCong = chamCongRepository.findById(maChamCong)
                .orElseThrow(
                        () -> new IllegalArgumentException("Không tìm thấy bản ghi chấm công với mã: " + maChamCong));
        chamCong.setDaXoa(true);
        chamCongRepository.save(chamCong);
    }

    @Override
    public ChamCong restoreChamCong(Integer maChamCong) {
        ChamCong chamCong = chamCongRepository.findById(maChamCong)
                .orElseThrow(
                        () -> new IllegalArgumentException("Không tìm thấy bản ghi chấm công với mã: " + maChamCong));

        if (!chamCong.getDaXoa()) {
            throw new IllegalArgumentException("Bản ghi chấm công chưa bị xóa");
        }

        chamCong.setDaXoa(false);
        return chamCongRepository.save(chamCong);
    }

    @Override
    public void hardDeleteChamCong(Integer maChamCong) {
        if (!chamCongRepository.existsById(maChamCong)) {
            throw new IllegalArgumentException("Không tìm thấy bản ghi chấm công với mã: " + maChamCong);
        }
        chamCongRepository.deleteById(maChamCong);
    }

    @Override
    @Transactional(readOnly = true)
    public Optional<ChamCong> getActiveChamCong(Integer maNV) {
        return chamCongRepository.findActiveCheckin(maNV);
    }

    @Override
    @Transactional(readOnly = true)
    public Optional<ChamCong> getLatestChamCong(Integer maNV) {
        return chamCongRepository.findTopByMaNVOrderByGioVaoDesc(maNV);
    }

    @Override
    @Transactional(readOnly = true)
    public Long countChamCong(Integer maNV, LocalDateTime tuNgay, LocalDateTime denNgay) {
        return chamCongRepository.countByMaNVAndDateRange(maNV, tuNgay, denNgay);
    }

    @Override
    @Transactional(readOnly = true)
    public Map<String, Object> getStatisticsByDate(LocalDate ngay) {
        LocalDateTime startOfDay = ngay.atStartOfDay();
        LocalDateTime endOfDay = ngay.atTime(LocalTime.MAX);

        List<ChamCong> chamCongs = chamCongRepository.findByDateRange(startOfDay, endOfDay);

        Map<String, Object> statistics = new HashMap<>();
        statistics.put("ngay", ngay);
        statistics.put("tongSoLuotChamCong", chamCongs.size());
        statistics.put("soNhanVienDaChamCong", chamCongs.stream()
                .map(ChamCong::getMaNV)
                .distinct()
                .count());
        statistics.put("soLuotVanTay", chamCongs.stream()
                .filter(c -> "VanTay".equals(c.getPhuongThuc()))
                .count());
        statistics.put("soLuotKhuonMat", chamCongs.stream()
                .filter(c -> "KhuonMat".equals(c.getPhuongThuc()))
                .count());
        statistics.put("soLuotNFC", chamCongs.stream()
                .filter(c -> "NFC".equals(c.getPhuongThuc()))
                .count());
        statistics.put("soLuotThuCong", chamCongs.stream()
                .filter(c -> "ThuCong".equals(c.getPhuongThuc()))
                .count());

        return statistics;
    }

    @Override
    @Transactional(readOnly = true)
    public Map<String, Object> getEmployeeStatisticsByMonth(Integer maNV, int nam, int thang) {
        YearMonth yearMonth = YearMonth.of(nam, thang);
        LocalDateTime startOfMonth = yearMonth.atDay(1).atStartOfDay();
        LocalDateTime endOfMonth = yearMonth.atEndOfMonth().atTime(LocalTime.MAX);

        List<ChamCong> chamCongs = chamCongRepository.findByMaNVAndDateRange(maNV, startOfMonth, endOfMonth);

        double totalHours = chamCongs.stream()
                .filter(c -> c.getGioVao() != null && c.getGioRa() != null)
                .mapToDouble(c -> {
                    Double hours = c.getThoiGianLamViec();
                    return hours != null ? hours : 0.0;
                })
                .sum();

        Map<String, Object> statistics = new HashMap<>();
        statistics.put("maNV", maNV);
        statistics.put("thang", thang);
        statistics.put("nam", nam);
        statistics.put("tongSoLuotChamCong", chamCongs.size());
        statistics.put("tongGioLamViec", Math.round(totalHours * 100.0) / 100.0);
        statistics.put("soNgayLamViec", chamCongs.stream()
                .map(c -> c.getGioVao().toLocalDate())
                .distinct()
                .count());

        return statistics;
    }

    @Override
    @Transactional(readOnly = true)
    public List<Integer> getEmployeesCheckedInToday() {
        LocalDateTime startOfDay = LocalDate.now().atStartOfDay();
        LocalDateTime endOfDay = LocalDate.now().atTime(LocalTime.MAX);
        return chamCongRepository.findEmployeesCheckedInToday(startOfDay, endOfDay);
    }
}
