import 'package:get/get.dart';
import '../constants/app_constants.dart';
import '../models/championship.dart';
import '../models/team.dart';
import '../models/match.dart';
import '../core/simulation_engine.dart';
import '../services/data_service.dart';

/// Controller principal que gerencia o estado do jogo usando GetX
class GameController extends GetxController {
  // Dependências
  final DataService _dataService = DataService.instance;
  final SimulationEngine _simulationEngine = SimulationEngine();

  // Estado reativo - Dados principais
  final RxList<Championship> _championships = <Championship>[].obs;
  final Rx<Championship?> _selectedChampionship = Rx<Championship?>(null);
  final RxList<Match> _matches = <Match>[].obs;
  final RxList<TeamStats> _standings = <TeamStats>[].obs;
  
  // Estado reativo - Controle de fluxo
  final RxInt _currentRound = 1.obs;
  final RxBool _isLoading = false.obs;
  final RxString _errorMessage = ''.obs;
  final Rx<Team?> _champion = Rx<Team?>(null);

  // Getters públicos (imutáveis)
  List<Championship> get championships => List.unmodifiable(_championships);
  Championship? get selectedChampionship => _selectedChampionship.value;
  List<Match> get matches => List.unmodifiable(_matches);
  List<TeamStats> get standings => List.unmodifiable(_standings);
  int get currentRound => _currentRound.value;
  bool get isLoading => _isLoading.value;
  String get errorMessage => _errorMessage.value;
  Team? get champion => _champion.value;

  // Getters calculados
  bool get hasSelectedChampionship => _selectedChampionship.value != null;
  bool get isChampionshipFinished => _currentRound.value > (selectedChampionship?.rounds ?? 0);
  bool get hasError => _errorMessage.value.isNotEmpty;
  int get totalMatches => _matches.length;
  int get playedMatches => _matches.where((m) => m.isPlayed).length;
  int get remainingMatches => totalMatches - playedMatches;

  @override
  void onInit() {
    super.onInit();
    _loadChampionships();
  }

  /// Carrega todos os campeonatos disponíveis
  Future<void> _loadChampionships() async {
    await _executeWithLoading(() async {
      final loadedChampionships = await _dataService.loadChampionships();
      _championships.assignAll(loadedChampionships);
    });
  }

  /// Seleciona um campeonato para gerenciar
  Future<void> selectChampionship(Championship championship) async {
    if (!_dataService.validateChampionshipData(championship)) {
      _setError('Dados do campeonato inválidos');
      return;
    }

    _selectedChampionship.value = championship;
    _resetChampionshipState();
    _initializeStandings();
    _generateAllMatches();
    
    _clearError();
  }

  /// Simula uma rodada completa do campeonato
  Future<void> simulateRound() async {
    if (!_canSimulateRound()) return;

    await _executeWithLoading(() async {
      final roundMatches = _getCurrentRoundMatches();
      
      for (final match in roundMatches) {
        await _simulateMatchWithDelay(match);
        _updateStandingsWithMatch(match);
      }

      _advanceToNextRound();
      
      if (isChampionshipFinished) {
        _determineChampion();
      }
    });
  }

  /// Simula o campeonato completo
  Future<void> simulateFullChampionship() async {
    while (!isChampionshipFinished && hasSelectedChampionship) {
      await simulateRound();
    }
  }

  /// Reinicia o campeonato selecionado
  void resetChampionship() {
    if (!hasSelectedChampionship) return;
    
    _resetChampionshipState();
    _initializeStandings();
    _generateAllMatches();
  }

  /// Recarrega todos os dados
  Future<void> reloadData() async {
    await _executeWithLoading(() async {
      await _dataService.reloadChampionships();
      await _loadChampionships();
    });
  }

  // Métodos de consulta

  /// Obtém partidas de uma rodada específica
  List<Match> getMatchesForRound(int round) {
    return _matches.where((match) => match.round == round).toList();
  }

  /// Obtém próximas partidas
  List<Match> getUpcomingMatches({int limit = 5}) {
    return _matches
        .where((match) => !match.isPlayed)
        .take(limit)
        .toList();
  }

  /// Obtém resultados recentes
  List<Match> getRecentResults({int limit = 5}) {
    return _matches
        .where((match) => match.isPlayed)
        .toList()
        .reversed
        .take(limit)
        .toList();
  }

  /// Obtém tabela de classificação ordenada
  List<TeamStats> getSortedStandings() {
    final sorted = List<TeamStats>.from(_standings);
    sorted.sort(_compareTeamStats);
    
    // Atualiza posições
    for (int i = 0; i < sorted.length; i++) {
      sorted[i].position = i + 1;
    }
    
    return sorted;
  }

