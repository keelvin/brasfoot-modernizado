import '../constants/app_constants.dart';

/// Representa um time de futebol com todas suas características
class Team {
  // Informações básicas
  final String name;
  final String city;
  final String history;
  final int foundedYear;
  
  // Estatísticas e performance
  final int titles;
  final TeamForm currentForm;
  final double fatigue;
  
  // Ratings técnicos (1-100)
  final int overallRating;
  final int attack;
  final int defense;
  final int midfield;
  
  // Informações do estádio
  final String stadium;
  final int stadiumCapacity;
  final double homeFactor;
  
  // Identidade visual
  final List<String> colors;

  const Team({
    required this.name,
    required this.city,
    required this.history,
    required this.foundedYear,
    required this.titles,
    required this.currentForm,
    required this.fatigue,
    required this.overallRating,
    required this.attack,
    required this.defense,
    required this.midfield,
    required this.stadium,
    required this.stadiumCapacity,
    required this.homeFactor,
    required this.colors,
  });

  /// Cria um time a partir de dados JSON
  factory Team.fromJson(Map<String, dynamic> json) {
    return Team(
      name: _parseString(json['name']),
      city: _parseString(json['city']),
      history: _parseString(json['history']),
      foundedYear: _parseInt(json['foundedYear'], defaultValue: 1900),
      titles: _parseInt(json['titles'], defaultValue: 0),
      currentForm: _parseTeamForm(json['currentForm']),
      fatigue: _parseDouble(json['fatigue'], defaultValue: 0.0, max: 1.0),
      overallRating: _parseRating(json['overallRating']),
      attack: _parseRating(json['attack']),
      defense: _parseRating(json['defense']),
      midfield: _parseRating(json['midfield']),
      stadium: _parseString(json['stadium']),
      stadiumCapacity: _parseInt(json['stadiumCapacity'], defaultValue: 5000),
      homeFactor: _parseDouble(json['homeFactor'], defaultValue: 1.0, min: 0.8, max: 2.0),
      colors: _parseStringList(json['colors']),
    );
  }

