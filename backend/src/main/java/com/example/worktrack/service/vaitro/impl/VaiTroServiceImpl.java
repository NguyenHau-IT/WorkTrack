package com.example.worktrack.service.vaitro.impl;

import com.example.worktrack.model.vaitro.VaiTro;
import com.example.worktrack.repository.vaitro.VaiTroRepository;
import com.example.worktrack.service.vaitro.VaiTroService;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;
import java.util.Optional;

@Service
@RequiredArgsConstructor
@Transactional
public class VaiTroServiceImpl implements VaiTroService {

    private final VaiTroRepository vaiTroRepository;

    @Override
    @Transactional(readOnly = true)
    public List<VaiTro> getAllVaiTro() {
        return vaiTroRepository.findAll();
    }

    // lấy tất cả vai trò chưa bị xóa
    public List<VaiTro> getAllVaiTroChuaXoa() {
        return vaiTroRepository.findAll().stream()
                .filter(vaiTro -> !Boolean.TRUE.equals(vaiTro.getDaXoa()))
                .toList();
    }

    @Override
    @Transactional(readOnly = true)
    public Optional<VaiTro> getVaiTroById(Integer maVaiTro) {
        return vaiTroRepository.findById(maVaiTro);
    }

    @Override
    @Transactional(readOnly = true)
    public Optional<VaiTro> getVaiTroByTen(String tenVaiTro) {
        return vaiTroRepository.findByTenVaiTro(tenVaiTro);
    }

    @Override
    public VaiTro createVaiTro(VaiTro vaiTro) {
        // Đặt ID = null để đảm bảo đây là entity mới
        vaiTro.setMaVaiTro(null);
        vaiTro.setDaXoa(false);

        // Kiểm tra tên vai trò đã tồn tại
        if (vaiTroRepository.existsByTenVaiTro(vaiTro.getTenVaiTro())) {
            throw new IllegalArgumentException("Vai trò đã tồn tại trong hệ thống");
        }

        return vaiTroRepository.save(vaiTro);
    }

    @Override
    public VaiTro updateVaiTro(Integer maVaiTro, VaiTro vaiTro) {
        VaiTro existingVaiTro = vaiTroRepository.findById(maVaiTro)
                .orElseThrow(() -> new IllegalArgumentException("Không tìm thấy vai trò với mã: " + maVaiTro));

        // Kiểm tra tên vai trò nếu thay đổi
        if (!existingVaiTro.getTenVaiTro().equals(vaiTro.getTenVaiTro())) {
            if (vaiTroRepository.existsByTenVaiTro(vaiTro.getTenVaiTro())) {
                throw new IllegalArgumentException("Tên vai trò đã tồn tại trong hệ thống");
            }
            existingVaiTro.setTenVaiTro(vaiTro.getTenVaiTro());
        }

        // Cập nhật mô tả
        existingVaiTro.setMoTa(vaiTro.getMoTa());

        return vaiTroRepository.save(existingVaiTro);
    }

    @Override
    public void deleteVaiTro(Integer maVaiTro) {
        VaiTro vaiTro = vaiTroRepository.findById(maVaiTro)
                .orElseThrow(() -> new IllegalArgumentException("Không tìm thấy vai trò với mã: " + maVaiTro));
        vaiTro.setDaXoa(true);
        vaiTroRepository.save(vaiTro);
    }

    // Khôi phục vai trò
    public void restoreVaiTro(Integer maVaiTro) {
        VaiTro vaiTro = vaiTroRepository.findById(maVaiTro)
                .orElseThrow(() -> new IllegalArgumentException("Không tìm thấy vai trò với mã: " + maVaiTro));
        vaiTro.setDaXoa(false);
        vaiTroRepository.save(vaiTro);
    }

    @Override
    public void hardDeleteVaiTro(Integer maVaiTro) {
        if (!vaiTroRepository.existsById(maVaiTro)) {
            throw new IllegalArgumentException("Không tìm thấy vai trò với mã: " + maVaiTro);
        }
        vaiTroRepository.deleteById(maVaiTro);
    }

    @Override
    @Transactional(readOnly = true)
    public boolean isVaiTroExists(String tenVaiTro) {
        return vaiTroRepository.existsByTenVaiTro(tenVaiTro);
    }
}