  /// Obtém estatísticas de um time específico
  TeamStats? getTeamStats(Team team) {
    try {
      return _standings.firstWhere((stats) => stats.team == team);
    } catch (e) {
      return null;
    }
  }

  // Métodos privados - Inicialização

  void _resetChampionshipState() {
    _currentRound.value = 1;
    _champion.value = null;
    _matches.clear();
    _standings.clear();
    _clearError();
  }

  void _initializeStandings() {
    if (!hasSelectedChampionship) return;

    final stats = selectedChampionship!.teams
        .map((team) => TeamStats(team: team))
        .toList();

    _standings.assignAll(stats);
  }

  void _generateAllMatches() {
    if (!hasSelectedChampionship) return;

    _matches.clear();
    final teams = selectedChampionship!.teams;
    
    for (int round = 1; round <= selectedChampionship!.rounds; round++) {
      final roundMatches = _generateRoundMatches(teams, round);
      _matches.addAll(roundMatches);
    }
  }

  List<Match> _generateRoundMatches(List<Team> teams, int round) {
    final roundMatches = <Match>[];
    var teamsForRound = List<Team>.from(teams);
    
    // No segundo turno, inverte mando de campo
    if (round > 1) {
      teamsForRound = teamsForRound.reversed.toList();
    }

    for (int i = 0; i < teamsForRound.length; i++) {
      for (int j = i + 1; j < teamsForRound.length; j++) {
        final match = Match(
          homeTeam: teamsForRound[i],
          awayTeam: teamsForRound[j],
          round: round,
          championship: selectedChampionship!,
          date: _calculateMatchDate(roundMatches.length),
        );
        
        roundMatches.add(match);
      }
    }

    return roundMatches;
  }

  DateTime _calculateMatchDate(int matchIndex) {
    return DateTime.now().add(Duration(days: matchIndex * 3));
  }

  // Métodos privados - Simulação

  bool _canSimulateRound() {
    return hasSelectedChampionship && 
           !isChampionshipFinished && 
           !isLoading;
  }

  List<Match> _getCurrentRoundMatches() {
    return _matches
        .where((match) => match.round == currentRound && !match.isPlayed)
        .toList();
  }

  Future<void> _simulateMatchWithDelay(Match match) async {
    await Future.delayed(const Duration(milliseconds: 100));
    _simulationEngine.simulateMatch(match);
  }

  void _updateStandingsWithMatch(Match match) {
    final homeStats = _getTeamStats(match.homeTeam);
    final awayStats = _getTeamStats(match.awayTeam);

    if (homeStats != null && awayStats != null) {
      homeStats.addMatchResult(
        goalsScored: match.homeGoals,
        goalsConceded: match.awayGoals,
      );
      
      awayStats.addMatchResult(
        goalsScored: match.awayGoals,
        goalsConceded: match.homeGoals,
      );
      
      _standings.refresh();
    }
  }

  TeamStats? _getTeamStats(Team team) {
    try {
      return _standings.firstWhere((stats) => stats.team == team);
    } catch (e) {
      return null;
    }
  }

  void _advanceToNextRound() {
    _currentRound.value++;
  }

  void _determineChampion() {
    final sortedStandings = getSortedStandings();
    if (sortedStandings.isNotEmpty) {
      _champion.value = sortedStandings.first.team;
    }
  }

  // Métodos privados - Utilitários

  int _compareTeamStats(TeamStats a, TeamStats b) {
    // Primeiro critério: pontos
    if (a.points != b.points) {
      return b.points.compareTo(a.points);
    }
    
    // Segundo critério: saldo de gols
    if (a.goalDifference != b.goalDifference) {
      return b.goalDifference.compareTo(a.goalDifference);
    }
    
    // Terceiro critério: gols marcados
    return b.goalsFor.compareTo(a.goalsFor);
  }

  Future<void> _executeWithLoading(Future<void> Function() operation) async {
    try {
      _setLoading(true);
      _clearError();
      await operation();
    } catch (error) {
      _setError('Erro na operação: $error');
    } finally {
      _setLoading(false);
    }
  }

  void _setLoading(bool loading) {
    _isLoading.value = loading;
  }

  void _setError(String message) {
    _errorMessage.value = message;
  }

  void _clearError() {
    _errorMessage.value = '';
  }

  @override
  void onClose() {
    // Limpa recursos se necessário
    super.onClose();
  }
}
