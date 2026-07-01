import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/project_model.dart';

class ApiService {
  // Gunakan 192.168.1.6 untuk aplikasi Windows/Desktop. 
  // Jika di Android emulator, gunakan 192.168.1.6.
  static const String baseUrl = 'http://38.47.94.194/tif2/engineering/api';

  Future<List<ProjectInitiation>> getProjects() async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/projects/list/'));

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.map((json) => _mapDjangoProjectToInitiation(json)).toList();
      } else {
        throw Exception('Failed to load projects from server: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching projects: $e');
      // Kembalikan empty list jika server mati atau ada error
      return [];
    }
  }

  /// Memetakan JSON response Django ke model ProjectInitiation lokal.
  ProjectInitiation _mapDjangoProjectToInitiation(Map<String, dynamic> jsonResponse) {
    // Kita gunakan tipe default atau yang mendekati karena belum ada mapping langsung
    // Untuk saat ini gunakan tipe pertama saja sebagai mockup visual.
    final defaultType = availableProjects.first;

    Map<String, dynamic> parsedDraft = {};
    if (jsonResponse['json_draft'] != null && jsonResponse['json_draft'].toString().isNotEmpty) {
      try {
        parsedDraft = json.decode(jsonResponse['json_draft']);
      } catch (e) {
        print('Error parsing json_draft: $e');
      }
    }

    Map<String, dynamic> mappedDraft = {};
    if (parsedDraft.isNotEmpty) {
      // Map Django structure to Flutter Wizard structure
      
      // Step 1: Meaningful Objectives
      if (parsedDraft['objectives'] != null) {
        final obj = parsedDraft['objectives'] as Map<String, dynamic>;
        mappedDraft['step_1'] = {
          'organizational_objectives': obj['organizational']?.map((e) => {
            'objective': e['goal'] ?? '',
            'strategy': e['strategy'] ?? '',
            'measure': e['metrics'] ?? '',
          }).toList(),
          'leading_indicators': obj['leading_indicators']?['data']?.map((e) => {
            'feature': e['feature'] ?? '',
            'system': (e['values'] as List?)?.isNotEmpty == true ? e['values'][0] : '',
            'competitor': (e['values'] as List?) != null && (e['values'] as List).length >= 2 ? e['values'][1] : '',
          }).toList(),
          'user_outcomes': obj['user_outcomes']?.map((e) => {
            'outcome': e['outcome'] ?? '',
            'strategy': e['strategy'] ?? '',
            'measure': e['metrics'] ?? '',
          }).toList(),
          'model_properties': obj['model_properties']?.map((e) => {
            'property': e['property'] ?? '',
            'strategy': e['strategy'] ?? '',
            'measure': e['metrics'] ?? '',
          }).toList(),
        };
      }

      // Step 2: Intelligence Experience
      if (parsedDraft['experiences'] != null) {
        final exp = parsedDraft['experiences'] as Map<String, dynamic>;
        mappedDraft['step_2'] = {
          'presentations': exp['presentation']?['types']?.map((e) => e['label']?.toString().toLowerCase()).toList(),
          'presentation_description': exp['presentation']?['description'],
          'functions': exp['functions'],
          'error_minimizations': exp['error_minimization'],
          'data_collections': exp['data_collection'],
        };
      }

      // Step 3: Intelligence Implementation
      if (parsedDraft['implementation'] != null) {
        final impl = parsedDraft['implementation'] as Map<String, dynamic>;
        mappedDraft['step_3'] = {
          'business_processes': impl['business_processes'],
          'technologies': impl['technologies'],
          'smart_processes': impl['smart_processes']?.map((e) => {
            'process': e['process'],
            'is_smart': true,
            'reason': e['reason'],
          }).toList(),
        };
      }

      // Step 4: Creation Status
      if (parsedDraft['creation'] != null) {
        final cre = parsedDraft['creation'] as Map<String, dynamic>;
        mappedDraft['step_4'] = {
          'constraints': cre['constraints'],
          'module_statuses': (cre['module_statuses'] as List?)?.map((e) {
            String status = e['status']?.toString().toLowerCase() ?? 'not_started';
            if (status == 'todo') status = 'not_started';
            if (status == 'doing') status = 'in_progress';
            // done remains done
            return {
              'module': e['module'],
              'status': status,
              'notes': e['notes'],
            };
          }).toList(),
        };
      }

      // Step 5: Orchestration
      if (parsedDraft['orchestration'] != null) {
        final orch = parsedDraft['orchestration'] as Map<String, dynamic>;
        mappedDraft['step_5'] = {
          'timelines': (orch['timeline'] as List?)?.map((e) {
            String status = e['status']?.toString().toLowerCase() ?? 'backlog';
            if (status == 'todo') status = 'backlog';
            if (status == 'doing' || status == 'in_progress') status = 'ongoing';
            if (status == 'done') status = 'completed';
            return {
              'category': e['category'],
              'phase_name': e['phase'],
              'start_date': e['start_date'],
              'end_date': e['end_date'],
              'pic': e['pic'],
              'status': status,
            };
          }).toList(),
          'operators': orch['operators'],
        };
      }
    }

    return ProjectInitiation(
      id: jsonResponse['id'].toString(),
      projectType: defaultType,
      createdAt: jsonResponse['created_at'] != null ? DateTime.parse(jsonResponse['created_at']) : DateTime.now(),
      formData: {
        'pm_project_id': (jsonResponse['pm_project_id'] != null && jsonResponse['pm_project_id'].toString().isNotEmpty)
            ? jsonResponse['pm_project_id'].toString()
            : jsonResponse['id'].toString(),
        'name': jsonResponse['name'] ?? 'Untitled Project',
        'description': jsonResponse['description'] ?? '',
        'status': jsonResponse['status'] ?? 'New',
        'progress': jsonResponse['progress'] ?? 0,
        'start_date': jsonResponse['start_date'],
        'end_date': jsonResponse['end_date'],
        ...mappedDraft, // Gunakan mappedDraft yang sudah disesuaikan
      },
    );
  }

  Future<Map<String, dynamic>> login(String username, String password) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/auth/login/'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'username': username, 'password': password}),
      );
      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        final Map<String, dynamic> errorData = json.decode(response.body);
        return {'success': false, 'message': errorData['message'] ?? 'Login gagal'};
      }
    } catch (e) {
      return {'success': false, 'message': 'Koneksi gagal: $e'};
    }
  }

  Future<Map<String, dynamic>> register(String username, String email, String password) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/auth/register/'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'username': username, 'email': email, 'password': password}),
      );
      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        final Map<String, dynamic> errorData = json.decode(response.body);
        return {'success': false, 'message': errorData['message'] ?? 'Registrasi gagal'};
      }
    } catch (e) {
      return {'success': false, 'message': 'Koneksi gagal: $e'};
    }
  }

  Map<String, dynamic> _mapFlutterDraftToDjango(Map<String, dynamic> formData) {
    return {
      'objectives': {
        'organizational': (formData['step_1']?['organizational_objectives'] as List?)?.map((e) => {
          'goal': e['objective'],
          'strategy': e['strategy'],
          'metrics': e['measure'],
        }).toList() ?? [],
        'leading_indicators': {
          'data': (formData['step_1']?['leading_indicators'] as List?)?.map((e) => {
            'feature': e['feature'],
            'values': [e['system'] ?? '', e['competitor'] ?? ''],
          }).toList() ?? [],
        },
        'user_outcomes': (formData['step_1']?['user_outcomes'] as List?)?.map((e) => {
          'outcome': e['outcome'],
          'strategy': e['strategy'],
          'metrics': e['measure'],
        }).toList() ?? [],
        'model_properties': (formData['step_1']?['model_properties'] as List?)?.map((e) => {
          'property': e['property'],
          'strategy': e['strategy'],
          'metrics': e['measure'],
        }).toList() ?? [],
      },
      'experiences': {
        'presentation': {
          'types': (formData['step_2']?['presentations'] as List?)?.map((e) {
            final str = e.toString();
            final capitalized = str.isEmpty ? '' : '${str[0].toUpperCase()}${str.substring(1)}';
            return {'label': capitalized};
          }).toList() ?? [],
          'description': formData['step_2']?['presentation_description'] ?? '',
        },
        'functions': formData['step_2']?['functions'] ?? [],
        'error_minimization': formData['step_2']?['error_minimizations'] ?? [],
        'data_collection': formData['step_2']?['data_collections'] ?? [],
      },
      'implementation': {
        'business_processes': formData['step_3']?['business_processes'] ?? [],
        'technologies': formData['step_3']?['technologies'] ?? [],
        'smart_processes': formData['step_3']?['smart_processes'] ?? [],
      },
      'creation': {
        'constraints': formData['step_4']?['constraints'] ?? [],
        'module_statuses': (formData['step_4']?['module_statuses'] as List?)?.map((e) => {
          'module': e['module'],
          'status': e['status'],
          'notes': e['notes'],
        }).toList() ?? [],
      },
      'orchestration': {
        'timeline': (formData['step_5']?['timelines'] as List?)?.map((e) => {
          'category': e['category'],
          'phase': e['phase_name'],
          'start_date': e['start_date'],
          'end_date': e['end_date'],
          'pic': e['pic'],
          'status': e['status'],
        }).toList() ?? [],
        'operators': formData['step_5']?['operators'] ?? [],
      }
    };
  }

  Future<Map<String, dynamic>> createProjectToAPI(Map<String, dynamic> projectData) async {
    try {
      final payload = {
        'pm_project_id': projectData['pm_project_id'] ?? projectData['project_type'] ?? 'custom-${DateTime.now().millisecondsSinceEpoch}',
        'nama_proyek': projectData['name'],
        'deskripsi': projectData['description'],
        'pelaksana': projectData['division'],
        'pengawas': projectData['supervisor'],
        'json_draft': _mapFlutterDraftToDjango(projectData),
      };
      
      if (projectData['start_date'] != null) {
        payload['tanggal_mulai'] = (projectData['start_date'] as String).split('T')[0];
      }
      if (projectData['end_date'] != null) {
        payload['tanggal_selesai'] = (projectData['end_date'] as String).split('T')[0];
      }

      final response = await http.post(
        Uri.parse('$baseUrl/projects/mobile_save/'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(payload),
      );

      if (response.statusCode == 200) {
        return {'success': true, 'data': json.decode(response.body)};
      } else {
        return {'success': false, 'message': 'Gagal menyimpan proyek ke API: ${response.statusCode}'};
      }
    } catch (e) {
      return {'success': false, 'message': 'Koneksi API gagal: $e'};
    }
  }
}
