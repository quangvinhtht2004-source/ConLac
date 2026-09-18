package com.smarthome.backend.service;

import com.smarthome.backend.dto.PhongRequest;
import com.smarthome.backend.dto.PhongResponse;
import com.smarthome.backend.dto.ThietBiSummary;
import com.smarthome.backend.entity.CamBien;
import com.smarthome.backend.entity.Nha;
import com.smarthome.backend.entity.Phong;
import com.smarthome.backend.entity.ThietBi;
import com.smarthome.backend.repository.CamBienRepository;
import com.smarthome.backend.repository.LichSuCamBienRepository;
import com.smarthome.backend.repository.LichSuHoatDongRepository;
import com.smarthome.backend.repository.NhaRepository;
import com.smarthome.backend.repository.PhongRepository;
import com.smarthome.backend.repository.ThietBiRepository;
import jakarta.persistence.EntityNotFoundException;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.LocalDateTime;
import java.util.List;

@Service
public class PhongService {

    private final PhongRepository phongRepository;
    private final NhaRepository nhaRepository;
    private final ThietBiRepository thietBiRepository;
    private final CamBienRepository camBienRepository;
    private final LichSuCamBienRepository lichSuCamBienRepository;
    private final LichSuHoatDongRepository lichSuHoatDongRepository;

    public PhongService(PhongRepository phongRepository,
                        NhaRepository nhaRepository,
                        ThietBiRepository thietBiRepository,
                        CamBienRepository camBienRepository,
                        LichSuCamBienRepository lichSuCamBienRepository,
                        LichSuHoatDongRepository lichSuHoatDongRepository) {
        this.phongRepository = phongRepository;
        this.nhaRepository = nhaRepository;
        this.thietBiRepository = thietBiRepository;
        this.camBienRepository = camBienRepository;
        this.lichSuCamBienRepository = lichSuCamBienRepository;
        this.lichSuHoatDongRepository = lichSuHoatDongRepository;
    }

    public List<PhongResponse> danhSachTheoNha(Integer maNha) {
        return phongRepository.findByNha_MaNha(maNha)
                .stream()
                .map(this::toResponse)
                .toList();
    }

    public PhongResponse chiTiet(Integer maPhong) {
        Phong phong = phongRepository.findById(maPhong)
                .orElseThrow(() -> new EntityNotFoundException("Không tìm thấy phòng có mã " + maPhong));
        return toResponse(phong);
    }

    public PhongResponse taoPhong(PhongRequest request) {
        Nha nha = nhaRepository.findById(request.getMaNha())
                .orElseThrow(() -> new EntityNotFoundException("Không tìm thấy nhà có mã " + request.getMaNha()));

        Phong phong = new Phong();
        phong.setTenPhong(request.getTenPhong());
        phong.setNha(nha);
        phong.setNgayTao(LocalDateTime.now());

        phongRepository.save(phong);
        return toResponse(phong);
    }

    public PhongResponse capNhatPhong(Integer maPhong, PhongRequest request) {
        Phong phong = phongRepository.findById(maPhong)
                .orElseThrow(() -> new EntityNotFoundException("Không tìm thấy phòng có mã " + maPhong));

        if (!phong.getNha().getMaNha().equals(request.getMaNha())) {
            Nha nha = nhaRepository.findById(request.getMaNha())
                    .orElseThrow(() -> new EntityNotFoundException("Không tìm thấy nhà có mã " + request.getMaNha()));
            phong.setNha(nha);
        }

        phong.setTenPhong(request.getTenPhong());
        phongRepository.save(phong);
        return toResponse(phong);
    }

    @Transactional
    public void xoaPhong(Integer maPhong) {
        if (!phongRepository.existsById(maPhong)) {
            throw new EntityNotFoundException("Không tìm thấy phòng có mã " + maPhong);
        }

        // 1. Xóa tất cả cảm biến thuộc phòng này
        List<CamBien> camBienList = camBienRepository.findByPhong_MaPhong(maPhong);
        for (CamBien cb : camBienList) {
            lichSuCamBienRepository.deleteByCamBien_MaCamBien(cb.getMaCamBien());
            camBienRepository.delete(cb);
        }

        // 2. Xóa tất cả thiết bị thuộc phòng này
        List<ThietBi> thietBiList = thietBiRepository.findByPhong_MaPhong(maPhong);
        for (ThietBi tb : thietBiList) {
            // Gỡ liên kết nếu có cảm biến nào ngoài phòng liên kết tới thiết bị này
            List<CamBien> cbGanVoiTb = camBienRepository.findByThietBi_MaThietBi(tb.getMaThietBi());
            for (CamBien cb : cbGanVoiTb) {
                cb.setThietBi(null);
                camBienRepository.save(cb);
            }
            // Xóa lịch sử hoạt động của thiết bị
            lichSuHoatDongRepository.deleteByThietBi_MaThietBi(tb.getMaThietBi());
            // Xóa thiết bị
            thietBiRepository.delete(tb);
        }

        // 3. Xóa phòng
        phongRepository.deleteById(maPhong);
    }

    private PhongResponse toResponse(Phong phong) {
        List<ThietBi> thietBiList = thietBiRepository.findByPhong_MaPhong(phong.getMaPhong());
        List<ThietBiSummary> danhSachThietBi = thietBiList.stream()
                .map(tb -> new ThietBiSummary(tb.getMaThietBi(), tb.getTenThietBi(), tb.getLoaiThietBi(), tb.getTrangThai()))
                .toList();

        return new PhongResponse(
                phong.getMaPhong(),
                phong.getTenPhong(),
                phong.getNha().getMaNha(),
                phong.getNgayTao(),
                danhSachThietBi
        );
    }
}
