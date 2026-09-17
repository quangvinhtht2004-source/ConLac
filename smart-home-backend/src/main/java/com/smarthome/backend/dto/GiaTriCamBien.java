package com.smarthome.backend.dto;

import lombok.AllArgsConstructor;
import lombok.Getter;

import java.time.LocalDateTime;

@Getter
@AllArgsConstructor
public class GiaTriCamBien {
    private Double giaTri;
    private LocalDateTime thoiGianGhiNhan;
}
