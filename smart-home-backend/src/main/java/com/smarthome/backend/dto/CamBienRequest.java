package com.smarthome.backend.dto;

import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotNull;
import lombok.Getter;
import lombok.Setter;

@Getter
@Setter
public class CamBienRequest {

    @NotBlank(message = "Loại cảm biến không được để trống")
    private String loaiCamBien;

    @NotNull(message = "Phải chọn phòng")
    private Integer maPhong;

    private Integer maThietBi;
}
