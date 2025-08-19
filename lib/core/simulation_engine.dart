import 'dart:math';
import '../models/team.dart';
import '../models/match.dart';
import '../models/championship.dart';

class SimulationEngine {
  static final SimulationEngine _instance = SimulationEngine._internal();
  factory SimulationEngine() => _instance;
  SimulationEngine._internal();

  final Random _random = Random();

  /// Simula uma partida entre dois times
  MatchResult simulateMatch(Team homeTeam, Team awayTeam) {
    // Calcula as forças dos times
    double homeStrength = _calculateTeamStrength(homeTeam, isHome: true);
    double awayStrength = _calculateTeamStrength(awayTeam, isHome: false);
    
    // Fator de rivalidade (times da mesma cidade)
    double rivalryFactor = 1.0;
    if (homeTeam.city == awayTeam.city) {
      rivalryFactor = 1.2; // Jogos de rivalidade são mais intensos
    }

    // Calcula probabilidades baseadas nas forças
    double totalStrength = homeStrength + awayStrength;
    double homeProbability = (homeStrength / totalStrength) * rivalryFactor;
    
    // Simula eventos do jogo
    List<MatchEvent> events = _simulateMatchEvents(
      homeTeam, 
      awayTeam, 
      homeProbability
    );
    
    // Conta gols
    int homeGoals = events.where((e) => 
        e.type == MatchEventType.goal && e.team == homeTeam
    ).length;
    
    int awayGoals = events.where((e) => 
        e.type == MatchEventType.goal && e.team == awayTeam
    ).length;

    // Determina o resultado
    MatchResultType resultType;
    if (homeGoals > awayGoals) {
      resultType = MatchResultType.homeWin;
    } else if (awayGoals > homeGoals) {
      resultType = MatchResultType.awayWin;
    } else {
      resultType = MatchResultType.draw;
    }

    return MatchResult(
      homeGoals: homeGoals,
      awayGoals: awayGoals,
      events: events,
      result: resultType,
      homeTeam: homeTeam,
      awayTeam: awayTeam,
    );
  }

  /// Calcula a força atual de um time
  double _calculateTeamStrength(Team team, {required bool isHome}) {
    double baseStrength = team.overallRating / 100.0;
    double formMultiplier = team.currentForm.multiplier;
    double fatigueMultiplier = 1.0 - (team.fatigue * 0.3);
    
    double strength = baseStrength * formMultiplier * fatigueMultiplier;
    
    // Aplica fator casa/visitante
    if (isHome) {
      strength *= team.homeFactor;
    } else {
      strength *= 0.9; // Penalidade por jogar fora
    }
    
    return strength;
  }

  /// Simula os eventos de uma partida
  List<MatchEvent> _simulateMatchEvents(
    Team homeTeam, 
    Team awayTeam, 
    double homeProbability
  ) {
    List<MatchEvent> events = [];
    
    // Número de eventos baseado na qualidade dos times
    double avgAttack = (homeTeam.attack + awayTeam.attack) / 200.0;
    int maxEvents = (avgAttack * 20).round().clamp(8, 25);
    
    for (int i = 0; i < maxEvents; i++) {
      int minute = _random.nextInt(90) + 1;
      
      // Determina qual time tem a posse
      bool isHomeTeamEvent = _random.nextDouble() < homeProbability;
      Team attackingTeam = isHomeTeamEvent ? homeTeam : awayTeam;
      Team defendingTeam = isHomeTeamEvent ? awayTeam : homeTeam;
      
      // Calcula chance de gol baseada nos atributos
      double attackPower = attackingTeam.attack / 100.0;
      double defensePower = defendingTeam.defense / 100.0;
      double goalChance = (attackPower - defensePower * 0.7).clamp(0.0, 1.0);
      
      if (_random.nextDouble() < goalChance * 0.15) { // 15% chance base de gol
        events.add(MatchEvent(
          minute: minute,
          type: MatchEventType.goal,
          team: attackingTeam,
          description: 'Gol de ${attackingTeam.name}!',
        ));
      } else if (_random.nextDouble() < goalChance * 0.3) {
        // Chance perdida
        events.add(MatchEvent(
          minute: minute,
          type: MatchEventType.chance,
          team: attackingTeam,
          description: '${attackingTeam.name} desperdiça boa chance!',
        ));
      }
      
      // Eventos disciplinares
      if (_random.nextDouble() < 0.05) { // 5% chance de cartão
        MatchEventType cardType = _random.nextDouble() < 0.8 
            ? MatchEventType.yellowCard 
            : MatchEventType.redCard;
            
        events.add(MatchEvent(
          minute: minute,
          type: cardType,
          team: _random.nextBool() ? homeTeam : awayTeam,
          description: cardType == MatchEventType.yellowCard 
              ? 'Cartão amarelo' 
              : 'Cartão vermelho!',
        ));
      }
    }
    
    // Ordena eventos por minuto
    events.sort((a, b) => a.minute.compareTo(b.minute));
    return events;
  }

