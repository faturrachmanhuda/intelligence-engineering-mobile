import 'package:flutter/material.dart';

import '../models/project_model.dart';
import '../services/project_storage_service.dart';
import '../services/api_service.dart';

/// ViewModel for the Dashboard page.
/// Manages the list of completed project initiations with persistent storage.
class DashboardViewModel extends ChangeNotifier {
  final ProjectStorageService _storage = ProjectStorageService();
  final ApiService _apiService = ApiService();
  
  List<ProjectInitiation> _initiations = <ProjectInitiation>[];
  bool _isLoading = false;

  List<ProjectInitiation> get initiations =>
      List<ProjectInitiation>.unmodifiable(_initiations);

  int get initiationCount => _initiations.length;
  bool get hasInitiations => _initiations.isNotEmpty;
  bool get isLoading => _isLoading;

  /// Load initiations from persistent storage and Django API.
  Future<void> loadInitiations({bool silent = false}) async {
    if (!silent) {
      _isLoading = true;
      notifyListeners();
    }

    // Ambil data lokal
    final localInitiations = await _storage.getAllInitiations();
    
    // Ambil data dari server Django
    final serverInitiations = await _apiService.getProjects();

    // Deduplikasi: server takes priority. Match by pm_project_id.
    final Map<String, ProjectInitiation> mergedMap = {};
    
    // Local projects first (will be overwritten by server if same pm_project_id)
    for (final local in localInitiations) {
      final key = local.formData['pm_project_id']?.toString() ?? local.id;
      mergedMap[key] = local;
    }
    
    // Server projects overwrite local duplicates
    for (final server in serverInitiations) {
      final key = server.formData['pm_project_id']?.toString() ?? server.id;
      mergedMap[key] = server;
    }
    
    _initiations = mergedMap.values.toList();
    // Sort by creation date, newest first
    _initiations.sort((a, b) => b.createdAt.compareTo(a.createdAt));

    if (!silent) {
      _isLoading = false;
    }
    notifyListeners();
  }

  /// Add a new project initiation or update an existing one.
  Future<void> saveInitiation({
    String? id,
    required ProjectType projectType,
    required Map<String, dynamic> formData,
  }) async {
    // Buat copy formData yang aman (tanpa objek class Flutter yang tidak bisa di-serialize)
    final safeFormData = Map<String, dynamic>.from(formData);
    safeFormData.remove('selected_project');
    
    final finalId = safeFormData['pm_project_id'] ?? id ?? 'init-${DateTime.now().millisecondsSinceEpoch}';
    safeFormData['pm_project_id'] = finalId;

    final initiation = ProjectInitiation(
      id: finalId,
      projectType: projectType,
      createdAt: DateTime.now(),
      formData: safeFormData,
    );

    // Save ke SQLite lokal (menggunakan ConflictAlgorithm.replace, aman untuk update)
    await _storage.insertInitiation(initiation);
    
    // Save/Kirim ke Django API
    try {
      final response = await _apiService.createProjectToAPI(safeFormData);
      if (response['success'] != true) {
        debugPrint('Gagal mengirim ke API: ${response['message']}');
      }
    } catch (e) {
      debugPrint('Error mengirim ke API: $e');
    }

    if (id == null) {
      // Check if already exists by pm_project_id (avoid UI duplicate)
      final existingIdx = _initiations.indexWhere((e) => 
        e.formData['pm_project_id'] == finalId || e.id == finalId);
      if (existingIdx != -1) {
        _initiations[existingIdx] = initiation;
      } else {
        _initiations.insert(0, initiation);
      }
    } else {
      final index = _initiations.indexWhere((e) => e.id == id || 
        e.formData['pm_project_id'] == finalId);
      if (index != -1) {
        _initiations[index] = initiation;
      } else {
        _initiations.insert(0, initiation);
      }
    }
    notifyListeners();
  }

  /// Remove an initiation by index and persist the change.
  Future<void> removeInitiation(int index) async {
    if (index >= 0 && index < _initiations.length) {
      final id = _initiations[index].id;
      await _storage.deleteInitiation(id);
      _initiations.removeAt(index);
      notifyListeners();
    }
  }
}
