package com.smarthome.backend.controller;

import com.smarthome.backend.dto.PhongRequest;
import com.smarthome.backend.dto.PhongResponse;
import com.smarthome.backend.service.PhongService;
import jakarta.validation.Valid;
import org.springframework.http.ResponseEntity;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.web.bind.annotation.DeleteMapping;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.PutMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;

import java.util.List;

@RestController
@RequestMapping("/api/phong")
public class PhongController {

    private final PhongService phongService;

    public PhongController(PhongService phongService) {
        this.phongService = phongService;
    }

    @GetMapping
    public List<PhongResponse> danhSach(@RequestParam Integer maNha) {
        return phongService.danhSachTheoNha(maNha);
    }

    @GetMapping("/{maPhong}")
    public PhongResponse chiTiet(@PathVariable Integer maPhong) {
        return phongService.chiTiet(maPhong);
    }

    @PostMapping
    @PreAuthorize("hasRole('ADMIN')")
    public ResponseEntity<PhongResponse> tao(@Valid @RequestBody PhongRequest request) {
        return ResponseEntity.ok(phongService.taoPhong(request));
    }

    @PutMapping("/{maPhong}")
    @PreAuthorize("hasRole('ADMIN')")
    public ResponseEntity<PhongResponse> capNhat(@PathVariable Integer maPhong, @Valid @RequestBody PhongRequest request) {
        return ResponseEntity.ok(phongService.capNhatPhong(maPhong, request));
    }

    @DeleteMapping("/{maPhong}")
    @PreAuthorize("hasRole('ADMIN')")
    public ResponseEntity<Void> xoa(@PathVariable Integer maPhong) {
        phongService.xoaPhong(maPhong);
        return ResponseEntity.noContent().build();
    }
}
