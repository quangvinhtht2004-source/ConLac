package com.smarthome.backend.dto;

import lombok.AllArgsConstructor;
import lombok.Getter;

import java.time.LocalDateTime;
import java.util.List;

@Getter
@AllArgsConstructor
public class PhongResponse {
    private Integer maPhong;
    private String tenPhong;
    private Integer maNha;
    private LocalDateTime ngayTao;
    private List<ThietBiSummary> danhSachThietBi;
}
