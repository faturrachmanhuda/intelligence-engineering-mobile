import 'package:flutter/material.dart';

import 'data/dashboard_modules.dart';
import 'widgets/background_gradient.dart';

class MenuDetailPage extends StatefulWidget {
  final DashboardModule module;

  const MenuDetailPage({super.key, required this.module});

  @override
  State<MenuDetailPage> createState() => _MenuDetailPageState();
}

class _MenuDetailPageState extends State<MenuDetailPage> {
  final _formKey = GlobalKey<FormState>();
  late final Map<String, TextEditingController> _controllers;
  late final Map<String, String?> _selectedValues;
  late final List<TextEditingController> _indicatorControllers;
  int _formVersion = 0;

  @override
  void initState() {
    super.initState();
    _controllers = <String, TextEditingController>{};
    _selectedValues = <String, String?>{};
    _indicatorControllers = <TextEditingController>[];

    for (final section in widget.module.sections) {
      for (final field in section.fields) {
        if (field.type == ModuleFieldType.dropdown) {
          _selectedValues[field.key] = field.initialValue;
        } else if (field.key == 'leading_indicator') {
          _indicatorControllers.add(
            TextEditingController(text: field.initialValue ?? ''),
          );
        } else {
          _controllers[field.key] = TextEditingController(
            text: field.initialValue ?? '',
          );
        }
      }
    }
  }

  @override
  void dispose() {
    for (final controller in _controllers.values) {
      controller.dispose();
    }
    for (final controller in _indicatorControllers) {
      controller.dispose();
    }
    super.dispose();
  }

