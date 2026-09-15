package com.smarthome.backend.controller;

import com.smarthome.backend.dto.LoginRequest;
import com.smarthome.backend.dto.LoginResponse;
import com.smarthome.backend.dto.RegisterRequest;
import com.smarthome.backend.entity.NguoiDung;
import com.smarthome.backend.repository.NguoiDungRepository;
import com.smarthome.backend.security.JwtUtil;
import jakarta.validation.Valid;
import org.springframework.http.ResponseEntity;
import org.springframework.security.authentication.AuthenticationManager;
import org.springframework.security.authentication.BadCredentialsException;
import org.springframework.security.authentication.UsernamePasswordAuthenticationToken;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import java.time.LocalDateTime;
import java.util.List;
import java.util.Map;

@RestController
@RequestMapping("/api/auth")
public class AuthController {

    private static final List<String> VAI_TRO_HOP_LE = List.of("Admin", "ThanhVien");

    private final AuthenticationManager authenticationManager;
    private final NguoiDungRepository nguoiDungRepository;
    private final PasswordEncoder passwordEncoder;
    private final JwtUtil jwtUtil;

    public AuthController(AuthenticationManager authenticationManager,
                           NguoiDungRepository nguoiDungRepository,
                           PasswordEncoder passwordEncoder,
                           JwtUtil jwtUtil) {
        this.authenticationManager = authenticationManager;
        this.nguoiDungRepository = nguoiDungRepository;
        this.passwordEncoder = passwordEncoder;
        this.jwtUtil = jwtUtil;
    }

    @PostMapping("/login")
    public ResponseEntity<?> login(@Valid @RequestBody LoginRequest request) {
        try {
            authenticationManager.authenticate(
                    new UsernamePasswordAuthenticationToken(request.getTenDangNhap(), request.getMatKhau())
            );
        } catch (BadCredentialsException ex) {
            return ResponseEntity.status(401).body(Map.of("message", "Sai tên đăng nhập hoặc mật khẩu"));
        }

        NguoiDung nguoiDung = nguoiDungRepository.findByTenDangNhap(request.getTenDangNhap())
                .orElseThrow();

        String token = jwtUtil.generateToken(nguoiDung.getTenDangNhap(), nguoiDung.getVaiTro());

        LoginResponse response = new LoginResponse(
                token,
                nguoiDung.getMaNguoiDung(),
                nguoiDung.getHoTen(),
                nguoiDung.getVaiTro()
        );

        return ResponseEntity.ok(response);
    }

    @PostMapping("/register")
    public ResponseEntity<?> register(@Valid @RequestBody RegisterRequest request) {
        if (!VAI_TRO_HOP_LE.contains(request.getVaiTro())) {
            return ResponseEntity.badRequest().body(Map.of("message", "Vai trò phải là Admin hoặc ThanhVien"));
        }

        if (nguoiDungRepository.existsByTenDangNhap(request.getTenDangNhap())) {
            return ResponseEntity.badRequest().body(Map.of("message", "Tên đăng nhập đã tồn tại"));
        }

        NguoiDung nguoiDung = new NguoiDung();
        nguoiDung.setTenDangNhap(request.getTenDangNhap());
        nguoiDung.setMatKhau(passwordEncoder.encode(request.getMatKhau()));
        nguoiDung.setHoTen(request.getHoTen());
        nguoiDung.setEmail(request.getEmail());
        nguoiDung.setSoDienThoai(request.getSoDienThoai());
        nguoiDung.setVaiTro(request.getVaiTro());
        nguoiDung.setNgayTao(LocalDateTime.now());

        nguoiDungRepository.save(nguoiDung);

        return ResponseEntity.ok(Map.of("message", "Tạo tài khoản thành công"));
    }
}
