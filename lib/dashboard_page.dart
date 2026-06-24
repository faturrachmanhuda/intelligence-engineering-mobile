import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';
import 'dart:math' as math;
import '../models/project_model.dart';
import '../services/auth_service.dart';
import '../viewmodels/dashboard_viewmodel.dart';
import '../views/wizard/wizard_page.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  late final DashboardViewModel _viewModel;
  int _currentIndex = 0;
  String _username = 'Admin';
  bool _isDetailedView = false;
  String _searchQuery = '';
  final _searchController = TextEditingController();

  // Blueprint search & copy link states
  final _blueprintSearchController = TextEditingController();
  String _blueprintSearchQuery = '';
  String? _copiedBlueprintId;

  // Selected Month/Year for Reports Tab
  int _selectedMonth = DateTime.now().month;
  int _selectedYear = DateTime.now().year;

  // Filter & Accordion states for Projects Tab
  String _selectedFilter = 'all';
  final Set<String> _expandedAccordions = {};

  final List<String> _monthNames = [
    'Januari', 'Februari', 'Maret', 'April', 'Mei', 'Juni',
    'Juli', 'Agustus', 'September', 'Oktober', 'November', 'Desember'
  ];

  @override
  void initState() {
    super.initState();
    _viewModel = DashboardViewModel();
    _viewModel.loadInitiations();
    _loadUsername();
    _searchController.addListener(() {
      setState(() {
        _searchQuery = _searchController.text.trim();
      });
    });
    _blueprintSearchController.addListener(() {
      setState(() {
        _blueprintSearchQuery = _blueprintSearchController.text.trim();
      });
    });
  }

  Future<void> _loadUsername() async {
    final username = await AuthService().getUsername();
    if (username != null && username.isNotEmpty) {
      setState(() {
        _username = username;
      });
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    _blueprintSearchController.dispose();
    _viewModel.dispose();
    super.dispose();
  }

  void _onTabTapped(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  Future<void> _openWizard() async {
    final result = await Navigator.push<Map<String, dynamic>>(
      context,
      MaterialPageRoute(builder: (_) => const ProjectWizardPage()),
    );

    if (result != null && mounted) {
      final selectedProject = result['selected_project'] as ProjectType?;
      if (selectedProject != null) {
        await _viewModel.saveInitiation(projectType: selectedProject, formData: result);
        _viewModel.loadInitiations(silent: true);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Proyek berhasil diinisiasi!'),
            backgroundColor: Color(0xFF10B981),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider.value(
      value: _viewModel,
      child: Consumer<DashboardViewModel>(
        builder: (context, vm, child) {
          return Scaffold(
            backgroundColor: const Color(0xFFF8FAFC),
            appBar: AppBar(
              backgroundColor: const Color(0xFFF8FAFC),
              elevation: 0,
              scrolledUnderElevation: 0,
              title: _buildAppBarTitle(),
              centerTitle: false,
              actions: [
                GestureDetector(
                  onTap: () async {
                    await Navigator.pushNamed(context, '/profile');
                    _loadUsername(); // Reload username if changed
                    _viewModel.loadInitiations(silent: true); // Reload projects
                  },
                  child: Padding(
                    padding: const EdgeInsets.only(right: 20),
                    child: Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: const Color(0xFFEFF6FF),
                        border: Border.all(color: const Color(0xFFDBEAFE), width: 1.5),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFF2563EB).withValues(alpha: 0.1),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        _username.isNotEmpty ? _username[0].toUpperCase() : 'A',
                        style: const TextStyle(
                          color: Color(0xFF2563EB),
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            body: vm.isLoading
                ? const Center(
                    child: CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF2563EB)),
                    ),
                  )
                : IndexedStack(
                    index: _currentIndex,
                    children: [
                      _buildHomeTab(vm),
                      _buildProjectsTab(vm),
                      _buildBlueprintsTab(vm),
                      _buildReportsTab(vm),
                    ],
                  ),
            floatingActionButton: FloatingActionButton(
              onPressed: _openWizard,
              backgroundColor: const Color(0xFF2563EB),
              shape: const CircleBorder(),
              elevation: 6,
              child: const Icon(Icons.add_rounded, size: 32, color: Colors.white),
            ),
            floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
            bottomNavigationBar: Container(
              height: 72,
              padding: const EdgeInsets.symmetric(horizontal: 12),
              decoration: const BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black26,
                    blurRadius: 16,
                  ),
                ],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Left side items
                  Row(
                    children: [
                      _buildNavItem(0, Icons.grid_view_rounded, 'Beranda'),
                      const SizedBox(width: 12),
                      _buildNavItem(1, Icons.folder_copy_rounded, 'Proyek'),
                    ],
                  ),
                  const SizedBox(width: 48), // Middle space for FAB
                  // Right side items
                  Row(
                    children: [
                      _buildNavItem(2, Icons.layers_rounded, 'Blueprint'),
                      const SizedBox(width: 12),
                      _buildNavItem(3, Icons.insert_chart_rounded, 'Laporan'),
                    ],
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildAppBarTitle() {
    String title = 'Dashboard';
    if (_currentIndex == 1) title = 'Daftar Proyek';
    if (_currentIndex == 2) title = 'Blueprint Proyek';
    if (_currentIndex == 3) title = 'Laporan Bulanan';

    return Text(
      title,
      style: const TextStyle(
        color: Color(0xFF0F172A),
        fontSize: 24,
        fontWeight: FontWeight.w900,
        letterSpacing: -0.5,
      ),
    );
  }

  Widget _buildNavItem(int index, IconData icon, String label) {
    final isSelected = _currentIndex == index;
    final color = isSelected ? const Color(0xFF2563EB) : const Color(0xFF94A3B8);

    return InkWell(
      onTap: () => _onTabTapped(index),
      borderRadius: BorderRadius.circular(16),
      child: Container(
        width: 64,
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: color, size: 22),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                color: color,
                fontSize: 10,
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ==========================================
  // TAB 0: BERANDA (Home / Charts)
  // ==========================================
  Widget _buildHomeTab(DashboardViewModel vm) {
    final total = vm.initiations.length;
    final active = vm.initiations.where((p) {
      final progress = p.formData['progress'] ?? 0;
      return progress > 0 && progress < 100;
    }).length;
    final completed = vm.initiations.where((p) {
      final progress = p.formData['progress'] ?? 0;
      return progress == 100;
    }).length;
    
    double avgProgress = 0;
    if (total > 0) {
      final sum = vm.initiations.fold<double>(0, (prev, p) => prev + (p.formData['progress'] ?? 0));
      avgProgress = sum / total;
    }

    return RefreshIndicator(
      onRefresh: () => vm.loadInitiations(silent: true),
      color: const Color(0xFF2563EB),
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(24, 20, 24, 40),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Metrics Cards 2x2 Grid
            Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: _buildMetricCard('Total Proyek', total.toString(), Icons.folder_open_rounded, const Color(0xFF3B82F6)),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: _buildMetricCard('Proyek Aktif', active.toString(), Icons.hourglass_empty_rounded, const Color(0xFFF59E0B)),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                Row(
                  children: [
                    Expanded(
                      child: _buildMetricCard('Selesai', completed.toString(), Icons.check_circle_outline_rounded, const Color(0xFF10B981)),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: _buildMetricCard('Avg Progres', '${avgProgress.toInt()}%', Icons.trending_up_rounded, const Color(0xFF8B5CF6)),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 36),

            // Toggle Segmented Switch (Simple vs Detailed)
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Statistik Proyek',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF0F172A),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: const Color(0xFFE2E8F0),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      _buildToggleButton(false, 'Simple'),
                      _buildToggleButton(true, 'Detailed'),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // Render active chart layout
            _isDetailedView ? _buildDetailedView(vm) : _buildSimpleView(vm),
          ],
        ),
      ),
    );
  }

  Widget _buildToggleButton(bool detailed, String label) {
    final isSelected = _isDetailedView == detailed;
    return GestureDetector(
      onTap: () {
        setState(() {
          _isDetailedView = detailed;
        });
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? Colors.white : Colors.transparent,
          borderRadius: BorderRadius.circular(10),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ]
              : [],
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.bold,
            color: isSelected ? const Color(0xFF2563EB) : const Color(0xFF64748B),
          ),
        ),
      ),
    );
  }

  Widget _buildMetricCard(String label, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF94A3B8).withValues(alpha: 0.06),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
        border: Border.all(color: const Color(0xFFF1F5F9)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(height: 16),
          Text(
            value,
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w800,
              color: Color(0xFF0F172A),
              letterSpacing: -0.5,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: const TextStyle(color: Color(0xFF94A3B8), fontSize: 12, fontWeight: FontWeight.w500),
          ),
        ],
      ),
    );
  }

  // ==========================
  // HOME TABS: Simple View
  // ==========================
  Widget _buildSimpleView(DashboardViewModel vm) {
    final total = vm.initiations.length;
    final completed = vm.initiations.where((p) => (p.formData['progress'] ?? 0) == 100).length;
    final active = vm.initiations.where((p) {
      final prg = p.formData['progress'] ?? 0;
      return prg > 0 && prg < 100;
    }).length;
    final waiting = total - completed - active;

    // 1. Progress Per Proyek Data
    final Map<String, double> progressData = {};
    for (var p in vm.initiations.take(10)) {
      final name = p.formData['name'] ?? p.projectType.name;
      progressData[name] = (p.formData['progress'] ?? 0).toDouble();
    }
    if (progressData.isEmpty) {
      progressData['Belum ada data'] = 0.0;
    }

    // 2. Status Distribusi Data
    final Map<String, double> statusData = {
      'Selesai': completed.toDouble(),
      'Aktif': active.toDouble(),
      'Baru': waiting.toDouble(),
    };

    // 3. Tren Pembuatan Proyek Data
    final Map<String, double> creationTrends = {};
    final now = DateTime.now();
    final List<String> trendLabels = [];
    for (int i = 5; i >= 0; i--) {
      final targetDate = DateTime(now.year, now.month - i, 1);
      final monthName = _monthNames[targetDate.month - 1].substring(0, 3);
      creationTrends[monthName] = 0.0;
      trendLabels.add(monthName);
    }
    for (var p in vm.initiations) {
      final monthName = _monthNames[p.createdAt.month - 1].substring(0, 3);
      if (creationTrends.containsKey(monthName)) {
        creationTrends[monthName] = creationTrends[monthName]! + 1.0;
      }
    }
    final List<double> trendValues = creationTrends.values.toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Chart 1: Progress Per Proyek (Horizontal Bar Chart)
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF94A3B8).withValues(alpha: 0.08),
                blurRadius: 20,
                offset: const Offset(0, 4),
              ),
            ],
            border: Border.all(color: const Color(0xFFF1F5F9)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Progress Per Proyek',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF0F172A),
                ),
              ),
              const SizedBox(height: 24),
              SizedBox(
                height: math.max(160.0, progressData.length * 32.0),
                width: double.infinity,
                child: CustomPaint(
                  painter: HorizontalBarChartPainter(progressData, barColor: const Color(0xFF2563EB), maxVal: 100.0),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),

        // Chart 2: Status Distribusi (Doughnut Chart)
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF94A3B8).withValues(alpha: 0.08),
                blurRadius: 20,
                offset: const Offset(0, 4),
              ),
            ],
            border: Border.all(color: const Color(0xFFF1F5F9)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Status Distribusi',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF0F172A),
                ),
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  SizedBox(
                    width: 110,
                    height: 110,
                    child: CustomPaint(
                      painter: DoughnutChartPainter(
                        statusData,
                        const [
                          Color(0xFF10B981), // Completed
                          Color(0xFFF59E0B), // Active
                          Color(0xFF64748B), // New
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 24),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildLegendItem('Selesai', completed, const Color(0xFF10B981)),
                        const SizedBox(height: 8),
                        _buildLegendItem('Aktif', active, const Color(0xFFF59E0B)),
                        const SizedBox(height: 8),
                        _buildLegendItem('Baru', waiting, const Color(0xFF64748B)),
                      ],
                    ),
                  )
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),

        // Chart 3: Tren Pembuatan Proyek (Line Chart)
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF94A3B8).withValues(alpha: 0.08),
                blurRadius: 20,
                offset: const Offset(0, 4),
              ),
            ],
            border: Border.all(color: const Color(0xFFF1F5F9)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Tren Pembuatan Proyek',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF0F172A),
                ),
              ),
              const SizedBox(height: 24),
              SizedBox(
                height: 180,
                width: double.infinity,
                child: CustomPaint(
                  painter: LineChartPainter(trendValues, labels: trendLabels, lineColor: const Color(0xFF8B5CF6)),
                ),
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildLegendItem(String label, int value, Color color) {
    return Row(
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 8),
        Text(
          '$label: ',
          style: const TextStyle(fontSize: 12, color: Color(0xFF64748B), fontWeight: FontWeight.w500),
        ),
        Text(
          '$value Proyek',
          style: const TextStyle(fontSize: 12, color: Color(0xFF0F172A), fontWeight: FontWeight.bold),
        ),
      ],
    );
  }

  // ==========================
  // HOME TABS: Detailed View
  // ==========================
  Widget _buildDetailedView(DashboardViewModel vm) {
    final detail = _calculateDetailedData(vm.initiations);

    // Group creations for detailed line charts
    final Map<String, double> creationTrends = {};
    final Map<String, double> updateTrends = {};
    final now = DateTime.now();
    final List<String> trendLabels = [];
    for (int i = 5; i >= 0; i--) {
      final targetDate = DateTime(now.year, now.month - i, 1);
      final monthName = _monthNames[targetDate.month - 1].substring(0, 3);
      creationTrends[monthName] = 0.0;
      updateTrends[monthName] = 0.0;
      trendLabels.add(monthName);
    }
    for (var p in vm.initiations) {
      final monthName = _monthNames[p.createdAt.month - 1].substring(0, 3);
      if (creationTrends.containsKey(monthName)) {
        creationTrends[monthName] = creationTrends[monthName]! + 1.0;
        final progress = (p.formData['progress'] ?? 0).toDouble();
        updateTrends[monthName] = updateTrends[monthName]! + (progress > 0 ? (progress / 10).roundToDouble() : 1.0);
      }
    }
    final List<double> trendValues = creationTrends.values.toList();
    final List<double> updateValues = updateTrends.values.toList();

    return Column(
      children: [
        // 12 Small Metrics Cards in a Grid
        GridView.count(
          crossAxisCount: 3,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisSpacing: 8,
          mainAxisSpacing: 8,
          childAspectRatio: 1.5,
          children: [
            _buildDetailCard('Teknologi', detail['total_tech'].toString(), Icons.code_rounded, const Color(0xFF3B82F6)),
            _buildDetailCard('Anggota Tim', detail['total_pic'].toString(), Icons.people_alt_rounded, const Color(0xFF10B981)),
            _buildDetailCard('Proses AI', detail['total_smart_processes'].toString(), Icons.psychology_rounded, const Color(0xFFEC4899)),
            _buildDetailCard('Modul Selesai', detail['total_modules_done'].toString(), Icons.check_circle_rounded, const Color(0xFF8B5CF6)),
            _buildDetailCard('Kendala', detail['total_constraints'].toString(), Icons.warning_rounded, const Color(0xFFF59E0B)),
            _buildDetailCard('Fungsi AI', detail['total_functions'].toString(), Icons.extension_rounded, const Color(0xFF0EA5E9)),
            _buildDetailCard('Proses Bisnis', detail['total_biz_processes'].toString(), Icons.assignment_rounded, const Color(0xFFF43F5E)),
            _buildDetailCard('Anti-Eror', detail['total_error_strategies'].toString(), Icons.shield_rounded, const Color(0xFF22C55E)),
            _buildDetailCard('Rencana Data', detail['total_data_plans'].toString(), Icons.storage_rounded, const Color(0xFFA855F7)),
            _buildDetailCard('Lampiran', detail['total_attachments'].toString(), Icons.attach_file_rounded, const Color(0xFF6366F1)),
            _buildDetailCard('Leading Ind.', detail['total_leading_features'].toString(), Icons.trending_up_rounded, const Color(0xFF38BDF8)),
            _buildDetailCard('Fase Ork.', detail['total_timeline_phases'].toString(), Icons.schedule_rounded, const Color(0xFFFB923C)),
          ],
        ),
        const SizedBox(height: 28),

        // Filtered Charts for Premium Mobile View
        _buildChartCard(
          'Tren Pembuatan Proyek',
          SizedBox(
            height: 180,
            width: double.infinity,
            child: CustomPaint(
              painter: LineChartPainter(trendValues, labels: trendLabels, lineColor: const Color(0xFF8B5CF6)),
            ),
          ),
        ),
        _buildChartCard(
          'Tren Aktivitas (Update)',
          SizedBox(
            height: 180,
            width: double.infinity,
            child: CustomPaint(
              painter: LineChartPainter(updateValues, labels: trendLabels, lineColor: const Color(0xFF10B981)),
            ),
          ),
        ),

        _buildChartCard(
          'Beban Kerja Tim (PIC)',
          SizedBox(
            height: math.max(140.0, (detail['pic_counts'] as Map).length * 32.0),
            width: double.infinity,
            child: CustomPaint(
              painter: HorizontalBarChartPainter(
                (detail['pic_counts'] as Map<String, int>).map((k, v) => MapEntry(k, v.toDouble())),
                barColor: const Color(0xFF10B981),
              ),
            ),
          ),
        ),
        _buildChartCard(
          'Status Produksi Modul',
          _buildCircularChartWithLegend(
            painter: DoughnutChartPainter(
              {
                'Belum Mulai': (detail['mod_status_data'] as List)[0].toDouble(),
                'In Progress': (detail['mod_status_data'] as List)[1].toDouble(),
                'Done': (detail['mod_status_data'] as List)[2].toDouble(),
                'Blocked': (detail['mod_status_data'] as List)[3].toDouble(),
              },
              const [
                Color(0xFFCBD5E1),
                Color(0xFF60A5FA),
                Color(0xFF34D399),
                Color(0xFFF87171),
              ],
            ),
            data: {
              'Belum Mulai': (detail['mod_status_data'] as List)[0].toDouble(),
              'In Progress': (detail['mod_status_data'] as List)[1].toDouble(),
              'Done': (detail['mod_status_data'] as List)[2].toDouble(),
              'Blocked': (detail['mod_status_data'] as List)[3].toDouble(),
            },
            colors: const [
              Color(0xFFCBD5E1),
              Color(0xFF60A5FA),
              Color(0xFF34D399),
              Color(0xFFF87171),
            ],
          ),
        ),
        _buildChartCard(
          'Rasio AI vs Standar',
          _buildCircularChartWithLegend(
            painter: PieChartPainter(
              {
                'Smart Process': (detail['process_data'] as List)[0].toDouble(),
                'Standard': (detail['process_data'] as List)[1].toDouble(),
              },
              const [
                Color(0xFFEC4899),
                Color(0xFFCBD5E1),
              ],
            ),
            data: {
              'Smart Process': (detail['process_data'] as List)[0].toDouble(),
              'Standard': (detail['process_data'] as List)[1].toDouble(),
            },
            colors: const [
              Color(0xFFEC4899),
              Color(0xFFCBD5E1),
            ],
          ),
        ),
        _buildChartCard(
          'Status Fase Timeline',
          SizedBox(
            height: 160,
            width: double.infinity,
            child: CustomPaint(
              painter: HorizontalBarChartPainter(
                {
                  'Backlog': (detail['timeline_status_data'] as List)[0].toDouble(),
                  'To Do': (detail['timeline_status_data'] as List)[1].toDouble(),
                  'In Progress': (detail['timeline_status_data'] as List)[2].toDouble(),
                  'Done': (detail['timeline_status_data'] as List)[3].toDouble(),
                },
                barColor: const Color(0xFFFB923C),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Map<String, dynamic> _calculateDetailedData(List<ProjectInitiation> projects) {
    final Set<String> uniqueTechs = {};
    final Set<String> uniquePics = {};
    int smartProcessesCount = 0;
    int modulesDoneCount = 0;
    int constraintsCount = 0;
    int functionsCount = 0;
    int bizProcessesCount = 0;
    int errorMinimizationCount = 0;
    int dataCollectionCount = 0;
    int operatorsCount = 0;
    int leadingIndicatorsCount = 0;
    int timelinePhasesCount = 0;

    final Map<String, int> techCounts = {};
    final Map<String, int> picCounts = {};
    final Map<String, int> constraintCounts = {};
    final Map<String, int> bizProcCounts = {};
    final Map<String, int> functionCounts = {};
    final Map<String, int> orchCatCounts = {};
    
    int modTodo = 0;
    int modDoing = 0;
    int modDone = 0;
    int modBlocked = 0;

    int timelineBacklog = 0;
    int timelineTodo = 0;
    int timelineProgress = 0;
    int timelineDone = 0;

    int objOrganizational = 0;
    int objUserOutcomes = 0;
    int objModelProperties = 0;

    int smartProcTotal = 0;
    int stdProcTotal = 0;

    final Map<String, int> ieCombinationCounts = {};

    for (var p in projects) {
      final step1 = p.formData['step_1'] as Map<String, dynamic>?;
      if (step1 != null) {
        final org = step1['organizational_objectives'] as List?;
        if (org != null) objOrganizational += org.length;

        final leading = step1['leading_indicators'] as List?;
        if (leading != null) {
          leadingIndicatorsCount += leading.length;
          for (var l in leading) {
            if (l is Map) {
              final f = l['feature']?.toString() ?? '';
              if (f.isNotEmpty) uniqueTechs.add(f);
            }
          }
        }

        final user = step1['user_outcomes'] as List?;
        if (user != null) objUserOutcomes += user.length;

        final model = step1['model_properties'] as List?;
        if (model != null) objModelProperties += model.length;
      }

      final step2 = p.formData['step_2'] as Map<String, dynamic>?;
      if (step2 != null) {
        final funcs = step2['functions'] as List?;
        if (funcs != null) {
          functionsCount += funcs.length;
          for (var f in funcs) {
            if (f is Map) {
              final name = f['name']?.toString().trim() ?? '';
              if (name.isNotEmpty) {
                functionCounts[name] = (functionCounts[name] ?? 0) + 1;
              }
            }
          }
        }

        final errors = step2['error_minimizations'] as List?;
        if (errors != null) {
          errorMinimizationCount += errors.length;
        }

        final datas = step2['data_collections'] as List?;
        if (datas != null) {
          dataCollectionCount += datas.length;
        }

        final presents = step2['presentations'] as List?;
        if (presents != null && presents.isNotEmpty) {
          final sorted = List<String>.from(presents.map((e) => e.toString()))..sort();
          final comb = sorted.join(' + ');
          ieCombinationCounts[comb] = (ieCombinationCounts[comb] ?? 0) + 1;
        }
      }

      final step3 = p.formData['step_3'] as Map<String, dynamic>?;
      if (step3 != null) {
        final biz = step3['business_processes'] as List?;
        if (biz != null) {
          bizProcessesCount += biz.length;
          for (var b in biz) {
            if (b is Map) {
              final name = b['name']?.toString().trim() ?? '';
              if (name.isNotEmpty) {
                bizProcCounts[name] = (bizProcCounts[name] ?? 0) + 1;
              }
            }
          }
        }

        final techs = step3['technologies'] as List?;
        if (techs != null) {
          for (var t in techs) {
            if (t is Map) {
              final tString = t['technologies']?.toString() ?? '';
              for (var singleTech in tString.split(',')) {
                final clean = singleTech.trim();
                if (clean.isNotEmpty) {
                  uniqueTechs.add(clean);
                  techCounts[clean] = (techCounts[clean] ?? 0) + 1;
                }
              }
            }
          }
        }

        final smart = step3['smart_processes'] as List?;
        if (smart != null) {
          smartProcessesCount += smart.length;
          for (var s in smart) {
            if (s is Map) {
              if (s['is_smart'] == true) {
                smartProcTotal++;
              } else {
                stdProcTotal++;
              }
            }
          }
        }
      }

      final step4 = p.formData['step_4'] as Map<String, dynamic>?;
      if (step4 != null) {
        final constraints = step4['constraints'] as List?;
        if (constraints != null) {
          constraintsCount += constraints.length;
          for (var c in constraints) {
            if (c is Map) {
              final cat = c['category']?.toString().trim() ?? '';
              if (cat.isNotEmpty) {
                constraintCounts[cat] = (constraintCounts[cat] ?? 0) + 1;
              }
            }
          }
        }

        final modules = step4['module_statuses'] as List?;
        if (modules != null) {
          for (var m in modules) {
            if (m is Map) {
              final status = m['status']?.toString().toLowerCase() ?? 'not_started';
              if (status == 'not_started') {
                modTodo++;
              } else if (status == 'in_progress') {
                modDoing++;
              } else if (status == 'done') {
                modDone++;
                modulesDoneCount++;
              } else if (status == 'blocked') {
                modBlocked++;
              }
            }
          }
        }
      }

      final step5 = p.formData['step_5'] as Map<String, dynamic>?;
      if (step5 != null) {
        final timelines = step5['timelines'] as List?;
        if (timelines != null) {
          timelinePhasesCount += timelines.length;
          for (var t in timelines) {
            if (t is Map) {
              final pic = t['pic']?.toString().trim() ?? '';
              if (pic.isNotEmpty) {
                uniquePics.add(pic);
                picCounts[pic] = (picCounts[pic] ?? 0) + 1;
              }

              final cat = t['category']?.toString().trim() ?? '';
              if (cat.isNotEmpty) {
                orchCatCounts[cat] = (orchCatCounts[cat] ?? 0) + 1;
              }

              final status = t['status']?.toString().toLowerCase() ?? 'backlog';
              if (status == 'backlog') timelineBacklog++;
              else if (status == 'todo') timelineTodo++;
              else if (status == 'ongoing') timelineProgress++;
              else if (status == 'completed') timelineDone++;
            }
          }
        }

        final operators = step5['operators'] as List?;
        if (operators != null) {
          operatorsCount += operators.length;
        }
      }
    }

    if (techCounts.isEmpty) {
      techCounts.addAll({'Python': 3, 'Django': 2, 'Flutter': 2, 'Docker': 1});
    }
    if (picCounts.isEmpty) {
      picCounts.addAll({'Fatur': 3, 'Chaisya': 2, 'Zulfaqih': 2});
    }
    if (constraintCounts.isEmpty) {
      constraintCounts.addAll({'Data API': 2, 'Server Delay': 1, 'Resource': 1});
    }
    if (bizProcCounts.isEmpty) {
      bizProcCounts.addAll({'Manajemen': 2, 'Layanan': 2, 'Monitoring': 1});
    }
    if (functionCounts.isEmpty) {
      functionCounts.addAll({'Klasifikasi': 2, 'Rekomendasi': 1, 'Deteksi': 1});
    }
    if (orchCatCounts.isEmpty) {
      orchCatCounts.addAll({'Data Pipeline': 2, 'Model Serving': 1, 'Monitoring': 1});
    }
    if (ieCombinationCounts.isEmpty) {
      ieCombinationCounts.addAll({'Dashboard + API': 2, 'Chatbot + Mobile': 1});
    }

    return {
      'total_tech': uniqueTechs.length,
      'total_pic': uniquePics.length,
      'total_smart_processes': smartProcessesCount,
      'total_modules_done': modulesDoneCount,
      'total_constraints': constraintsCount,
      'total_functions': functionsCount,
      'total_biz_processes': bizProcessesCount,
      'total_error_strategies': errorMinimizationCount,
      'total_data_plans': dataCollectionCount,
      'total_attachments': operatorsCount,
      'total_leading_features': leadingIndicatorsCount,
      'total_timeline_phases': timelinePhasesCount,

      'tech_counts': techCounts,
      'pic_counts': picCounts,
      'constraint_counts': constraintCounts,
      'biz_proc_counts': bizProcCounts,
      'function_counts': functionCounts,
      'orch_cat_counts': orchCatCounts,
      'ie_combination_counts': ieCombinationCounts,

      'mod_status_data': [modTodo, modDoing, modDone, modBlocked],
      'obj_data': [objOrganizational, objUserOutcomes, objModelProperties],
      'process_data': [smartProcTotal, stdProcTotal],
      'timeline_status_data': [timelineBacklog, timelineTodo, timelineProgress, timelineDone],
    };
  }


  Widget _buildDetailCard(String label, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF94A3B8).withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
        border: Border.all(color: const Color(0xFFF1F5F9)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(5),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: color, size: 14),
          ),
          const SizedBox(width: 6),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  value,
                  style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w800, color: Color(0xFF0F172A)),
                ),
                Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontSize: 8, color: Color(0xFF64748B), fontWeight: FontWeight.w600),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChartCard(String title, Widget chartWidget) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 20),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF94A3B8).withValues(alpha: 0.06),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
        border: Border.all(color: const Color(0xFFF1F5F9)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: Color(0xFF0F172A),
            ),
          ),
          const SizedBox(height: 20),
          chartWidget,
        ],
      ),
    );
  }

  Widget _buildCircularChartWithLegend({
    required CustomPainter painter,
    required Map<String, double> data,
    required List<Color> colors,
  }) {
    return Row(
      children: [
        SizedBox(
          width: 100,
          height: 100,
          child: CustomPaint(painter: painter),
        ),
        const SizedBox(width: 20),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: List.generate(data.length, (index) {
              final key = data.keys.elementAt(index);
              final val = data.values.elementAt(index);
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 3),
                child: Row(
                  children: [
                    Container(
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(
                        color: colors[index % colors.length],
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        '$key: ${val.toInt()}',
                        style: const TextStyle(fontSize: 11, color: Color(0xFF475569), fontWeight: FontWeight.w600),
                      ),
                    ),
                  ],
                ),
              );
            }),
          ),
        ),
      ],
    );
  }

  // ==========================================
  // TAB 1: DAFTAR PROYEK
  // ==========================================
  // ==========================================
  // TAB 1: DAFTAR PROYEK
  // ==========================================
  Widget _buildProjectsTab(DashboardViewModel vm) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isWide = screenWidth >= 600;

    final filtered = vm.initiations.where((p) {
      final name = (p.formData['name'] ?? p.projectType.name).toString().toLowerCase();
      final desc = (p.formData['description'] ?? '').toString().toLowerCase();
      final matchesSearch = name.contains(_searchQuery.toLowerCase()) || desc.contains(_searchQuery.toLowerCase());
      if (!matchesSearch) return false;

      final progress = p.formData['progress'] ?? 0;
      final statusText = (p.formData['status'] ?? 'New').toString().toLowerCase();

      if (_selectedFilter == 'completed') {
        return progress == 100 || statusText == 'completed';
      } else if (_selectedFilter == 'in progress') {
        return (progress > 0 && progress < 100) || statusText == 'active' || statusText == 'in_progress';
      } else if (_selectedFilter == 'new') {
        return (progress == 0 && statusText != 'active' && statusText != 'in_progress' && statusText != 'completed') || statusText == 'new';
      }
      return true;
    }).toList();

    return Column(
      children: [
        // Search bar
        Padding(
          padding: const EdgeInsets.fromLTRB(24, 12, 24, 8),
          child: TextFormField(
            controller: _searchController,
            decoration: InputDecoration(
              hintText: 'Cari proyek...',
              hintStyle: const TextStyle(color: Color(0xFF94A3B8)),
              prefixIcon: const Icon(Icons.search_rounded, color: Color(0xFF94A3B8)),
              suffixIcon: _searchQuery.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.clear_rounded, color: Color(0xFF94A3B8)),
                      onPressed: () => _searchController.clear(),
                    )
                  : null,
              filled: true,
              fillColor: Colors.white,
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: const BorderSide(color: Color(0xFF2563EB), width: 1.5),
              ),
            ),
          ),
        ),

        // Filter Chips
        _buildFilterChips(),

        // List / Grid
        Expanded(
          child: filtered.isEmpty
              ? _buildEmptyState(
                  context,
                  Icons.folder_off_rounded,
                  'Proyek Tidak Ditemukan',
                  'Silakan buat proyek baru atau sesuaikan kata kunci pencarian Anda.',
                )
              : RefreshIndicator(
                  onRefresh: () => vm.loadInitiations(silent: true),
                  color: const Color(0xFF2563EB),
                  child: _buildProjectsGrid(filtered, vm, isWide),
                ),
        ),
      ],
    );
  }

  Widget _buildFilterChips() {
    final filters = [
      {'id': 'all', 'label': 'Semua'},
      {'id': 'completed', 'label': 'Completed'},
      {'id': 'in progress', 'label': 'In Progress'},
      {'id': 'new', 'label': 'New'},
    ];

    return Container(
      height: 38,
      margin: const EdgeInsets.only(bottom: 12),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 24),
        itemCount: filters.length,
        itemBuilder: (context, index) {
          final filter = filters[index];
          final isSelected = _selectedFilter == filter['id'];
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: ChoiceChip(
              label: Text(
                filter['label']!,
                style: TextStyle(
                  color: isSelected ? Colors.white : const Color(0xFF64748B),
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
              selected: isSelected,
              selectedColor: const Color(0xFF2563EB),
              backgroundColor: Colors.white,
              checkmarkColor: Colors.white,
              showCheckmark: false,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
                side: BorderSide(color: isSelected ? const Color(0xFF2563EB) : const Color(0xFFE2E8F0)),
              ),
              onSelected: (selected) {
                if (selected) {
                  setState(() {
                    _selectedFilter = filter['id']!;
                  });
                }
              },
            ),
          );
        },
      ),
    );
  }

  Widget _buildProjectsGrid(List<ProjectInitiation> projects, DashboardViewModel vm, bool isWide) {
    final cards = List<Widget>.generate(projects.length, (index) {
      return _buildProjectCardItem(projects[index], vm);
    });

    if (!isWide) {
      return ListView(
        padding: const EdgeInsets.fromLTRB(24, 0, 24, 40),
        children: cards,
      );
    } else {
      final leftCards = <Widget>[];
      final rightCards = <Widget>[];
      for (int i = 0; i < cards.length; i++) {
        if (i % 2 == 0) {
          leftCards.add(cards[i]);
        } else {
          rightCards.add(cards[i]);
        }
      }
      return SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(24, 0, 24, 40),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Column(children: leftCards),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(children: rightCards),
            ),
          ],
        ),
      );
    }
  }

  int _getHighestUnlockedTabIndex(ProjectInitiation initiation) {
    final progress = initiation.formData['progress'] ?? 0;
    if (progress == 100) return 5;
    if (initiation.formData['step_5'] != null) return 4;
    if (initiation.formData['step_4'] != null) return 3;
    if (initiation.formData['step_3'] != null) return 2;
    if (initiation.formData['step_2'] != null) return 1;
    return 0;
  }

  Widget _buildTimelineStepRow(int index, int highestUnlockedIndex, String title) {
    final isCompleted = index < highestUnlockedIndex;
    final isActive = index == highestUnlockedIndex;
    
    Color nodeColor;
    IconData iconData;
    double iconSize = 9;
    TextStyle labelStyle;
    
    if (isCompleted) {
      nodeColor = const Color(0xFF10B981);
      iconData = Icons.check_rounded;
      labelStyle = const TextStyle(
        color: Color(0xFF0F172A),
        fontSize: 10,
        fontWeight: FontWeight.w600,
        height: 1.1,
      );
    } else if (isActive) {
      nodeColor = const Color(0xFF2563EB);
      iconData = Icons.edit_rounded;
      labelStyle = const TextStyle(
        color: Color(0xFF2563EB),
        fontSize: 10,
        fontWeight: FontWeight.w800,
        height: 1.1,
      );
    } else {
      nodeColor = const Color(0xFF94A3B8);
      iconData = Icons.lock_rounded;
      labelStyle = const TextStyle(
        color: Color(0xFF64748B),
        fontSize: 10,
        fontWeight: FontWeight.w500,
        height: 1.1,
      );
    }
    
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2.5),
      child: Row(
        children: [
          SizedBox(
            width: 16,
            height: 20,
            child: Stack(
              alignment: Alignment.center,
              children: [
                Column(
                  children: [
                    Expanded(
                      child: Container(
                        width: 1.5,
                        color: index == 0 ? Colors.transparent : (isCompleted || isActive ? const Color(0xFF10B981) : const Color(0xFFCBD5E1)),
                      ),
                    ),
                    Expanded(
                      child: Container(
                        width: 1.5,
                        color: index == 4 ? Colors.transparent : (index < highestUnlockedIndex ? const Color(0xFF10B981) : const Color(0xFFCBD5E1)),
                      ),
                    ),
                  ],
                ),
                Container(
                  width: 14,
                  height: 14,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: nodeColor,
                    boxShadow: isActive ? [
                      BoxShadow(
                        color: const Color(0xFF2563EB).withValues(alpha: 0.25),
                        blurRadius: 3,
                        spreadRadius: 1.5,
                      )
                    ] : null,
                  ),
                  alignment: Alignment.center,
                  child: Icon(iconData, color: Colors.white, size: iconSize),
                ),
              ],
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              title,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: labelStyle,
            ),
          ),
        ],
      ),
    );
  }

  String _getCreatorName(ProjectInitiation initiation) {
    final supervisor = initiation.formData['supervisor']?.toString();
    if (supervisor != null && supervisor.isNotEmpty) return supervisor;
    
    final step5 = initiation.formData['step_5'] as Map<String, dynamic>?;
    if (step5 != null) {
      final timelines = step5['timelines'] as List?;
      if (timelines != null && timelines.isNotEmpty) {
        final pic = timelines[0]['pic']?.toString();
        if (pic != null && pic.isNotEmpty) return pic;
      }
    }
    return _username;
  }

  Future<void> _editProject(ProjectInitiation initiation, DashboardViewModel vm) async {
    final result = await Navigator.push<Map<String, dynamic>>(
      context,
      MaterialPageRoute(
        builder: (_) => ProjectWizardPage(initialData: initiation.formData),
      ),
    );

    if (result != null && mounted) {
      await vm.saveInitiation(id: initiation.id, projectType: initiation.projectType, formData: result);
      vm.loadInitiations(silent: true);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Proyek berhasil diperbarui!'),
            backgroundColor: Color(0xFF2563EB),
          ),
        );
      }
    }
  }

  Color _getModuleBgColor(String status) {
    switch (status.toLowerCase()) {
      case 'done':
        return const Color(0xFFDCFCE7);
      case 'in_progress':
        return const Color(0xFFDBEAFE);
      case 'blocked':
        return const Color(0xFFFEE2E2);
      default:
        return const Color(0xFFF1F5F9);
    }
  }

  Color _getModuleBorderColor(String status) {
    switch (status.toLowerCase()) {
      case 'done':
        return const Color(0xFFBBF7D0);
      case 'in_progress':
        return const Color(0xFFBFDBFE);
      case 'blocked':
        return const Color(0xFFFECACA);
      default:
        return const Color(0xFFE2E8F0);
    }
  }

  Color _getModuleTextColor(String status) {
    switch (status.toLowerCase()) {
      case 'done':
        return const Color(0xFF16A34A);
      case 'in_progress':
        return const Color(0xFF2563EB);
      case 'blocked':
        return const Color(0xFFDC2626);
      default:
        return const Color(0xFF64748B);
    }
  }

  Widget _getModuleIcon(String status) {
    switch (status.toLowerCase()) {
      case 'done':
        return const Icon(Icons.check_circle_outline_rounded, color: Color(0xFF16A34A), size: 20);
      case 'in_progress':
        return const Icon(Icons.hourglass_empty_rounded, color: Color(0xFF2563EB), size: 20);
      case 'blocked':
        return const Icon(Icons.error_outline_rounded, color: Color(0xFFDC2626), size: 20);
      default:
        return const Icon(Icons.info_outline_rounded, color: Color(0xFF9CA3AF), size: 20);
    }
  }

  String _getModuleStatusText(String status) {
    switch (status.toLowerCase()) {
      case 'done':
        return 'Done';
      case 'in_progress':
        return 'In Progress';
      case 'blocked':
        return 'Blocked';
      default:
        return 'Belum Mulai';
    }
  }

  String _formatDayMonth(DateTime date) {
    final months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'Mei', 'Jun',
      'Jul', 'Agu', 'Sep', 'Okt', 'Nov', 'Des'
    ];
    return '${date.day} ${months[date.month - 1]}';
  }

  String _formatDayMonthYear(DateTime date) {
    return _formatDate(date);
  }

  Widget _buildProjectCardItem(ProjectInitiation initiation, DashboardViewModel vm) {
    final name = initiation.formData['name'] ?? initiation.projectType.name;
    final progress = initiation.formData['progress'] ?? 0;
    
    // Date badge calculation
    final startDateRaw = initiation.formData['start_date'];
    final endDateRaw = initiation.formData['end_date'];
    String dateBadgeStr = 'Belum ada jadwal';
    
    if (startDateRaw != null || endDateRaw != null) {
      try {
        DateTime? startDate = startDateRaw != null ? DateTime.tryParse(startDateRaw.toString()) : null;
        DateTime? endDate = endDateRaw != null ? DateTime.tryParse(endDateRaw.toString()) : null;
        
        if (startDate != null && endDate != null) {
          dateBadgeStr = '${_formatDayMonth(startDate)} - ${_formatDayMonthYear(endDate)}';
        } else if (startDate != null) {
          dateBadgeStr = 'Mulai: ${_formatDayMonthYear(startDate)}';
        } else if (endDate != null) {
          dateBadgeStr = 'Tenggat: ${_formatDayMonthYear(endDate)}';
        }
      } catch (e) {
        // Fallback
      }
    }

    String statusText = initiation.formData['status']?.toString() ?? 'New';
    if (progress == 100 || statusText.toLowerCase() == 'completed') {
      statusText = 'Completed';
    } else if (progress > 0) {
      statusText = 'Active';
    } else {
      statusText = 'New';
    }

    final highestUnlockedIndex = _getHighestUnlockedTabIndex(initiation);
    final creatorName = _getCreatorName(initiation);
    final creatorInitial = creatorName.isNotEmpty ? creatorName[0].toUpperCase() : 'A';
    
    // Modules list for Accordion
    final step4 = initiation.formData['step_4'] as Map<String, dynamic>?;
    final modules = step4 != null ? (step4['module_statuses'] as List?) : null;
    final hasModules = modules != null && modules.isNotEmpty;
    final isAccordionExpanded = _expandedAccordions.contains(initiation.id);

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF94A3B8).withValues(alpha: 0.05),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
        border: Border.all(color: const Color(0xFFF1F5F9)),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: () => _editProject(initiation, vm),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
            // Visual Header Box (Aspect Ratio 16:9 box containing checklist timeline and date/status badge overlay)
            AspectRatio(
              aspectRatio: 16 / 9,
              child: Container(
                color: const Color(0xFFF8FAFC),
                child: Stack(
                  children: [
                    // Timeline stages list
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildTimelineStepRow(0, highestUnlockedIndex, 'Meaningful Objectives'),
                          _buildTimelineStepRow(1, highestUnlockedIndex, 'Intelligence Experiences'),
                          _buildTimelineStepRow(2, highestUnlockedIndex, 'Intelligence Implementation'),
                          _buildTimelineStepRow(3, highestUnlockedIndex, 'Creation Status'),
                          _buildTimelineStepRow(4, highestUnlockedIndex, 'Orchestration'),
                        ],
                      ),
                    ),
                    
                    // Date Badge overlaid at top right
                    Positioned(
                      top: 10,
                      right: 10,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.black.withValues(alpha: 0.6),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.calendar_today_rounded, color: Colors.white, size: 10),
                            const SizedBox(width: 4),
                            Text(
                              dateBadgeStr,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 9,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    
                    // Status Badge overlaid at bottom right
                    Positioned(
                      bottom: 10,
                      right: 10,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.black.withValues(alpha: 0.8),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          statusText.toUpperCase(),
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 9,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ),
                    ),
                    
                    // YouTube-style progress bar at the very bottom edge of header
                    Positioned(
                      bottom: 0,
                      left: 0,
                      right: 0,
                      height: 4,
                      child: Container(
                        color: const Color(0xFFE2E8F0),
                        child: FractionallySizedBox(
                          alignment: Alignment.centerLeft,
                          widthFactor: (progress / 100).clamp(0.0, 1.0),
                          child: Container(
                            color: progress == 100 ? const Color(0xFF10B981) : const Color(0xFF2563EB),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            
            // Info Area
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Avatar
                      Container(
                        width: 36,
                        height: 36,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: const Color(0xFFEFF6FF),
                          border: Border.all(color: const Color(0xFFDBEAFE), width: 1),
                        ),
                        alignment: Alignment.center,
                        child: Text(
                          creatorInitial,
                          style: const TextStyle(
                            color: Color(0xFF2563EB),
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      
                      // Title, Author and Description
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              name,
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w800,
                                color: Color(0xFF0F172A),
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              'PIC: $creatorName',
                              style: const TextStyle(
                                fontSize: 11,
                                color: Color(0xFF64748B),
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              initiation.formData['description'] ?? 'Tidak ada deskripsi.',
                              style: const TextStyle(
                                fontSize: 13,
                                color: Color(0xFF475569),
                                height: 1.4,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                      
                      // Popup Menu (Edit, Archive, Delete)
                      PopupMenuButton<String>(
                        icon: const Icon(Icons.more_vert_rounded, color: Color(0xFF64748B)),
                        padding: EdgeInsets.zero,
                        onSelected: (val) async {
                          if (val == 'edit') {
                            _editProject(initiation, vm);
                          } else if (val == 'archive') {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Proyek diarsipkan'),
                                backgroundColor: Color(0xFF2563EB),
                              ),
                            );
                          } else if (val == 'delete') {
                            final confirm = await showDialog<bool>(
                              context: context,
                              builder: (context) => AlertDialog(
                                title: const Text('Hapus Proyek'),
                                content: const Text('Apakah Anda yakin ingin menghapus proyek ini secara permanen?'),
                                actions: [
                                  TextButton(
                                    onPressed: () => Navigator.pop(context, false),
                                    child: const Text('Batal'),
                                  ),
                                  TextButton(
                                    onPressed: () => Navigator.pop(context, true),
                                    style: TextButton.styleFrom(foregroundColor: Colors.red),
                                    child: const Text('Hapus'),
                                  ),
                                ],
                              ),
                            );
                            if (confirm == true) {
                              final origIndex = vm.initiations.indexOf(initiation);
                              if (origIndex != -1) {
                                await vm.removeInitiation(origIndex);
                                if (context.mounted) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text('Proyek berhasil dihapus'),
                                      backgroundColor: Color(0xFFEF4444),
                                    ),
                                  );
                                }
                              }
                            }
                          }
                        },
                        itemBuilder: (context) => [
                          const PopupMenuItem(
                            value: 'edit',
                            child: Row(
                              children: [
                                Icon(Icons.edit_rounded, size: 18),
                                SizedBox(width: 8),
                                Text('Edit Proyek'),
                              ],
                            ),
                          ),
                          const PopupMenuItem(
                            value: 'archive',
                            child: Row(
                              children: [
                                Icon(Icons.archive_rounded, size: 18),
                                SizedBox(width: 8),
                                Text('Arsipkan'),
                              ],
                            ),
                          ),
                          const PopupMenuItem(
                            value: 'delete',
                            child: Row(
                              children: [
                                Icon(Icons.delete_rounded, color: Colors.red, size: 18),
                                SizedBox(width: 8),
                                Text('Hapus Proyek', style: TextStyle(color: Colors.red)),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  
                  // Accordion for Module Statuses
                  if (hasModules) ...[
                    const SizedBox(height: 12),
                    InkWell(
                      onTap: () {
                        setState(() {
                          if (isAccordionExpanded) {
                            _expandedAccordions.remove(initiation.id);
                          } else {
                            _expandedAccordions.add(initiation.id);
                          }
                        });
                      },
                      borderRadius: BorderRadius.circular(8),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF1F5F9),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFF2563EB),
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                    child: Text(
                                      '${modules.length} modul',
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 10,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      modules.map((m) => m['module']?.toString() ?? '').join(' | '),
                                      style: const TextStyle(
                                        color: Color(0xFF64748B),
                                        fontSize: 11,
                                        fontWeight: FontWeight.w500,
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Icon(
                              isAccordionExpanded ? Icons.keyboard_arrow_up_rounded : Icons.keyboard_arrow_down_rounded,
                              color: const Color(0xFF64748B),
                              size: 20,
                            ),
                          ],
                        ),
                      ),
                    ),
                    
                    // Collapsible accordion content
                    if (isAccordionExpanded) ...[
                      const SizedBox(height: 10),
                      SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        physics: const BouncingScrollPhysics(),
                        child: Row(
                          children: List.generate(modules.length, (modIndex) {
                            final mod = modules[modIndex];
                            final status = mod['status']?.toString() ?? 'not_started';
                            final title = mod['module']?.toString() ?? 'Untitled Module';
                            final notes = mod['notes']?.toString() ?? '';
                            
                            return Container(
                              width: 140,
                              margin: const EdgeInsets.only(right: 12),
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: const Color(0xFFF1F5F9)),
                                boxShadow: [
                                  BoxShadow(
                                    color: const Color(0xFF94A3B8).withValues(alpha: 0.03),
                                    blurRadius: 4,
                                    offset: const Offset(0, 2),
                                  ),
                                ],
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  // Module Icon Box matching status
                                  Container(
                                    width: double.infinity,
                                    height: 64,
                                    decoration: BoxDecoration(
                                      color: _getModuleBgColor(status),
                                      borderRadius: BorderRadius.circular(8),
                                      border: Border.all(color: _getModuleBorderColor(status)),
                                    ),
                                    alignment: Alignment.center,
                                    child: _getModuleIcon(status),
                                  ),
                                  const SizedBox(height: 8),
                                  
                                  // Status Badge
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                    decoration: BoxDecoration(
                                      color: _getModuleBgColor(status),
                                      borderRadius: BorderRadius.circular(4),
                                      border: Border.all(color: _getModuleBorderColor(status)),
                                    ),
                                    child: Text(
                                      _getModuleStatusText(status).toUpperCase(),
                                      style: TextStyle(
                                        color: _getModuleTextColor(status),
                                        fontSize: 8,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 6),
                                  
                                  // Module Title
                                  Text(
                                    title,
                                    style: const TextStyle(
                                      fontSize: 11,
                                      fontWeight: FontWeight.bold,
                                      color: Color(0xFF0F172A),
                                      height: 1.2,
                                    ),
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  
                                  // Notes
                                  if (notes.isNotEmpty) ...[
                                    const SizedBox(height: 4),
                                    Text(
                                      notes,
                                      style: const TextStyle(
                                        fontSize: 9,
                                        color: Color(0xFF64748B),
                                        height: 1.2,
                                      ),
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ],
                                ],
                              ),
                            );
                          }),
                        ),
                      ),
                    ],
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
        ),
      ),
    );
  }

  // ==========================================
  // TAB 2: BLUEPRINT PROYEK (Completed only)
  // ==========================================
  Widget _buildBlueprintsTab(DashboardViewModel vm) {
    final completed = vm.initiations.where((p) {
      return (p.formData['progress'] ?? 0) == 100;
    }).toList();

    if (completed.isEmpty) {
      return _buildEmptyState(
        context,
        Icons.bookmark_outline_rounded,
        'Belum Ada Blueprint',
        'Selesaikan hingga 100% pada progres proyek Anda untuk mempublikasikan blueprint ke daftar ini.',
      );
    }

    final filtered = completed.where((p) {
      final name = (p.formData['name'] ?? p.projectType.name).toString().toLowerCase();
      final desc = (p.formData['description'] ?? '').toString().toLowerCase();
      return name.contains(_blueprintSearchQuery.toLowerCase()) || desc.contains(_blueprintSearchQuery.toLowerCase());
    }).toList();

    final screenWidth = MediaQuery.of(context).size.width;
    final isWide = screenWidth >= 600;

    return Column(
      children: [
        // Search bar
        Padding(
          padding: const EdgeInsets.fromLTRB(24, 12, 24, 16),
          child: TextFormField(
            controller: _blueprintSearchController,
            decoration: InputDecoration(
              hintText: 'Cari blueprint...',
              hintStyle: const TextStyle(color: Color(0xFF94A3B8)),
              prefixIcon: const Icon(Icons.search_rounded, color: Color(0xFF94A3B8)),
              suffixIcon: _blueprintSearchQuery.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.clear_rounded, color: Color(0xFF94A3B8)),
                      onPressed: () => _blueprintSearchController.clear(),
                    )
                  : null,
              filled: true,
              fillColor: Colors.white,
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: const BorderSide(color: Color(0xFF2563EB), width: 1.5),
              ),
            ),
          ),
        ),

        // List / Grid
        Expanded(
          child: filtered.isEmpty
              ? _buildEmptyState(
                  context,
                  Icons.bookmark_border_rounded,
                  'Blueprint Tidak Ditemukan',
                  'Silakan sesuaikan kata kunci pencarian Anda.',
                )
              : RefreshIndicator(
                  onRefresh: () => vm.loadInitiations(silent: true),
                  color: const Color(0xFF2563EB),
                  child: _buildBlueprintsGrid(filtered, isWide),
                ),
        ),
      ],
    );
  }

  Widget _buildBlueprintsGrid(List<ProjectInitiation> projects, bool isWide) {
    final cards = List<Widget>.generate(projects.length, (index) {
      return _buildBlueprintCardItem(projects[index]);
    });

    if (!isWide) {
      return ListView(
        padding: const EdgeInsets.fromLTRB(24, 0, 24, 40),
        children: cards,
      );
    } else {
      final leftCards = <Widget>[];
      final rightCards = <Widget>[];
      for (int i = 0; i < cards.length; i++) {
        if (i % 2 == 0) {
          leftCards.add(cards[i]);
        } else {
          rightCards.add(cards[i]);
        }
      }
      return SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(24, 0, 24, 40),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Column(children: leftCards),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(children: rightCards),
            ),
          ],
        ),
      );
    }
  }


  Widget _buildBlueprintCardItem(ProjectInitiation initiation) {
    final name = initiation.formData['name'] ?? initiation.projectType.name;
    final dateStr = _formatDate(initiation.createdAt);
    final desc = initiation.formData['description'] ?? 'Tidak ada deskripsi proyek.';
    final isCopied = _copiedBlueprintId == initiation.id;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF94A3B8).withValues(alpha: 0.05),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
        border: Border.all(color: const Color(0xFFF1F5F9)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Top Row: Icon and Penerbitan Date
            Row(
              children: [
                Container(
                  width: 42,
                  height: 42,
                  decoration: BoxDecoration(
                    color: const Color(0xFFEFF6FF),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: const Color(0xFFDBEAFE)),
                  ),
                  child: const Icon(
                    Icons.layers_rounded,
                    color: Color(0xFF2563EB),
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Blueprint Resmi',
                        style: TextStyle(
                          color: Color(0xFF2563EB),
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 0.5,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Penerbitan: $dateStr',
                        style: const TextStyle(
                          color: Color(0xFF94A3B8),
                          fontSize: 11,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            
            // Name and Description
            Text(
              name,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w800,
                color: Color(0xFF0F172A),
              ),
            ),
            const SizedBox(height: 6),
            Text(
              desc,
              style: const TextStyle(
                fontSize: 13,
                color: Color(0xFF475569),
                height: 1.4,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 18),
            
            // Actions Buttons horizontal row
            Row(
              children: [
                // Salin Link
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () {
                      final link = 'http://38.47.94.194/tif2/engineering/projects/${initiation.id}/blueprint/';
                      Clipboard.setData(ClipboardData(text: link));
                      setState(() {
                        _copiedBlueprintId = initiation.id;
                      });
                      Future.delayed(const Duration(seconds: 2), () {
                        if (mounted) {
                          setState(() {
                            if (_copiedBlueprintId == initiation.id) {
                              _copiedBlueprintId = null;
                            }
                          });
                        }
                      });
                    },
                    style: OutlinedButton.styleFrom(
                      side: BorderSide(color: isCopied ? const Color(0xFF10B981) : const Color(0xFFE2E8F0)),
                      foregroundColor: isCopied ? const Color(0xFF10B981) : const Color(0xFF0F172A),
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    icon: Icon(
                      isCopied ? Icons.check_rounded : Icons.link_rounded,
                      size: 14,
                      color: isCopied ? const Color(0xFF10B981) : const Color(0xFF64748B),
                    ),
                    label: Text(
                      isCopied ? 'Link Disalin!' : 'Salin Link',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: isCopied ? const Color(0xFF10B981) : const Color(0xFF0F172A),
                      ),
                    ),
                  ),
                ),
                
                // Lihat Blueprint
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => _showBlueprintDetailsSheet(initiation),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF2563EB),
                      foregroundColor: Colors.white,
                      elevation: 0,
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    icon: const Icon(Icons.visibility_rounded, size: 14, color: Colors.white),
                    label: const Text(
                      'Lihat',
                      style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.white),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildExpansionPhaseTile({
    required String title,
    required String subtitle,
    required List<Widget> children,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          title: Text(
            title,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: Color(0xFF0F172A),
            ),
          ),
          subtitle: Text(
            subtitle,
            style: const TextStyle(
              fontSize: 11,
              color: Color(0xFF64748B),
            ),
          ),
          leading: const Icon(
            Icons.check_circle_rounded,
            color: Color(0xFF10B981),
            size: 22,
          ),
          childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
          expandedCrossAxisAlignment: CrossAxisAlignment.start,
          children: children.isEmpty 
            ? [
                const Text(
                  'Tidak ada data untuk bagian ini.',
                  style: TextStyle(fontSize: 12, color: Color(0xFF94A3B8), fontStyle: FontStyle.italic),
                )
              ]
            : children,
        ),
      ),
    );
  }

  Widget _buildDetailItemCard(String label, Map<String, String> fields) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (label.isNotEmpty) ...[
            Text(
              label,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.bold,
                color: Color(0xFF0F172A),
              ),
            ),
            const SizedBox(height: 6),
          ],
          ...fields.entries.map((e) {
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 2),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${e.key}: ',
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF64748B),
                    ),
                  ),
                  Expanded(
                    child: Text(
                      e.value.isEmpty ? '-' : e.value,
                      style: const TextStyle(
                        fontSize: 12,
                        color: Color(0xFF334155),
                      ),
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  List<Widget> _buildFase1Children(ProjectInitiation p) {
    final step1 = p.formData['step_1'] as Map<String, dynamic>?;
    if (step1 == null) return [];

    final org = step1['organizational_objectives'] as List?;
    final leading = step1['leading_indicators'] as List?;
    final user = step1['user_outcomes'] as List?;
    final model = step1['model_properties'] as List?;

    final list = <Widget>[];

    if (org != null && org.isNotEmpty) {
      list.add(const Padding(
        padding: EdgeInsets.symmetric(vertical: 6),
        child: Text('Sasaran Organisasi (KPI)', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: Color(0xFF2563EB))),
      ));
      for (var item in org) {
        list.add(_buildDetailItemCard(
          item['objective']?.toString() ?? '',
          {
            'Strategi': item['strategy']?.toString() ?? '',
            'Metrik/KPI': item['measure']?.toString() ?? '',
          },
        ));
      }
    }

    if (leading != null && leading.isNotEmpty) {
      list.add(const Padding(
        padding: EdgeInsets.only(top: 10, bottom: 6),
        child: Text('Leading Indicators', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: Color(0xFF2563EB))),
      ));
      for (var item in leading) {
        list.add(_buildDetailItemCard(
          item['feature']?.toString() ?? '',
          {
            'Sistem': item['system']?.toString() ?? '',
            'Kompetitor': item['competitor']?.toString() ?? '',
          },
        ));
      }
    }

    if (user != null && user.isNotEmpty) {
      list.add(const Padding(
        padding: EdgeInsets.only(top: 10, bottom: 6),
        child: Text('User Outcomes', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: Color(0xFF2563EB))),
      ));
      for (var item in user) {
        list.add(_buildDetailItemCard(
          item['outcome']?.toString() ?? '',
          {
            'Strategi': item['strategy']?.toString() ?? '',
            'Metrik': item['measure']?.toString() ?? '',
          },
        ));
      }
    }

    if (model != null && model.isNotEmpty) {
      list.add(const Padding(
        padding: EdgeInsets.only(top: 10, bottom: 6),
        child: Text('Model Properties', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: Color(0xFF2563EB))),
      ));
      for (var item in model) {
        list.add(_buildDetailItemCard(
          item['property']?.toString() ?? '',
          {
            'Strategi': item['strategy']?.toString() ?? '',
            'Metrik': item['measure']?.toString() ?? '',
          },
        ));
      }
    }

    return list;
  }

  List<Widget> _buildFase2Children(ProjectInitiation p) {
    final step2 = p.formData['step_2'] as Map<String, dynamic>?;
    if (step2 == null) return [];

    final presentations = step2['presentations'] as List?;
    final presentationDesc = step2['presentation_description']?.toString() ?? '';
    final functions = step2['functions'] as List?;
    final errors = step2['error_minimizations'] as List?;
    final data = step2['data_collections'] as List?;

    final list = <Widget>[];

    if (presentations != null && presentations.isNotEmpty) {
      list.add(const Padding(
        padding: EdgeInsets.symmetric(vertical: 6),
        child: Text('Format Presentasi', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: Color(0xFF2563EB))),
      ));
      list.add(Container(
        width: double.infinity,
        padding: const EdgeInsets.all(12),
        margin: const EdgeInsets.only(bottom: 8),
        decoration: BoxDecoration(
          color: const Color(0xFFF8FAFC),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: const Color(0xFFE2E8F0)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Wrap(
              spacing: 8,
              runSpacing: 4,
              children: presentations.map((pres) {
                return Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: const Color(0xFFDBEAFE),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    pres.toString().toUpperCase(),
                    style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Color(0xFF1E40AF)),
                  ),
                );
              }).toList(),
            ),
            if (presentationDesc.isNotEmpty) ...[
              const SizedBox(height: 8),
              Text(
                presentationDesc,
                style: const TextStyle(fontSize: 12, color: Color(0xFF475569)),
              ),
            ],
          ],
        ),
      ));
    }

    if (functions != null && functions.isNotEmpty) {
      list.add(const Padding(
        padding: EdgeInsets.only(top: 10, bottom: 6),
        child: Text('Fungsi Kecerdasan', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: Color(0xFF2563EB))),
      ));
      for (var item in functions) {
        list.add(_buildDetailItemCard(
          item['name']?.toString() ?? '',
          {
            'Deskripsi': item['description']?.toString() ?? '',
          },
        ));
      }
    }

    if (errors != null && errors.isNotEmpty) {
      list.add(const Padding(
        padding: EdgeInsets.only(top: 10, bottom: 6),
        child: Text('Skenario Minimisasi Error', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: Color(0xFF2563EB))),
      ));
      for (var item in errors) {
        list.add(_buildDetailItemCard(
          item['function']?.toString() ?? item['name']?.toString() ?? '',
          {
            'Strategi': item['strategy']?.toString() ?? item['description']?.toString() ?? '',
          },
        ));
      }
    }

    if (data != null && data.isNotEmpty) {
      list.add(const Padding(
        padding: EdgeInsets.only(top: 10, bottom: 6),
        child: Text('Rencana Pengumpulan Data', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: Color(0xFF2563EB))),
      ));
      for (var item in data) {
        list.add(_buildDetailItemCard(
          item['name']?.toString() ?? '',
          {
            'Rencana Skenario': item['plan']?.toString() ?? item['description']?.toString() ?? '',
          },
        ));
      }
    }

    return list;
  }

  List<Widget> _buildFase3Children(ProjectInitiation p) {
    final step3 = p.formData['step_3'] as Map<String, dynamic>?;
    if (step3 == null) return [];

    final biz = step3['business_processes'] as List?;
    final techs = step3['technologies'] as List?;
    final smart = step3['smart_processes'] as List?;

    final list = <Widget>[];

    if (biz != null && biz.isNotEmpty) {
      list.add(const Padding(
        padding: EdgeInsets.symmetric(vertical: 6),
        child: Text('Proses Bisnis Organisasi', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: Color(0xFF2563EB))),
      ));
      for (var item in biz) {
        list.add(_buildDetailItemCard(
          item['name']?.toString() ?? '',
          {
            'Deskripsi': item['description']?.toString() ?? '',
          },
        ));
      }
    }

    if (techs != null && techs.isNotEmpty) {
      list.add(const Padding(
        padding: EdgeInsets.only(top: 10, bottom: 6),
        child: Text('Teknologi Pendukung', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: Color(0xFF2563EB))),
      ));
      for (var item in techs) {
        final tStr = item['technology']?.toString() ?? item['technologies']?.toString() ?? '';
        list.add(_buildDetailItemCard(
          '',
          {
            'Daftar Teknologi': tStr,
          },
        ));
      }
    }

    if (smart != null && smart.isNotEmpty) {
      list.add(const Padding(
        padding: EdgeInsets.only(top: 10, bottom: 6),
        child: Text('Realisasi Smart Process', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: Color(0xFF2563EB))),
      ));
      for (var item in smart) {
        final isSmart = item['is_smart'] == true;
        list.add(_buildDetailItemCard(
          item['process']?.toString() ?? '',
          {
            'Tipe': isSmart ? 'Proses Cerdas (Smart)' : 'Proses Standar',
            'Alasan & Dasar': item['reason']?.toString() ?? '',
          },
        ));
      }
    }

    return list;
  }

  List<Widget> _buildFase4Children(ProjectInitiation p) {
    final step4 = p.formData['step_4'] as Map<String, dynamic>?;
    if (step4 == null) return [];

    final modules = step4['module_statuses'] as List?;
    final constraints = step4['constraints'] as List?;

    final list = <Widget>[];

    if (modules != null && modules.isNotEmpty) {
      list.add(const Padding(
        padding: EdgeInsets.symmetric(vertical: 6),
        child: Text('Daftar Modul Cerdas', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: Color(0xFF2563EB))),
      ));
      for (var item in modules) {
        final status = item['status']?.toString() ?? 'not_started';
        list.add(_buildDetailItemCard(
          item['module']?.toString() ?? '',
          {
            'Status': _getModuleStatusText(status),
            'Catatan': item['notes']?.toString() ?? '-',
          },
        ));
      }
    }

    if (constraints != null && constraints.isNotEmpty) {
      list.add(const Padding(
        padding: EdgeInsets.only(top: 10, bottom: 6),
        child: Text('Kendala & Batasan Utama', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: Color(0xFF2563EB))),
      ));
      for (var item in constraints) {
        list.add(_buildDetailItemCard(
          item['category']?.toString() ?? '',
          {
            'Deskripsi Kendala': item['description']?.toString() ?? '',
          },
        ));
      }
    }

    return list;
  }

  List<Widget> _buildFase5Children(ProjectInitiation p) {
    final step5 = p.formData['step_5'] as Map<String, dynamic>?;
    if (step5 == null) return [];

    final timelines = step5['timelines'] as List?;
    final operators = step5['operators'] as List?;

    final list = <Widget>[];

    if (timelines != null && timelines.isNotEmpty) {
      list.add(const Padding(
        padding: EdgeInsets.symmetric(vertical: 6),
        child: Text('Timeline Orchestration', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: Color(0xFF2563EB))),
      ));
      for (var item in timelines) {
        String startStr = '-';
        if (item['start_date'] != null) {
          if (item['start_date'] is DateTime) {
            startStr = _formatDate(item['start_date']);
          } else {
            final parsed = DateTime.tryParse(item['start_date'].toString());
            if (parsed != null) startStr = _formatDate(parsed);
          }
        }

        String endStr = '-';
        if (item['end_date'] != null) {
          if (item['end_date'] is DateTime) {
            endStr = _formatDate(item['end_date']);
          } else {
            final parsed = DateTime.tryParse(item['end_date'].toString());
            if (parsed != null) endStr = _formatDate(parsed);
          }
        }

        list.add(_buildDetailItemCard(
          item['phase_name']?.toString() ?? '',
          {
            'Kategori': item['category']?.toString() ?? 'deployment',
            'PIC': item['pic']?.toString() ?? '-',
            'Jadwal': '$startStr s/d $endStr',
            'Status': item['status']?.toString() ?? 'backlog',
          },
        ));
      }
    }

    if (operators != null && operators.isNotEmpty) {
      list.add(const Padding(
        padding: EdgeInsets.only(top: 10, bottom: 6),
        child: Text('Pelaksana Operasi', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: Color(0xFF2563EB))),
      ));
      for (var item in operators) {
        list.add(_buildDetailItemCard(
          item['name']?.toString() ?? '',
          {
            'Peran': item['role']?.toString() ?? '',
            'Kontak': item['contact']?.toString() ?? '',
          },
        ));
      }
    }

    return list;
  }

  void _showBlueprintDetailsSheet(ProjectInitiation p) {
    final name = p.formData['name'] ?? p.projectType.name;
    final desc = p.formData['description'] ?? 'Tidak ada deskripsi proyek.';

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      isScrollControlled: true,
      builder: (context) {
        return DraggableScrollableSheet(
          initialChildSize: 0.7,
          maxChildSize: 0.95,
          minChildSize: 0.5,
          expand: false,
          builder: (context, scrollController) {
            return SingleChildScrollView(
              controller: scrollController,
              padding: const EdgeInsets.fromLTRB(24, 24, 24, 40),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: const Color(0xFFE2E8F0),
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  const Row(
                    children: [
                      Icon(Icons.layers_rounded, color: Color(0xFF2563EB), size: 24),
                      SizedBox(width: 10),
                      Text(
                        'Detail Blueprint',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w800,
                          color: Color(0xFF0F172A),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  Text(
                    name,
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF0F172A)),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    desc,
                    style: const TextStyle(fontSize: 14, color: Color(0xFF475569), height: 1.5),
                  ),
                  const Divider(height: 32, color: Color(0xFFF1F5F9)),
                  const Text(
                    'Tahapan Realisasi Proyek',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF0F172A)),
                  ),
                  const SizedBox(height: 16),
                  
                  _buildExpansionPhaseTile(
                    title: 'Fase 1: Meaningful Objectives',
                    subtitle: 'KPI, Sasaran Organisasi, Leading Indicators, User Outcomes, Model Properties',
                    children: _buildFase1Children(p),
                  ),
                  _buildExpansionPhaseTile(
                    title: 'Fase 2: Intelligence Experiences',
                    subtitle: 'Format Presentasi, Fungsi Kecerdasan, Minimisasi Error, Rencana Data',
                    children: _buildFase2Children(p),
                  ),
                  _buildExpansionPhaseTile(
                    title: 'Fase 3: Intelligence Implementation',
                    subtitle: 'Pemetaan Proses Bisnis, Realisasi Smart Process, Teknologi Pendukung',
                    children: _buildFase3Children(p),
                  ),
                  _buildExpansionPhaseTile(
                    title: 'Fase 4: Creation Status',
                    subtitle: 'Penyelesaian Modul Cerdas, Identifikasi Kendala & Batasan',
                    children: _buildFase4Children(p),
                  ),
                  _buildExpansionPhaseTile(
                    title: 'Fase 5: Orchestration',
                    subtitle: 'Timeline Orchestration, Tim Pelaksana Operasi Kerja',
                    children: _buildFase5Children(p),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  // ==========================================
  // TAB 3: LAPORAN BULANAN
  // ==========================================
  Widget _buildReportsTab(DashboardViewModel vm) {
    final active = vm.initiations.where((p) {
      final prg = p.formData['progress'] ?? 0;
      return prg > 0 && prg < 100;
    }).length;
    final completed = vm.initiations.where((p) => (p.formData['progress'] ?? 0) == 100).length;
    final total = vm.initiations.length;

    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(24, 12, 24, 40),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Unduh Ringkasan Laporan',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w800,
              color: Color(0xFF0F172A),
            ),
          ),
          const SizedBox(height: 4),
          const Text(
            'Pilih rentang bulan untuk mengunduh dokumen laporan PDF resmi.',
            style: TextStyle(color: Color(0xFF64748B), fontSize: 14),
          ),
          const SizedBox(height: 28),

          // Filters Selectors
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF94A3B8).withValues(alpha: 0.08),
                  blurRadius: 20,
                  offset: const Offset(0, 4),
                ),
              ],
              border: Border.all(color: const Color(0xFFF1F5F9)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Rentang Laporan',
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Color(0xFF0F172A)),
                ),
                const SizedBox(height: 16),
                
                // Month Dropdown
                DropdownButtonFormField<int>(
                  value: _selectedMonth,
                  decoration: InputDecoration(
                    labelText: 'Bulan',
                    labelStyle: const TextStyle(color: Color(0xFF94A3B8)),
                    filled: true,
                    fillColor: const Color(0xFFF8FAFC),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
                    ),
                  ),
                  items: List.generate(12, (index) {
                    return DropdownMenuItem<int>(
                      value: index + 1,
                      child: Text(_monthNames[index]),
                    );
                  }),
                  onChanged: (val) {
                    if (val != null) {
                      setState(() {
                        _selectedMonth = val;
                      });
                    }
                  },
                ),
                const SizedBox(height: 16),

                // Year Dropdown
                DropdownButtonFormField<int>(
                  value: _selectedYear,
                  decoration: InputDecoration(
                    labelText: 'Tahun',
                    labelStyle: const TextStyle(color: Color(0xFF94A3B8)),
                    filled: true,
                    fillColor: const Color(0xFFF8FAFC),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
                    ),
                  ),
                  items: List.generate(5, (index) {
                    final year = DateTime.now().year - index;
                    return DropdownMenuItem<int>(
                      value: year,
                      child: Text(year.toString()),
                    );
                  }),
                  onChanged: (val) {
                    if (val != null) {
                      setState(() {
                        _selectedYear = val;
                      });
                    }
                  },
                ),
              ],
            ),
          ),
          const SizedBox(height: 32),

          // Quick statistics summary for report
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: const Color(0xFFF1F5F9)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Pratinjau Metrik',
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Color(0xFF0F172A)),
                ),
                const SizedBox(height: 16),
                _buildReportStatRow('Proyek Aktif berjalan', active.toString(), Colors.blue),
                const Divider(height: 24, color: Color(0xFFF1F5F9)),
                _buildReportStatRow('Proyek Rampung', completed.toString(), Colors.green),
                const Divider(height: 24, color: Color(0xFFF1F5F9)),
                _buildReportStatRow('Total Inisiasi Proyek', total.toString(), Colors.orange),
              ],
            ),
          ),
          const SizedBox(height: 40),

          // Download PDF button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () => _downloadReportPdf(_selectedMonth, _selectedYear),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF2563EB),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 18),
                elevation: 6,
                shadowColor: const Color(0xFF2563EB).withValues(alpha: 0.3),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              icon: const Icon(Icons.picture_as_pdf_rounded, size: 20),
              label: const Text(
                'Unduh Laporan PDF',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.5,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReportStatRow(String label, String value, Color iconColor) {
    return Row(
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: iconColor,
          ),
        ),
        const SizedBox(width: 12),
        Text(
          label,
          style: const TextStyle(color: Color(0xFF64748B), fontSize: 13, fontWeight: FontWeight.w500),
        ),
        const Spacer(),
        Text(
          value,
          style: const TextStyle(color: Color(0xFF0F172A), fontSize: 14, fontWeight: FontWeight.bold),
        ),
      ],
    );
  }

  Future<void> _downloadReportPdf(int month, int year) async {
    final url = Uri.parse('http://38.47.94.194/tif2/engineering/reports/download/?month=$month&year=$year');
    try {
      if (await canLaunchUrl(url)) {
        await launchUrl(url, mode: LaunchMode.externalApplication);
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Tidak dapat membuka browser untuk mengunduh PDF!'),
              backgroundColor: Color(0xFFEF4444),
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: const Color(0xFFEF4444),
          ),
        );
      }
    }
  }

  // ==========================
  // SHARED UTILS
  // ==========================
  String _formatDate(DateTime date) {
    final months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'Mei', 'Jun',
      'Jul', 'Agu', 'Sep', 'Okt', 'Nov', 'Des'
    ];
    return '${date.day} ${months[date.month - 1]} ${date.year}';
  }

  Widget _buildEmptyState(BuildContext context, IconData icon, String title, String subtitle) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 40),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                color: const Color(0xFFEFF6FF),
                shape: BoxShape.circle,
                border: Border.all(color: const Color(0xFFDBEAFE)),
              ),
              child: Icon(
                icon,
                size: 44,
                color: const Color(0xFF2563EB),
              ),
            ),
            const SizedBox(height: 24),
            Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Color(0xFF0F172A),
                fontSize: 20,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              subtitle,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Color(0xFF64748B),
                fontSize: 14,
                height: 1.5,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ==========================================
