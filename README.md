<p align="center">
  <img src="https://img.shields.io/badge/Flutter-02569B?style=for-the-badge&logo=flutter&logoColor=white" />
  <img src="https://img.shields.io/badge/Dart-0175C2?style=for-the-badge&logo=dart&logoColor=white" />
  <img src="https://img.shields.io/badge/Django-092E20?style=for-the-badge&logo=django&logoColor=white" />
  <img src="https://img.shields.io/badge/REST_API-FF6F00?style=for-the-badge&logo=fastapi&logoColor=white" />
</p>

# 🏗️ Intelligence Engineering — Mobile

> **Subsistem Perencanaan & Perancangan Proyek AI**
> 
> Bagian dari ekosistem **Intelligence Engineerings** — Platform Terintegrasi untuk Siklus Hidup Pengembangan Kecerdasan Buatan.

---

## 📖 Tentang Proyek

**Intelligence Engineerings** adalah sebuah platform terintegrasi yang dirancang untuk mendukung seluruh siklus hidup (*lifecycle*) pengembangan proyek berbasis kecerdasan buatan (AI). Platform ini dikembangkan sebagai bagian dari mata kuliah **Praktikum Rekayasa Perangkat Lunak** di **Universitas Trisakti**, dengan tujuan memberikan pengalaman langsung kepada mahasiswa dalam membangun sistem perangkat lunak berskala besar yang saling terintegrasi.

Platform ini terdiri dari **5 subsistem** yang masing-masing menangani fase berbeda dalam *lifecycle* pengembangan AI:

| # | Subsistem | Deskripsi |
|---|-----------|-----------|
| 1 | **Intelligence Engineering** | Perencanaan & perancangan blueprint proyek AI |
| 2 | **Project Management** | Manajemen proyek, tugas, dan timeline |
| 3 | **Intelligence Creation** | Pembuatan & pelatihan model machine learning |
| 4 | **Dataset Management** | Pengelolaan dataset dan distribusi data |
| 5 | **Implementation** | Deployment, monitoring, dan pemeliharaan model AI |

Aplikasi mobile ini merupakan **companion app** untuk subsistem **Intelligence Engineering**, yang memungkinkan pengguna untuk merancang dan mengelola blueprint proyek AI langsung dari perangkat mobile.

---

## ✨ Fitur Utama

- 🧙 **Project Creation Wizard** — Pembuatan proyek AI melalui wizard langkah-demi-langkah yang intuitif
- 🎯 **Meaningful Objectives** — Pendefinisian tujuan proyek berbasis kerangka CERDAS
- 🧠 **Intelligence Experience** — Analisis pengalaman dan kebutuhan intelijen
- ⚙️ **Implementation Planning** — Perencanaan implementasi teknis
- 📊 **Constraints & Status** — Manajemen batasan dan status proyek
- 🔗 **Cross-System Integration** — Sinkronisasi otomatis dengan Project Management & Intelligence Creation
- 📱 **Responsive Design** — UI modern dengan Material Design 3

---

## 🛠️ Tech Stack

| Teknologi | Versi | Keterangan |
|-----------|-------|------------|
| Flutter | 3.x | Framework UI cross-platform |
| Dart | 3.x | Bahasa pemrograman |
| Provider | Latest | State management |
| HTTP | Latest | REST API communication |
| Django REST API | 5.x | Backend server |

---

## 🚀 Getting Started

### Prerequisites

