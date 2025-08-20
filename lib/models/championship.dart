import 'team.dart';

class Championship {
  final String name;
  final String shortName;
  final ChampionshipType type;
  final List<Team> teams;
  final int year;
  final String description;
  final int rounds;
  final bool hasPlayoffs;

  Championship({
    required this.name,
    required this.shortName,
    required this.type,
    required this.teams,
    required this.year,
    required this.description,
    required this.rounds,
    this.hasPlayoffs = false,
  });

  factory Championship.fromJson(Map<String, dynamic> json) {
    return Championship(
      name: json['name'] ?? '',
      shortName: json['shortName'] ?? '',
      type: ChampionshipType.values.firstWhere(
        (type) => type.name == json['type'],
        orElse: () => ChampionshipType.serieA,
      ),
      teams: (json['teams'] as List<dynamic>?)
          ?.map((teamJson) => Team.fromJson(teamJson))
          .toList() ?? [],
      year: json['year'] ?? DateTime.now().year,
      description: json['description'] ?? '',
      rounds: json['rounds'] ?? 2,
      hasPlayoffs: json['hasPlayoffs'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'shortName': shortName,
      'type': type.name,
      'teams': teams.map((team) => team.toJson()).toList(),
      'year': year,
      'description': description,
      'rounds': rounds,
      'hasPlayoffs': hasPlayoffs,
    };
  }

  // Número total de jogos no campeonato
  int get totalMatches {
    int teamsCount = teams.length;
    int matchesPerRound = (teamsCount * (teamsCount - 1)) ~/ 2;
    return matchesPerRound * rounds;
  }

  // Duração estimada do campeonato em semanas
  int get estimatedWeeks {
    return (totalMatches / (teams.length ~/ 2)).ceil();
  }
}

enum ChampionshipType {
  serieA('Série A', 'A elite do futebol catarinense'),
  serieB('Série B', 'Segunda divisão estadual'),
  serieC('Série C', 'Terceira divisão estadual'),
  estadual('Estadual', 'Campeonato estadual unificado'),
  amador('Amador', 'Campeonato amador');

  const ChampionshipType(this.displayName, this.description);
  
  final String displayName;
  final String description;
}

class ChampionshipTable {
  final List<TeamStats> standings;
  final Championship championship;

  ChampionshipTable({
    required this.standings,
    required this.championship,
  });

  // Ordena a tabela por pontos, saldo de gols, etc.
  List<TeamStats> get sortedStandings {
    List<TeamStats> sorted = List.from(standings);
    sorted.sort((a, b) {
      // Primeiro por pontos
      if (a.points != b.points) {
        return b.points.compareTo(a.points);
      }
      // Depois por saldo de gols
      if (a.goalDifference != b.goalDifference) {
        return b.goalDifference.compareTo(a.goalDifference);
      }
      // Por último, gols marcados
      return b.goalsFor.compareTo(a.goalsFor);
    });
    
    // Atualiza as posições
    for (int i = 0; i < sorted.length; i++) {
      sorted[i].position = i + 1;
    }
    
    return sorted;
  }
}

class TeamStats {
  final Team team;
  int position;
  int matchesPlayed;
  int wins;
  int draws;
  int losses;
  int goalsFor;
  int goalsAgainst;
  int points;

  TeamStats({
    required this.team,
    this.position = 0,
    this.matchesPlayed = 0,
    this.wins = 0,
    this.draws = 0,
    this.losses = 0,
    this.goalsFor = 0,
    this.goalsAgainst = 0,
    this.points = 0,
  });

  int get goalDifference => goalsFor - goalsAgainst;
  
  double get winPercentage => 
      matchesPlayed > 0 ? (wins / matchesPlayed) * 100 : 0.0;
  
  double get averageGoalsFor => 
      matchesPlayed > 0 ? goalsFor / matchesPlayed : 0.0;
  
  double get averageGoalsAgainst => 
      matchesPlayed > 0 ? goalsAgainst / matchesPlayed : 0.0;

  void addMatchResult({
    required int goalsScored,
    required int goalsConceded,
  }) {
    matchesPlayed++;
    goalsFor += goalsScored;
    goalsAgainst += goalsConceded;
    
    if (goalsScored > goalsConceded) {
      wins++;
      points += 3;
    } else if (goalsScored == goalsConceded) {
      draws++;
      points += 1;
    } else {
      losses++;
    }
  }
}
