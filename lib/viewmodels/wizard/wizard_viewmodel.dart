import 'package:flutter/material.dart';
import '../../models/project_model.dart';
import '../../models/wizard_step_model.dart';
import 'step_viewmodels.dart';

/// Main ViewModel for the project initiation wizard.
/// Coordinates all step ViewModels and manages navigation and draft persistence.
class WizardViewModel extends ChangeNotifier {
  // ── Step ViewModels ──
  late final List<WizardStepViewModel> _stepViewModels;

  WizardViewModel() {
    _stepViewModels = [
      ProjectCreationViewModel(),
      MeaningfulObjectivesViewModel(),
      IntelligenceExperienceViewModel(),
      IntelligenceImplementationViewModel(),
      ConstraintsStatusViewModel(),
      ImplementationPlanningViewModel(),
    ];

    // Listen to changes in step viewmodels and forward notifications
    for (final vm in _stepViewModels) {
      vm.addListener(_onStepChanged);
    }
  }

  void _onStepChanged() {
    _syncModuleNames();
    notifyListeners();
  }

  void _syncModuleNames() {
    final functions = intelligenceExperienceVM.functions;
    final moduleStatuses = constraintsStatusVM.moduleStatuses;

    for (int i = 0; i < functions.length; i++) {
      final funcName = functions[i]['name']?.text ?? '';
      
      if (i < moduleStatuses.length) {
        final currentModName = (moduleStatuses[i]['module'] as TextEditingController).text;
        if (currentModName != funcName && funcName.isNotEmpty) {
          (moduleStatuses[i]['module'] as TextEditingController).text = funcName;
        }
      } else {
        if (funcName.isNotEmpty) {
          constraintsStatusVM.addModuleStatus();
          (moduleStatuses.last['module'] as TextEditingController).text = funcName;
        }
      }
    }
  }

  // ── Navigation state ──
  int _currentStep = 0;
  int get currentStep => _currentStep;
  int get totalSteps => wizardSteps.length;
  WizardStepInfo get currentStepInfo => wizardSteps[_currentStep];
  bool get isFirstStep => _currentStep == 0;
  bool get isLastStep => _currentStep == totalSteps - 1;
  double get progress => (_currentStep + 1) / totalSteps;

  // ── Step ViewModel accessors ──
  ProjectCreationViewModel get projectSelectionVM =>
      _stepViewModels[0] as ProjectCreationViewModel;
  MeaningfulObjectivesViewModel get meaningfulObjectivesVM =>
      _stepViewModels[1] as MeaningfulObjectivesViewModel;
  IntelligenceExperienceViewModel get intelligenceExperienceVM =>
      _stepViewModels[2] as IntelligenceExperienceViewModel;
  IntelligenceImplementationViewModel get intelligenceImplementationVM =>
      _stepViewModels[3] as IntelligenceImplementationViewModel;
  ConstraintsStatusViewModel get constraintsStatusVM =>
      _stepViewModels[4] as ConstraintsStatusViewModel;
  ImplementationPlanningViewModel get implementationPlanningVM =>
      _stepViewModels[5] as ImplementationPlanningViewModel;

  WizardStepViewModel get currentStepViewModel => _stepViewModels[_currentStep];

  void loadInitialData(Map<String, dynamic> initialData) {
    _currentStep = 1; // Skip Project Selection when loading from dashboard
    _loadDataToSteps(initialData);
    notifyListeners();
  }

