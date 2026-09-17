package com.smarthome.backend.dto;

import lombok.AllArgsConstructor;
import lombok.Getter;

import java.time.LocalDateTime;

@Getter
@AllArgsConstructor
public class CamBienResponse {
    private Integer maCamBien;
    private String loaiCamBien;
    private Integer maPhong;
    private String tenPhong;
    private LocalDateTime ngayTao;
}