- [Flutter SDK](https://docs.flutter.dev/get-started/install) (>= 3.0.0)
- [Android Studio](https://developer.android.com/studio) atau [VS Code](https://code.visualstudio.com/)
- Android Emulator atau physical device

### Installation

```bash
# Clone repository
git clone https://github.com/faturrachmanhuda/intelligence-engineering-mobile.git

# Masuk ke direktori proyek
cd intelligence-engineering-mobile

# Install dependencies
flutter pub get

# Jalankan aplikasi
flutter run
```

### Konfigurasi API

Sesuaikan base URL API di `lib/services/api_service.dart`:
```dart
static const String baseUrl = 'http://38.47.94.194/tif2/engineering';
```

---

## 📁 Struktur Proyek

```
lib/
├── main.dart                    # Entry point
├── main_app.dart                # App configuration
├── dashboard_page.dart          # Halaman dashboard utama
├── login_page.dart              # Autentikasi pengguna
├── register_page.dart           # Registrasi akun
├── profile_page.dart            # Profil pengguna
├── models/                      # Data models
│   ├── project_model.dart
│   └── wizard_step_model.dart
├── services/                    # API & business logic
│   ├── api_service.dart
│   ├── auth_service.dart
│   └── project_api_service.dart
├── viewmodels/                  # State management (MVVM)
│   ├── dashboard_viewmodel.dart
│   └── wizard/
│       ├── wizard_viewmodel.dart
│       └── step_viewmodels.dart
├── views/                       # UI screens
│   └── wizard/
│       ├── wizard_page.dart
│       ├── project_creation_step.dart
│       ├── meaningful_objectives_step.dart
│       ├── intelligence_experience_step.dart
│       ├── implementation_planning_step.dart
│       └── constraints_status_step.dart
└── widgets/                     # Reusable widgets
    └── background_gradient.dart
```

---

## 📚 Dokumentasi

| Dokumen | Link |
|---------|------|
| 📘 User Guide | [Download PDF](https://drive.google.com/file/d/1WTeHLY9JuE3rY4PTO3hp7VTAXNJax0UE/view?usp=sharing) |
| 📐 UML Diagrams (APPL) | [Download PDF](https://drive.google.com/file/d/1feMkxV2QAGJ4yXbWxB_K1bZZDuGjGf61/view?usp=sharing) |
| 🎨 Figma Design | [Open in Figma](https://www.figma.com/design/hf44nu47pby70p3se21fSj/Untitled?node-id=0-1&t=1Udfm1RHOPRNGRU6-1) |
| 🌐 Web Demo | [Open Web App](http://38.47.94.194/tif2/engineering/) |

> **User Guide** berisi panduan lengkap penggunaan aplikasi, termasuk langkah-langkah pembuatan proyek, navigasi fitur, dan troubleshooting umum.
>
> **UML Diagrams (APPL)** berisi dokumentasi arsitektur sistem yang mencakup Use Case Diagram, Sequence Diagram, Activity Diagram, Class Diagram, dan Component Diagram.

---

## 🔗 Subsistem Terkait

| Subsistem | Repository | Web Demo |
|-----------|------------|----------|
| Intelligence Engineering | 📍 *You are here* | [🌐 Demo](http://38.47.94.194/tif2/engineering/) |
| Project Management | [GitHub](https://github.com/faturrachmanhuda/project-management-mobile) | [🌐 Demo](http://38.47.94.194/tif2/pm/) |
| Intelligence Creation | [GitHub](https://github.com/faturrachmanhuda/intelligence-creation-mobile) | [🌐 Demo](http://38.47.94.194/tif2/creation/) |
| Dataset Management | [GitHub](https://github.com/faturrachmanhuda/dataset-management-mobile) | [🌐 Demo](http://38.47.94.194/tif2/dataset/) |
| Implementation | [GitHub](https://github.com/faturrachmanhuda/implementation-mobile) | [🌐 Demo](http://38.47.94.194/tif2/implementation/) |

---

## 👥 Tim Pengembang

Dikembangkan oleh mahasiswa **Universitas Trisakti** — Fakultas Teknologi Industri, Program Studi Teknik Informatika.

---

## 📄 Lisensi

Proyek ini dikembangkan untuk keperluan akademis dalam rangka mata kuliah **Praktikum Rekayasa Perangkat Lunak**.

---

<p align="center">
  <b>Intelligence Engineerings</b> — Integrated AI Development Lifecycle Platform<br/>
  <sub>Universitas Trisakti • 2024/2025</sub>
</p>