  Future<void> _saveForm() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    _resetFormValues();
    await _showSuccessDialog();
  }

  void _resetFormValues() {
    String? initialIndicatorValue;

    for (final section in widget.module.sections) {
      for (final field in section.fields) {
        if (field.type == ModuleFieldType.dropdown) {
          _selectedValues[field.key] = field.initialValue;
        } else if (field.key == 'leading_indicator') {
          initialIndicatorValue = field.initialValue;
        } else {
          _controllers[field.key]?.text = field.initialValue ?? '';
        }
      }
    }

    for (final controller in _indicatorControllers) {
      controller.dispose();
    }

    _indicatorControllers
      ..clear()
      ..add(TextEditingController(text: initialIndicatorValue ?? ''));

    _formKey.currentState?.reset();

    setState(() {
      _formVersion++;
    });
  }

  Future<void> _showSuccessDialog() async {
    final dialogFuture = showGeneralDialog<void>(
      context: context,
      barrierDismissible: false,
      barrierLabel: 'Sukses',
      barrierColor: Colors.black.withValues(alpha: 0.55),
      transitionDuration: const Duration(milliseconds: 280),
      pageBuilder: (context, animation, secondaryAnimation) {
        return const Center(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 32),
            child: _SuccessDialogCard(),
          ),
        );
      },
      transitionBuilder: (context, animation, secondaryAnimation, child) {
        final curved = CurvedAnimation(
          parent: animation,
          curve: Curves.easeOutBack,
        );

        return FadeTransition(
          opacity: animation,
          child: ScaleTransition(scale: curved, child: child),
        );
      },
    );

    await Future<void>.delayed(const Duration(milliseconds: 1500));

    if (mounted) {
      Navigator.of(context, rootNavigator: true).pop();
    }

    await dialogFuture;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          const BackgroundGradient(),
          SafeArea(
            child: Form(
              key: _formKey,
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 28),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        IconButton(
                          onPressed: () => Navigator.pop(context),
                          icon: const Icon(
                            Icons.arrow_back_ios_new_rounded,
                            color: Colors.white,
                          ),
                          style: IconButton.styleFrom(
                            backgroundColor: Colors.white.withValues(
                              alpha: 0.08,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Text(
                          'Kembali',
                          style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.82),
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    Text(
                      widget.module.title,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 32,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      widget.module.description,
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.74),
                        fontSize: 15,
                        height: 1.6,
                      ),
                    ),
                    const SizedBox(height: 24),
                    ...widget.module.sections.map(
                      (section) => Padding(
                        padding: const EdgeInsets.only(bottom: 18),
                        child: _SectionCard(
                          title: section.title,
                          description: section.description,
                          child: Column(
                            children: section.fields
                                .map(
                                  (field) => Padding(
                                    padding: const EdgeInsets.only(bottom: 18),
                                    child: _buildField(field),
                                  ),
                                )
                                .toList(),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _saveForm,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF2563EB),
                          shadowColor: Colors.transparent,
                          foregroundColor: Colors.white,
                          elevation: 0,
                          minimumSize: const Size.fromHeight(58),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                        ),
                        child: const Text(
                          'Simpan Data',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildField(ModuleField field) {
    if (field.key == 'leading_indicator') {
      return _buildLeadingIndicators(field);
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          field.label,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 15,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 10),
        if (field.type == ModuleFieldType.dropdown)
          DropdownButtonFormField<String>(
            key: ValueKey('${field.key}-$_formVersion'),
            initialValue: _selectedValues[field.key],
            isExpanded: true,
            itemHeight: 64,
            dropdownColor: const Color(0xFF1C1F2B),
            iconEnabledColor: Colors.white70,
            style: const TextStyle(color: Colors.white),
            hint: Text(
              field.hint,
              style: TextStyle(color: Colors.white.withValues(alpha: 0.35)),
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return '${field.label} wajib dipilih';
              }
              return null;
            },
            onChanged: (value) {
              setState(() {
                _selectedValues[field.key] = value;
              });
            },
            decoration: _inputDecoration(label: field.hint, icon: field.icon),
            items: field.options
                .map(
                  (option) => DropdownMenuItem<String>(
                    value: option,
                    child: Text(
                      option,
                      style: const TextStyle(color: Colors.white),
                    ),
                  ),
                )
                .toList(),
          )
        else
          TextFormField(
            controller: _controllers[field.key],
            minLines: field.type == ModuleFieldType.multiline ? 4 : 1,
            maxLines: field.type == ModuleFieldType.multiline ? 5 : 1,
            style: const TextStyle(color: Colors.white),
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return '${field.label} wajib diisi';
              }
              return null;
            },
            decoration: _inputDecoration(label: field.hint, icon: field.icon),
          ),
      ],
    );
  }

  Widget _buildLeadingIndicators(ModuleField field) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          field.label,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 15,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 10),
        ...List.generate(_indicatorControllers.length, (index) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (index > 0)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: Align(
                      alignment: Alignment.centerRight,
                      child: TextButton.icon(
                        onPressed: () {
                          final controller = _indicatorControllers.removeAt(
                            index,
                          );
                          controller.dispose();
                          setState(() {});
                        },
                        style: TextButton.styleFrom(
                          foregroundColor: Colors.white70,
                          backgroundColor: Colors.white.withValues(alpha: 0.05),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 10,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                        icon: const Icon(
                          Icons.delete_outline_rounded,
                          size: 18,
                        ),
                        label: const Text(
                          'Hapus',
                          style: TextStyle(fontWeight: FontWeight.w700),
                        ),
                      ),
                    ),
                  ),
                TextFormField(
                  controller: _indicatorControllers[index],
                  minLines: 4,
                  maxLines: 5,
                  style: const TextStyle(color: Colors.white),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Indikator keberhasilan wajib diisi';
                    }
                    return null;
                  },
                  decoration: _inputDecoration(
                    label: index == 0
                        ? field.hint
                        : 'Tambahkan indikator keberhasilan lainnya',
                    icon: field.icon,
                  ),
                ),
              ],
            ),
          );
        }),
        TextButton.icon(
          onPressed: () {
            setState(() {
              _indicatorControllers.add(TextEditingController());
            });
          },
          style: TextButton.styleFrom(
            foregroundColor: Colors.white,
            backgroundColor: const Color(0xFF242938),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
            ),
          ),
          icon: const Icon(Icons.add_rounded),
          label: const Text(
            'Tambah Indikator',
            style: TextStyle(fontWeight: FontWeight.w700),
          ),
        ),
      ],
    );
  }

  InputDecoration _inputDecoration({
    required String label,
    required IconData icon,
  }) {
    return InputDecoration(
      hintText: label,
      hintStyle: TextStyle(color: Colors.white.withValues(alpha: 0.35)),
      prefixIcon: Padding(
        padding: const EdgeInsets.only(left: 18, right: 14),
        child: Icon(icon, color: Colors.white54),
      ),
      prefixIconConstraints: const BoxConstraints(minWidth: 0),
      suffixIconColor: Colors.white70,
      alignLabelWithHint: true,
      filled: true,
      fillColor: const Color(0xFF1A1D28),
      contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 20),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(18),
        borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.08)),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(18),
        borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.08)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(18),
        borderSide: BorderSide(color: widget.module.accent, width: 1.2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(18),
        borderSide: const BorderSide(color: Color(0xFFFF7A7A)),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(18),
        borderSide: const BorderSide(color: Color(0xFFFF7A7A)),
      ),
    );
  }
}

class _SectionCard extends StatelessWidget {
  final String title;
  final String description;
  final Widget child;

  const _SectionCard({
    required this.title,
    required this.description,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF171A24).withValues(alpha: 0.95),
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 17,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            description,
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.64),
              fontSize: 13.5,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 18),
          child,
        ],
      ),
    );
  }
}

class _SuccessDialogCard extends StatelessWidget {
  const _SuccessDialogCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(24, 28, 24, 24),
      decoration: BoxDecoration(
        color: const Color(0xFF171A24),
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
        boxShadow: const [
          BoxShadow(
            color: Color(0x33000000),
            blurRadius: 28,
            offset: Offset(0, 18),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TweenAnimationBuilder<double>(
            tween: Tween<double>(begin: 0.7, end: 1),
            duration: const Duration(milliseconds: 450),
            curve: Curves.easeOutBack,
            builder: (context, value, child) {
              return Transform.scale(scale: value, child: child);
            },
            child: Container(
              width: 78,
              height: 78,
              decoration: BoxDecoration(
                color: const Color(0xFF2563EB).withValues(alpha: 0.16),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.check_rounded,
                color: Color(0xFF2563EB),
                size: 42,
              ),
            ),
          ),
          const SizedBox(height: 18),
          const Text(
            'Data Berhasil Disimpan',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            'Form sudah dikosongkan dan siap diisi kembali.',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.72),
              fontSize: 14.5,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }
}
