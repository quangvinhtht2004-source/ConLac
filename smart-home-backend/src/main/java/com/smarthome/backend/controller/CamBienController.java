package com.smarthome.backend.controller;

import com.smarthome.backend.dto.CamBienRequest;
import com.smarthome.backend.dto.CamBienResponse;
import com.smarthome.backend.dto.GhiNhanCamBienRequest;
import com.smarthome.backend.dto.GiaTriCamBien;
import com.smarthome.backend.service.CamBienService;
import jakarta.validation.Valid;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.format.annotation.DateTimeFormat;
import org.springframework.http.ResponseEntity;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestHeader;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;

import java.time.LocalDateTime;
import java.util.List;
import java.util.Map;

@RestController
@RequestMapping("/api/cam-bien")
public class CamBienController {

    private final CamBienService camBienService;

    @Value("${device.api-key}")
    private String deviceApiKey;

    public CamBienController(CamBienService camBienService) {
        this.camBienService = camBienService;
    }

    @GetMapping
    public List<CamBienResponse> danhSach(@RequestParam Integer maPhong,
                                           @RequestParam(required = false) String loai) {
        return camBienService.danhSachTheoPhong(maPhong, loai);
    }

    @PostMapping
    @PreAuthorize("hasRole('ADMIN')")
    public ResponseEntity<CamBienResponse> tao(@Valid @RequestBody CamBienRequest request) {
        return ResponseEntity.ok(camBienService.taoCamBien(request));
    }

    @GetMapping("/{maCamBien}/hien-tai")
    public ResponseEntity<GiaTriCamBien> giaTriHienTai(@PathVariable Integer maCamBien) {
        GiaTriCamBien giaTri = camBienService.giaTriHienTai(maCamBien);
        if (giaTri == null) {
            return ResponseEntity.noContent().build();
        }
        return ResponseEntity.ok(giaTri);
    }

    @GetMapping("/{maCamBien}/lich-su")
    public List<GiaTriCamBien> lichSu(@PathVariable Integer maCamBien,
                                       @RequestParam(required = false) @DateTimeFormat(iso = DateTimeFormat.ISO.DATE_TIME) LocalDateTime tu,
                                       @RequestParam(required = false) @DateTimeFormat(iso = DateTimeFormat.ISO.DATE_TIME) LocalDateTime den) {
        LocalDateTime thoiDiemDen = den != null ? den : LocalDateTime.now();
        LocalDateTime thoiDiemTu = tu != null ? tu : thoiDiemDen.minusHours(24);
        return camBienService.lichSu(maCamBien, thoiDiemTu, thoiDiemDen);
    }

    @PostMapping("/ingest")
    public ResponseEntity<?> ghiNhan(@RequestHeader("X-Device-Key") String khoaThietBi,
                                      @Valid @RequestBody GhiNhanCamBienRequest request) {
        if (!deviceApiKey.equals(khoaThietBi)) {
            return ResponseEntity.status(401).body(Map.of("message", "Sai khóa xác thực thiết bị"));
        }
        camBienService.ghiNhanGiaTri(request.getMaCamBien(), request.getGiaTri());
        return ResponseEntity.ok(Map.of("message", "Đã ghi nhận dữ liệu"));
    }
}
