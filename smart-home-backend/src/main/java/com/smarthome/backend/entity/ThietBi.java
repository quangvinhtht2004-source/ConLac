package com.smarthome.backend.entity;

import jakarta.persistence.Column;
import jakarta.persistence.Entity;
import jakarta.persistence.FetchType;
import jakarta.persistence.GeneratedValue;
import jakarta.persistence.GenerationType;
import jakarta.persistence.Id;
import jakarta.persistence.JoinColumn;
import jakarta.persistence.ManyToOne;
import jakarta.persistence.Table;
import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;

import java.time.LocalDateTime;

@Entity
@Table(name = "ThietBi")
@Getter
@Setter
@NoArgsConstructor
public class ThietBi {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    @Column(name = "MaThietBi")
    private Integer maThietBi;

    @Column(name = "TenThietBi", nullable = false)
    private String tenThietBi;

    @Column(name = "LoaiThietBi", nullable = false)
    private String loaiThietBi;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "MaPhong", nullable = false)
    private Phong phong;

    @Column(name = "TrangThai", nullable = false)
    private String trangThai;

    @Column(name = "NgayTao")
    private LocalDateTime ngayTao;
}
