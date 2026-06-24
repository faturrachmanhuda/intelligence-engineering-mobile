import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/project_model.dart';

/// Service for persistent local storage of project initiations using SQLite.
class ProjectStorageService {
  static Database? _db;
  static final ProjectStorageService _instance = ProjectStorageService._internal();

  factory ProjectStorageService() => _instance;
  ProjectStorageService._internal();

  Future<Database> get database async {
    _db ??= await _initDB();
    return _db!;
  }

  Future<Database> _initDB() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'projects.db');

    return openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE initiations(
            id TEXT PRIMARY KEY,
            projectTypeId TEXT NOT NULL,
            projectName TEXT NOT NULL,
            description TEXT NOT NULL,
            iconCodePoint INTEGER NOT NULL,
            accentValue INTEGER NOT NULL,
            createdAt TEXT NOT NULL,
            formData TEXT NOT NULL
          )
        ''');
      },
    );
  }

  /// Insert a new project initiation.
  Future<void> insertInitiation(ProjectInitiation initiation) async {
    final db = await database;
    await db.insert(
      'initiations',
      _toMap(initiation),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  /// Get all initiations ordered by newest first.
  Future<List<ProjectInitiation>> getAllInitiations() async {
    final db = await database;
    final maps = await db.query(
      'initiations',
      orderBy: 'createdAt DESC',
    );
    return maps.map((m) => _fromMap(m)).toList();
  }

  /// Delete an initiation by id.
  Future<void> deleteInitiation(String id) async {
    final db = await database;
    await db.delete(
      'initiations',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Map<String, dynamic> _toMap(ProjectInitiation initiation) {
    return {
      'id': initiation.id,
      'projectTypeId': initiation.projectType.id,
      'projectName': initiation.projectType.name,
      'description': initiation.projectType.description,
      'iconCodePoint': initiation.projectType.icon.codePoint,
      'accentValue': initiation.projectType.accent.value,
      'createdAt': initiation.createdAt.toIso8601String(),
      'formData': jsonEncode(initiation.formData),
    };
  }

  ProjectInitiation _fromMap(Map<String, dynamic> map) {
    final projectType = ProjectType(
      id: map['projectTypeId'] as String,
      name: map['projectName'] as String,
      description: map['description'] as String,
      icon: IconData(map['iconCodePoint'] as int, fontFamily: 'MaterialIcons'),
      accent: Color(map['accentValue'] as int),
    );

    return ProjectInitiation(
      id: map['id'] as String,
      projectType: projectType,
      createdAt: DateTime.parse(map['createdAt'] as String),
      formData: jsonDecode(map['formData'] as String) as Map<String, dynamic>,
    );
  }
}
