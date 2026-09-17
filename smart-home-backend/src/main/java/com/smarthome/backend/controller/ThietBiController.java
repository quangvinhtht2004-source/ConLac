package com.smarthome.backend.controller;

import com.smarthome.backend.dto.DieuKhienRequest;
import com.smarthome.backend.dto.ThietBiRequest;
import com.smarthome.backend.dto.ThietBiResponse;
import com.smarthome.backend.service.ThietBiService;
import jakarta.validation.Valid;
import org.springframework.http.ResponseEntity;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.security.core.Authentication;
import org.springframework.web.bind.annotation.DeleteMapping;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PatchMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.PutMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;

import java.util.List;

@RestController
@RequestMapping("/api/thiet-bi")
public class ThietBiController {

    private final ThietBiService thietBiService;

    public ThietBiController(ThietBiService thietBiService) {
        this.thietBiService = thietBiService;
    }

    @GetMapping
    public List<ThietBiResponse> danhSach(@RequestParam Integer maPhong) {
        return thietBiService.danhSachTheoPhong(maPhong);
    }

    @GetMapping("/{maThietBi}")
    public ThietBiResponse chiTiet(@PathVariable Integer maThietBi) {
        return thietBiService.chiTiet(maThietBi);
    }

    @PostMapping
    @PreAuthorize("hasRole('ADMIN')")
    public ResponseEntity<ThietBiResponse> tao(@Valid @RequestBody ThietBiRequest request) {
        return ResponseEntity.ok(thietBiService.taoThietBi(request));
    }

    @PutMapping("/{maThietBi}")
    @PreAuthorize("hasRole('ADMIN')")
    public ResponseEntity<ThietBiResponse> capNhat(@PathVariable Integer maThietBi, @Valid @RequestBody ThietBiRequest request) {
        return ResponseEntity.ok(thietBiService.capNhatThietBi(maThietBi, request));
    }

    @DeleteMapping("/{maThietBi}")
    @PreAuthorize("hasRole('ADMIN')")
    public ResponseEntity<Void> xoa(@PathVariable Integer maThietBi) {
        thietBiService.xoaThietBi(maThietBi);
        return ResponseEntity.noContent().build();
    }

    @PatchMapping("/{maThietBi}/dieu-khien")
    public ResponseEntity<ThietBiResponse> dieuKhien(@PathVariable Integer maThietBi,
                                                       @Valid @RequestBody DieuKhienRequest request,
                                                       Authentication authentication) {
        ThietBiResponse response = thietBiService.dieuKhien(maThietBi, request.getHanhDong(), authentication.getName());
        return ResponseEntity.ok(response);
    }
}
