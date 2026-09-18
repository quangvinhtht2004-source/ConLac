package com.smarthome.backend.repository;

import com.smarthome.backend.entity.LichSuCamBien;
import org.springframework.data.jpa.repository.JpaRepository;

import java.time.LocalDateTime;
import java.util.List;
import java.util.Optional;

public interface LichSuCamBienRepository extends JpaRepository<LichSuCamBien, Long> {
    Optional<LichSuCamBien> findTopByCamBien_MaCamBienOrderByThoiGianGhiNhanDesc(Integer maCamBien);
    List<LichSuCamBien> findByCamBien_MaCamBienAndThoiGianGhiNhanBetweenOrderByThoiGianGhiNhanAsc(
            Integer maCamBien, LocalDateTime tu, LocalDateTime den);
    void deleteByCamBien_MaCamBien(Integer maCamBien);
}
