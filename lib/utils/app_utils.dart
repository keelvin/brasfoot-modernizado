import 'package:flutter/material.dart';
import '../constants/app_constants.dart';
import '../models/team.dart';

/// Utilitários gerais da aplicação
class AppUtils {
  
  /// Formata números grandes com separadores de milhares
  static String formatNumber(int number) {
    return number.toString().replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (Match match) => '${match[1]}.',
    );
  }
  
  /// Calcula a porcentagem de um valor
  static String formatPercentage(double value, {int decimals = 0}) {
    return '${(value * 100).toStringAsFixed(decimals)}%';
  }
  
  /// Formata o saldo de gols com sinal
  static String formatGoalDifference(int difference) {
    if (difference > 0) return '+$difference';
    return difference.toString();
  }
  
  /// Retorna a cor baseada na posição na tabela
  static Color getPositionColor(int position, int totalTeams) {
    if (position <= 2) return const Color(0xFF4CAF50); // Verde - Classificação
    if (position <= 4) return const Color(0xFF2196F3); // Azul - Copa
    if (position >= totalTeams - 1) return const Color(0xFFF44336); // Vermelho - Rebaixamento
    return Colors.grey; // Neutro
  }
  
  /// Retorna a cor baseada na forma do time
  static Color getFormColor(TeamForm form) {
    switch (form) {
      case TeamForm.terrible:
        return Colors.red[800]!;
      case TeamForm.poor:
        return Colors.orange[800]!;
      case TeamForm.average:
        return Colors.grey[600]!;
      case TeamForm.good:
        return Colors.lightGreen[700]!;
      case TeamForm.excellent:
        return Colors.green[700]!;
    }
  }
  
  /// Retorna a cor baseada no rating do time
  static Color getRatingColor(int rating) {
    if (rating >= 80) return Colors.green[600]!;
    if (rating >= 70) return Colors.lightGreen[600]!;
    if (rating >= 60) return Colors.yellow[600]!;
    if (rating >= 50) return Colors.orange[600]!;
    return Colors.red[600]!;
  }
  
  /// Mapeia cores do time para cores do Flutter
  static Color getTeamPrimaryColor(List<String> teamColors) {
    if (teamColors.isEmpty) return const Color(AppConstants.primaryGreen);
    
    String primaryColor = teamColors.first.toLowerCase();
    
    switch (primaryColor) {
      case 'azul':
        return Colors.blue[700]!;
      case 'verde':
        return Colors.green[700]!;
      case 'vermelho':
        return Colors.red[700]!;
      case 'amarelo':
        return Colors.yellow[700]!;
      case 'preto':
        return Colors.grey[800]!;
      case 'branco':
        return Colors.grey[300]!;
      default:
        return const Color(AppConstants.primaryGreen);
    }
  }
  
  /// Calcula a duração estimada do campeonato
  static String getChampionshipDuration(int totalMatches, int teamsCount) {
    int estimatedWeeks = (totalMatches / (teamsCount ~/ 2)).ceil();
    if (estimatedWeeks <= 4) return '$estimatedWeeks semanas';
    int months = (estimatedWeeks / 4).ceil();
    return '$months ${months == 1 ? 'mês' : 'meses'}';
  }
  
  /// Valida se um time é válido
  static bool isValidTeam(Team? team) {
    return team != null && 
           team.name.isNotEmpty && 
           team.overallRating > 0 && 
           team.overallRating <= 100;
  }
  
  /// Gera uma cor aleatória para times sem cor definida
  static Color generateTeamColor(String teamName) {
    final colors = [
      Colors.blue[700]!,
      Colors.green[700]!,
      Colors.red[700]!,
      Colors.orange[700]!,
      Colors.purple[700]!,
      Colors.teal[700]!,
    ];
    
    int index = teamName.hashCode % colors.length;
    return colors[index.abs()];
  }
  
  /// Formata tempo de jogo (minutos)
  static String formatMatchTime(int minutes) {
    if (minutes <= 45) return "${minutes}'";
    if (minutes <= 90) return "${minutes}'";
    return "${minutes}' (+${minutes - 90})";
  }
  
  /// Calcula a intensidade de um confronto
  static double calculateMatchIntensity(Team homeTeam, Team awayTeam) {
    double intensity = 1.0;
    
    // Rivalidade (mesma cidade)
    if (homeTeam.city == awayTeam.city) {
      intensity *= AppConstants.rivalryIntensityBonus;
    }
    
    // Diferença de força (jogos mais equilibrados são mais intensos)
    double strengthDifference = (homeTeam.overallRating - awayTeam.overallRating).abs();
    if (strengthDifference < 10) {
      intensity *= 1.1; // Jogos equilibrados são mais intensos
    }
    
    return intensity;
  }
}

/// Extensões úteis para widgets
extension WidgetExtensions on Widget {
  /// Adiciona padding padrão
  Widget withDefaultPadding() {
    return Padding(
      padding: const EdgeInsets.all(AppConstants.defaultPadding),
      child: this,
    );
  }
  
  /// Adiciona margem
  Widget withMargin(EdgeInsets margin) {
    return Container(
      margin: margin,
      child: this,
    );
  }
}

/// Extensões para strings
extension StringExtensions on String {
  /// Capitaliza a primeira letra
  String capitalize() {
    if (isEmpty) return this;
    return '${this[0].toUpperCase()}${substring(1).toLowerCase()}';
  }
  
  /// Trunca string com reticências
  String truncate(int maxLength) {
    if (length <= maxLength) return this;
    return '${substring(0, maxLength)}...';
  }
}

/// Extensões para números
extension IntExtensions on int {
  /// Converte rating em estrelas (1-5)
  int get stars {
    if (this >= 90) return 5;
    if (this >= 80) return 4;
    if (this >= 70) return 3;
    if (this >= 60) return 2;
    return 1;
  }
  
  /// Converte para ordinal (1º, 2º, 3º...)
  String get ordinal {
    if (this == 1) return '1º';
    if (this == 2) return '2º';
    if (this == 3) return '3º';
    return '${this}º';
  }
}
