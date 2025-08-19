import 'team.dart';
import 'championship.dart';

class Match {
  final Team homeTeam;
  final Team awayTeam;
  final int round;
  final Championship championship;
  final DateTime date;
  
  int homeGoals = 0;
  int awayGoals = 0;
  bool isPlayed = false;
  List<MatchEvent> events = [];
  MatchResultType? result;

  Match({
    required this.homeTeam,
    required this.awayTeam,
    required this.round,
    required this.championship,
    required this.date,
  });

  String get scoreText => '$homeGoals x $awayGoals';
  
  String get resultText {
    if (!isPlayed) return 'Não realizada';
    
    switch (result!) {
      case MatchResultType.homeWin:
        return 'Vitória ${homeTeam.name}';
      case MatchResultType.awayWin:
        return 'Vitória ${awayTeam.name}';
      case MatchResultType.draw:
        return 'Empate';
    }
  }

  Team? get winner {
    if (!isPlayed || result == MatchResultType.draw) return null;
    return result == MatchResultType.homeWin ? homeTeam : awayTeam;
  }

  Team? get loser {
    if (!isPlayed || result == MatchResultType.draw) return null;
    return result == MatchResultType.homeWin ? awayTeam : homeTeam;
  }

  // Retorna os gols de um evento específico
  List<MatchEvent> get goalEvents {
    return events.where((event) => event.type == MatchEventType.goal).toList();
  }

  // Retorna estatísticas básicas da partida
  MatchStats get stats {
    int homeChances = events.where((e) => 
        e.team == homeTeam && 
        (e.type == MatchEventType.goal || e.type == MatchEventType.chance)
    ).length;
    
    int awayChances = events.where((e) => 
        e.team == awayTeam && 
        (e.type == MatchEventType.goal || e.type == MatchEventType.chance)
    ).length;

    return MatchStats(
      homeChances: homeChances,
      awayChances: awayChances,
      homeCards: events.where((e) => 
          e.team == homeTeam && 
          (e.type == MatchEventType.yellowCard || e.type == MatchEventType.redCard)
      ).length,
      awayCards: events.where((e) => 
          e.team == awayTeam && 
          (e.type == MatchEventType.yellowCard || e.type == MatchEventType.redCard)
      ).length,
    );
  }
}

class MatchEvent {
  final int minute;
  final MatchEventType type;
  final Team team;
  final String description;

  MatchEvent({
    required this.minute,
    required this.type,
    required this.team,
    required this.description,
  });
}

enum MatchEventType {
  goal,
  chance,
  yellowCard,
  redCard,
  substitution,
}

enum MatchResultType {
  homeWin,
  awayWin,
  draw,
}

class MatchStats {
  final int homeChances;
  final int awayChances;
  final int homeCards;
  final int awayCards;

  MatchStats({
    required this.homeChances,
    required this.awayChances,
    required this.homeCards,
    required this.awayCards,
  });

  int get totalChances => homeChances + awayChances;
  int get totalCards => homeCards + awayCards;
}
