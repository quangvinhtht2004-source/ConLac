package com.smarthome.backend.security;

import com.smarthome.backend.entity.NguoiDung;
import com.smarthome.backend.repository.NguoiDungRepository;
import org.springframework.security.core.authority.SimpleGrantedAuthority;
import org.springframework.security.core.userdetails.UserDetails;
import org.springframework.security.core.userdetails.UserDetailsService;
import org.springframework.security.core.userdetails.UsernameNotFoundException;
import org.springframework.stereotype.Service;

import java.util.List;

@Service
public class CustomUserDetailsService implements UserDetailsService {

    private final NguoiDungRepository nguoiDungRepository;

    public CustomUserDetailsService(NguoiDungRepository nguoiDungRepository) {
        this.nguoiDungRepository = nguoiDungRepository;
    }

    @Override
    public UserDetails loadUserByUsername(String tenDangNhap) throws UsernameNotFoundException {
        NguoiDung nguoiDung = nguoiDungRepository.findByTenDangNhap(tenDangNhap)
                .orElseThrow(() -> new UsernameNotFoundException("Không tìm thấy tài khoản: " + tenDangNhap));

        String authority = "ROLE_" + nguoiDung.getVaiTro().toUpperCase();

        return org.springframework.security.core.userdetails.User
                .withUsername(nguoiDung.getTenDangNhap())
                .password(nguoiDung.getMatKhau())
                .authorities(List.of(new SimpleGrantedAuthority(authority)))
                .build();
    }
}
