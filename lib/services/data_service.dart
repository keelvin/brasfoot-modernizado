import 'dart:convert';
import 'package:flutter/services.dart';
import '../constants/app_constants.dart';
import '../models/championship.dart';

/// Serviço responsável pelo carregamento e gerenciamento de dados
class DataService {
  static DataService? _instance;
  static DataService get instance => _instance ??= DataService._();
  
  DataService._();
  
  List<Championship>? _cachedChampionships;
  
  /// Carrega os campeonatos do arquivo JSON
  Future<List<Championship>> loadChampionships() async {
    if (_cachedChampionships != null) {
      return _cachedChampionships!;
    }
    
    try {
      final String jsonString = await rootBundle.loadString(
        AppConstants.championshipDataPath,
      );
      
      final Map<String, dynamic> jsonData = json.decode(jsonString);
      final List<dynamic> championshipsJson = jsonData['championships'] ?? [];
      
      _cachedChampionships = championshipsJson
          .map((json) => Championship.fromJson(json))
          .toList();
      
      return _cachedChampionships!;
    } catch (error) {
      throw DataServiceException('Erro ao carregar campeonatos: $error');
    }
  }
  
  /// Busca um campeonato por tipo
  Future<Championship?> getChampionshipByType(ChampionshipType type) async {
    final championships = await loadChampionships();
    try {
      return championships.firstWhere((c) => c.type == type);
    } catch (e) {
      return null;
    }
  }
  
  /// Busca campeonatos por nível (Série A, B, C)
  Future<List<Championship>> getChampionshipsByLevel(String level) async {
    final championships = await loadChampionships();
    return championships.where((c) => c.name.contains(level)).toList();
  }
  
  /// Valida a integridade dos dados carregados
  bool validateChampionshipData(Championship championship) {
    if (championship.teams.isEmpty) return false;
    if (championship.name.isEmpty) return false;
    
    // Valida cada time
    for (final team in championship.teams) {
      if (team.name.isEmpty) return false;
      if (team.overallRating < 1 || team.overallRating > 100) return false;
      if (team.attack < 1 || team.attack > 100) return false;
      if (team.defense < 1 || team.defense > 100) return false;
      if (team.midfield < 1 || team.midfield > 100) return false;
    }
    
    return true;
  }
  
  /// Limpa o cache de dados
  void clearCache() {
    _cachedChampionships = null;
  }
  
  /// Recarrega os dados forçadamente
  Future<List<Championship>> reloadChampionships() async {
    clearCache();
    return loadChampionships();
  }
  
  /// Obtém estatísticas gerais dos dados
  Future<DataStatistics> getDataStatistics() async {
    final championships = await loadChampionships();
    
    int totalTeams = 0;
    int totalMatches = 0;
    double averageRating = 0;
    
    for (final championship in championships) {
      totalTeams += championship.teams.length;
      totalMatches += championship.totalMatches;
      
      double championshipAverage = championship.teams
          .map((t) => t.overallRating)
          .reduce((a, b) => a + b) / championship.teams.length;
      averageRating += championshipAverage;
    }
    
    averageRating /= championships.length;
    
    return DataStatistics(
      totalChampionships: championships.length,
      totalTeams: totalTeams,
      totalMatches: totalMatches,
      averageTeamRating: averageRating,
    );
  }
}

/// Exceção personalizada para erros do serviço de dados
class DataServiceException implements Exception {
  final String message;
  const DataServiceException(this.message);
  
  @override
  String toString() => 'DataServiceException: $message';
}

/// Estatísticas dos dados carregados
class DataStatistics {
  final int totalChampionships;
  final int totalTeams;
  final int totalMatches;
  final double averageTeamRating;
  
  const DataStatistics({
    required this.totalChampionships,
    required this.totalTeams,
    required this.totalMatches,
    required this.averageTeamRating,
  });
  
  @override
  String toString() {
    return 'DataStatistics('
        'championships: $totalChampionships, '
        'teams: $totalTeams, '
        'matches: $totalMatches, '
        'avgRating: ${averageTeamRating.toStringAsFixed(1)}'
        ')';
  }
}