  void _loadDataToSteps(Map<String, dynamic> formData) {
    // Step 0: Project Selection (Metadata)
    final projectVm = projectSelectionVM;
    projectVm.pmProjectId = formData['pm_project_id'];
    projectVm.nameController.text = formData['name'] ?? '';
    projectVm.descriptionController.text = formData['description'] ?? '';

    // Step 1: Meaningful Objectives
    final step1Data = formData['step_1'] as Map<String, dynamic>?;
    if (step1Data != null) {
      final vm = meaningfulObjectivesVM;

      void loadList(String key, List<Map<String, TextEditingController>> target, Function addFunc) {
        final listData = step1Data[key] as List?;
        if (listData != null && listData.isNotEmpty) {
          for (var i = 1; i < target.length; i++) target[i].forEach((_, c) => c.dispose());
          target.clear();
          for (final item in listData) {
            addFunc();
            final lastIndex = target.length - 1;
            target[lastIndex]['objective']?.text = item['objective']?.toString() ?? '';
            target[lastIndex]['feature']?.text = item['feature']?.toString() ?? '';
            target[lastIndex]['system']?.text = item['system']?.toString() ?? '';
            target[lastIndex]['competitor']?.text = item['competitor']?.toString() ?? '';
            target[lastIndex]['outcome']?.text = item['outcome']?.toString() ?? '';
            target[lastIndex]['property']?.text = item['property']?.toString() ?? '';
            target[lastIndex]['strategy']?.text = item['strategy']?.toString() ?? '';
            target[lastIndex]['measure']?.text = item['measure']?.toString() ?? '';
          }
        }
      }

      loadList('organizational_objectives', vm.organizationalObjectives, vm.addOrganizationalObjective);
      loadList('leading_indicators', vm.leadingIndicators, vm.addLeadingIndicator);
      loadList('user_outcomes', vm.userOutcomes, vm.addUserOutcome);
      loadList('model_properties', vm.modelProperties, vm.addModelProperty);
    }

    // Step 2: Intelligence Experience
    final step2Data = formData['step_2'] as Map<String, dynamic>?;
    if (step2Data != null) {
      final vm = intelligenceExperienceVM;
      final presentations = step2Data['presentations'] as List?;
      if (presentations != null) {
        for (final p in presentations) vm.togglePresentation(p.toString());
      }
      vm.presentationDescController.text = step2Data['presentation_description']?.toString() ?? '';

      void loadList(String key, List<Map<String, TextEditingController>> target, Function addFunc) {
        final listData = step2Data[key] as List?;
        if (listData != null && listData.isNotEmpty) {
          for (var i = 1; i < target.length; i++) target[i].forEach((_, c) => c.dispose());
          target.clear();
          for (final item in listData) {
            addFunc();
            final lastIndex = target.length - 1;
            target[lastIndex]['name']?.text = item['name']?.toString() ?? '';
            target[lastIndex]['description']?.text = item['description']?.toString() ?? '';
            target[lastIndex]['function']?.text = item['function']?.toString() ?? '';
            target[lastIndex]['strategy']?.text = item['strategy']?.toString() ?? '';
            target[lastIndex]['plan']?.text = item['plan']?.toString() ?? '';
          }
        }
      }

      loadList('functions', vm.functions, vm.addFunction);
      loadList('error_minimizations', vm.errorMinimizations, vm.addErrorMinimization);
      loadList('data_collections', vm.dataCollections, vm.addDataCollection);
    }

    // Step 3: Intelligence Implementation
    final step3Data = formData['step_3'] as Map<String, dynamic>?;
    if (step3Data != null) {
      final vm = intelligenceImplementationVM;
      
      final businessProcesses = step3Data['business_processes'] as List?;
      if (businessProcesses != null && businessProcesses.isNotEmpty) {
        for (var i = 1; i < vm.businessProcesses.length; i++) {
          vm.businessProcesses[i].forEach((_, c) => c.dispose());
        }
        vm.businessProcesses.clear();
        vm.technologies.clear();
        vm.smartProcesses.clear();
        for (final item in businessProcesses) {
          vm.addBusinessProcess();
          final lastIndex = vm.businessProcesses.length - 1;
          vm.businessProcesses[lastIndex]['name']?.text = item['name']?.toString() ?? '';
          vm.businessProcesses[lastIndex]['description']?.text = item['description']?.toString() ?? '';
        }
      }

      final technologies = step3Data['technologies'] as List?;
      if (technologies != null) {
        for (int i = 0; i < technologies.length && i < vm.technologies.length; i++) {
          final techString = technologies[i]['technology']?.toString() ?? technologies[i]['technologies']?.toString() ?? '';
          vm.technologies[i]['technology']?.text = techString;
        }
      }

      final smartProcesses = step3Data['smart_processes'] as List?;
      if (smartProcesses != null) {
        for (int i = 0; i < smartProcesses.length && i < vm.smartProcesses.length; i++) {
          vm.smartProcesses[i]['is_smart'] = smartProcesses[i]['is_smart'] ?? false;
          (vm.smartProcesses[i]['reason'] as TextEditingController).text = smartProcesses[i]['reason']?.toString() ?? '';
        }
      }
      
      vm.syncProcessNames();
    }

    // Step 4: Creation Status
    final step4Data = formData['step_4'] as Map<String, dynamic>?;
    if (step4Data != null) {
      final vm = constraintsStatusVM;

      final constraints = step4Data['constraints'] as List?;
      if (constraints != null && constraints.isNotEmpty) {
        for (var i = 1; i < vm.constraints.length; i++) {
          vm.constraints[i].forEach((_, c) => c.dispose());
        }
        vm.constraints.clear();
        for (final c in constraints) {
          vm.addConstraint();
          final lastIndex = vm.constraints.length - 1;
          vm.constraints[lastIndex]['category']?.text = c['category']?.toString() ?? '';
          vm.constraints[lastIndex]['description']?.text = c['description']?.toString() ?? '';
        }
      }

      final moduleStatuses = step4Data['module_statuses'] as List?;
      if (moduleStatuses != null && moduleStatuses.isNotEmpty) {
        for (var i = 1; i < vm.moduleStatuses.length; i++) {
          (vm.moduleStatuses[i]['module'] as TextEditingController).dispose();
          (vm.moduleStatuses[i]['notes'] as TextEditingController).dispose();
        }
        vm.moduleStatuses.clear();
        for (final m in moduleStatuses) {
          vm.addModuleStatus();
          final lastIndex = vm.moduleStatuses.length - 1;
          (vm.moduleStatuses[lastIndex]['module'] as TextEditingController).text = m['module']?.toString() ?? '';
          vm.moduleStatuses[lastIndex]['status'] = m['status']?.toString() ?? 'not_started';
          (vm.moduleStatuses[lastIndex]['notes'] as TextEditingController).text = m['notes']?.toString() ?? '';
        }
        vm.calculateCompletionPercentage();
      }
    }

    // Step 5: Orchestration
    final step5Data = formData['step_5'] as Map<String, dynamic>?;
    if (step5Data != null) {
      final vm = implementationPlanningVM;

      final timelines = step5Data['timelines'] as List?;
      if (timelines != null && timelines.isNotEmpty) {
        for (var i = 1; i < vm.timelines.length; i++) {
          (vm.timelines[i]['phase_name'] as TextEditingController).dispose();
          (vm.timelines[i]['pic'] as TextEditingController).dispose();
        }
        vm.timelines.clear();
        for (final t in timelines) {
          vm.addTimeline();
          final lastIndex = vm.timelines.length - 1;
          vm.timelines[lastIndex]['category'] = t['category']?.toString() ?? 'deployment';
          (vm.timelines[lastIndex]['phase_name'] as TextEditingController).text = t['phase_name']?.toString() ?? '';
          if (t['start_date'] != null) vm.timelines[lastIndex]['start_date'] = DateTime.tryParse(t['start_date'].toString());
          if (t['end_date'] != null) vm.timelines[lastIndex]['end_date'] = DateTime.tryParse(t['end_date'].toString());
          (vm.timelines[lastIndex]['pic'] as TextEditingController).text = t['pic']?.toString() ?? '';
          vm.timelines[lastIndex]['status'] = t['status']?.toString() ?? 'backlog';
        }
      }

      final operators = step5Data['operators'] as List?;
      if (operators != null && operators.isNotEmpty) {
        for (var i = 1; i < vm.operators.length; i++) {
          vm.operators[i].forEach((_, c) => c.dispose());
        }
        vm.operators.clear();
        for (final o in operators) {
          vm.addOperator();
          final lastIndex = vm.operators.length - 1;
          vm.operators[lastIndex]['name']?.text = o['name']?.toString() ?? '';
          vm.operators[lastIndex]['role']?.text = o['role']?.toString() ?? '';
          vm.operators[lastIndex]['contact']?.text = o['contact']?.toString() ?? '';
        }
      }
    }
  }

