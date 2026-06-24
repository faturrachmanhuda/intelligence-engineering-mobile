import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:ui';
import 'about_page.dart';
import 'dashboard_page.dart';
import 'login_page.dart';
import 'register_page.dart';
import 'profile_page.dart';

class NoScrollbarBehavior extends MaterialScrollBehavior {
  const NoScrollbarBehavior();
  
  @override
  Widget buildScrollbar(BuildContext context, Widget child, ScrollableDetails details) {
    return child; // Hides the scrollbar
  }

  @override
  Set<PointerDeviceKind> get dragDevices => {
        PointerDeviceKind.touch,
        PointerDeviceKind.mouse,
      };
}

class IntelligenceEngineeringApp extends StatelessWidget {
  final bool isLoggedIn;

  const IntelligenceEngineeringApp({super.key, required this.isLoggedIn});

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
    ));

    return MaterialApp(
      title: 'Intelligence Engineering',
      debugShowCheckedModeBanner: false,
      scrollBehavior: const NoScrollbarBehavior(),
      theme: ThemeData(
        useMaterial3: true,
        fontFamily: 'Arial',
        scaffoldBackgroundColor: const Color(0xFFF8FAFC),
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF2563EB),
          primary: const Color(0xFF2563EB),
          background: const Color(0xFFF8FAFC),
          surface: const Color(0xFFFFFFFF),
        ),
      ),
      home: isLoggedIn ? const DashboardPage() : const LandingPageMobile(),
      routes: {
        '/home': (context) => const LandingPageMobile(),
        '/about': (context) => const AboutPage(),
        '/login': (context) => const LoginPage(),
        '/register': (context) => const RegisterPage(),
        '/dashboard': (context) => const DashboardPage(),
        '/profile': (context) => const ProfilePage(),
      },
    );
  }
}

class LandingPageMobile extends StatefulWidget {
  const LandingPageMobile({super.key});

  @override
  State<LandingPageMobile> createState() => _LandingPageMobileState();
}

class _LandingPageMobileState extends State<LandingPageMobile> with SingleTickerProviderStateMixin {
  int _activeTabIndex = 0;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  late ScrollController _tabScrollController;
  bool _canScrollLeft = false;
  bool _canScrollRight = false;

  final List<Map<String, dynamic>> _tabs = [
    {
      'title': 'Objectives',
      'icon': Icons.track_changes_rounded,
      'content': 'Mendefinisikan tujuan dan sasaran dari sistem cerdas yang akan dirancang. Modul ini mencakup analisis kebutuhan, penentuan KPI, dan perencanaan strategis untuk memastikan sistem yang dibangun sesuai dengan visi organisasi.'
    },
    {
      'title': 'Experiences',
      'icon': Icons.auto_awesome_rounded,
      'content': 'Mengumpulkan dan menganalisis pengalaman dari proyek-proyek sebelumnya. Modul ini berfokus pada lessons learned, best practices, dan knowledge base yang dapat digunakan untuk meningkatkan kualitas perancangan sistem cerdas.'
    },
    {
      'title': 'Implementation',
      'icon': Icons.settings_suggest_rounded,
      'content': 'Tahap implementasi teknis dari sistem cerdas, mencakup pengembangan model, integrasi data, deployment pipeline, dan pengujian sistem. Memastikan solusi dapat berjalan dengan optimal di lingkungan produksi.'
    },
    {
      'title': 'Creation',
      'icon': Icons.brush_rounded,
      'content': 'Proses kreatif dalam merancang arsitektur dan komponen sistem cerdas. Meliputi desain algoritma, pemilihan teknologi, prototyping, dan iterasi desain untuk menghasilkan solusi yang inovatif dan efisien.'
    },
    {
      'title': 'Orchestration',
      'icon': Icons.account_tree_rounded,
      'content': 'Mengelola dan mengkoordinasikan seluruh komponen sistem cerdas agar bekerja secara harmonis. Mencakup workflow management, resource allocation, monitoring, dan continuous improvement dari sistem yang telah berjalan.'
    },
  ];

