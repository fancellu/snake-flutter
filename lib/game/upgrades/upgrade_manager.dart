import 'dart:math';
import 'upgrade.dart';

class UpgradeManager {
  static final List<Upgrade> _allUpgrades = [
    const Upgrade(
      id: 'bit_cruncher',
      name: 'Bit-Cruncher',
      description: 'Head deals damage to enemies.',
      type: UpgradeType.bitCruncher,
    ),
    const Upgrade(
      id: 'ghost_protocol',
      name: 'Ghost Protocol',
      description: 'Survive one wall collision per level.',
      type: UpgradeType.ghostProtocol,
    ),
    const Upgrade(
      id: 'magnetize',
      name: 'Magnetize',
      description: 'Increase food pickup range.',
      type: UpgradeType.magnetize,
    ),
    const Upgrade(
      id: 'crypto_miner',
      name: 'Crypto-Miner',
      description: 'Earn double score from data nodes.',
      type: UpgradeType.cryptoMiner,
    ),
    const Upgrade(
      id: 'speed_demon',
      name: 'Speed Demon',
      description: 'Move 20% faster.',
      type: UpgradeType.speedDemon,
    ),
  ];

  static List<Upgrade> getRandomUpgrades(int count) {
    final random = Random();
    final List<Upgrade> available = List.from(_allUpgrades);
    final List<Upgrade> selected = [];

    for (int i = 0; i < count; i++) {
      if (available.isEmpty) break;
      final index = random.nextInt(available.length);
      selected.add(available.removeAt(index));
    }

    return selected;
  }
}
