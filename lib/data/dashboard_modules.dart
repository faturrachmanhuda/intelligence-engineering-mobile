import 'package:flutter/material.dart';

class DashboardModule {
  final String id;
  final String step;
  final String title;
  final String subtitle;
  final String description;
  final IconData icon;
  final Color accent;
  final List<String> highlights;
  final List<ModuleSection> sections;

  const DashboardModule({
    required this.id,
    required this.step,
    required this.title,
    required this.subtitle,
    required this.description,
    required this.icon,
    required this.accent,
    required this.highlights,
    required this.sections,
  });

  int get fieldCount =>
      sections.fold(0, (total, section) => total + section.fields.length);
}

class ModuleSection {
  final String title;
  final String description;
  final List<ModuleField> fields;

  const ModuleSection({
    required this.title,
    required this.description,
    required this.fields,
  });
}

enum ModuleFieldType { text, multiline, dropdown }

class ModuleField {
  final String key;
  final String label;
  final String hint;
  final IconData icon;
  final ModuleFieldType type;
  final List<String> options;
  final String? initialValue;

  const ModuleField({
    required this.key,
    required this.label,
    required this.hint,
    required this.icon,
    this.type = ModuleFieldType.text,
    this.options = const <String>[],
    this.initialValue,
  });
}

const List<DashboardModule> dashboardModules = <DashboardModule>[
  DashboardModule(
    id: 'meaningful-objectives',
    step: '01',
    title: 'Meaningful Objectives',
    subtitle: 'Tetapkan sasaran utama sistem cerdas',
    description:
        'Merekam objective inti proyek, indikator awal, dampak pengguna, dan properti model yang ingin dijaga.',
    icon: Icons.track_changes_rounded,
    accent: Color(0xFF2563EB),
    highlights: <String>[
      'Organizational objectives',
      'Leading indicator',
      'User outcomes',
      'Model properties',
    ],
    sections: <ModuleSection>[
      ModuleSection(
        title: 'Informasi Utama',
        description: 'Tetapkan konteks proyek dan target organisasi utama.',
        fields: <ModuleField>[
          ModuleField(
            key: 'project_name',
            label: 'Pilih Proyek',
            hint: 'Pilih proyek yang relevan',
            icon: Icons.folder_open_rounded,
            type: ModuleFieldType.dropdown,
            options: <String>[
              'Rekomendasi Produk',
              'Analitik Layanan Pelanggan',
              'Deteksi Fraud Internal',
              'Asisten Pengetahuan Operasional',
            ],
          ),
          ModuleField(
            key: 'organizational_objective',
            label: 'Target Organisasi',
            hint: 'Contoh: Meningkatkan efisiensi layanan pelanggan hingga 40%',
            icon: Icons.gps_fixed_rounded,
            type: ModuleFieldType.multiline,
          ),
        ],
      ),
      ModuleSection(
        title: 'Metrik Keberhasilan',
        description: 'Gunakan indikator awal yang paling cepat diamati.',
        fields: <ModuleField>[
          ModuleField(
            key: 'leading_indicator',
            label: 'Leading Indicator',
            hint:
                'Contoh: Tingkat kepuasan pelanggan meningkat 30% dalam 2 bulan',
            icon: Icons.query_stats_rounded,
            type: ModuleFieldType.multiline,
          ),
        ],
      ),
      ModuleSection(
        title: 'Dampak & Teknologi',
        description:
            'Pastikan hasil untuk pengguna dan karakteristik model terdokumentasi.',
        fields: <ModuleField>[
          ModuleField(
            key: 'user_outcomes',
            label: 'Hasil bagi Pengguna',
            hint:
                'Contoh: Pengguna mendapatkan rekomendasi yang relevan dan lebih cepat mengambil keputusan',
            icon: Icons.groups_rounded,
            type: ModuleFieldType.multiline,
          ),
          ModuleField(
            key: 'model_properties',
            label: 'Properti Model Kecerdasan',
            hint:
                'Contoh: Akurasi minimal 95%, latency rendah, dan mudah diaudit',
            icon: Icons.memory_rounded,
            type: ModuleFieldType.multiline,
          ),
        ],
      ),
    ],
  ),
  DashboardModule(
    id: 'intelligence-experience',
    step: '02',
    title: 'Intelligence Experience',
    subtitle: 'Rancang pengalaman kecerdasan yang dipakai user',
    description:
        'Dokumentasikan cara penyajian kecerdasan, fungsi inti, strategi pengurangan error, dan pengumpulan data evaluasi.',
    icon: Icons.auto_awesome_rounded,
    accent: Color(0xFF2563EB),
    highlights: <String>[
      'Automate / Prompt / Organisation / Annotate',
      'Fungsi pendukung objective',
      'Mitigasi kesalahan',
      'Data improvement loop',
    ],
    sections: <ModuleSection>[
      ModuleSection(
        title: 'Penyajian Kecerdasan',
        description:
            'Pilih bentuk pengalaman utama yang akan dirasakan pengguna.',
        fields: <ModuleField>[
          ModuleField(
            key: 'experience_mode',
            label: 'Mode Intelligence Experience',
            hint: 'Pilih bentuk penyajian kecerdasan',
            icon: Icons.tune_rounded,
            type: ModuleFieldType.dropdown,
            options: <String>['Automate', 'Prompt', 'Organisation', 'Annotate'],
          ),
          ModuleField(
            key: 'core_functions',
            label: 'Fungsi yang Merealisasikan Objective',
            hint:
                'Contoh: rekomendasi otomatis, ringkasan keputusan, atau klasifikasi kasus prioritas',
            icon: Icons.widgets_rounded,
            type: ModuleFieldType.multiline,
          ),
        ],
      ),
      ModuleSection(
        title: 'Mitigasi Kesalahan',
        description:
            'Catat kontrol yang menurunkan risiko output model yang tidak tepat.',
        fields: <ModuleField>[
          ModuleField(
            key: 'error_reduction',
            label: 'Cara Meminimalkan Kesalahan',
            hint:
                'Contoh: human review, threshold confidence, fallback manual, audit log',
            icon: Icons.shield_outlined,
            type: ModuleFieldType.multiline,
          ),
          ModuleField(
            key: 'data_collection',
            label: 'Pengumpulan Data Perbaikan',
            hint:
                'Contoh: feedback pengguna, log kegagalan, koreksi operator, data retraining',
            icon: Icons.dataset_linked_rounded,
            type: ModuleFieldType.multiline,
          ),
        ],
      ),
    ],
  ),
  DashboardModule(
    id: 'intelligence-implementation',
    step: '03',
    title: 'Intelligence Implementation',
    subtitle: 'Susun proses bisnis dan teknologi implementasi',
    description:
        'Merekam proses bisnis, teknologi di setiap tahap, dan titik proses yang membuat keseluruhan sistem menjadi cerdas.',
    icon: Icons.settings_suggest_rounded,
    accent: Color(0xFF2563EB),
    highlights: <String>[
      'Proses bisnis sistem cerdas',
      'Teknologi di tiap proses',
      'Titik kecerdasan utama',
    ],
    sections: <ModuleSection>[
      ModuleSection(
        title: 'Peta Proses',
        description: 'Jelaskan urutan proses dari input hingga keputusan.',
        fields: <ModuleField>[
          ModuleField(
            key: 'business_process',
            label: 'Proses Bisnis Sistem Cerdas',
            hint:
                'Contoh: data masuk, validasi, inferensi, review operator, keputusan akhir',
            icon: Icons.account_tree_rounded,
            type: ModuleFieldType.multiline,
          ),
          ModuleField(
            key: 'intelligence_point',
            label: 'Proses yang Menjadikan Sistem Cerdas',
            hint:
                'Contoh: scoring otomatis, ranking prioritas, atau ekstraksi insight',
            icon: Icons.psychology_alt_rounded,
            type: ModuleFieldType.multiline,
          ),
        ],
      ),
      ModuleSection(
        title: 'Teknologi',
        description: 'Petakan stack yang dipakai di setiap komponen.',
        fields: <ModuleField>[
          ModuleField(
            key: 'process_technology',
            label: 'Teknologi Setiap Proses',
            hint:
                'Contoh: Flutter untuk UI, API gateway, model ML, vector DB, monitoring',
            icon: Icons.developer_board_rounded,
            type: ModuleFieldType.multiline,
          ),
          ModuleField(
            key: 'integration_note',
            label: 'Catatan Integrasi',
            hint:
                'Contoh: integrasi dengan ERP, CRM, atau sistem approval internal',
            icon: Icons.hub_rounded,
            type: ModuleFieldType.multiline,
          ),
        ],
      ),
    ],
  ),
  DashboardModule(
    id: 'constraints-status',
    step: '04',
    title: 'Batasan & Status Pengembangan',
    subtitle: 'Pantau hambatan dan progres modul cerdas',
    description:
        'Mencatat faktor pembatas pengembangan serta status realisasi modul cerdas yang sedang dibangun.',
    icon: Icons.rule_folder_outlined,
    accent: Color(0xFF2563EB),
    highlights: <String>[
      'Batasan teknis dan operasional',
      'Status modul cerdas',
      'Risiko implementasi',
    ],
    sections: <ModuleSection>[
      ModuleSection(
        title: 'Batasan Pengembangan',
        description:
            'Tuliskan constraint utama yang paling memengaruhi delivery.',
        fields: <ModuleField>[
          ModuleField(
            key: 'technical_constraints',
            label: 'Batasan Teknis',
            hint:
                'Contoh: kualitas data rendah, keterbatasan infrastruktur, atau akses API',
            icon: Icons.build_circle_outlined,
            type: ModuleFieldType.multiline,
          ),
          ModuleField(
            key: 'operational_constraints',
            label: 'Batasan Operasional',
            hint:
                'Contoh: SOP belum siap, tim reviewer terbatas, atau regulasi internal',
            icon: Icons.warning_amber_rounded,
            type: ModuleFieldType.multiline,
          ),
        ],
      ),
      ModuleSection(
        title: 'Status Realisasi',
        description: 'Simpan status modul yang sedang dikerjakan.',
        fields: <ModuleField>[
          ModuleField(
            key: 'module_name',
            label: 'Nama Modul Cerdas',
            hint: 'Contoh: Smart Recommendation Engine',
            icon: Icons.extension_rounded,
          ),
          ModuleField(
            key: 'implementation_status',
            label: 'Status Realisasi',
            hint: 'Pilih status saat ini',
            icon: Icons.flag_circle_rounded,
            type: ModuleFieldType.dropdown,
            options: <String>[
              'Belum Dimulai',
              'Perancangan',
              'Dalam Pengembangan',
              'Uji Coba',
              'Selesai',
            ],
          ),
          ModuleField(
            key: 'status_note',
            label: 'Catatan Progres',
            hint: 'Contoh: model baseline selesai, integrasi API minggu depan',
            icon: Icons.sticky_note_2_outlined,
            type: ModuleFieldType.multiline,
          ),
        ],
      ),
    ],
  ),
  DashboardModule(
    id: 'implementation-planning',
    step: '05',
    title: 'Perencanaan Implementasi',
    subtitle: 'Tetapkan deployment, maintenance, dan operasi',
    description:
        'Mencatat rencana deployment, pemeliharaan sistem cerdas, dan penanggung jawab operasional pasca rilis.',
    icon: Icons.rocket_launch_outlined,
    accent: Color(0xFF2563EB),
    highlights: <String>['Deployment plan', 'Maintenance plan', 'Tim operasi'],
    sections: <ModuleSection>[
      ModuleSection(
        title: 'Go Live Plan',
        description:
            'Pastikan rencana implementasi terdokumentasi dengan jelas.',
        fields: <ModuleField>[
          ModuleField(
            key: 'deployment_plan',
            label: 'Pelaksanaan Deployment',
            hint:
                'Contoh: pilot terbatas, staging validation, rollout bertahap per divisi',
            icon: Icons.cloud_upload_rounded,
            type: ModuleFieldType.multiline,
          ),
          ModuleField(
            key: 'maintenance_plan',
            label: 'Pemeliharaan Sistem Cerdas',
            hint:
                'Contoh: monitoring mingguan, retraining bulanan, backup dan incident response',
            icon: Icons.handyman_rounded,
            type: ModuleFieldType.multiline,
          ),
        ],
      ),
      ModuleSection(
        title: 'Operasional',
        description:
            'Tentukan siapa yang menjalankan, mengawasi, dan mengevaluasi sistem.',
        fields: <ModuleField>[
          ModuleField(
            key: 'operations_owner',
            label: 'Pelaksana Operasi Sistem',
            hint:
                'Contoh: AI Ops Team, Product Owner, Supervisor Layanan Pelanggan',
            icon: Icons.manage_accounts_rounded,
            type: ModuleFieldType.multiline,
          ),
          ModuleField(
            key: 'evaluation_schedule',
            label: 'Jadwal Evaluasi',
            hint:
                'Contoh: review performa setiap Jumat dan evaluasi model setiap akhir bulan',
            icon: Icons.calendar_month_rounded,
            type: ModuleFieldType.multiline,
          ),
        ],
      ),
    ],
  ),
];