  @override
  void initState() {
    super.initState();
    _tabScrollController = ScrollController();
    _tabScrollController.addListener(_scrollListener);

    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOut),
    );
    _slideAnimation = Tween<Offset>(begin: const Offset(0, 0.05), end: Offset.zero).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOut),
    );
    _animationController.forward();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scrollListener();
    });
  }

  void _scrollListener() {
    if (!_tabScrollController.hasClients) return;
    final maxScroll = _tabScrollController.position.maxScrollExtent;
    final currentScroll = _tabScrollController.offset;
    final showLeft = currentScroll > 5;
    final showRight = currentScroll < maxScroll - 5;
    if (showLeft != _canScrollLeft || showRight != _canScrollRight) {
      setState(() {
        _canScrollLeft = showLeft;
        _canScrollRight = showRight;
      });
    }
  }

  void _onTabChanged(int index) {
    if (_activeTabIndex == index) return;
    setState(() {
      _activeTabIndex = index;
    });
    _animationController.reset();
    _animationController.forward();
  }

  @override
  void dispose() {
    _tabScrollController.removeListener(_scrollListener);
    _tabScrollController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      extendBodyBehindAppBar: true,
      drawer: const _MobileDrawer(),
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(90),
        child: ClipRRect(
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
            child: Container(
              color: Colors.white.withValues(alpha: 0.8),
              child: SafeArea(
                bottom: false,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                  child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 36,
                          height: 36,
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [Color(0xFF3B82F6), Color(0xFF1D4ED8)],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            borderRadius: BorderRadius.circular(10),
                            boxShadow: [
                              BoxShadow(
                                color: const Color(0xFF2563EB).withValues(alpha: 0.3),
                                blurRadius: 10,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: const Icon(Icons.layers_rounded, color: Colors.white, size: 20),
                        ),
                        const SizedBox(width: 12),
                        const Text(
                          'CoreIE',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w800,
                            color: Color(0xFF0F172A),
                            letterSpacing: -0.5,
                          ),
                        ),
                      ],
                    ),
                    Builder(
                      builder: (context) {
                        return IconButton(
                          icon: const Icon(Icons.menu_rounded, color: Color(0xFF0F172A)),
                          onPressed: () => Scaffold.of(context).openDrawer(),
                        );
                      }
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    ),
    body: Stack(
        children: [
          SingleChildScrollView(
            padding: const EdgeInsets.only(top: 110, bottom: 120),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Hero Section
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: const Color(0xFFEFF6FF),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: const Color(0xFFDBEAFE)),
                        ),
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.rocket_launch_rounded, size: 14, color: Color(0xFF2563EB)),
                            SizedBox(width: 6),
                            Text(
                              'Platform Masa Depan',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: Color(0xFF1D4ED8),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        'Intelligence\nEngineering',
                        style: TextStyle(
                          fontSize: 42,
                          fontWeight: FontWeight.w900,
                          color: Color(0xFF0F172A),
                          height: 1.1,
                          letterSpacing: -1,
                        ),
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        'Mengelola perancangan rekayasa sistem cerdas dengan standar tak terbatas.',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w400,
                          color: Color(0xFF475569),
                          height: 1.6,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 40),

                // Horizontal Tabs (Pills)
                Stack(
                  children: [
                    SizedBox(
                      height: 44,
                      child: ListView.builder(
                        controller: _tabScrollController,
                        scrollDirection: Axis.horizontal,
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        itemCount: _tabs.length,
                        itemBuilder: (context, index) {
                          final isActive = index == _activeTabIndex;
                          return Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 4),
                            child: GestureDetector(
                              onTap: () => _onTabChanged(index),
                              child: AnimatedContainer(
                                duration: const Duration(milliseconds: 250),
                                curve: Curves.easeInOut,
                                padding: const EdgeInsets.symmetric(horizontal: 20),
                                alignment: Alignment.center,
                                decoration: BoxDecoration(
                                  color: isActive ? const Color(0xFF0F172A) : Colors.white,
                                  borderRadius: BorderRadius.circular(22),
                                  border: Border.all(
                                    color: isActive ? const Color(0xFF0F172A) : const Color(0xFFE2E8F0),
                                    width: 1,
                                  ),
                                  boxShadow: isActive
                                      ? [
                                          BoxShadow(
                                            color: const Color(0xFF0F172A).withValues(alpha: 0.2),
                                            blurRadius: 10,
                                            offset: const Offset(0, 4),
                                          )
                                        ]
                                      : [],
                                ),
                                child: Text(
                                  _tabs[index]['title'],
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: isActive ? FontWeight.w600 : FontWeight.w500,
                                    color: isActive ? Colors.white : const Color(0xFF64748B),
                                  ),
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                    if (_canScrollLeft)
                      Positioned(
                        left: 0,
                        top: 0,
                        bottom: 0,
                        child: Container(
                          width: 80,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                const Color(0xFFF8FAFC),
                                const Color(0xFFF8FAFC).withValues(alpha: 0.8),
                                const Color(0xFFF8FAFC).withValues(alpha: 0.0),
                              ],
                              begin: Alignment.centerLeft,
                              end: Alignment.centerRight,
                            ),
                          ),
                          alignment: Alignment.centerLeft,
                          padding: const EdgeInsets.only(left: 8),
                          child: IconButton(
                            icon: const Icon(Icons.chevron_left_rounded),
                            color: const Color(0xFF0F172A),
                            style: IconButton.styleFrom(
                              backgroundColor: Colors.white,
                              elevation: 4,
                              shadowColor: Colors.black12,
                            ),
                            onPressed: () {
                              _tabScrollController.animateTo(
                                _tabScrollController.offset - 150,
                                duration: const Duration(milliseconds: 300),
                                curve: Curves.easeInOut,
                              );
                            },
                          ),
                        ),
                      ),
                    if (_canScrollRight)
                      Positioned(
                        right: 0,
                        top: 0,
                        bottom: 0,
                        child: Container(
                          width: 80,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                const Color(0xFFF8FAFC).withValues(alpha: 0.0),
                                const Color(0xFFF8FAFC).withValues(alpha: 0.8),
                                const Color(0xFFF8FAFC),
                              ],
                              begin: Alignment.centerLeft,
                              end: Alignment.centerRight,
                            ),
                          ),
                          alignment: Alignment.centerRight,
                          padding: const EdgeInsets.only(right: 8),
                          child: IconButton(
                            icon: const Icon(Icons.chevron_right_rounded),
                            color: const Color(0xFF0F172A),
                            style: IconButton.styleFrom(
                              backgroundColor: Colors.white,
                              elevation: 4,
                              shadowColor: Colors.black12,
                            ),
                            onPressed: () {
                              _tabScrollController.animateTo(
                                _tabScrollController.offset + 150,
                                duration: const Duration(milliseconds: 300),
                                curve: Curves.easeInOut,
                              );
                            },
                          ),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 32),

                // Active Tab Content
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: FadeTransition(
                    opacity: _fadeAnimation,
                    child: SlideTransition(
                      position: _slideAnimation,
                      child: Container(
                        padding: const EdgeInsets.all(28),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(24),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFF94A3B8).withValues(alpha: 0.15),
                              blurRadius: 24,
                              offset: const Offset(0, 8),
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: const Color(0xFFEFF6FF),
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: Icon(
                                _tabs[_activeTabIndex]['icon'],
                                color: const Color(0xFF2563EB),
                                size: 28,
                              ),
                            ),
                            const SizedBox(height: 20),
                            Text(
                              _tabs[_activeTabIndex]['title'],
                              style: const TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF0F172A),
                                letterSpacing: -0.5,
                              ),
                            ),
                            const SizedBox(height: 12),
                            Text(
                              _tabs[_activeTabIndex]['content'],
                              style: const TextStyle(
                                fontSize: 15,
                                color: Color(0xFF475569),
                                height: 1.7,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Sticky Bottom Action
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: Container(
              padding: const EdgeInsets.fromLTRB(24, 24, 24, 32),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    const Color(0xFFF8FAFC).withValues(alpha: 0.0),
                    const Color(0xFFF8FAFC).withValues(alpha: 0.9),
                    const Color(0xFFF8FAFC),
                  ],
                ),
              ),
              child: ElevatedButton(
                onPressed: () => Navigator.pushNamed(context, '/login'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF2563EB),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 20),
                  elevation: 10,
                  shadowColor: const Color(0xFF2563EB).withValues(alpha: 0.4),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Mulai Sekarang',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.5,
                      ),
                    ),
                    SizedBox(width: 8),
                    Icon(Icons.arrow_forward_rounded, size: 20),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _MobileDrawer extends StatelessWidget {
  const _MobileDrawer();

  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: Colors.white,
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 42,
                    height: 42,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      gradient: const LinearGradient(
                        colors: [Color(0xFF3B82F6), Color(0xFF1D4ED8)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                    ),
                    child: const Icon(
                      Icons.layers_rounded,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Text(
                      'Intelligence\nEngineering',
                      style: TextStyle(
                        color: Color(0xFF0F172A),
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                        height: 1.1,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 32),
              _DrawerItem(
                title: 'Beranda',
                icon: Icons.home_rounded,
                onTap: () => Navigator.pop(context),
              ),
              _DrawerItem(
                title: 'Tentang Kami',
                icon: Icons.info_rounded,
                onTap: () {
                  Navigator.pop(context);
                  Navigator.pushNamed(context, '/about');
                },
              ),
              const Spacer(),
              _DrawerItem(
                title: 'Login',
                icon: Icons.login_rounded,
                onTap: () {
                  Navigator.pop(context);
                  Navigator.pushNamed(context, '/login');
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _DrawerItem extends StatelessWidget {
  final String title;
  final IconData icon;
  final VoidCallback onTap;

  const _DrawerItem({
    required this.title,
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            color: const Color(0xFFF8FAFC),
            border: Border.all(color: const Color(0xFFE2E8F0)),
          ),
          child: Row(
            children: [
              Icon(icon, color: const Color(0xFF475569), size: 22),
              const SizedBox(width: 14),
              Text(
                title,
                style: const TextStyle(
                  color: Color(0xFF0F172A),
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
