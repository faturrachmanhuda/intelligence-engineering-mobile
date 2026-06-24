import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../viewmodels/wizard/wizard_viewmodel.dart';

class IntelligenceImplementationStep extends StatelessWidget {
  const IntelligenceImplementationStep({super.key});

  @override
  Widget build(BuildContext context) {
    final vm = context.read<WizardViewModel>().intelligenceImplementationVM;

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
      child: Form(
        key: vm.formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Proses Bisnis Sistem Cerdas
            _buildComplexListSection(
              context: context,
              title: 'Proses Bisnis Sistem Cerdas',
              icon: Icons.business_center_rounded,
              accentColor: const Color(0xFF2563EB),
              items: vm.businessProcesses,
              onAdd: () => vm.addBusinessProcess(),
              onRemove: (index) => vm.removeBusinessProcess(index),
              fields: [
                {'key': 'name', 'label': 'Nama Proses Bisnis'},
                {'key': 'description', 'label': 'Deskripsi Proses Bisnis'},
              ],
            ),
            const SizedBox(height: 16),

            // Teknologi per Proses
            _buildTechnologiesSection(context, vm),
            const SizedBox(height: 16),

            // Identifikasi Proses Cerdas
            _buildSmartProcessesSection(context, vm),
          ],
        ),
      ),
    );
  }

  Widget _buildTechnologiesSection(BuildContext context, dynamic vm) {
    return Consumer<WizardViewModel>(
      builder: (context, wizardVm, child) {
        return Container(
          width: double.infinity,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0xFFE2E8F0)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.04),
                blurRadius: 16,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(Icons.memory_rounded, color: Color(0xFF8E6BFF), size: 20),
                  const SizedBox(width: 8),
                  const Text(
                    'Teknologi per Proses',
                    style: TextStyle(
                      color: Color(0xFF8E6BFF),
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              if (vm.technologies.isEmpty)
                const Text(
                  'Tambahkan proses bisnis terlebih dahulu.',
                  style: TextStyle(color: Color(0xFF64748B)),
                )
              else
                ...List.generate(vm.technologies.length, (index) {
                  final tech = vm.technologies[index];
                  final processName = tech['process']?.text ?? 'Proses ${index + 1}';
                  return Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF8FAFC),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: const Color(0xFFE2E8F0)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          processName.isNotEmpty ? processName : 'Proses ${index + 1}',
                          style: const TextStyle(color: Color(0xFF0F172A), fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 8),
                        TextFormField(
                          controller: tech['technology'],
                          style: const TextStyle(color: Color(0xFF0F172A), fontSize: 14),
                          decoration: InputDecoration(
                            labelText: 'Teknologi yang digunakan',
                            labelStyle: const TextStyle(
                              color: Color(0xFF64748B),
                              fontSize: 14,
                            ),
                            filled: true,
                            fillColor: Colors.white,
                            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide: const BorderSide(color: Color(0xFF8E6BFF), width: 1.5),
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
      },
    );
  }

  Widget _buildSmartProcessesSection(BuildContext context, dynamic vm) {
    return Consumer<WizardViewModel>(
      builder: (context, wizardVm, child) {
        return Container(
          width: double.infinity,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0xFFE2E8F0)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.04),
                blurRadius: 16,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(Icons.psychology_rounded, color: Color(0xFF00C88C), size: 20),
                  const SizedBox(width: 8),
                  const Text(
                    'Identifikasi Proses Cerdas',
                    style: TextStyle(
                      color: Color(0xFF00C88C),
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              if (vm.smartProcesses.isEmpty)
                const Text(
                  'Tambahkan proses bisnis terlebih dahulu.',
                  style: TextStyle(color: Color(0xFF64748B)),
                )
              else
                ...List.generate(vm.smartProcesses.length, (index) {
                  final smart = vm.smartProcesses[index];
                  final processName = smart['process'] ?? 'Proses ${index + 1}';
                  return Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF8FAFC),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: const Color(0xFFE2E8F0)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        CheckboxListTile(
                          value: smart['is_smart'],
                          onChanged: (val) => vm.toggleSmartProcess(index, val ?? false),
                          title: Text(
                            processName.isNotEmpty ? processName : 'Proses ${index + 1}',
                            style: const TextStyle(color: Color(0xFF0F172A), fontWeight: FontWeight.bold),
                          ),
                          subtitle: const Text(
                            'Apakah ini proses cerdas?',
                            style: TextStyle(color: Color(0xFF64748B), fontSize: 12),
                          ),
                          activeColor: const Color(0xFF00C88C),
                          checkColor: Colors.white,
                          contentPadding: EdgeInsets.zero,
                          controlAffinity: ListTileControlAffinity.leading,
                        ),
                        if (smart['is_smart'])
                          Padding(
                            padding: const EdgeInsets.only(top: 8),
                            child: TextFormField(
                              controller: smart['reason'],
                              style: const TextStyle(color: Color(0xFF0F172A), fontSize: 14),
                              decoration: InputDecoration(
                                labelText: 'Alasan mengapa cerdas',
                                labelStyle: const TextStyle(
                                  color: Color(0xFF64748B),
                                  fontSize: 14,
                                ),
                                filled: true,
                                fillColor: Colors.white,
                                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8),
                                  borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8),
                                  borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8),
                                  borderSide: const BorderSide(color: Color(0xFF00C88C), width: 1.5),
                                ),
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
      },
    );
  }

  Widget _buildComplexListSection({
    required BuildContext context,
    required String title,
    required IconData icon,
    required Color accentColor,
    required List<Map<String, TextEditingController>> items,
    required VoidCallback onAdd,
    required void Function(int) onRemove,
    required List<Map<String, String>> fields,
  }) {
    return Consumer<WizardViewModel>(
      builder: (context, wizardVm, child) {
        return Container(
          width: double.infinity,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0xFFE2E8F0)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.04),
                blurRadius: 16,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(icon, color: accentColor, size: 20),
                  const SizedBox(width: 8),
                  Text(
                    title,
                    style: TextStyle(
                      color: accentColor,
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              ...List.generate(items.length, (index) {
                final item = items[index];
                return Container(
                  margin: const EdgeInsets.only(bottom: 16),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF8FAFC),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: const Color(0xFFE2E8F0)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Item ${index + 1}',
                            style: const TextStyle(
                              color: Color(0xFF64748B),
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          if (index > 0)
                            InkWell(
                              onTap: () => onRemove(index),
                              borderRadius: BorderRadius.circular(8),
                              child: const Padding(
                                padding: EdgeInsets.all(4.0),
                                child: Icon(
                                  Icons.close_rounded,
                                  color: Colors.redAccent,
                                  size: 16,
                                ),
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      ...fields.map((f) {
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: TextFormField(
                            controller: item[f['key']],
                            onChanged: (_) {
                              // Sync if the field is 'name'
                              if (f['key'] == 'name') {
                                context.read<WizardViewModel>().intelligenceImplementationVM.syncProcessNames();
                              }
                            },
                            style: const TextStyle(color: Color(0xFF0F172A), fontSize: 14),
                            validator: (value) {
                              if (index == 0 && (value == null || value.trim().isEmpty)) {
                                return 'Wajib diisi';
                              }
                              return null;
                            },
                            decoration: InputDecoration(
                              labelText: f['label'],
                              labelStyle: const TextStyle(
                                color: Color(0xFF64748B),
                                fontSize: 14,
                              ),
                              filled: true,
                              fillColor: Colors.white,
                              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                                borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                                borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                                borderSide: BorderSide(color: accentColor, width: 1.5),
                              ),
                            ),
                          ),
                        );
                      }),
                    ],
                  ),
                );
              }),
              TextButton.icon(
                onPressed: onAdd,
                icon: Icon(Icons.add, color: accentColor, size: 18),
                label: Text(
                  'Tambah Data',
                  style: TextStyle(
                    color: accentColor,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                style: TextButton.styleFrom(
                  backgroundColor: accentColor.withValues(alpha: 0.1),
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