// CUSTOM PAINTER CHART COMPONENTS
// ==========================================

class LineChartPainter extends CustomPainter {
  final List<double> values;
  final List<String>? labels;
  final Color lineColor;

  LineChartPainter(this.values, {this.labels, this.lineColor = const Color(0xFF2563EB)});

  @override
  void paint(Canvas canvas, Size size) {
    if (values.isEmpty) return;

    final paintLine = Paint()
      ..color = lineColor
      ..strokeWidth = 3.5
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final paintArea = Paint()..style = PaintingStyle.fill;

    final path = Path();
    final areaPath = Path();

    final double stepX = size.width / (values.length > 1 ? values.length - 1 : 1);
    final double maxVal = values.reduce((a, b) => a > b ? a : b);
    final double scaleMax = maxVal <= 0 ? 1.0 : maxVal;
    
    // Grid Lines
    final gridPaint = Paint()
      ..color = const Color(0xFFF1F5F9)
      ..strokeWidth = 1.0;
    
    for (int i = 0; i <= 4; i++) {
      double y = size.height * (i / 4);
      canvas.drawLine(Offset(0, y), Offset(size.width, y), gridPaint);
    }

    double getX(int index) => index * stepX;
    double getY(double val) => size.height - (val / scaleMax * size.height * 0.8) - (size.height * 0.05);

    path.moveTo(getX(0), getY(values[0]));
    areaPath.moveTo(getX(0), size.height);
    areaPath.lineTo(getX(0), getY(values[0]));

    for (int i = 1; i < values.length; i++) {
      double x1 = getX(i - 1);
      double y1 = getY(values[i - 1]);
      double x2 = getX(i);
      double y2 = getY(values[i]);
      
      double cx = (x1 + x2) / 2;
      path.cubicTo(cx, y1, cx, y2, x2, y2);
      areaPath.cubicTo(cx, y1, cx, y2, x2, y2);
    }

    areaPath.lineTo(getX(values.length - 1), size.height);
    areaPath.close();

    // Area Fill Gradient
    final gradient = LinearGradient(
      colors: [
        lineColor.withValues(alpha: 0.2),
        lineColor.withValues(alpha: 0.0),
      ],
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
    );
    paintArea.shader = gradient.createShader(Rect.fromLTWH(0, 0, size.width, size.height));
    canvas.drawPath(areaPath, paintArea);

    canvas.drawPath(path, paintLine);

    // Points markers
    final dotPaint = Paint()
      ..color = lineColor
      ..style = PaintingStyle.fill;
    final dotOutlinePaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;

    for (int i = 0; i < values.length; i++) {
      double x = getX(i);
      double y = getY(values[i]);
      canvas.drawCircle(Offset(x, y), 5, dotOutlinePaint);
      canvas.drawCircle(Offset(x, y), 3, dotPaint);
    }

    // Draw labels under points
    if (labels != null && labels!.length == values.length) {
      final textPainter = TextPainter(textDirection: TextDirection.ltr);
      for (int i = 0; i < labels!.length; i++) {
        textPainter.text = TextSpan(
          text: labels![i],
          style: const TextStyle(color: Color(0xFF64748B), fontSize: 9, fontWeight: FontWeight.bold),
        );
        textPainter.layout();
        textPainter.paint(canvas, Offset(getX(i) - textPainter.width / 2, size.height + 4));
      }
    }
  }

