import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/project_model.dart';
import '../../services/api_service.dart';
import '../../viewmodels/wizard/wizard_viewmodel.dart';
import '../../widgets/background_gradient.dart';
import 'project_creation_step.dart';
import 'meaningful_objectives_step.dart';
import 'intelligence_experience_step.dart';
import 'intelligence_implementation_step.dart';
import 'constraints_status_step.dart';
import 'implementation_planning_step.dart';

class ProjectWizardPage extends StatefulWidget {
  final Map<String, dynamic>? initialData;

  const ProjectWizardPage({super.key, this.initialData});

  @override
  State<ProjectWizardPage> createState() => _ProjectWizardPageState();
}

class _ProjectWizardPageState extends State<ProjectWizardPage> {
  late final WizardViewModel _viewModel;

  @override
  void initState() {
    super.initState();
    _viewModel = WizardViewModel();
    if (widget.initialData != null) {
      _viewModel.loadInitialData(widget.initialData!);
    }
  }

  @override
  void dispose() {
    _viewModel.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider.value(
      value: _viewModel,
      child: const _WizardPageContent(),
    );
  }
}

class _WizardPageContent extends StatelessWidget {
  const _WizardPageContent();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          const BackgroundGradient(),
          SafeArea(
            child: Column(
              children: [
                // Header with back button, progress, and save draft
                const _WizardHeader(),

                // Step indicator
                const _StepIndicator(),

                // Main content - current step
                Expanded(
                  child: Consumer<WizardViewModel>(
                    builder: (context, vm, child) {
                      return AnimatedSwitcher(
                        duration: const Duration(milliseconds: 300),
                        transitionBuilder: (child, animation) {
                          return FadeTransition(
                            opacity: animation,
                            child: SlideTransition(
                              position: Tween<Offset>(
                                begin: const Offset(0.05, 0),
                                end: Offset.zero,
                              ).animate(animation),
                              child: child,
                            ),
                          );
                        },
                        layoutBuilder: (currentChild, previousChildren) {
                          return Stack(
                            alignment: Alignment.topCenter,
                            children: <Widget>[
                              ...previousChildren,
                              if (currentChild != null) currentChild,
                            ],
                          );
                        },
                        child: _buildStep(vm.currentStep),
                      );
                    },
                  ),
                ),

                // Navigation buttons
                const _WizardNavigation(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStep(int step) {
    switch (step) {
      case 0:
        return const ProjectCreationStep(key: ValueKey(0));
      case 1:
        return const MeaningfulObjectivesStep(key: ValueKey(1));
      case 2:
        return const IntelligenceExperienceStep(key: ValueKey(2));
      case 3:
        return const IntelligenceImplementationStep(key: ValueKey(3));
      case 4:
        return const ConstraintsStatusStep(key: ValueKey(4));
      case 5:
        return const ImplementationPlanningStep(key: ValueKey(5));
      default:
        return const ProjectCreationStep(key: ValueKey(0));
    }
  }
}

class _WizardHeader extends StatelessWidget {
  const _WizardHeader();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
      child: Row(
        children: [
          GestureDetector(
            onTap: () {
              FocusScope.of(context).unfocus(); // Ensure keyboard is dismissed
              Navigator.pop(context);
            },
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: 0.05),
                borderRadius: BorderRadius.circular(14),
              ),
              child: const Icon(
                Icons.arrow_back_ios_new_rounded,
                color: Color(0xFF0F172A),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Consumer<WizardViewModel>(
              builder: (context, vm, child) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      vm.currentStepInfo.title,
                      style: const TextStyle(
                        color: Color(0xFF0F172A),
                        fontSize: 20,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    Text(
                      vm.currentStepInfo.subtitle,
                      style: TextStyle(
                        color: Color(0xFF475569),
                        fontSize: 13,
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
          // Space placeholder for right-aligned items
          const SizedBox(width: 48),
        ],
      ),
    );
  }
}

class _StepIndicator extends StatelessWidget {
  const _StepIndicator();

  @override
  Widget build(BuildContext context) {
    return Consumer<WizardViewModel>(
      builder: (context, vm, child) {
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          child: Row(
            children: List.generate(vm.totalSteps, (index) {
              final isActive = index == vm.currentStep;
              final isCompleted = index < vm.currentStep;
              final canNavigate = index < vm.currentStep;

              return Expanded(
                child: GestureDetector(
                  onTap: canNavigate ? () => vm.goToStep(index) : null,
                  child: Container(
                    margin: const EdgeInsets.symmetric(horizontal: 2),
                    height: 4,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(2),
                      color: isActive
                          ? vm.currentStepInfo.accent
                          : isCompleted
                          ? vm.currentStepInfo.accent.withValues(alpha: 0.5)
                          : Colors.black.withValues(alpha: 0.1),
                    ),
                  ),
                ),
              );
            }),
          ),
        );
      },
    );
  }
}

class _WizardNavigation extends StatelessWidget {
  const _WizardNavigation();

  @override
  Widget build(BuildContext context) {
    return Consumer<WizardViewModel>(
      builder: (context, vm, child) {
        return Container(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                const Color(0xFFF1F5F9).withValues(alpha: 0.0),
                const Color(0xFFF1F5F9).withValues(alpha: 0.9),
                const Color(0xFFF1F5F9),
              ],
            ),
          ),
          child: SafeArea(
            top: false,
            child: Row(
              children: [
                // Back button (hidden on first step)
                if (!vm.isFirstStep)
                  Expanded(
                    flex: 1,
                    child: ElevatedButton(
                      onPressed: () => vm.goBack(),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.black.withValues(alpha: 0.05),
                        foregroundColor: const Color(0xFF0F172A),
                        elevation: 0,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                          side: BorderSide(
                            color: Colors.black.withValues(alpha: 0.1),
                          ),
                        ),
                      ),
                      child: const Text(
                        'Kembali',
                        style: TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 15,
                        ),
                      ),
                    ),
                  ),
                if (!vm.isFirstStep) const SizedBox(width: 12),

                // Next/Submit button
                Expanded(
                  flex: vm.isFirstStep ? 2 : 1,
                  child: ElevatedButton(
                    onPressed: vm.projectSelectionVM.isSubmitting ? null : () async {
                      if (vm.isLastStep) {
                        _submitWizard(context, vm);
                      } else {
                        if (vm.isFirstStep) {
                          if (!vm.currentStepViewModel.validate()) return;
                          
                          final pvm = vm.projectSelectionVM;
                          pvm.setSubmitting(true);
                          
                          // Generate a stable ID once if not already set
                          pvm.pmProjectId ??= 'init-${DateTime.now().millisecondsSinceEpoch}';
                          
                          final apiService = ApiService();
                          final res = await apiService.createProjectToAPI(pvm.collectData());
                          
                          pvm.setSubmitting(false);
                          
                          if (res['success'] == true) {
                            vm.goNext();
                          } else {
                            if (context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(res['message'] ?? 'Gagal membuat proyek di server'),
                                  backgroundColor: Colors.redAccent,
                                ),
                              );
                            }
                          }
                        } else {
                          vm.goNext();
                        }
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: vm.currentStepInfo.accent,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    child: vm.projectSelectionVM.isSubmitting && vm.isFirstStep
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                            ),
                          )
                        : Text(
                            vm.isLastStep ? 'Simpan' : 'Lanjut',
                            style: const TextStyle(
                              fontWeight: FontWeight.w800,
                              fontSize: 15,
                            ),
                          ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _submitWizard(BuildContext context, WizardViewModel vm) async {
    final formData = vm.submit();
    if (formData != null) {
      if (context.mounted) {
        Navigator.pop(context, formData);
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Mohon lengkapi semua data'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
}
