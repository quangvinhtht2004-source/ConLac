package com.smarthome.backend.dto;

import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotNull;
import lombok.Getter;
import lombok.Setter;

@Getter
@Setter
public class PhongRequest {

    @NotBlank(message = "Tên phòng không được để trống")
    private String tenPhong;

    @NotNull(message = "Phải chọn nhà")
    private Integer maNha;
}
