package com.smarthome.backend.service;

import com.smarthome.backend.dto.ThietBiRequest;
import com.smarthome.backend.dto.ThietBiResponse;
import com.smarthome.backend.entity.LichSuHoatDong;
import com.smarthome.backend.entity.NguoiDung;
import com.smarthome.backend.entity.Phong;
import com.smarthome.backend.entity.ThietBi;
import com.smarthome.backend.repository.LichSuHoatDongRepository;
import com.smarthome.backend.repository.NguoiDungRepository;
import com.smarthome.backend.repository.PhongRepository;
import com.smarthome.backend.repository.ThietBiRepository;
import jakarta.persistence.EntityNotFoundException;
import org.springframework.stereotype.Service;

import java.time.LocalDateTime;
import java.util.List;

@Service
public class ThietBiService {

    private static final String TRANG_THAI_MAC_DINH = "Tat";
    private static final String NGUON_NGUOI_DUNG = "NguoiDung";

    private final ThietBiRepository thietBiRepository;
    private final PhongRepository phongRepository;
    private final LichSuHoatDongRepository lichSuHoatDongRepository;
    private final NguoiDungRepository nguoiDungRepository;

    public ThietBiService(ThietBiRepository thietBiRepository,
                           PhongRepository phongRepository,
                           LichSuHoatDongRepository lichSuHoatDongRepository,
                           NguoiDungRepository nguoiDungRepository) {
        this.thietBiRepository = thietBiRepository;
        this.phongRepository = phongRepository;
        this.lichSuHoatDongRepository = lichSuHoatDongRepository;
        this.nguoiDungRepository = nguoiDungRepository;
    }

    public ThietBiResponse dieuKhien(Integer maThietBi, String hanhDong, String tenDangNhap) {
        ThietBi thietBi = timHoacLoi(maThietBi);
        thietBi.setTrangThai(hanhDong);
        thietBiRepository.save(thietBi);

        NguoiDung nguoiDung = nguoiDungRepository.findByTenDangNhap(tenDangNhap).orElse(null);

        LichSuHoatDong lichSu = new LichSuHoatDong();
        lichSu.setThietBi(thietBi);
        lichSu.setNguoiDung(nguoiDung);
        lichSu.setHanhDong(hanhDong);
        lichSu.setNguon(NGUON_NGUOI_DUNG);
        lichSu.setThoiGian(LocalDateTime.now());
        lichSuHoatDongRepository.save(lichSu);

        return toResponse(thietBi);
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
