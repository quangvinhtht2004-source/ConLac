package com.smarthome.backend.repository;

import com.smarthome.backend.entity.CamBien;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.List;

public interface CamBienRepository extends JpaRepository<CamBien, Integer> {
    List<CamBien> findByPhong_MaPhongAndLoaiCamBien(Integer maPhong, String loaiCamBien);
    List<CamBien> findByPhong_MaPhong(Integer maPhong);
    List<CamBien> findByThietBi_MaThietBi(Integer maThietBi);
}