  /// Converte o time para JSON
  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'city': city,
      'history': history,
      'foundedYear': foundedYear,
      'titles': titles,
      'currentForm': currentForm.name,
      'fatigue': fatigue,
      'overallRating': overallRating,
      'attack': attack,
      'defense': defense,
      'midfield': midfield,
      'stadium': stadium,
      'stadiumCapacity': stadiumCapacity,
      'homeFactor': homeFactor,
      'colors': colors,
    };
  }

  // Getters calculados para força do time

  /// Força base do time (0.0 - 1.0)
  double get baseStrength => overallRating / 100.0;

  /// Força atual considerando forma e cansaço
  double get currentStrength {
    final formMultiplier = currentForm.multiplier;
    final fatigueMultiplier = 1.0 - (fatigue * AppConstants.maxFatigueImpact);
    
    return baseStrength * formMultiplier * fatigueMultiplier;
  }

  /// Força quando joga em casa
  double get homeStrength => currentStrength * homeFactor;

  /// Força quando joga fora de casa
  double get awayStrength => currentStrength * AppConstants.awayPenaltyMultiplier;

  /// Força ofensiva específica
  double get attackStrength => (attack / 100.0) * currentStrength;

  /// Força defensiva específica
  double get defenseStrength => (defense / 100.0) * currentStrength;

  /// Força do meio-campo
  double get midfieldStrength => (midfield / 100.0) * currentStrength;

  // Getters de informação

  /// Retorna se o time tem boa tradição (mais de 5 títulos)
  bool get hasGoodTradition => titles >= 5;

  /// Retorna se o time está em boa forma
  bool get isInGoodForm => currentForm.index >= TeamForm.good.index;

  /// Retorna se o time está cansado
  bool get isFatigued => fatigue > 0.5;

  /// Retorna se o time tem vantagem significativa em casa
  bool get hasStrongHomeFactor => homeFactor >= 1.2;

  /// Retorna a idade do clube
  int get age => DateTime.now().year - foundedYear;

  /// Retorna se é um clube centenário
  bool get isCentenary => age >= 100;

  // Métodos de comparação

  /// Compara a força com outro time
  int compareStrengthWith(Team other) {
    return currentStrength.compareTo(other.currentStrength);
  }

  /// Verifica se é rival (mesma cidade)
  bool isRivalOf(Team other) {
    return city.toLowerCase() == other.city.toLowerCase() && name != other.name;
  }

  /// Cria uma cópia do time com modificações
  Team copyWith({
    String? name,
    String? city,
    String? history,
    int? foundedYear,
    int? titles,
    TeamForm? currentForm,
    double? fatigue,
    int? overallRating,
    int? attack,
    int? defense,
    int? midfield,
    String? stadium,
    int? stadiumCapacity,
    double? homeFactor,
    List<String>? colors,
  }) {
    return Team(
      name: name ?? this.name,
      city: city ?? this.city,
      history: history ?? this.history,
      foundedYear: foundedYear ?? this.foundedYear,
      titles: titles ?? this.titles,
      currentForm: currentForm ?? this.currentForm,
      fatigue: fatigue ?? this.fatigue,
      overallRating: overallRating ?? this.overallRating,
      attack: attack ?? this.attack,
      defense: defense ?? this.defense,
      midfield: midfield ?? this.midfield,
      stadium: stadium ?? this.stadium,
      stadiumCapacity: stadiumCapacity ?? this.stadiumCapacity,
      homeFactor: homeFactor ?? this.homeFactor,
      colors: colors ?? this.colors,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Team && other.name == name && other.city == city;
  }

  @override
  int get hashCode => name.hashCode ^ city.hashCode;

  @override
  String toString() => 'Team(name: $name, city: $city, rating: $overallRating)';

  // Métodos auxiliares de parsing

  static String _parseString(dynamic value) {
    return value?.toString() ?? '';
  }

  static int _parseInt(dynamic value, {required int defaultValue}) {
    if (value is int) return value;
    if (value is String) return int.tryParse(value) ?? defaultValue;
    return defaultValue;
  }

  static double _parseDouble(dynamic value, {
    required double defaultValue,
    double? min,
    double? max,
  }) {
    double result = defaultValue;
    
    if (value is double) {
      result = value;
    } else if (value is int) {
      result = value.toDouble();
    } else if (value is String) {
      result = double.tryParse(value) ?? defaultValue;
    }
    
    if (min != null && result < min) result = min;
    if (max != null && result > max) result = max;
    
    return result;
  }

  static int _parseRating(dynamic value) {
    final rating = _parseInt(value, defaultValue: 50);
    return rating.clamp(1, 100);
  }

  static TeamForm _parseTeamForm(dynamic value) {
    if (value is String) {
      try {
        return TeamForm.values.firstWhere((form) => form.name == value);
      } catch (e) {
        return TeamForm.average;
      }
    }
    return TeamForm.average;
  }

  static List<String> _parseStringList(dynamic value) {
    if (value is List) {
      return value.map((e) => e.toString()).toList();
    }
    return [];
  }
}

/// Enum que representa a forma atual do time
enum TeamForm {
  terrible(0.7, 'Péssima'),
  poor(0.8, 'Ruim'),
  average(1.0, 'Média'),
  good(1.2, 'Boa'),
  excellent(1.4, 'Excelente');

  const TeamForm(this.multiplier, this.description);
  
  /// Multiplicador aplicado à força do time
  final double multiplier;
  
  /// Descrição legível da forma
  final String description;
  
  /// Retorna se a forma é considerada positiva
  bool get isPositive => index >= TeamForm.good.index;
  
  /// Retorna se a forma é considerada negativa
  bool get isNegative => index <= TeamForm.poor.index;
}
