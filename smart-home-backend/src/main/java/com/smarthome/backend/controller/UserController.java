package com.smarthome.backend.controller;

import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.security.core.Authentication;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import java.util.Map;

@RestController
@RequestMapping("/api")
public class UserController {

    @GetMapping("/user/me")
    public Map<String, Object> currentUser(Authentication authentication) {
        return Map.of(
                "tenDangNhap", authentication.getName(),
                "quyen", authentication.getAuthorities()
        );
    }

    @GetMapping("/admin/ping")
    @PreAuthorize("hasRole('ADMIN')")
    public Map<String, String> adminOnly() {
        return Map.of("message", "Chỉ Admin mới truy cập được endpoint này");
    }
}