  /// Simula uma rodada completa de jogos
  List<MatchResult> simulateRound(List<Match> matches) {
    List<MatchResult> results = [];
    
    for (Match match in matches) {
      if (!match.isPlayed) {
        MatchResult result = simulateMatch(match.homeTeam, match.awayTeam);
        results.add(result);
        
        // Atualiza o match com o resultado
        match.homeGoals = result.homeGoals;
        match.awayGoals = result.awayGoals;
        match.events = result.events;
        match.result = result.result;
        match.isPlayed = true;
      }
    }
    
    return results;
  }

  /// Gera fixtures para um campeonato
  List<Match> generateFixtures(Championship championship) {
    List<Match> matches = [];
    List<Team> teams = championship.teams;
    
    // Gera jogos para cada turno
    for (int round = 1; round <= championship.rounds; round++) {
      List<Match> roundMatches = _generateRoundMatches(teams, round, championship);
      matches.addAll(roundMatches);
    }
    
    return matches;
  }

  /// Gera jogos de uma rodada específica
  List<Match> _generateRoundMatches(List<Team> teams, int round, Championship championship) {
    List<Match> roundMatches = [];
    List<Team> shuffledTeams = List.from(teams);
    
    if (round > 1) {
      // No segundo turno, inverte mando de campo
      shuffledTeams = shuffledTeams.reversed.toList();
    }

    for (int i = 0; i < shuffledTeams.length; i++) {
      for (int j = i + 1; j < shuffledTeams.length; j++) {
        Team homeTeam = shuffledTeams[i];
        Team awayTeam = shuffledTeams[j];
        
        Match match = Match(
          homeTeam: homeTeam,
          awayTeam: awayTeam,
          round: round,
          championship: championship,
          date: DateTime.now().add(Duration(days: (roundMatches.length * 3))),
        );
        
        roundMatches.add(match);
      }
    }

    return roundMatches;
  }

  /// Calcula estatísticas de um time baseado nos resultados
  TeamStats calculateTeamStats(Team team, List<MatchResult> results) {
    TeamStats stats = TeamStats(team: team);
    
    for (MatchResult result in results) {
      if (result.homeTeam == team) {
        stats.addMatchResult(
          goalsScored: result.homeGoals,
          goalsConceded: result.awayGoals,
        );
      } else if (result.awayTeam == team) {
        stats.addMatchResult(
          goalsScored: result.awayGoals,
          goalsConceded: result.homeGoals,
        );
      }
    }
    
    return stats;
  }
}

/// Resultado de uma partida simulada
class MatchResult {
  final int homeGoals;
  final int awayGoals;
  final List<MatchEvent> events;
  final MatchResultType result;
  final Team homeTeam;
  final Team awayTeam;

  MatchResult({
    required this.homeGoals,
    required this.awayGoals,
    required this.events,
    required this.result,
    required this.homeTeam,
    required this.awayTeam,
  });

  String get scoreText => '$homeGoals x $awayGoals';
  
  String get resultText {
    switch (result) {
      case MatchResultType.homeWin:
        return 'Vitória ${homeTeam.name}';
      case MatchResultType.awayWin:
        return 'Vitória ${awayTeam.name}';
      case MatchResultType.draw:
        return 'Empate';
    }
  }

  Team? get winner {
    if (result == MatchResultType.draw) return null;
    return result == MatchResultType.homeWin ? homeTeam : awayTeam;
  }

  Team? get loser {
    if (result == MatchResultType.draw) return null;
    return result == MatchResultType.homeWin ? awayTeam : homeTeam;
  }
}

enum MatchResultType {
  homeWin,
  awayWin,
  draw,
}
