import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../viewmodels/wizard/wizard_viewmodel.dart';

class IntelligenceExperienceStep extends StatelessWidget {
  const IntelligenceExperienceStep({super.key});

  @override
  Widget build(BuildContext context) {
    final vm = context.read<WizardViewModel>().intelligenceExperienceVM;

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
      child: Form(
        key: vm.formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Penyajian Kecerdasan
            _buildSection(
              title: 'Penyajian Kecerdasan',
              icon: Icons.dashboard_customize_rounded,
              accentColor: const Color(0xFF2563EB),
              child: Consumer<WizardViewModel>(
                builder: (context, wizardVm, child) {
                  return Column(
                    children: [
                      _buildCheckboxTile(
                        context: context,
                        title: 'Automate',
                        subtitle: 'Melakukan aksi tanpa perlu persetujuan user',
                        value: 'automate',
                        groupValue: vm.selectedPresentations,
                        onChanged: (_) => vm.togglePresentation('automate'),
                      ),
                      _buildCheckboxTile(
                        context: context,
                        title: 'Prompt',
                        subtitle: 'Memberikan saran kepada user untuk bertindak',
                        value: 'prompt',
                        groupValue: vm.selectedPresentations,
                        onChanged: (_) => vm.togglePresentation('prompt'),
                      ),
                      _buildCheckboxTile(
                        context: context,
                        title: 'Organisation',
                        subtitle: 'Menyajikan UI secara dinamis (sorting/filter/layout)',
                        value: 'organisation',
                        groupValue: vm.selectedPresentations,
                        onChanged: (_) => vm.togglePresentation('organisation'),
                      ),
                      _buildCheckboxTile(
                        context: context,
                        title: 'Annotate',
                        subtitle: 'Menambahkan metadata atau highlight informasi penting',
                        value: 'annotate',
                        groupValue: vm.selectedPresentations,
                        onChanged: (_) => vm.togglePresentation('annotate'),
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: vm.presentationDescController,
                        maxLines: 3,
                        style: const TextStyle(color: Color(0xFF0F172A), fontSize: 14),
                        decoration: InputDecoration(
                          hintText: 'Deskripsi tambahan terkait penyajian kecerdasan',
                          hintStyle: const TextStyle(color: Color(0xFF94A3B8)),
                          filled: true,
                          fillColor: Colors.white,
                          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(color: Color(0xFF2563EB), width: 1.5),
                          ),
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
            const SizedBox(height: 16),

            // Fungsi-fungsi Realisasi Objectives
            _buildComplexListSection(
              context: context,
              title: 'Fungsi Realisasi',
              icon: Icons.functions_rounded,
              accentColor: const Color(0xFF2563EB),
              items: vm.functions,
              onAdd: () => vm.addFunction(),
              onRemove: (index) => vm.removeFunction(index),
              fields: [
                {'key': 'name', 'label': 'Nama Fungsi / Fitur'},
                {'key': 'description', 'label': 'Deskripsi Fungsi / Fitur'},
              ],
            ),
            const SizedBox(height: 16),

            // Minimalisasi Kesalahan
            _buildComplexListSection(
              context: context,
              title: 'Minimalisasi Kesalahan',
              icon: Icons.shield_rounded,
              accentColor: const Color(0xFF2563EB),
              items: vm.errorMinimizations,
              onAdd: () => vm.addErrorMinimization(),
              onRemove: (index) => vm.removeErrorMinimization(index),
              fields: [
                {'key': 'function', 'label': 'Fungsi / Fitur Terkait'},
                {'key': 'strategy', 'label': 'Strategi Minimalisasi'},
              ],
            ),
            const SizedBox(height: 16),

            // Pengumpulan Data
            _buildComplexListSection(
              context: context,
              title: 'Pengumpulan Data',
              icon: Icons.data_usage_rounded,
              accentColor: const Color(0xFF2563EB),
              items: vm.dataCollections,
              onAdd: () => vm.addDataCollection(),
              onRemove: (index) => vm.removeDataCollection(index),
              fields: [
                {'key': 'function', 'label': 'Fungsi / Fitur Terkait'},
                {'key': 'plan', 'label': 'Rencana Pengumpulan'},
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSection({
    required String title,
    required IconData icon,
    required Color accentColor,
    required Widget child,
  }) {
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
          child,
        ],
      ),
    );
  }

  Widget _buildCheckboxTile({
    required BuildContext context,
    required String title,
    required String subtitle,
    required String value,
    required Set<String> groupValue,
    required ValueChanged<bool?> onChanged,
  }) {
    final isSelected = groupValue.contains(value);
    
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: isSelected ? const Color(0xFF2563EB).withValues(alpha: 0.08) : const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isSelected ? const Color(0xFF2563EB).withValues(alpha: 0.5) : const Color(0xFFE2E8F0),
        ),
      ),
      child: CheckboxListTile(
        value: isSelected,
        onChanged: onChanged,
        activeColor: const Color(0xFF2563EB),
        checkColor: Colors.white,
        title: Text(
          title,
          style: TextStyle(
            color: const Color(0xFF0F172A),
            fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
            fontSize: 14,
          ),
        ),
        subtitle: Text(
          subtitle,
          style: const TextStyle(
            color: Color(0xFF64748B),
            fontSize: 12,
          ),
        ),
        controlAffinity: ListTileControlAffinity.leading,
        contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      ),
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