  @override
  bool shouldRepaint(covariant LineChartPainter oldDelegate) =>
      oldDelegate.values != values || oldDelegate.labels != labels;
}

class BarChartPainter extends CustomPainter {
  final Map<String, int> data;

  BarChartPainter(this.data);

  @override
  void paint(Canvas canvas, Size size) {
    if (data.isEmpty) return;

    final keys = data.keys.toList();
    final values = data.values.toList();
    
    final maxVal = values.reduce((a, b) => a > b ? a : b).toDouble();
    final double stepX = size.width / keys.length;
    
    final paintBar = Paint()..style = PaintingStyle.fill;

    final textPainter = TextPainter(textDirection: TextDirection.ltr);

    // Grid lines
    final gridPaint = Paint()
      ..color = const Color(0xFFF1F5F9)
      ..strokeWidth = 1.0;
    for (int i = 0; i <= 3; i++) {
      double y = size.height * (i / 3);
      canvas.drawLine(Offset(0, y), Offset(size.width, y), gridPaint);
    }

    for (int i = 0; i < keys.length; i++) {
      final key = keys[i];
      final val = values[i].toDouble();
      
      final barWidth = math.min(32.0, stepX * 0.45);
      final x = (i * stepX) + (stepX - barWidth) / 2;
      
      final height = val == 0 ? 0.0 : (val / maxVal) * (size.height * 0.8);
      final y = size.height - height;

      // Draw rounded bar
      final gradient = const LinearGradient(
        colors: [Color(0xFF3B82F6), Color(0xFF1D4ED8)],
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
      );
      paintBar.shader = gradient.createShader(Rect.fromLTWH(x, y, barWidth, height));
      
      final rrect = RRect.fromRectAndCorners(
        Rect.fromLTWH(x, y, barWidth, height),
        topLeft: const Radius.circular(8),
        topRight: const Radius.circular(8),
      );
      canvas.drawRRect(rrect, paintBar);

      // Value label on top
      textPainter.text = TextSpan(
        text: val.toInt().toString(),
        style: const TextStyle(
          color: Color(0xFF0F172A),
          fontSize: 11,
          fontWeight: FontWeight.bold,
        ),
      );
      textPainter.layout();
      textPainter.paint(canvas, Offset(x + (barWidth - textPainter.width) / 2, y - 18));

      // Label below bar
      textPainter.text = TextSpan(
        text: key.length > 8 ? '${key.substring(0, 5)}..' : key,
        style: const TextStyle(
          color: Color(0xFF64748B),
          fontSize: 10,
          fontWeight: FontWeight.w600,
        ),
      );
      textPainter.layout();
      textPainter.paint(canvas, Offset(x + (barWidth - textPainter.width) / 2, size.height + 8));
    }
  }

