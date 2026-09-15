package com.smarthome.backend.repository;

import com.smarthome.backend.entity.ThietBi;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.List;

public interface ThietBiRepository extends JpaRepository<ThietBi, Integer> {
    List<ThietBi> findByPhong_MaPhong(Integer maPhong);
}
