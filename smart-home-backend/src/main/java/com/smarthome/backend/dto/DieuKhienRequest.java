package com.smarthome.backend.dto;

import jakarta.validation.constraints.Pattern;
import lombok.Getter;
import lombok.Setter;

@Getter
@Setter
public class DieuKhienRequest {

    @Pattern(regexp = "Bat|Tat", message = "Hành động phải là Bat hoặc Tat")
    private String hanhDong;
}