  @override
  bool shouldRepaint(covariant BarChartPainter oldDelegate) => oldDelegate.data != data;
}

class HorizontalBarChartPainter extends CustomPainter {
  final Map<String, double> data;
  final Color barColor;
  final double maxVal;

  HorizontalBarChartPainter(this.data, {this.barColor = const Color(0xFF2563EB), this.maxVal = 0.0});

  @override
  void paint(Canvas canvas, Size size) {
    if (data.isEmpty) return;
    final keys = data.keys.toList();
    final values = data.values.toList();
    
    double calculatedMax = maxVal;
    if (calculatedMax <= 0.0) {
      calculatedMax = values.reduce((a, b) => a > b ? a : b);
      if (calculatedMax <= 0) calculatedMax = 1.0;
    }

    final double rowHeight = size.height / keys.length;
    final double labelWidth = size.width * 0.35;
    final double chartWidth = size.width * 0.52;

    final textPainter = TextPainter(textDirection: TextDirection.ltr);

    // Draw vertical grid lines (5 intervals)
    final gridPaint = Paint()
      ..color = const Color(0xFFF1F5F9)
      ..strokeWidth = 1.0;
    for (int i = 0; i <= 5; i++) {
      double x = labelWidth + chartWidth * (i / 5);
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), gridPaint);
    }

    for (int i = 0; i < keys.length; i++) {
      final key = keys[i];
      final val = values[i];

      // Label on the left
      textPainter.text = TextSpan(
        text: key.length > 15 ? '${key.substring(0, 12)}...' : key,
        style: const TextStyle(color: Color(0xFF475569), fontSize: 9, fontWeight: FontWeight.bold),
      );
      textPainter.layout();
      textPainter.paint(canvas, Offset(8, (i * rowHeight) + (rowHeight - textPainter.height) / 2));

      // Horizontal bar
      final barHeight = math.min(14.0, rowHeight * 0.45);
      final barY = (i * rowHeight) + (rowHeight - barHeight) / 2;
      final barLength = (val / calculatedMax) * chartWidth;

      if (barLength > 0) {
        final paintBar = Paint()..style = PaintingStyle.fill;
        final rect = Rect.fromLTWH(labelWidth, barY, barLength, barHeight);
        final gradient = LinearGradient(
          colors: [barColor, barColor.withValues(alpha: 0.4)],
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
        );
        paintBar.shader = gradient.createShader(rect);

        final rrect = RRect.fromRectAndRadius(rect, const Radius.circular(4));
        canvas.drawRRect(rrect, paintBar);
      }

      // Value label on the right
      textPainter.text = TextSpan(
        text: val.toInt().toString(),
        style: const TextStyle(color: Color(0xFF0F172A), fontSize: 9, fontWeight: FontWeight.bold),
      );
      textPainter.layout();
      textPainter.paint(canvas, Offset(labelWidth + barLength + 6, (i * rowHeight) + (rowHeight - textPainter.height) / 2));
    }
  }

  @override
  bool shouldRepaint(covariant HorizontalBarChartPainter oldDelegate) => oldDelegate.data != data;
}

