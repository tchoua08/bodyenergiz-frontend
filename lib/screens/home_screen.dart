import 'package:flutter/material.dart';
import '../widgets/energy_gauge.dart';
import '../models/energy_result.dart';
import 'aura_scan_screen.dart';
import 'energy_detail_page.dart';
import '../utils/theme.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}
class _HomeScreenState extends State<HomeScreen> {
  EnergyResult? last;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Accueil'), backgroundColor: AppTheme.primaryTeal),
      body: Container(
        decoration: const BoxDecoration(gradient: LinearGradient(colors: [AppTheme.primaryTeal, AppTheme.darkBlue], begin: Alignment.topLeft, end: Alignment.bottomRight)),
        child: Padding(
          padding: const EdgeInsets.all(18),
          child: Column(children: [
            EnergyGauge(score: last?.energyScore ?? 0.0),
            const SizedBox(height: 12),
            ElevatedButton(onPressed: () async {
              final res = await Navigator.push<EnergyResult?>(context, MaterialPageRoute(builder: (_) => const AuraScanScreen()));
              if (res != null) setState(() => last = res);
            }, child: const Text('Scanner l\'aura')),
            const SizedBox(height: 8),
            if (last != null)
              ElevatedButton(onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => EnergyDetailPage(result: last!))), child: const Text('Voir détails')),
          ]),
        ),
      ),
    );
  }
}


