package com.smarthome.backend.dto;

import lombok.AllArgsConstructor;
import lombok.Getter;

@Getter
@AllArgsConstructor
public class LoginResponse {
    private String token;
    private Integer maNguoiDung;
    private String hoTen;
    private String vaiTro;
}
