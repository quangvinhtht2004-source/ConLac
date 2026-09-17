package com.smarthome.backend.service;

import com.smarthome.backend.dto.CamBienRequest;
import com.smarthome.backend.dto.CamBienResponse;
import com.smarthome.backend.dto.GiaTriCamBien;
import com.smarthome.backend.entity.CamBien;
import com.smarthome.backend.entity.LichSuCamBien;
import com.smarthome.backend.entity.Phong;
import com.smarthome.backend.entity.ThietBi;
import com.smarthome.backend.repository.CamBienRepository;
import com.smarthome.backend.repository.LichSuCamBienRepository;
import com.smarthome.backend.repository.PhongRepository;
import com.smarthome.backend.repository.ThietBiRepository;
import jakarta.persistence.EntityNotFoundException;
import org.springframework.stereotype.Service;

import java.time.LocalDateTime;
import java.util.List;

@Service
public class CamBienService {

    private final CamBienRepository camBienRepository;
    private final PhongRepository phongRepository;
    private final ThietBiRepository thietBiRepository;
    private final LichSuCamBienRepository lichSuCamBienRepository;

    public CamBienService(CamBienRepository camBienRepository,
                           PhongRepository phongRepository,
                           ThietBiRepository thietBiRepository,
                           LichSuCamBienRepository lichSuCamBienRepository) {
        this.camBienRepository = camBienRepository;
        this.phongRepository = phongRepository;
        this.thietBiRepository = thietBiRepository;
        this.lichSuCamBienRepository = lichSuCamBienRepository;
    }

    public CamBienResponse taoCamBien(CamBienRequest request) {
        Phong phong = phongRepository.findById(request.getMaPhong())
                .orElseThrow(() -> new EntityNotFoundException("Không tìm thấy phòng có mã " + request.getMaPhong()));

        CamBien camBien = new CamBien();
        camBien.setLoaiCamBien(request.getLoaiCamBien());
        camBien.setPhong(phong);
        camBien.setNgayTao(LocalDateTime.now());

        if (request.getMaThietBi() != null) {
            ThietBi thietBi = thietBiRepository.findById(request.getMaThietBi())
                    .orElseThrow(() -> new EntityNotFoundException("Không tìm thấy thiết bị có mã " + request.getMaThietBi()));
            camBien.setThietBi(thietBi);
        }

        camBienRepository.save(camBien);
        return toResponse(camBien);
    }

    public List<CamBienResponse> danhSachTheoPhong(Integer maPhong, String loaiCamBien) {
        List<CamBien> danhSach = loaiCamBien != null
                ? camBienRepository.findByPhong_MaPhongAndLoaiCamBien(maPhong, loaiCamBien)
                : camBienRepository.findByPhong_MaPhong(maPhong);

        return danhSach.stream().map(this::toResponse).toList();
    }

    public GiaTriCamBien giaTriHienTai(Integer maCamBien) {
        timCamBienHoacLoi(maCamBien);
        return lichSuCamBienRepository.findTopByCamBien_MaCamBienOrderByThoiGianGhiNhanDesc(maCamBien)
                .map(bg -> new GiaTriCamBien(bg.getGiaTri(), bg.getThoiGianGhiNhan()))
                .orElse(null);
    }

    public List<GiaTriCamBien> lichSu(Integer maCamBien, LocalDateTime tu, LocalDateTime den) {
        timCamBienHoacLoi(maCamBien);
        return lichSuCamBienRepository
                .findByCamBien_MaCamBienAndThoiGianGhiNhanBetweenOrderByThoiGianGhiNhanAsc(maCamBien, tu, den)
                .stream()
                .map(bg -> new GiaTriCamBien(bg.getGiaTri(), bg.getThoiGianGhiNhan()))
                .toList();
    }

    public void ghiNhanGiaTri(Integer maCamBien, Double giaTri) {
        CamBien camBien = timCamBienHoacLoi(maCamBien);

        LichSuCamBien banGhi = new LichSuCamBien();
        banGhi.setCamBien(camBien);
        banGhi.setGiaTri(giaTri);
        banGhi.setThoiGianGhiNhan(LocalDateTime.now());

        lichSuCamBienRepository.save(banGhi);
    }

    private CamBien timCamBienHoacLoi(Integer maCamBien) {
        return camBienRepository.findById(maCamBien)
                .orElseThrow(() -> new EntityNotFoundException("Không tìm thấy cảm biến có mã " + maCamBien));
    }

    private CamBienResponse toResponse(CamBien camBien) {
        return new CamBienResponse(
                camBien.getMaCamBien(),
                camBien.getLoaiCamBien(),
                camBien.getPhong().getMaPhong(),
                camBien.getPhong().getTenPhong(),
                camBien.getNgayTao()
        );
    }
}
