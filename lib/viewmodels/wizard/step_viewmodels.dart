import 'package:flutter/material.dart';
import '../../models/project_model.dart';
import '../../services/project_api_service.dart';

/// Base ViewModel for individual wizard steps
abstract class WizardStepViewModel extends ChangeNotifier {
  final int stepIndex;

  WizardStepViewModel({required this.stepIndex});

  /// Validate the current step
  bool validate();

  /// Collect data from this step
  Map<String, dynamic> collectData();

  /// Reset the step
  void reset();
}

/// ViewModel for Step 0: Project Creation
class ProjectCreationViewModel extends WizardStepViewModel {
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();

  final TextEditingController nameController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();
  final TextEditingController divisionController = TextEditingController();
  final TextEditingController supervisorController = TextEditingController();
  
  DateTime? startDate;
  DateTime? endDate;

  bool isSubmitting = false;
  String? pmProjectId;

  ProjectCreationViewModel() : super(stepIndex: 0);

  // Expose selected project type for backward compatibility with wizard header
  ProjectType get generatedProjectType {
    return ProjectType(
      id: 'custom-${DateTime.now().millisecondsSinceEpoch}',
      name: nameController.text.isNotEmpty ? nameController.text : 'Proyek Baru',
      description: descriptionController.text,
      icon: Icons.rocket_launch_rounded,
      accent: const Color(0xFF2563EB),
    );
  }

  void setStartDate(DateTime date) {
    startDate = date;
    notifyListeners();
  }

  void setEndDate(DateTime date) {
    endDate = date;
    notifyListeners();
  }

  void setSubmitting(bool value) {
    isSubmitting = value;
    notifyListeners();
  }

  @override
  bool validate() {
    return formKey.currentState?.validate() ?? false;
  }

  @override
  Map<String, dynamic> collectData() {
    final project = generatedProjectType;
    return {
      'project_type': pmProjectId ?? project.id,
      'pm_project_id': pmProjectId,
      'project_name': project.name,
      'selected_project': project,
      'name': nameController.text,
      'description': descriptionController.text,
      'division': divisionController.text,
      'supervisor': supervisorController.text,
      'start_date': startDate?.toIso8601String(),
      'end_date': endDate?.toIso8601String(),
    };
  }

  @override
  void reset() {
    nameController.clear();
    descriptionController.clear();
    divisionController.clear();
    supervisorController.clear();
    startDate = null;
    endDate = null;
    isSubmitting = false;
    notifyListeners();
  }

  @override
  void dispose() {
    nameController.dispose();
    descriptionController.dispose();
    divisionController.dispose();
    supervisorController.dispose();
    super.dispose();
  }
}

/// ViewModel for Step 1: Meaningful Objectives
class MeaningfulObjectivesViewModel extends WizardStepViewModel {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  // Organizational Objectives (list of maps)
  final List<Map<String, TextEditingController>> _organizationalObjectives = [];

  // Leading Indicators
  final List<Map<String, TextEditingController>> _leadingIndicators = [];

  // User Outcomes
  final List<Map<String, TextEditingController>> _userOutcomes = [];

  // Model Properties
  final List<Map<String, TextEditingController>> _modelProperties = [];

  MeaningfulObjectivesViewModel() : super(stepIndex: 1) {
    addOrganizationalObjective();
    addLeadingIndicator();
    addUserOutcome();
    addModelProperty();
  }

  GlobalKey<FormState> get formKey => _formKey;
  List<Map<String, TextEditingController>> get organizationalObjectives => _organizationalObjectives;
  List<Map<String, TextEditingController>> get leadingIndicators => _leadingIndicators;
  List<Map<String, TextEditingController>> get userOutcomes => _userOutcomes;
  List<Map<String, TextEditingController>> get modelProperties => _modelProperties;

  void addOrganizationalObjective() {
    _organizationalObjectives.add({
      'objective': TextEditingController(),
      'strategy': TextEditingController(),
      'measure': TextEditingController(),
    });
    notifyListeners();
  }

