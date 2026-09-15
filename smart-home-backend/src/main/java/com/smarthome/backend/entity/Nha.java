package com.smarthome.backend.entity;

import jakarta.persistence.Column;
import jakarta.persistence.Entity;
import jakarta.persistence.GeneratedValue;
import jakarta.persistence.GenerationType;
import jakarta.persistence.Id;
import jakarta.persistence.Table;
import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;

import java.time.LocalDateTime;

@Entity
@Table(name = "Nha")
@Getter
@Setter
@NoArgsConstructor
public class Nha {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    @Column(name = "MaNha")
    private Integer maNha;

    @Column(name = "TenNha", nullable = false)
    private String tenNha;

    @Column(name = "DiaChi")
    private String diaChi;

    @Column(name = "TrangThai", nullable = false)
    private String trangThai;

    @Column(name = "MaNguoiDung", nullable = false)
    private Integer maNguoiDung;

    @Column(name = "NgayTao")
    private LocalDateTime ngayTao;
}
