package com.smarthome.backend.dto;

import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotNull;
import lombok.Getter;
import lombok.Setter;

@Getter
@Setter
public class ThietBiRequest {

    @NotBlank(message = "Tên thiết bị không được để trống")
    private String tenThietBi;

    @NotBlank(message = "Loại thiết bị không được để trống")
    private String loaiThietBi;

    @NotNull(message = "Phải chọn phòng")
    private Integer maPhong;
}
