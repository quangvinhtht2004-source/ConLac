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
@Table(name = "Phong")
@Getter
@Setter
@NoArgsConstructor
public class Phong {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    @Column(name = "MaPhong")
    private Integer maPhong;

    @Column(name = "TenPhong", nullable = false)
    private String tenPhong;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "MaNha", nullable = false)
    private Nha nha;

    @Column(name = "NgayTao")
    private LocalDateTime ngayTao;
}
