import 'package:flutter/material.dart';

class SimScenario {
  final int id;
  final String category;
  final String goal;
  final String sim;
  final String link;
  final String map;
  final String tips;
  final String drone;
  final IconData icon;

  const SimScenario({
    required this.id,
    required this.category,
    required this.goal,
    required this.sim,
    required this.link,
    required this.map,
    required this.tips,
    required this.drone,
    required this.icon,
  });
}