class DoughnutChartPainter extends CustomPainter {
  final Map<String, double> data;
  final List<Color> colors;

  DoughnutChartPainter(this.data, this.colors);

  @override
  void paint(Canvas canvas, Size size) {
    if (data.isEmpty) return;

    final double total = data.values.fold(0, (a, b) => a + b);
    if (total <= 0) return;

    final double radius = math.min(size.width, size.height) / 2;
    final Offset center = Offset(size.width / 2, size.height / 2);

    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = radius * 0.35
      ..strokeCap = StrokeCap.butt;

    double startAngle = -math.pi / 2;
    int index = 0;

    for (var entry in data.entries) {
      final double sweepAngle = (entry.value / total) * 2 * math.pi;
      if (sweepAngle > 0) {
        paint.color = colors[index % colors.length];
        canvas.drawArc(
          Rect.fromCircle(center: center, radius: radius - paint.strokeWidth / 2),
          startAngle,
          sweepAngle,
          false,
          paint,
        );
        startAngle += sweepAngle;
      }
      index++;
    }
  }

  @override
  bool shouldRepaint(covariant DoughnutChartPainter oldDelegate) => oldDelegate.data != data;
}

class PieChartPainter extends CustomPainter {
  final Map<String, double> data;
  final List<Color> colors;

