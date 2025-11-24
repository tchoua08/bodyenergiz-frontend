import 'package:flutter/material.dart';
import '../services/advice_repository.dart';
import '../utils/theme.dart';

class AdviceHistoryScreen extends StatefulWidget {
  const AdviceHistoryScreen({super.key});
  @override
  State<AdviceHistoryScreen> createState() => _AdviceHistoryScreenState();
}

class _AdviceHistoryScreenState extends State<AdviceHistoryScreen> {
  final AdviceRepository _repo = AdviceRepository();
  List items = [];
  bool loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final r = await _repo.getHistory();
    if (r["ok"]) {
      setState(() { items = r["data"]; loading = false; });
    } else {
      setState(() { loading = false; });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Historique des conseils")),
      body: Container(
        decoration: AppTheme.mainGradient,
        padding: const EdgeInsets.all(12),
        child: loading ? const Center(child: CircularProgressIndicator()) :
        ListView.builder(
          itemCount: items.length,
          itemBuilder: (_, i) {
            final it = items[i];
            return Card(
              color: Colors.white.withOpacity(.06),
              child: ListTile(
                title: Text(it["adviceText"].toString().split("\n").first, style: const TextStyle(color: Colors.white)),
                subtitle: Text(DateTime.parse(it["createdAt"]).toString(), style: const TextStyle(color: Colors.white70)),
                trailing: it["audioUrl"] != null ? const Icon(Icons.play_circle) : null,
                onTap: () {
                  // open details / play audio
                },
              ),
            );
          },
        ),
      ),
    );
  }
}