  void removeOrganizationalObjective(int index) {
    if (index > 0 && index < _organizationalObjectives.length) {
      _organizationalObjectives[index].forEach((_, c) => c.dispose());
      _organizationalObjectives.removeAt(index);
      notifyListeners();
    }
  }

  void addLeadingIndicator() {
    _leadingIndicators.add({
      'feature': TextEditingController(),
      'system': TextEditingController(),
      'competitor': TextEditingController(),
    });
    notifyListeners();
  }

  void removeLeadingIndicator(int index) {
    if (index > 0 && index < _leadingIndicators.length) {
      _leadingIndicators[index].forEach((_, c) => c.dispose());
      _leadingIndicators.removeAt(index);
      notifyListeners();
    }
  }

  void addUserOutcome() {
    _userOutcomes.add({
      'outcome': TextEditingController(),
      'strategy': TextEditingController(),
      'measure': TextEditingController(),
    });
    notifyListeners();
  }

  void removeUserOutcome(int index) {
    if (index > 0 && index < _userOutcomes.length) {
      _userOutcomes[index].forEach((_, c) => c.dispose());
      _userOutcomes.removeAt(index);
      notifyListeners();
    }
  }

  void addModelProperty() {
    _modelProperties.add({
      'property': TextEditingController(),
      'strategy': TextEditingController(),
      'measure': TextEditingController(),
    });
    notifyListeners();
  }

  void removeModelProperty(int index) {
    if (index > 0 && index < _modelProperties.length) {
      _modelProperties[index].forEach((_, c) => c.dispose());
      _modelProperties.removeAt(index);
      notifyListeners();
    }
  }

  @override
  bool validate() {
    return _formKey.currentState?.validate() ?? false;
  }

  @override
  Map<String, dynamic> collectData() {
    return {
      'organizational_objectives': _organizationalObjectives
          .map((c) => {
                'objective': c['objective']?.text ?? '',
                'strategy': c['strategy']?.text ?? '',
                'measure': c['measure']?.text ?? '',
              })
          .toList(),
      'leading_indicators': _leadingIndicators
          .map((c) => {
                'feature': c['feature']?.text ?? '',
                'system': c['system']?.text ?? '',
                'competitor': c['competitor']?.text ?? '',
              })
          .toList(),
      'user_outcomes': _userOutcomes
          .map((c) => {
                'outcome': c['outcome']?.text ?? '',
                'strategy': c['strategy']?.text ?? '',
                'measure': c['measure']?.text ?? '',
              })
          .toList(),
      'model_properties': _modelProperties
          .map((c) => {
                'property': c['property']?.text ?? '',
                'strategy': c['strategy']?.text ?? '',
                'measure': c['measure']?.text ?? '',
              })
          .toList(),
    };
  }

  @override
  void reset() {
    _formKey.currentState?.reset();

    for (final c in _organizationalObjectives) c.forEach((_, ctrl) => ctrl.dispose());
    _organizationalObjectives.clear();
    addOrganizationalObjective();

    for (final c in _leadingIndicators) c.forEach((_, ctrl) => ctrl.dispose());
    _leadingIndicators.clear();
    addLeadingIndicator();

    for (final c in _userOutcomes) c.forEach((_, ctrl) => ctrl.dispose());
    _userOutcomes.clear();
    addUserOutcome();

    for (final c in _modelProperties) c.forEach((_, ctrl) => ctrl.dispose());
    _modelProperties.clear();
    addModelProperty();

    notifyListeners();
  }

  @override
  void dispose() {
    for (final c in _organizationalObjectives) c.forEach((_, ctrl) => ctrl.dispose());
    for (final c in _leadingIndicators) c.forEach((_, ctrl) => ctrl.dispose());
    for (final c in _userOutcomes) c.forEach((_, ctrl) => ctrl.dispose());
    for (final c in _modelProperties) c.forEach((_, ctrl) => ctrl.dispose());
    super.dispose();
  }
}

