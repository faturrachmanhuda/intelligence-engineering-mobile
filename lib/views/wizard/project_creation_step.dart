import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../viewmodels/wizard/wizard_viewmodel.dart';

class ProjectCreationStep extends StatelessWidget {
  const ProjectCreationStep({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Title
          const Text(
            'Buat Proyek Baru',
            style: TextStyle(
              color: Color(0xFF0F172A),
              fontSize: 24,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Lengkapi informasi dasar proyek Anda sebelum melanjutkan ke tahap perencanaan dan inisiasi Blueprint.',
            style: TextStyle(
              color: Color(0xFF475569),
              fontSize: 14,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 24),

          // Form
          Consumer<WizardViewModel>(
            builder: (context, vm, child) {
              final pVM = vm.projectSelectionVM;

              return Form(
                key: pVM.formKey,
                child: Column(
                  children: [
                    _buildTextField(
                      controller: pVM.nameController,
                      label: 'Nama Proyek',
                      hint: 'Contoh: Sistem Rekomendasi AI',
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Nama proyek tidak boleh kosong';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    _buildTextField(
                      controller: pVM.descriptionController,
                      label: 'Deskripsi Proyek',
                      hint: 'Jelaskan secara singkat tujuan proyek ini...',
                      maxLines: 3,
                    ),
                    const SizedBox(height: 16),
                    _buildTextField(
                      controller: pVM.divisionController,
                      label: 'Divisi Pelaksana',
                      hint: 'Divisi / Tim',
                    ),
                    const SizedBox(height: 16),
                    _buildTextField(
                      controller: pVM.supervisorController,
                      label: 'Pengawas',
                      hint: 'Nama Pengawas',
                    ),
                    const SizedBox(height: 16),
                    _buildDateField(
                      context: context,
                      label: 'Tanggal Mulai',
                      selectedDate: pVM.startDate,
                      onDateSelected: (date) => pVM.setStartDate(date),
                    ),
                    const SizedBox(height: 16),
                    _buildDateField(
                      context: context,
                      label: 'Tanggal Selesai',
                      selectedDate: pVM.endDate,
                      onDateSelected: (date) => pVM.setEndDate(date),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    int maxLines = 1,
    String? Function(String?)? validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            color: Color(0xFF475569),
            fontSize: 13,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.5,
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          maxLines: maxLines,
          style: const TextStyle(color: Color(0xFF0F172A), fontSize: 15),
          validator: validator,
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(color: const Color(0xFF94A3B8)),
            filled: true,
            fillColor: Colors.white,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide.none,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: const BorderSide(color: Color(0xFF2563EB), width: 1.5),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide(color: Colors.redAccent.withValues(alpha: 0.5)),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: const BorderSide(color: Colors.redAccent, width: 1.5),
            ),
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          ),
        ),
      ],
    );
  }

  Widget _buildDateField({
    required BuildContext context,
    required String label,
    required DateTime? selectedDate,
    required Function(DateTime) onDateSelected,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            color: Color(0xFF475569),
            fontSize: 13,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.5,
          ),
        ),
        const SizedBox(height: 8),
        InkWell(
          onTap: () async {
            final date = await showDatePicker(
              context: context,
              initialDate: selectedDate ?? DateTime.now(),
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
            if (date != null) {
              onDateSelected(date);
            }
          },
          borderRadius: BorderRadius.circular(16),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFFE2E8F0)),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    selectedDate != null
                        ? '${selectedDate.day}/${selectedDate.month}/${selectedDate.year}'
                        : 'Pilih Tanggal',
                    style: TextStyle(
                      color: selectedDate != null ? const Color(0xFF0F172A) : const Color(0xFF94A3B8),
                      fontSize: 15,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