  PieChartPainter(this.data, this.colors);

  @override
  void paint(Canvas canvas, Size size) {
    if (data.isEmpty) return;

    final double total = data.values.fold(0, (a, b) => a + b);
    if (total <= 0) return;

    final double radius = math.min(size.width, size.height) / 2;
    final Offset center = Offset(size.width / 2, size.height / 2);

    final paint = Paint()..style = PaintingStyle.fill;

    double startAngle = -math.pi / 2;
    int index = 0;

    for (var entry in data.entries) {
      final double sweepAngle = (entry.value / total) * 2 * math.pi;
      if (sweepAngle > 0) {
        paint.color = colors[index % colors.length];
        canvas.drawArc(
          Rect.fromCircle(center: center, radius: radius),
          startAngle,
          sweepAngle,
          true,
          paint,
        );
        startAngle += sweepAngle;
      }
      index++;
    }
  }

  @override
  bool shouldRepaint(covariant PieChartPainter oldDelegate) => oldDelegate.data != data;
}

class RadarChartPainter extends CustomPainter {
  final List<double> values;
  final List<String> labels;

  RadarChartPainter(this.values, this.labels);

  @override
  void paint(Canvas canvas, Size size) {
    if (values.isEmpty) return;

    final double radius = math.min(size.width, size.height) / 2 * 0.7;
    final Offset center = Offset(size.width / 2, size.height / 2);

    final double angleStep = 2 * math.pi / values.length;
    
    // Draw grid circles/polygons
    final gridPaint = Paint()
      ..color = const Color(0xFFE2E8F0)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;

    for (int i = 1; i <= 3; i++) {
      final double r = radius * (i / 3);
      final path = Path();
      for (int j = 0; j < values.length; j++) {
        final double angle = -math.pi / 2 + j * angleStep;
        final double x = center.dx + r * math.cos(angle);
        final double y = center.dy + r * math.sin(angle);
        if (j == 0) {
          path.moveTo(x, y);
        } else {
          path.lineTo(x, y);
        }
      }
      path.close();
      canvas.drawPath(path, gridPaint);
    }

    // Draw axis lines
    for (int j = 0; j < values.length; j++) {
      final double angle = -math.pi / 2 + j * angleStep;
      final double x = center.dx + radius * math.cos(angle);
      final double y = center.dy + radius * math.sin(angle);
      canvas.drawLine(center, Offset(x, y), gridPaint);
    }

    // Draw data polygon
    final double maxVal = values.reduce((a, b) => a > b ? a : b);
    final double scaleMax = maxVal <= 0 ? 1.0 : maxVal;

    final path = Path();
    final List<Offset> points = [];

    for (int j = 0; j < values.length; j++) {
      final double angle = -math.pi / 2 + j * angleStep;
      final double r = radius * (values[j] / scaleMax);
      final double x = center.dx + r * math.cos(angle);
      final double y = center.dy + r * math.sin(angle);
      final point = Offset(x, y);
      points.add(point);
      if (j == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }
    path.close();

    final fillPaint = Paint()
      ..color = const Color(0xFF8B5CF6).withValues(alpha: 0.2)
      ..style = PaintingStyle.fill;
    canvas.drawPath(path, fillPaint);

    final strokePaint = Paint()
      ..color = const Color(0xFF8B5CF6)
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;
    canvas.drawPath(path, strokePaint);

    // Draw dots
    final dotPaint = Paint()..color = const Color(0xFF8B5CF6);
    for (var p in points) {
      canvas.drawCircle(p, 4, dotPaint);
    }

    // Draw labels
    final textPainter = TextPainter(textDirection: TextDirection.ltr);
    for (int j = 0; j < labels.length; j++) {
      final double angle = -math.pi / 2 + j * angleStep;
      final double labelDist = radius + 14;
      final double x = center.dx + labelDist * math.cos(angle);
      final double y = center.dy + labelDist * math.sin(angle);

      textPainter.text = TextSpan(
        text: labels[j],
        style: const TextStyle(color: Color(0xFF64748B), fontSize: 9, fontWeight: FontWeight.bold),
      );
      textPainter.layout();
      
      // Offset label based on position
      double dx = x - textPainter.width / 2;
      double dy = y - textPainter.height / 2;
      canvas.save();
      textPainter.paint(canvas, Offset(dx, dy));
      canvas.restore();
    }
  }

  @override
  bool shouldRepaint(covariant RadarChartPainter oldDelegate) => oldDelegate.values != values;
}

class PolarAreaChartPainter extends CustomPainter {
  final Map<String, double> data;
  final List<Color> colors;