  // ── Navigation ──
  bool goNext() {
    if (!currentStepViewModel.validate()) return false;
    if (!isLastStep) {
      _currentStep++;
      notifyListeners();
      return true;
    }
    return false;
  }

  void goBack() {
    if (!isFirstStep) {
      _currentStep--;
      notifyListeners();
    }
  }

  void goToStep(int step) {
    if (step >= 0 && step < totalSteps && step <= _currentStep) {
      _currentStep = step;
      notifyListeners();
    }
  }

  // ── Collect all form data ──
  Map<String, dynamic> collectFormData() {
    final data = <String, dynamic>{};

    // Add project type info
    final projectData = projectSelectionVM.collectData();
    data.addAll(projectData);

    // Add data from all form steps
    for (int i = 1; i < _stepViewModels.length; i++) {
      final stepData = _stepViewModels[i].collectData();
      data['step_$i'] = stepData;
    }

    return data;
  }

  /// Submit the wizard: validate last step and return collected data.
  Map<String, dynamic>? submit() {
    if (!currentStepViewModel.validate()) return null;
    return collectFormData();
  }

  /// Reset entire wizard
  void reset() {
    _currentStep = 0;
    for (final vm in _stepViewModels) {
      vm.reset();
    }
    notifyListeners();
  }

  // ── Cleanup ──
  @override
  void dispose() {
    for (final vm in _stepViewModels) {
      vm.removeListener(_onStepChanged);
      vm.dispose();
    }
    super.dispose();
  }
}