/// ViewModel for Step 2: Intelligence Experience
class IntelligenceExperienceViewModel extends WizardStepViewModel {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  // Penyajian Kecerdasan
  final Set<String> _selectedPresentations = {};
  final TextEditingController _presentationDescController = TextEditingController();

  // Fungsi-fungsi Realisasi Objectives
  final List<Map<String, TextEditingController>> _functions = [];

  // Minimalisasi Kesalahan
  final List<Map<String, TextEditingController>> _errorMinimizations = [];

  // Pengumpulan Data
  final List<Map<String, TextEditingController>> _dataCollections = [];

  IntelligenceExperienceViewModel() : super(stepIndex: 2) {
    addFunction();
    addErrorMinimization();
    addDataCollection();
  }

  GlobalKey<FormState> get formKey => _formKey;
  Set<String> get selectedPresentations => _selectedPresentations;
  TextEditingController get presentationDescController => _presentationDescController;
  List<Map<String, TextEditingController>> get functions => _functions;
  List<Map<String, TextEditingController>> get errorMinimizations => _errorMinimizations;
  List<Map<String, TextEditingController>> get dataCollections => _dataCollections;

  void togglePresentation(String option) {
    if (_selectedPresentations.contains(option)) {
      _selectedPresentations.remove(option);
    } else {
      _selectedPresentations.add(option);
    }
    notifyListeners();
  }

  void addFunction() {
    final nameCtrl = TextEditingController();
    nameCtrl.addListener(() {
      notifyListeners();
    });
    _functions.add({
      'name': nameCtrl,
      'description': TextEditingController(),
    });
    notifyListeners();
  }

  void removeFunction(int index) {
    if (index > 0 && index < _functions.length) {
      _functions[index].forEach((_, c) => c.dispose());
      _functions.removeAt(index);
      notifyListeners();
    }
  }

  void addErrorMinimization() {
    _errorMinimizations.add({
      'function': TextEditingController(),
      'strategy': TextEditingController(),
    });
    notifyListeners();
  }

  void removeErrorMinimization(int index) {
    if (index > 0 && index < _errorMinimizations.length) {
      _errorMinimizations[index].forEach((_, c) => c.dispose());
      _errorMinimizations.removeAt(index);
      notifyListeners();
    }
  }

  void addDataCollection() {
    _dataCollections.add({
      'function': TextEditingController(),
      'plan': TextEditingController(),
    });
    notifyListeners();
  }

  void removeDataCollection(int index) {
    if (index > 0 && index < _dataCollections.length) {
      _dataCollections[index].forEach((_, c) => c.dispose());
      _dataCollections.removeAt(index);
      notifyListeners();
    }
  }

  @override
  bool validate() {
    return _formKey.currentState?.validate() ?? false;
  }

  @override
  Map<String, dynamic> collectData() {
    return {
      'presentations': _selectedPresentations.toList(),
      'presentation_description': _presentationDescController.text,
      'functions': _functions
          .map((c) => {
                'name': c['name']?.text ?? '',
                'description': c['description']?.text ?? '',
              })
          .toList(),
      'error_minimizations': _errorMinimizations
          .map((c) => {
                'function': c['function']?.text ?? '',
                'strategy': c['strategy']?.text ?? '',
              })
          .toList(),
      'data_collections': _dataCollections
          .map((c) => {
                'function': c['function']?.text ?? '',
                'plan': c['plan']?.text ?? '',
              })
          .toList(),
    };
  }

  @override
  void reset() {
    _formKey.currentState?.reset();
    _selectedPresentations.clear();
    _presentationDescController.clear();

    for (final c in _functions) c.forEach((_, ctrl) => ctrl.dispose());
    _functions.clear();
    addFunction();

    for (final c in _errorMinimizations) c.forEach((_, ctrl) => ctrl.dispose());
    _errorMinimizations.clear();
    addErrorMinimization();

    for (final c in _dataCollections) c.forEach((_, ctrl) => ctrl.dispose());
    _dataCollections.clear();
    addDataCollection();

    notifyListeners();
  }

