package com.smarthome.backend.dto;

import lombok.AllArgsConstructor;
import lombok.Getter;

@Getter
@AllArgsConstructor
public class ThietBiSummary {
    private Integer maThietBi;
    private String tenThietBi;
    private String loaiThietBi;
    private String trangThai;
}
