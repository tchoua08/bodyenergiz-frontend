class EnergyResult {
  final double bpm;
  final double movement;
  final double energyScore;
  final String auraColor;

  EnergyResult({required this.bpm, required this.movement, required this.energyScore, required this.auraColor});

  Map<String, dynamic> toMap() => {
    'bpm': bpm,
    'movement': movement,
    'energyScore': energyScore,
    'auraColor': auraColor
  };
}


