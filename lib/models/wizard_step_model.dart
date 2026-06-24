import 'package:flutter/material.dart';

/// Represents a single step in the wizard
class WizardStepInfo {
  final int stepIndex;
  final String title;
  final String subtitle;
  final IconData icon;
  final Color accent;

  const WizardStepInfo({
    required this.stepIndex,
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.accent,
  });
}

/// All wizard steps definition
const List<WizardStepInfo> wizardSteps = <WizardStepInfo>[
  WizardStepInfo(
    stepIndex: 0,
    title: 'Pilih Proyek',
    subtitle: 'Pilih proyek yang akan diinisiasi',
    icon: Icons.folder_open_rounded,
    accent: Color(0xFF2563EB),
  ),
  WizardStepInfo(
    stepIndex: 1,
    title: 'Meaningful Objectives',
    subtitle: 'Tetapkan sasaran utama sistem cerdas',
    icon: Icons.track_changes_rounded,
    accent: Color(0xFF2563EB),
  ),
  WizardStepInfo(
    stepIndex: 2,
    title: 'Intelligence Experience',
    subtitle: 'Rancang pengalaman kecerdasan',
    icon: Icons.auto_awesome_rounded,
    accent: Color(0xFF2563EB),
  ),
  WizardStepInfo(
    stepIndex: 3,
    title: 'Intelligence Implementation',
    subtitle: 'Susun proses bisnis dan teknologi',
    icon: Icons.settings_suggest_rounded,
    accent: Color(0xFF2563EB),
  ),
  WizardStepInfo(
    stepIndex: 4,
    title: 'Creation Status',
    subtitle: 'Batasan Pengembangan & Status',
    icon: Icons.rule_folder_outlined,
    accent: Color(0xFF2563EB),
  ),
  WizardStepInfo(
    stepIndex: 5,
    title: 'Orchestration',
    subtitle: 'Timeline & Pelaksana Operasi',
    icon: Icons.rocket_launch_outlined,
    accent: Color(0xFF2563EB),
  ),
];
