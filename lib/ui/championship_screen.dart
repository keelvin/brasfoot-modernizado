import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../models/championship.dart';
import '../controllers/game_controller.dart';
import '../models/team.dart';
import '../models/match.dart';
import 'simulation_screen.dart';
import 'team_screen.dart';

class ChampionshipScreen extends StatefulWidget {
  final Championship championship;

  const ChampionshipScreen({
    super.key,
    required this.championship,
  });

  @override
  State<ChampionshipScreen> createState() => _ChampionshipScreenState();
}

class _ChampionshipScreenState extends State<ChampionshipScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final GameController gameController = Get.find<GameController>();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
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
          child: Column(
            children: [
              _buildHeader(),
              _buildTabBar(),
              Expanded(
                child: TabBarView(
                  controller: _tabController,
                  children: [
                    _buildOverviewTab(),
                    _buildTableTab(),
                    _buildMatchesTab(),
                    _buildTeamsTab(),
                  ],
                ),
              ),
            ],
          ),
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              IconButton(
                onPressed: () => Get.back(),
                icon: const Icon(Icons.arrow_back, color: Colors.white),
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.championship.name,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      '${widget.championship.teams.length} times • ${widget.championship.year}',
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
              Obx(() => ElevatedButton.icon(
                onPressed: gameController.isLoading.value ? null : () {
                  Get.to(() => const SimulationScreen());
                },
                icon: gameController.isLoading.value 
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                      )
                    : const Icon(Icons.play_arrow),
                label: Text(gameController.isLoading.value ? 'Simulando...' : 'Simular'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: const Color(0xFF2E7D32),
                ),
              )),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTabBar() {
    return Container(
      color: const Color(0xFF2D2D2D),
      child: TabBar(
        controller: _tabController,
        indicatorColor: const Color(0xFF2E7D32),
        labelColor: Colors.white,
        unselectedLabelColor: Colors.white60,
        tabs: const [
          Tab(text: 'Visão Geral'),
          Tab(text: 'Tabela'),
          Tab(text: 'Jogos'),
          Tab(text: 'Times'),
        ],
      ),
    );
  }

  Widget _buildOverviewTab() {
    return Obx(() => SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildStatsCards(),
          const SizedBox(height: 24),
          _buildRecentMatches(),
          const SizedBox(height: 24),
          _buildUpcomingMatches(),
        ],
      ),
    ));
  }

  Widget _buildStatsCards() {
    int totalMatches = gameController.matches.length;
    int playedMatches = gameController.matches.where((m) => m.isPlayed).length;
    int remainingMatches = totalMatches - playedMatches;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Estatísticas do Campeonato',
          style: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: _buildStatCard(
                'Rodada Atual',
                '${gameController.currentRound.value}',
                Icons.calendar_today,
                const Color(0xFF2E7D32),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildStatCard(
                'Jogos Realizados',
                '$playedMatches',
                Icons.sports_soccer,
                const Color(0xFF1976D2),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _buildStatCard(
                'Jogos Restantes',
                '$remainingMatches',
                Icons.schedule,
                const Color(0xFFFF9800),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildStatCard(
                'Total de Jogos',
                '$totalMatches',
                Icons.emoji_events,
                const Color(0xFF9C27B0),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color color) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Icon(icon, color: color, size: 32),
            const SizedBox(height: 8),
            Text(
              value,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              title,
              style: const TextStyle(
                color: Colors.white70,
                fontSize: 12,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRecentMatches() {
    List<Match> recentMatches = gameController.getRecentResults(limit: 3);
    
    if (recentMatches.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Últimos Resultados',
          style: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        ...recentMatches.map((match) => _buildMatchCard(match)).toList(),
      ],
    );
  }

  Widget _buildUpcomingMatches() {
    List<Match> upcomingMatches = gameController.getUpcomingMatches(limit: 3);
    
    if (upcomingMatches.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Próximos Jogos',
          style: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        ...upcomingMatches.map((match) => _buildMatchCard(match)).toList(),
      ],
    );
  }

  Widget _buildTableTab() {
    return Obx(() {
      if (gameController.standings.isEmpty) {
        return const Center(
          child: Text(
            'Tabela não disponível',
            style: TextStyle(color: Colors.white70),
          ),
        );
      }

      List<TeamStats> standings = gameController.sortedStandings;

      return SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    _buildTableHeader(),
                    const Divider(color: Colors.white30),
                    ...standings.map((stats) => _buildTableRow(stats)).toList(),
                  ],
                ),
              ),
            ),
          ],
        ),
      );
    });
  }

  Widget _buildTableHeader() {
    return const Row(
      children: [
        SizedBox(width: 30, child: Text('#', style: TextStyle(color: Colors.white70, fontSize: 12, fontWeight: FontWeight.bold))),
        Expanded(child: Text('Time', style: TextStyle(color: Colors.white70, fontSize: 12, fontWeight: FontWeight.bold))),
        SizedBox(width: 30, child: Text('J', style: TextStyle(color: Colors.white70, fontSize: 12, fontWeight: FontWeight.bold))),
        SizedBox(width: 30, child: Text('V', style: TextStyle(color: Colors.white70, fontSize: 12, fontWeight: FontWeight.bold))),
        SizedBox(width: 30, child: Text('E', style: TextStyle(color: Colors.white70, fontSize: 12, fontWeight: FontWeight.bold))),
        SizedBox(width: 30, child: Text('D', style: TextStyle(color: Colors.white70, fontSize: 12, fontWeight: FontWeight.bold))),
        SizedBox(width: 40, child: Text('SG', style: TextStyle(color: Colors.white70, fontSize: 12, fontWeight: FontWeight.bold))),
        SizedBox(width: 30, child: Text('Pts', style: TextStyle(color: Colors.white70, fontSize: 12, fontWeight: FontWeight.bold))),
      ],
    );
  }

  Widget _buildTableRow(TeamStats stats) {
    Color positionColor = _getPositionColor(stats.position);
    
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Container(
            width: 30,
            child: Container(
              width: 20,
              height: 20,
              decoration: BoxDecoration(
                color: positionColor,
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Text(
                  '${stats.position}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ),
          Expanded(
            child: Text(
              stats.team.name,
              style: const TextStyle(color: Colors.white, fontSize: 14),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          SizedBox(width: 30, child: Text('${stats.matchesPlayed}', style: const TextStyle(color: Colors.white70, fontSize: 12))),
          SizedBox(width: 30, child: Text('${stats.wins}', style: const TextStyle(color: Colors.green, fontSize: 12))),
          SizedBox(width: 30, child: Text('${stats.draws}', style: const TextStyle(color: Colors.yellow, fontSize: 12))),
          SizedBox(width: 30, child: Text('${stats.losses}', style: const TextStyle(color: Colors.red, fontSize: 12))),
          SizedBox(width: 40, child: Text('${stats.goalDifference > 0 ? '+' : ''}${stats.goalDifference}', style: const TextStyle(color: Colors.white70, fontSize: 12))),
          SizedBox(width: 30, child: Text('${stats.points}', style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold))),
        ],
      ),
    );
  }

  Color _getPositionColor(int position) {
    if (position <= 2) return const Color(0xFF4CAF50); // Verde - Classificação
    if (position <= 4) return const Color(0xFF2196F3); // Azul - Copa
    if (position >= widget.championship.teams.length - 1) return const Color(0xFFF44336); // Vermelho - Rebaixamento
    return Colors.grey; // Neutro
  }

  Widget _buildMatchesTab() {
    return Obx(() {
      if (gameController.matches.isEmpty) {
        return const Center(
          child: Text(
            'Nenhum jogo disponível',
            style: TextStyle(color: Colors.white70),
          ),
        );
      }

      // Agrupa jogos por rodada
      Map<int, List<Match>> matchesByRound = {};
      for (Match match in gameController.matches) {
        matchesByRound.putIfAbsent(match.round, () => []).add(match);
      }

      return SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: matchesByRound.entries.map((entry) {
            int round = entry.key;
            List<Match> roundMatches = entry.value;
            
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  child: Text(
                    'Rodada $round',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                ...roundMatches.map((match) => _buildMatchCard(match)).toList(),
              ],
            );
          }).toList(),
        ),
      );
    });
  }

  Widget _buildMatchCard(Match match) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    match.homeTeam.name,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                    textAlign: TextAlign.right,
                  ),
                  Text(
                    match.homeTeam.city,
                    style: const TextStyle(
                      color: Colors.white60,
                      fontSize: 12,
                    ),
                    textAlign: TextAlign.right,
                  ),
                ],
              ),
            ),
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 16),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: match.isPlayed ? const Color(0xFF2E7D32) : Colors.grey[700],
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                match.isPlayed ? match.scoreText : 'vs',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    match.awayTeam.name,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Text(
                    match.awayTeam.city,
                    style: const TextStyle(
                      color: Colors.white60,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTeamsTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: widget.championship.teams.map((team) => _buildTeamCard(team)).toList(),
      ),
    );
  }

  Widget _buildTeamCard(Team team) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: () {
          Get.to(() => TeamScreen(team: team));
        },
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          team.name,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          '${team.city} • Fundado em ${team.foundedYear}',
                          style: const TextStyle(
                            color: Colors.white70,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: _getFormColor(team.currentForm),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      team.currentForm.description,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  _buildTeamStat('Overall', team.overallRating),
                  const SizedBox(width: 16),
                  _buildTeamStat('Ataque', team.attack),
                  const SizedBox(width: 16),
                  _buildTeamStat('Defesa', team.defense),
                  const SizedBox(width: 16),
                  _buildTeamStat('Meio', team.midfield),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTeamStat(String label, int value) {
    return Column(
      children: [
        Text(
          '$value',
          style: const TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: const TextStyle(
            color: Colors.white70,
            fontSize: 12,
          ),
        ),
      ],
    );
  }

  Color _getFormColor(TeamForm form) {
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
}
