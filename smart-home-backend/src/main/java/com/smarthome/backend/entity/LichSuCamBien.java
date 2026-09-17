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
@Table(name = "LichSuCamBien")
@Getter
@Setter
@NoArgsConstructor
public class LichSuCamBien {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    @Column(name = "MaBanGhi")
    private Long maBanGhi;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "MaCamBien", nullable = false)
    private CamBien camBien;

    @Column(name = "GiaTri", nullable = false)
    private Double giaTri;

    @Column(name = "ThoiGianGhiNhan", nullable = false)
    private LocalDateTime thoiGianGhiNhan;
}
