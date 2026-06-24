import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../viewmodels/wizard/wizard_viewmodel.dart';

class MeaningfulObjectivesStep extends StatelessWidget {
  const MeaningfulObjectivesStep({super.key});

  @override
  Widget build(BuildContext context) {
    final vm = context.read<WizardViewModel>().meaningfulObjectivesVM;
    
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
      child: Form(
        key: vm.formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Organizational Objectives
            _buildComplexListSection(
              context: context,
              title: 'Organizational Objectives',
              icon: Icons.track_changes_rounded,
              accentColor: const Color(0xFF2563EB),
              items: vm.organizationalObjectives,
              onAdd: () => vm.addOrganizationalObjective(),
              onRemove: (index) => vm.removeOrganizationalObjective(index),
              fields: [
                {'key': 'objective', 'label': 'Objective'},
                {'key': 'strategy', 'label': 'Strategy'},
                {'key': 'measure', 'label': 'Measure'},
              ],
            ),
            const SizedBox(height: 16),

            // Leading Indicators
            _buildComplexListSection(
              context: context,
              title: 'Leading Indicators',
              icon: Icons.trending_up_rounded,
              accentColor: const Color(0xFF2563EB),
              items: vm.leadingIndicators,
              onAdd: () => vm.addLeadingIndicator(),
              onRemove: (index) => vm.removeLeadingIndicator(index),
              fields: [
                {'key': 'feature', 'label': 'Feature'},
                {'key': 'system', 'label': 'Sistem'},
                {'key': 'competitor', 'label': 'Produk Lain'},
              ],
            ),
            const SizedBox(height: 16),

            // User Outcomes
            _buildComplexListSection(
              context: context,
              title: 'User Outcomes',
              icon: Icons.people_rounded,
              accentColor: const Color(0xFF2563EB),
              items: vm.userOutcomes,
              onAdd: () => vm.addUserOutcome(),
              onRemove: (index) => vm.removeUserOutcome(index),
              fields: [
                {'key': 'outcome', 'label': 'User Outcome'},
                {'key': 'strategy', 'label': 'Strategy'},
                {'key': 'measure', 'label': 'Measure'},
              ],
            ),
            const SizedBox(height: 16),

            // Model Properties
            _buildComplexListSection(
              context: context,
              title: 'Model Properties',
              icon: Icons.psychology_rounded,
              accentColor: const Color(0xFF2563EB),
              items: vm.modelProperties,
              onAdd: () => vm.addModelProperty(),
              onRemove: (index) => vm.removeModelProperty(index),
              fields: [
                {'key': 'property', 'label': 'Model Property'},
                {'key': 'strategy', 'label': 'Strategy'},
                {'key': 'measure', 'label': 'Measure'},
              ],
            ),
          ],
        ),
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
                  Expanded(
                    child: Text(
                      title,
                      style: TextStyle(
                        color: accentColor,
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                      ),
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
