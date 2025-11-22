# Neon Ouroboros: System Override
> *A Cyberpunk Snake Roguelite*

**Neon Ouroboros** is a high-octane, cyberpunk-themed twist on the classic Snake game. Hack the system, devour data shards, and breach firewalls to ascend through the security layers of the mainframe.

## 🎮 Features

*   **Roguelite Progression:** Unlock new Snake Classes (Viper, Python, Cobra) with unique stats and abilities.
*   **Dynamic Gameplay:**
    *   **Firewalls:** Eat enough data shards to open the firewall and advance to the next zone.
    *   **Enemies:** Avoid or destroy security drones patrolling the grid.
    *   **Power-ups:** Utilize Slow-Mo, Nukes, and Shields to survive.
    *   **Combo System:** Chain food pickups within 2 seconds for score multipliers!
*   **Upgrade System:** Draft powerful upgrades between levels (Speed Demon, Crypto Miner, Magnetize, Ghost Protocol).
*   **Universal Control:** Full support for Keyboard, Touch, and Gamepad (Xbox/PS/Generic) on Windows, Web, and Android.
*   **Retro-Futuristic Aesthetic:** Neon glow graphics, CRT effects, and a pumping synthwave soundtrack.

## 🕹️ How to Play

### Controls

| Action | Keyboard | Gamepad | Touch |
| :--- | :--- | :--- | :--- |
| **Move** | Arrow Keys | D-Pad / Left Stick | Swipe |
| **Pause** | P | Start / Menu | Tap Center |
| **Select** | Enter / Space | A / Cross | Tap Button |
| **Back** | Esc | B / Circle | Back Button |

### Objective
1.  **Consume Data:** Eat the cyan data shards to grow and increase your score.
2.  **Build Combos:** Chain pickups within 2 seconds for bonus multipliers (x2, x3, x4...).
3.  **Breach Security:** Fill the Target meter to open the Firewall (Exit).
4.  **Survive:** Avoid crashing into walls, your own tail, or red security drones.
5.  **Evolve:** Complete levels to draft upgrades and become unstoppable.

### Tips
*   **Speed Demon:** Faster movement = easier combos, but harder control.
*   **Ghost Protocol:** Grants 3 charges to phase through obstacles.
*   **Magnetize:** Increases pickup radius - collect food without exact positioning.
*   **Crypto Miner:** Doubles your score multiplier permanently.

## 🛠️ Build & Deploy

This project is built with [Flutter](https://flutter.dev) and the [Flame Engine](https://flame-engine.org).

### Prerequisites
*   Flutter SDK (Latest Stable)
*   Dart SDK

### Running Locally

```bash
# Get dependencies
flutter pub get

# Run on Windows
flutter run -d windows

# Run on Web (Chrome)
flutter run -d chrome
```

### Building for Production

**Windows:**
```bash
flutter build windows
# Output: build/windows/runner/Release/
```

**Web:**
```bash
flutter build web --release --base-href /your-hosting-path/
# Output: build/web/
```

**Android:**
```bash
flutter build apk --release
# Output: build/app/outputs/flutter-apk/app-release.apk
```

## 📦 Dependencies

*   `flame`: Game engine core.
*   `gamepads`: Universal gamepad support.
*   `window_manager`: Desktop window control.
*   `google_fonts`: Typography.
*   `flame_audio`: Sound effects and music.
*   `hive` / `hive_flutter`: Save data persistence.

## 🐛 Known Issues

*   **Windows Audio Warning:** You may see threading warnings from `audioplayers` in the console. These are harmless and don't affect gameplay.
*   **Debug Mode:** Closing the game in debug mode may show errors - this is normal. Release builds exit cleanly.

## 🎯 Gameplay Tips

*   **Aggressive Play:** Risk getting close to enemies for faster food chains and higher combos.
*   **Upgrade Synergy:** Combine Speed Demon + Magnetize for maximum combo potential.
*   **Ghost Protocol:** Save charges for tight situations - you get 3 per pickup.
*   **Class Selection:** Python has double growth (longer snake faster), Cobra starts with speed boost.

## 📄 License

MIT License - Hack away!
