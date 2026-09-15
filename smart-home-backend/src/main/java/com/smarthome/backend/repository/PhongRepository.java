package com.smarthome.backend.repository;

import com.smarthome.backend.entity.Phong;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.List;

public interface PhongRepository extends JpaRepository<Phong, Integer> {
    List<Phong> findByNha_MaNha(Integer maNha);
}
