import 'package:flutter/material.dart';
import 'game_adventure_map_screen.dart';

/// WorldsScreen
/// Interactive Adventure Map for Mini-Games:
/// - Replaces the legacy grid view with an adventurous, scrollable winding trail
/// - 100% of all games are unlocked from the start for total child freedom
/// - Pixar 3D characters, bouncy stepping stones, and tactile sound effects
class WorldsScreen extends StatelessWidget {
  const WorldsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const GameAdventureMapScreen();
  }
}
