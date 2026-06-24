import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../models/project_model.dart';

class ProjectApiService {
  static const String _baseUrl = 'https://api.github.com/search/repositories';

  /// Fetches project management related repositories from GitHub
  Future<List<ProjectType>> fetchExternalProjects() async {
    try {
      // Searching for "project management" themed flutter repositories
      final response = await http.get(
        Uri.parse('$_baseUrl?q=project-management+language:dart&sort=stars&order=desc&per_page=10'),
        headers: {
          'Accept': 'application/json',
          'User-Agent': 'Flutter-Project-Wizard',
        },
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        final List<dynamic> items = data['items'];

        // Map GitHub repos to our ProjectType model
        return items.asMap().entries.map((entry) {
          final index = entry.key;
          final item = entry.value;
          
          // Define a set of accent colors for variety
          final accents = [
            const Color(0xFF2563EB),
            const Color(0xFFFF4FD8),
            const Color(0xFFFF8A3D),
            const Color(0xFF8E6BFF),
            const Color(0xFF00D2FF),
          ];

          return ProjectType(
            id: 'github-${item['id']}',
            name: item['name'] ?? 'Untitled Project',
            description: item['description'] ?? 'No description available for this GitHub project.',
            icon: Icons.code_rounded,
            accent: accents[index % accents.length],
          );
        }).toList();
      } else {
        throw Exception('Failed to load projects: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('Error fetching projects: $e');
      rethrow;
    }
  }
}
