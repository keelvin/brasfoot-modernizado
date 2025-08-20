import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/game_controller.dart';
import '../models/match.dart';

class SimulationScreen extends StatefulWidget {
  const SimulationScreen({super.key});

  @override
  State<SimulationScreen> createState() => _SimulationScreenState();
}

class _SimulationScreenState extends State<SimulationScreen>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  final GameController gameController = Get.find<GameController>();
  final RxList<Match> _currentRoundMatches = <Match>[].obs;
  final RxBool _isSimulating = false.obs;
  final RxInt _currentMatchIndex = 0.obs;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));
    
    _loadCurrentRoundMatches();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _loadCurrentRoundMatches() {
    _currentRoundMatches.assignAll(
      gameController.getMatchesForRound(gameController.currentRound.value)
    );
  }

  Future<void> _simulateRound() async {
    if (_isSimulating.value) return;
    
    _isSimulating.value = true;
    _currentMatchIndex.value = 0;

    // Simula cada jogo individualmente com animação
    for (int i = 0; i < _currentRoundMatches.length; i++) {
      _currentMatchIndex.value = i;
      
      _animationController.reset();
      _animationController.forward();
      
      await Future.delayed(const Duration(milliseconds: 1500));
      
      await Future.delayed(const Duration(milliseconds: 500));
    }

    // Atualiza o estado do jogo
    await gameController.simulateRound();
    
    _isSimulating.value = false;

    // Carrega próxima rodada se existir
    if (gameController.currentRound.value <= gameController.selectedChampionship.value!.rounds) {
      _loadCurrentRoundMatches();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFF1A1A1A),
              Color(0xFF2D2D2D),
            ],
          ),
        ),
        child: SafeArea(
          child: Obx(() => Column(
            children: [
              _buildHeader(),
              Expanded(
                child: _currentRoundMatches.isEmpty
                    ? _buildCompletedChampionship()
                    : _buildSimulationContent(),
              ),
              _buildControlPanel(),
            ],
          )),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF2E7D32),
            Color(0xFF1B5E20),
          ],
        ),
      ),
      child: Column(
        children: [
          Row(
            children: [
              IconButton(
                onPressed: () => Navigator.pop(context),
                icon: const Icon(Icons.arrow_back, color: Colors.white),
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Simulação de Jogos',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      gameController.selectedChampionship.value?.name ?? '',
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildHeaderStat(
                  'Rodada Atual',
                  '${gameController.currentRound.value}',
                  Icons.calendar_today,
                ),
              ),
              Expanded(
                child: _buildHeaderStat(
                  'Jogos da Rodada',
                  '${_currentRoundMatches.length}',
                  Icons.sports_soccer,
                ),
              ),
              Expanded(
                child: _buildHeaderStat(
                  'Simulados',
                  '${_currentRoundMatches.where((m) => m.isPlayed).length}',
                  Icons.check_circle,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildHeaderStat(String label, String value, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(12),
      margin: const EdgeInsets.symmetric(horizontal: 4),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: [
          Icon(icon, color: Colors.white, size: 20),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            label,
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 10,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildSimulationContent() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
            Text(
              'Rodada ${gameController.currentRound.value}',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Jogos da rodada atual',
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 24),
            ..._currentRoundMatches.asMap().entries.map((entry) {
              int index = entry.key;
              Match match = entry.value;
              bool isCurrentMatch = _isSimulating.value && index == _currentMatchIndex.value;
              
              return AnimatedBuilder(
                animation: _fadeAnimation,
                builder: (context, child) {
                  return _buildMatchSimulationCard(
                    match, 
                    isCurrentMatch,
                    isCurrentMatch ? _fadeAnimation.value : 1.0,
                  );
                },
              );
            }).toList(),
        ],
      ),
    );
  }

  Widget _buildMatchSimulationCard(Match match, bool isCurrentMatch, double opacity) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          border: isCurrentMatch 
              ? Border.all(color: const Color(0xFF2E7D32), width: 2)
              : null,
        ),
        child: Card(
          elevation: isCurrentMatch ? 8 : 4,
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: _buildTeamInfo(match.homeTeam, true),
                    ),
                    Container(
                      margin: const EdgeInsets.symmetric(horizontal: 16),
                      child: Column(
                        children: [
                          if (match.isPlayed) ...[
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                              decoration: BoxDecoration(
                                color: const Color(0xFF2E7D32),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                match.scoreText,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ] else if (isCurrentMatch) ...[
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: Colors.orange,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                ),
                              ),
                            ),
                          ] else ...[
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                              decoration: BoxDecoration(
                                color: Colors.grey[700],
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: const Text(
                                'vs',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                          const SizedBox(height: 8),
                          Text(
                            match.homeTeam.stadium,
                            style: const TextStyle(
                              color: Colors.white60,
                              fontSize: 12,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                    Expanded(
                      child: _buildTeamInfo(match.awayTeam, false),
                    ),
                  ],
                ),
                if (match.isPlayed && match.events.isNotEmpty) ...[
                  const SizedBox(height: 16),
                  _buildMatchEvents(match),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTeamInfo(team, bool isHome) {
    return Column(
      crossAxisAlignment: isHome ? CrossAxisAlignment.end : CrossAxisAlignment.start,
      children: [
        Text(
          team.name,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
          textAlign: isHome ? TextAlign.right : TextAlign.left,
        ),
        const SizedBox(height: 4),
        Text(
          team.city,
          style: const TextStyle(
            color: Colors.white70,
            fontSize: 12,
          ),
          textAlign: isHome ? TextAlign.right : TextAlign.left,
        ),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: isHome ? MainAxisAlignment.end : MainAxisAlignment.start,
          children: [
            _buildTeamStrengthBar(team.overallRating),
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: _getFormColor(team.currentForm),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                team.currentForm.description,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildTeamStrengthBar(int rating) {
    return Container(
      width: 60,
      height: 6,
      decoration: BoxDecoration(
        color: Colors.grey[700],
        borderRadius: BorderRadius.circular(3),
      ),
      child: FractionallySizedBox(
        alignment: Alignment.centerLeft,
        widthFactor: rating / 100.0,
        child: Container(
          decoration: BoxDecoration(
            color: _getRatingColor(rating),
            borderRadius: BorderRadius.circular(3),
          ),
        ),
      ),
    );
  }

  Color _getRatingColor(int rating) {
    if (rating >= 80) return Colors.green;
    if (rating >= 70) return Colors.lightGreen;
    if (rating >= 60) return Colors.yellow;
    if (rating >= 50) return Colors.orange;
    return Colors.red;
  }

  Color _getFormColor(form) {
    switch (form.name) {
      case 'terrible':
        return Colors.red[800]!;
      case 'poor':
        return Colors.orange[800]!;
      case 'average':
        return Colors.grey[600]!;
      case 'good':
        return Colors.lightGreen[700]!;
      case 'excellent':
        return Colors.green[700]!;
      default:
        return Colors.grey[600]!;
    }
  }

  Widget _buildMatchEvents(Match match) {
    List<MatchEvent> goalEvents = match.goalEvents;
    
    if (goalEvents.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.grey[800],
          borderRadius: BorderRadius.circular(8),
        ),
        child: const Text(
          'Jogo sem gols',
          style: TextStyle(
            color: Colors.white70,
            fontSize: 12,
          ),
          textAlign: TextAlign.center,
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey[800],
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Gols da Partida:',
            style: TextStyle(
              color: Colors.white,
              fontSize: 12,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          ...goalEvents.map((event) => Padding(
            padding: const EdgeInsets.symmetric(vertical: 2),
            child: Row(
              children: [
                Container(
                  width: 30,
                  child: Text(
                    "${event.minute}'",
                    style: const TextStyle(
                      color: Colors.white70,
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const Icon(
                  Icons.sports_soccer,
                  color: Colors.green,
                  size: 14,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    event.team.name,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 11,
                    ),
                  ),
                ),
              ],
            ),
          )).toList(),
        ],
      ),
    );
  }

  Widget _buildCompletedChampionship() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.emoji_events,
            size: 80,
            color: Color(0xFFFFD700),
          ),
          const SizedBox(height: 24),
          const Text(
            'Campeonato Finalizado!',
            style: TextStyle(
              color: Colors.white,
              fontSize: 28,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          if (gameController.champion != null) ...[
            Text(
              'Campeão: ${gameController.champion!.name}',
              style: const TextStyle(
                color: Color(0xFFFFD700),
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 32),
            ElevatedButton.icon(
              onPressed: () {
                gameController.resetChampionship();
                Get.back();
              },
              icon: const Icon(Icons.refresh),
              label: const Text('Reiniciar Campeonato'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF2E7D32),
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildControlPanel() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: const BoxDecoration(
        color: Color(0xFF2D2D2D),
        border: Border(
          top: BorderSide(color: Colors.white10),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            ElevatedButton.icon(
              onPressed: _isSimulating.value || _currentRoundMatches.isEmpty 
                  ? null 
                  : _simulateRound,
              icon: _isSimulating.value 
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    )
                  : const Icon(Icons.play_arrow),
              label: Text(_isSimulating.value ? 'Simulando...' : 'Simular Rodada'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF2E7D32),
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
            ),
          ),
          const SizedBox(width: 12),
          ElevatedButton.icon(
            onPressed: _isSimulating.value 
                ? null 
                : () async {
                    await gameController.simulateFullChampionship();
                    _loadCurrentRoundMatches();
                  },
            icon: const Icon(Icons.fast_forward),
            label: const Text('Simular Tudo'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.orange[700],
              padding: const EdgeInsets.symmetric(vertical: 16),
            ),
          ),
        ],
      ),
    );
  }
}