  @override
  void dispose() {
    _presentationDescController.dispose();
    for (final c in _functions) c.forEach((_, ctrl) => ctrl.dispose());
    for (final c in _errorMinimizations) c.forEach((_, ctrl) => ctrl.dispose());
    for (final c in _dataCollections) c.forEach((_, ctrl) => ctrl.dispose());
    super.dispose();
  }
}

/// ViewModel for Step 3: Intelligence Implementation
class IntelligenceImplementationViewModel extends WizardStepViewModel {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  // Proses Bisnis Sistem Cerdas
  final List<Map<String, TextEditingController>> _businessProcesses = [];

  // Teknologi per Proses
  final List<Map<String, TextEditingController>> _technologies = [];

  // Identifikasi Proses Cerdas
  final List<Map<String, dynamic>> _smartProcesses = [];

  IntelligenceImplementationViewModel() : super(stepIndex: 3) {
    addBusinessProcess();
  }

  GlobalKey<FormState> get formKey => _formKey;
  List<Map<String, TextEditingController>> get businessProcesses => _businessProcesses;
  List<Map<String, TextEditingController>> get technologies => _technologies;
  List<Map<String, dynamic>> get smartProcesses => _smartProcesses;

  void addBusinessProcess() {
    _businessProcesses.add({
      'name': TextEditingController(),
      'description': TextEditingController(),
    });
    
    // Automatically add to technologies and smart processes to keep them in sync
    _technologies.add({
      'process': TextEditingController(),
      'technology': TextEditingController(),
    });
    
    _smartProcesses.add({
      'process': '',
      'is_smart': false,
      'reason': TextEditingController(),
      'file': null,
    });
    
    notifyListeners();
  }

  void removeBusinessProcess(int index) {
    if (index >= 0 && index < _businessProcesses.length) {
      _businessProcesses[index].forEach((_, c) => c.dispose());
      _businessProcesses.removeAt(index);
      
      if (index < _technologies.length) {
        _technologies[index].forEach((_, c) => c.dispose());
        _technologies.removeAt(index);
      }
      
      if (index < _smartProcesses.length) {
        (_smartProcesses[index]['reason'] as TextEditingController).dispose();
        _smartProcesses.removeAt(index);
      }
      
      notifyListeners();
    }
  }

  void syncProcessNames() {
    for (int i = 0; i < _businessProcesses.length; i++) {
      final name = _businessProcesses[i]['name']?.text ?? '';
      if (i < _technologies.length) {
        _technologies[i]['process']?.text = name;
      }
      if (i < _smartProcesses.length) {
        _smartProcesses[i]['process'] = name;
      }
    }
    notifyListeners();
  }

  void toggleSmartProcess(int index, bool value) {
    if (index >= 0 && index < _smartProcesses.length) {
      _smartProcesses[index]['is_smart'] = value;
      notifyListeners();
    }
  }

  @override
  bool validate() {
    return _formKey.currentState?.validate() ?? false;
  }

  @override
  Map<String, dynamic> collectData() {
    syncProcessNames();
    return {
      'business_processes': _businessProcesses
          .map((c) => {
                'name': c['name']?.text ?? '',
                'description': c['description']?.text ?? '',
              })
          .toList(),
      'technologies': _technologies
          .map((c) => {
                'process': c['process']?.text ?? '',
                'technology': c['technology']?.text ?? '',
              })
          .toList(),
      'smart_processes': _smartProcesses
          .map((c) => {
                'process': c['process'] ?? '',
                'is_smart': c['is_smart'] ?? false,
                'reason': (c['reason'] as TextEditingController).text,
              })
          .toList(),
    };
  }

  @override
  void reset() {
    _formKey.currentState?.reset();

    for (final c in _businessProcesses) c.forEach((_, ctrl) => ctrl.dispose());
    _businessProcesses.clear();

    for (final c in _technologies) c.forEach((_, ctrl) => ctrl.dispose());
    _technologies.clear();

    for (final c in _smartProcesses) {
      (c['reason'] as TextEditingController).dispose();
    }
    _smartProcesses.clear();

    addBusinessProcess();
    notifyListeners();
  }

