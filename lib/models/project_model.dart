import 'package:flutter/material.dart';

/// Represents a selectable project type
class ProjectType {
  final String id;
  final String name;
  final String description;
  final IconData icon;
  final Color accent;

  const ProjectType({
    required this.id,
    required this.name,
    required this.description,
    required this.icon,
    required this.accent,
  });
}

/// All available project types
const List<ProjectType> availableProjects = <ProjectType>[
  ProjectType(
    id: 'rekomendasi-produk',
    name: 'Rekomendasi Produk',
    description:
        'Sistem cerdas yang memberikan rekomendasi produk secara otomatis berdasarkan preferensi, riwayat pembelian, dan perilaku pengguna menggunakan algoritma machine learning.',
    icon: Icons.recommend_rounded,
    accent: Color(0xFF2563EB),
  ),
  ProjectType(
    id: 'analitik-layanan',
    name: 'Analitik Layanan Pelanggan',
    description:
        'Platform analitik berbasis AI untuk menganalisis interaksi layanan pelanggan, mengidentifikasi tren masalah, dan mengoptimalkan respons layanan secara real-time.',
    icon: Icons.support_agent_rounded,
    accent: Color(0xFF2563EB),
  ),
  ProjectType(
    id: 'deteksi-fraud',
    name: 'Deteksi Fraud Internal',
    description:
        'Sistem deteksi anomali dan kecurangan internal yang memanfaatkan model machine learning untuk mengidentifikasi transaksi mencurigakan dan pola perilaku tidak wajar.',
    icon: Icons.security_rounded,
    accent: Color(0xFF2563EB),
  ),
  ProjectType(
    id: 'asisten-pengetahuan',
    name: 'Asisten Pengetahuan Operasional',
    description:
        'Asisten virtual berbasis NLP yang membantu karyawan mengakses pengetahuan operasional, SOP, dan panduan kerja secara cepat melalui antarmuka percakapan.',
    icon: Icons.psychology_alt_rounded,
    accent: Color(0xFF2563EB),
  ),
];

/// Data model for a completed project initiation
class ProjectInitiation {
  final String id;
  final ProjectType projectType;
  final DateTime createdAt;
  final Map<String, dynamic> formData;

  ProjectInitiation({
    required this.id,
    required this.projectType,
    required this.createdAt,
    required this.formData,
  });

  /// Create a copy with optional field overrides.
  ProjectInitiation copyWith({
    String? id,
    ProjectType? projectType,
    DateTime? createdAt,
    Map<String, dynamic>? formData,
  }) {
    return ProjectInitiation(
      id: id ?? this.id,
      projectType: projectType ?? this.projectType,
      createdAt: createdAt ?? this.createdAt,
      formData: formData ?? this.formData,
    );
  }
}
