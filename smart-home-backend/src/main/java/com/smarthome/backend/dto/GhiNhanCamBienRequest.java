package com.smarthome.backend.dto;

import jakarta.validation.constraints.NotNull;
import lombok.Getter;
import lombok.Setter;

@Getter
@Setter
public class GhiNhanCamBienRequest {

    @NotNull(message = "Phải cung cấp mã cảm biến")
    private Integer maCamBien;

    @NotNull(message = "Phải cung cấp giá trị đo được")
    private Double giaTri;
}
