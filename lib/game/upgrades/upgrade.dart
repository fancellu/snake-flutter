enum UpgradeType {
  bitCruncher, // Damage enemies on contact
  ghostProtocol, // Pass through walls once
  magnetize, // Larger food pickup radius
  cryptoMiner, // More score/currency
  speedDemon, // Faster speed
  dataCompression, // Shrink size
}

class Upgrade {
  final String id;
  final String name;
  final String description;
  final UpgradeType type;

  const Upgrade({
    required this.id,
    required this.name,
    required this.description,
    required this.type,
  });
}
