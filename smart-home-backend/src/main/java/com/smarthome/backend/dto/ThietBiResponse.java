package com.smarthome.backend.dto;

import lombok.AllArgsConstructor;
import lombok.Getter;

import java.time.LocalDateTime;

@Getter
@AllArgsConstructor
public class ThietBiResponse {
    private Integer maThietBi;
    private String tenThietBi;
    private String loaiThietBi;
    private Integer maPhong;
    private String tenPhong;
    private String trangThai;
    private LocalDateTime ngayTao;
}
