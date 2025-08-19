/// Constantes da aplicação Brasfoot Modernizado
class AppConstants {
  // Cores do tema
  static const primaryGreen = 0xFF2E7D32;
  static const darkGreen = 0xFF1B5E20;
  static const backgroundDark = 0xFF1A1A1A;
  static const cardDark = 0xFF2D2D2D;
  
  // Configurações de simulação
  static const double homeAdvantageMultiplier = 1.2;
  static const double awayPenaltyMultiplier = 0.9;
  static const double rivalryIntensityBonus = 1.2;
  static const double maxFatigueImpact = 0.3;
  static const double baseGoalChance = 0.15;
  static const double baseChanceChance = 0.3;
  static const double baseCardChance = 0.05;
  
  // Configurações de UI
  static const double defaultPadding = 16.0;
  static const double cardBorderRadius = 12.0;
  static const double buttonBorderRadius = 8.0;
  
  // Textos da aplicação
  static const String appTitle = 'Brasfoot Modernizado';
  static const String appSubtitle = 'Motor de Simulação Realista com GetX - Futebol Catarinense';
  static const String appSlogan = 'Do Contestado ao Litoral, o futebol catarinense em suas mãos!';
  
  // Configurações de dados
  static const String championshipDataPath = 'assets/data/championship_data.json';
  
  // Configurações de animação
  static const Duration defaultAnimationDuration = Duration(milliseconds: 300);
  static const Duration simulationEventDuration = Duration(milliseconds: 1500);
  
  // Limites
  static const int maxEventsPerMatch = 25;
  static const int minEventsPerMatch = 8;
  static const int maxMatchMinutes = 90;
}

/// Enums para melhor tipagem
enum SimulationSpeed {
  slow(2500),
  normal(1500),
  fast(500);
  
  const SimulationSpeed(this.milliseconds);
  final int milliseconds;
}

enum ChampionshipLevel {
  serieA('Série A', 'A elite do futebol catarinense'),
  serieB('Série B', 'Segunda divisão estadual'),
  serieC('Série C', 'Terceira divisão estadual'),
  estadual('Estadual', 'Campeonato estadual unificado'),
  amador('Amador', 'Campeonato amador');

  const ChampionshipLevel(this.displayName, this.description);
  final String displayName;
  final String description;
}
