package com.smarthome.backend.dto;

import jakarta.validation.constraints.Email;
import jakarta.validation.constraints.NotBlank;
import lombok.Getter;
import lombok.Setter;

@Getter
@Setter
public class RegisterRequest {

    @NotBlank
    private String tenDangNhap;

    @NotBlank
    private String matKhau;

    @NotBlank
    private String hoTen;

    @Email
    private String email;

    private String soDienThoai;

    @NotBlank
    private String vaiTro;
}
