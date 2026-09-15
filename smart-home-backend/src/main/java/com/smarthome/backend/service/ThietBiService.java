package com.smarthome.backend.service;

import com.smarthome.backend.dto.ThietBiRequest;
import com.smarthome.backend.dto.ThietBiResponse;
import com.smarthome.backend.entity.Phong;
import com.smarthome.backend.entity.ThietBi;
import com.smarthome.backend.repository.PhongRepository;
import com.smarthome.backend.repository.ThietBiRepository;
import jakarta.persistence.EntityNotFoundException;
import org.springframework.stereotype.Service;

import java.time.LocalDateTime;
import java.util.List;

@Service
public class ThietBiService {

    private static final String TRANG_THAI_MAC_DINH = "Tat";

    private final ThietBiRepository thietBiRepository;
    private final PhongRepository phongRepository;

    public ThietBiService(ThietBiRepository thietBiRepository, PhongRepository phongRepository) {
        this.thietBiRepository = thietBiRepository;
        this.phongRepository = phongRepository;
    }

    public List<ThietBiResponse> danhSachTheoPhong(Integer maPhong) {
        return thietBiRepository.findByPhong_MaPhong(maPhong)
                .stream()
                .map(this::toResponse)
                .toList();
    }

    public ThietBiResponse chiTiet(Integer maThietBi) {
        ThietBi thietBi = timHoacLoi(maThietBi);
        return toResponse(thietBi);
    }

    public ThietBiResponse taoThietBi(ThietBiRequest request) {
        Phong phong = phongRepository.findById(request.getMaPhong())
                .orElseThrow(() -> new EntityNotFoundException("Không tìm thấy phòng có mã " + request.getMaPhong()));

        ThietBi thietBi = new ThietBi();
        thietBi.setTenThietBi(request.getTenThietBi());
        thietBi.setLoaiThietBi(request.getLoaiThietBi());
        thietBi.setPhong(phong);
        thietBi.setTrangThai(TRANG_THAI_MAC_DINH);
        thietBi.setNgayTao(LocalDateTime.now());

        thietBiRepository.save(thietBi);
        return toResponse(thietBi);
    }

    public ThietBiResponse capNhatThietBi(Integer maThietBi, ThietBiRequest request) {
        ThietBi thietBi = timHoacLoi(maThietBi);

        if (!thietBi.getPhong().getMaPhong().equals(request.getMaPhong())) {
            Phong phong = phongRepository.findById(request.getMaPhong())
                    .orElseThrow(() -> new EntityNotFoundException("Không tìm thấy phòng có mã " + request.getMaPhong()));
            thietBi.setPhong(phong);
        }

        thietBi.setTenThietBi(request.getTenThietBi());
        thietBi.setLoaiThietBi(request.getLoaiThietBi());

        thietBiRepository.save(thietBi);
        return toResponse(thietBi);
    }

    public void xoaThietBi(Integer maThietBi) {
        if (!thietBiRepository.existsById(maThietBi)) {
            throw new EntityNotFoundException("Không tìm thấy thiết bị có mã " + maThietBi);
        }
        thietBiRepository.deleteById(maThietBi);
    }

    private ThietBi timHoacLoi(Integer maThietBi) {
        return thietBiRepository.findById(maThietBi)
                .orElseThrow(() -> new EntityNotFoundException("Không tìm thấy thiết bị có mã " + maThietBi));
    }

    private ThietBiResponse toResponse(ThietBi thietBi) {
        return new ThietBiResponse(
                thietBi.getMaThietBi(),
                thietBi.getTenThietBi(),
                thietBi.getLoaiThietBi(),
                thietBi.getPhong().getMaPhong(),
                thietBi.getPhong().getTenPhong(),
                thietBi.getTrangThai(),
                thietBi.getNgayTao()
        );
    }
}