  @override
  void dispose() {
    for (final c in _businessProcesses) c.forEach((_, ctrl) => ctrl.dispose());
    for (final c in _technologies) c.forEach((_, ctrl) => ctrl.dispose());
    for (final c in _smartProcesses) {
      (c['reason'] as TextEditingController).dispose();
    }
    super.dispose();
  }
}

/// ViewModel for Step 4: Creation Status
class ConstraintsStatusViewModel extends WizardStepViewModel {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  // Batasan Pengembangan
  final List<Map<String, TextEditingController>> _constraints = [];

  // Status Realisasi Modul Cerdas
  final List<Map<String, dynamic>> _moduleStatuses = [];

  // Progress Keseluruhan
  double _completionPercentage = 0;

  ConstraintsStatusViewModel() : super(stepIndex: 4) {
    addConstraint();
    addModuleStatus();
  }

  GlobalKey<FormState> get formKey => _formKey;
  List<Map<String, TextEditingController>> get constraints => _constraints;
  List<Map<String, dynamic>> get moduleStatuses => _moduleStatuses;
  double get completionPercentage => _completionPercentage;

  void addConstraint() {
    _constraints.add({
      'category': TextEditingController(),
      'description': TextEditingController(),
    });
    notifyListeners();
  }

  void removeConstraint(int index) {
    if (index >= 0 && index < _constraints.length) {
      _constraints[index].forEach((_, c) => c.dispose());
      _constraints.removeAt(index);
      notifyListeners();
    }
  }

  void addModuleStatus() {
    _moduleStatuses.add({
      'module': TextEditingController(),
      'status': 'not_started',
      'notes': TextEditingController(),
    });
    notifyListeners();
  }

  void removeModuleStatus(int index) {
    if (index >= 0 && index < _moduleStatuses.length) {
      (_moduleStatuses[index]['module'] as TextEditingController).dispose();
      (_moduleStatuses[index]['notes'] as TextEditingController).dispose();
      _moduleStatuses.removeAt(index);
      notifyListeners();
    }
  }

  void setModuleStatus(int index, String status) {
    if (index >= 0 && index < _moduleStatuses.length) {
      _moduleStatuses[index]['status'] = status;
      calculateCompletionPercentage();
      notifyListeners();
    }
  }

  void calculateCompletionPercentage() {
    if (_moduleStatuses.isEmpty) {
      _completionPercentage = 0;
      return;
    }
    int doneCount = _moduleStatuses.where((m) => m['status'] == 'done').length;
    _completionPercentage = (doneCount / _moduleStatuses.length) * 100;
  }

  @override
  bool validate() {
    return _formKey.currentState?.validate() ?? false;
  }

  @override
  Map<String, dynamic> collectData() {
    calculateCompletionPercentage();
    return {
      'constraints': _constraints
          .map((c) => {
                'category': c['category']?.text ?? '',
                'description': c['description']?.text ?? '',
              })
          .toList(),
      'module_statuses': _moduleStatuses
          .map((c) => {
                'module': (c['module'] as TextEditingController).text,
                'status': c['status'] ?? 'not_started',
                'notes': (c['notes'] as TextEditingController).text,
              })
          .toList(),
      'completion_percentage': _completionPercentage,
    };
  }

  @override
  void reset() {
    _formKey.currentState?.reset();
    _completionPercentage = 0;

    for (final c in _constraints) c.forEach((_, ctrl) => ctrl.dispose());
    _constraints.clear();
    addConstraint();

    for (final c in _moduleStatuses) {
      (c['module'] as TextEditingController).dispose();
      (c['notes'] as TextEditingController).dispose();
    }
    _moduleStatuses.clear();
    addModuleStatus();

    notifyListeners();
  }

  @override
  void dispose() {
    for (final c in _constraints) c.forEach((_, ctrl) => ctrl.dispose());
    for (final c in _moduleStatuses) {
      (c['module'] as TextEditingController).dispose();
      (c['notes'] as TextEditingController).dispose();
    }
    super.dispose();
  }
}