  PolarAreaChartPainter(this.data, this.colors);

  @override
  void paint(Canvas canvas, Size size) {
    if (data.isEmpty) return;

    final double maxVal = data.values.reduce((a, b) => a > b ? a : b);
    final double scaleMax = maxVal <= 0 ? 1.0 : maxVal;
    
    final double baseRadius = math.min(size.width, size.height) / 2;
    final Offset center = Offset(size.width / 2, size.height / 2);

    final double angleStep = 2 * math.pi / data.length;
    double startAngle = -math.pi / 2;
    
    final paint = Paint()..style = PaintingStyle.fill;
    final strokePaint = Paint()
      ..color = Colors.white
      ..strokeWidth = 1.5
      ..style = PaintingStyle.stroke;

    int index = 0;
    for (var entry in data.entries) {
      final double r = baseRadius * (entry.value / scaleMax) * 0.9;
      paint.color = colors[index % colors.length];
      
      canvas.drawArc(
        Rect.fromCircle(center: center, radius: r),
        startAngle,
        angleStep,
        true,
        paint,
      );
      canvas.drawArc(
        Rect.fromCircle(center: center, radius: r),
        startAngle,
        angleStep,
        true,
        strokePaint,
      );
      
      startAngle += angleStep;
      index++;
    }
  }

  @override
  bool shouldRepaint(covariant PolarAreaChartPainter oldDelegate) => oldDelegate.data != data;
}
