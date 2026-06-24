import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../viewmodels/wizard/wizard_viewmodel.dart';

class ImplementationPlanningStep extends StatelessWidget {
  const ImplementationPlanningStep({super.key});

  @override
  Widget build(BuildContext context) {
    final vm = context.read<WizardViewModel>().implementationPlanningVM;

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
      child: Form(
        key: vm.formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Timeline Orchestration
            _buildTimelineSection(context, vm),
            const SizedBox(height: 16),

            // Pelaksana Operasi
            _buildComplexListSection(
              context: context,
              title: 'Pelaksana Operasi',
              icon: Icons.people_outline_rounded,
              accentColor: const Color(0xFF2563EB),
              items: vm.operators,
              onAdd: () => vm.addOperator(),
              onRemove: (index) => vm.removeOperator(index),
              fields: [
                {'key': 'name', 'label': 'Nama Pelaksana'},
                {'key': 'role', 'label': 'Peran'},
                {'key': 'contact', 'label': 'Kontak'},
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTimelineSection(BuildContext context, dynamic vm) {
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
                  const Icon(Icons.timeline_rounded, color: Color(0xFF2563EB), size: 20),
                  const SizedBox(width: 8),
                  const Text(
                    'Timeline Orchestration',
                    style: TextStyle(
                      color: Color(0xFF2563EB),
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              ...List.generate(vm.timelines.length, (index) {
                final timeline = vm.timelines[index];
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
                            'Fase ${index + 1}',
                            style: const TextStyle(
                              color: Color(0xFF64748B),
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          if (index > 0)
                            InkWell(
                              onTap: () => vm.removeTimeline(index),
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
                      
                      // Kategori Dropdown
                      DropdownButtonFormField<String>(
                        value: timeline['category'],
                        decoration: InputDecoration(
                          labelText: 'Kategori Fase',
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
                        ),
                        dropdownColor: Colors.white,
                        style: const TextStyle(color: Color(0xFF0F172A)),
                        items: const [
                          DropdownMenuItem(value: 'deployment', child: Text('Deployment', style: TextStyle(color: Color(0xFF0F172A)))),
                          DropdownMenuItem(value: 'maintenance', child: Text('Maintenance', style: TextStyle(color: Color(0xFF0F172A)))),
                          DropdownMenuItem(value: 'operation', child: Text('Operation', style: TextStyle(color: Color(0xFF0F172A)))),
                        ],
                        onChanged: (val) {
                          if (val != null) vm.setTimelineCategory(index, val);
                        },
                      ),
                      const SizedBox(height: 12),

                      // Nama Fase
                      TextFormField(
                        controller: timeline['phase_name'],
                        style: const TextStyle(color: Color(0xFF0F172A), fontSize: 14),
                        validator: (value) {
                          if (index == 0 && (value == null || value.trim().isEmpty)) {
                            return 'Wajib diisi';
                          }
                          return null;
                        },
                        decoration: InputDecoration(
                          labelText: 'Nama Fase',
                          labelStyle: const TextStyle(color: Color(0xFF64748B), fontSize: 14),
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
                            borderSide: const BorderSide(color: Color(0xFF2563EB), width: 1.5),
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),

                      // Tanggal Mulai dan Selesai
                      Row(
                        children: [
                          Expanded(
                            child: InkWell(
                              onTap: () async {
                                final date = await showDatePicker(
                                  context: context,
                                  initialDate: timeline['start_date'] ?? DateTime.now(),
                                  firstDate: DateTime(2000),
                                  lastDate: DateTime(2100),
                                  builder: (context, child) {
                                    return Theme(
                                      data: Theme.of(context).copyWith(
                                        colorScheme: const ColorScheme.light(
                                          primary: Color(0xFF2563EB),
                                          onPrimary: Colors.white,
                                          surface: Colors.white,
                                          onSurface: Color(0xFF0F172A),
                                        ),
                                      ),
                                      child: child!,
                                    );
                                  },
                                );
                                if (date != null) vm.setTimelineStartDate(index, date);
                              },
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(color: const Color(0xFFE2E8F0)),
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text('Tanggal Mulai', style: TextStyle(color: Color(0xFF64748B), fontSize: 12)),
                                    const SizedBox(height: 4),
                                    Text(
                                      timeline['start_date'] != null 
                                          ? '${timeline['start_date'].day}/${timeline['start_date'].month}/${timeline['start_date'].year}'
                                          : 'Pilih Tanggal',
                                      style: const TextStyle(color: Color(0xFF0F172A), fontSize: 14),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: InkWell(
                              onTap: () async {
                                final date = await showDatePicker(
                                  context: context,
                                  initialDate: timeline['end_date'] ?? DateTime.now(),
                                  firstDate: DateTime(2000),
                                  lastDate: DateTime(2100),
                                  builder: (context, child) {
                                    return Theme(
                                      data: Theme.of(context).copyWith(
                                        colorScheme: const ColorScheme.light(
                                          primary: Color(0xFF2563EB),
                                          onPrimary: Colors.white,
                                          surface: Colors.white,
                                          onSurface: Color(0xFF0F172A),
                                        ),
                                      ),
                                      child: child!,
                                    );
                                  },
                                );
                                if (date != null) vm.setTimelineEndDate(index, date);
                              },
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(color: const Color(0xFFE2E8F0)),
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text('Tanggal Selesai', style: TextStyle(color: Color(0xFF64748B), fontSize: 12)),
                                    const SizedBox(height: 4),
                                    Text(
                                      timeline['end_date'] != null 
                                          ? '${timeline['end_date'].day}/${timeline['end_date'].month}/${timeline['end_date'].year}'
                                          : 'Pilih Tanggal',
                                      style: const TextStyle(color: Color(0xFF0F172A), fontSize: 14),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),

                      // PIC
                      TextFormField(
                        controller: timeline['pic'],
                        style: const TextStyle(color: Color(0xFF0F172A), fontSize: 14),
                        decoration: InputDecoration(
                          labelText: 'PIC (Person in Charge)',
                          labelStyle: const TextStyle(color: Color(0xFF64748B), fontSize: 14),
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
                            borderSide: const BorderSide(color: Color(0xFF2563EB), width: 1.5),
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),

                      // Status Dropdown
                      DropdownButtonFormField<String>(
                        value: timeline['status'],
                        decoration: InputDecoration(
                          labelText: 'Status',
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
                        ),
                        dropdownColor: Colors.white,
                        style: const TextStyle(color: Color(0xFF0F172A)),
                        items: const [
                          DropdownMenuItem(value: 'backlog', child: Text('Backlog', style: TextStyle(color: Color(0xFF0F172A)))),
                          DropdownMenuItem(value: 'ongoing', child: Text('Ongoing', style: TextStyle(color: Color(0xFF0F172A)))),
                          DropdownMenuItem(value: 'completed', child: Text('Completed', style: TextStyle(color: Color(0xFF0F172A)))),
                          DropdownMenuItem(value: 'delayed', child: Text('Delayed', style: TextStyle(color: Color(0xFF0F172A)))),
                        ],
                        onChanged: (val) {
                          if (val != null) vm.setTimelineStatus(index, val);
                        },
                      ),
                    ],
                  ),
                );
              }),
              TextButton.icon(
                onPressed: () => vm.addTimeline(),
                icon: const Icon(Icons.add, color: Color(0xFF2563EB), size: 18),
                label: const Text(
                  'Tambah Fase',
                  style: TextStyle(
                    color: Color(0xFF2563EB),
                    fontWeight: FontWeight.w600,
                  ),
                ),
                style: TextButton.styleFrom(
                  backgroundColor: const Color(0xFF2563EB).withValues(alpha: 0.1),
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
