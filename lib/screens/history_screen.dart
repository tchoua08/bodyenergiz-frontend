import 'package:flutter/material.dart';
import '../../utils/theme.dart';
import '../../models/energy_result.dart';

// NOTE: Ce fichier suppose l'existence d'un ScanRepository ou d'un service qui renvoie l'historique.
// Si tu n'as pas encore ce repo, la classe ci-dessous utilise un mock pour afficher l'UI.

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  bool loading = true;
  List<EnergyResult> _items = [];

  @override
  void initState() {
    super.initState();
    _loadHistory();
  }

  Future<void> _loadHistory() async {
    setState(() => loading = true);

    try {
      // TODO: Remplace par ton ScanRepository réel, ex:
      // final repo = ScanRepository();
      // final resp = await repo.getHistory();
      // if (resp['ok']) _items = (resp['data'] as List).map(...).toList();

      // Mock rapide :
      await Future.delayed(const Duration(milliseconds: 600));
      _items = [
        EnergyResult(bpm: 72, movement: 0.12, energyScore: 0.78, auraColor: 'green'),
        EnergyResult(bpm: 88, movement: 0.38, energyScore: 0.54, auraColor: 'red'),
        EnergyResult(bpm: 64, movement: 0.05, energyScore: 0.91, auraColor: 'gold'),
      ];
    } catch (_) {
      _items = [];
    } finally {
      setState(() => loading = false);
    }
  }

  Widget _itemTile(EnergyResult r) {
    return Card(
      color: Colors.white.withOpacity(0.06),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 6),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
        leading: CircleAvatar(
          radius: 28,
          backgroundColor: AppTheme.colorFromAura(r.auraColor),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text('${r.bpm.toInt()}',
                  style: const TextStyle(color: Colors.black87, fontWeight: FontWeight.bold)),
              const Text('BPM', style: TextStyle(fontSize: 10, color: Colors.black54)),
            ],
          ),
        ),
        title: Text(
          'Score: ${(r.energyScore * 100).toInt()}%',
          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
        ),
        subtitle: Text('Mouvement: ${(r.movement * 100).toInt()}%', style: const TextStyle(color: Colors.white70)),
        trailing: IconButton(
          icon: const Icon(Icons.chevron_right, color: Colors.white70),
          onPressed: () {
            // ouvrir detail
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => EnergyDetailPlaceholder(result: r),
              ),
            );
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Historique des scans'),
        backgroundColor: AppTheme.primaryTeal,
      ),
      body: SafeArea(
        bottom: false,
        child: Container(
          width: double.infinity,
          decoration: AppTheme.mainGradient,
          padding: const EdgeInsets.all(12),
          child: loading
              ? const Center(child: CircularProgressIndicator(color: Colors.white))
              : _items.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.history, size: 48, color: Colors.white24),
                          const SizedBox(height: 12),
                          const Text(
                            "Aucun scan enregistré",
                            style: TextStyle(color: Colors.white70),
                          ),
                        ],
                      ),
                    )
                  : RefreshIndicator(
                      onRefresh: _loadHistory,
                      color: AppTheme.primaryTeal,
                      child: ListView.builder(
                        itemCount: _items.length,
                        itemBuilder: (_, i) => _itemTile(_items[i]),
                      ),
                    ),
        ),
      ),
    );
  }
}

// Petit placeholder pour la page de détail (si tu n'as pas encore EnergyDetailPage)
class EnergyDetailPlaceholder extends StatelessWidget {
  final EnergyResult result;
  const EnergyDetailPlaceholder({required this.result, super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Détail du scan'), backgroundColor: AppTheme.primaryTeal),
      body: Container(
        decoration: AppTheme.mainGradient,
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            Text('BPM: ${result.bpm}', style: const TextStyle(color: Colors.white, fontSize: 18)),
            const SizedBox(height: 8),
            Text('Movement: ${result.movement}', style: const TextStyle(color: Colors.white70)),
            const SizedBox(height: 8),
            Text('Energy: ${(result.energyScore * 100).toInt()}%', style: const TextStyle(color: Colors.white70)),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(color: Colors.white.withOpacity(0.06), borderRadius: BorderRadius.circular(12)),
              child: Text('Aura: ${result.auraColor}', style: const TextStyle(color: Colors.white)),
            )
          ],
        ),
      ),
    );
  }
}