/// ViewModel for Step 5: Orchestration
class ImplementationPlanningViewModel extends WizardStepViewModel {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  // Timeline Orchestration
  final List<Map<String, dynamic>> _timelines = [];

  // Pelaksana Operasi
  final List<Map<String, TextEditingController>> _operators = [];

  ImplementationPlanningViewModel() : super(stepIndex: 5) {
    addTimeline();
    addOperator();
  }

  GlobalKey<FormState> get formKey => _formKey;
  List<Map<String, dynamic>> get timelines => _timelines;
  List<Map<String, TextEditingController>> get operators => _operators;

  void addTimeline() {
    _timelines.add({
      'category': 'deployment',
      'phase_name': TextEditingController(),
      'start_date': null,
      'end_date': null,
      'pic': TextEditingController(),
      'status': 'backlog',
    });
    notifyListeners();
  }

  void removeTimeline(int index) {
    if (index >= 0 && index < _timelines.length) {
      (_timelines[index]['phase_name'] as TextEditingController).dispose();
      (_timelines[index]['pic'] as TextEditingController).dispose();
      _timelines.removeAt(index);
      notifyListeners();
    }
  }

  void setTimelineStartDate(int index, DateTime? date) {
    if (index >= 0 && index < _timelines.length) {
      _timelines[index]['start_date'] = date;
      notifyListeners();
    }
  }

  void setTimelineEndDate(int index, DateTime? date) {
    if (index >= 0 && index < _timelines.length) {
      _timelines[index]['end_date'] = date;
      notifyListeners();
    }
  }

  void setTimelineCategory(int index, String category) {
    if (index >= 0 && index < _timelines.length) {
      _timelines[index]['category'] = category;
      notifyListeners();
    }
  }

  void setTimelineStatus(int index, String status) {
    if (index >= 0 && index < _timelines.length) {
      _timelines[index]['status'] = status;
      notifyListeners();
    }
  }

  void addOperator() {
    _operators.add({
      'name': TextEditingController(),
      'role': TextEditingController(),
      'contact': TextEditingController(),
    });
    notifyListeners();
  }

  void removeOperator(int index) {
    if (index >= 0 && index < _operators.length) {
      _operators[index].forEach((_, c) => c.dispose());
      _operators.removeAt(index);
      notifyListeners();
    }
  }

  @override
  bool validate() {
    return _formKey.currentState?.validate() ?? false;
  }

  @override
  Map<String, dynamic> collectData() {
    return {
      'timelines': _timelines
          .map((c) => {
                'category': c['category'] ?? 'deployment',
                'phase_name': (c['phase_name'] as TextEditingController).text,
                'start_date': (c['start_date'] as DateTime?)?.toIso8601String(),
                'end_date': (c['end_date'] as DateTime?)?.toIso8601String(),
                'pic': (c['pic'] as TextEditingController).text,
                'status': c['status'] ?? 'backlog',
              })
          .toList(),
      'operators': _operators
          .map((c) => {
                'name': c['name']?.text ?? '',
                'role': c['role']?.text ?? '',
                'contact': c['contact']?.text ?? '',
              })
          .toList(),
    };
  }

  @override
  void reset() {
    _formKey.currentState?.reset();

    for (final c in _timelines) {
      (c['phase_name'] as TextEditingController).dispose();
      (c['pic'] as TextEditingController).dispose();
    }
    _timelines.clear();
    addTimeline();

    for (final c in _operators) {
      c.forEach((_, ctrl) => ctrl.dispose());
    }
    _operators.clear();
    addOperator();

    notifyListeners();
  }

  @override
  void dispose() {
    for (final c in _timelines) {
      (c['phase_name'] as TextEditingController).dispose();
      (c['pic'] as TextEditingController).dispose();
    }
    for (final c in _operators) {
      c.forEach((_, ctrl) => ctrl.dispose());
    }
    super.dispose();
  }
}
