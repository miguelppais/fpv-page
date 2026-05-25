// Drop these three files into your project (e.g. lib/tools/sim_training/).
// Add to pubspec.yaml:
//   url_launcher: ^6.3.0
//
// Push to a screen from your navigation:
//   Navigator.of(context).push(MaterialPageRoute(
//     builder: (_) => const SimTrainingScreen(),
//   ));

import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import 'sim_scenario.dart';
import 'sim_training_data.dart';

// ── Palette (MiguelPais.FPV design system) ────────────────────────────────────
const _kBg = Color(0xFF020617);       // slate-950
const _kSurface = Color(0xFF0F172A);  // slate-900
const _kSurface2 = Color(0xFF1E293B); // slate-800
const _kBorder = Color(0xFF1E293B);   // slate-800
const _kText = Color(0xFFF1F5F9);     // slate-100
const _kMuted = Color(0xFF94A3B8);    // slate-400
const _kDim = Color(0xFF64748B);      // slate-500
const _kAccent = Color(0xFF38BDF8);   // sky-400
const _kAccentBright = Color(0xFF0EA5E9); // sky-500

Future<void> _launch(String url) async {
  final uri = Uri.parse(url);
  if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
    debugPrint('Could not launch $url');
  }
}

// ── Main screen ───────────────────────────────────────────────────────────────

class SimTrainingScreen extends StatefulWidget {
  const SimTrainingScreen({super.key});

  @override
  State<SimTrainingScreen> createState() => _SimTrainingScreenState();
}

class _SimTrainingScreenState extends State<SimTrainingScreen> {
  String? _goal;

  List<String> get _goals {
    final unique = simTrainingData.map((s) => s.goal).toSet().toList()..sort();
    return unique;
  }

  List<SimScenario> get _filtered =>
      _goal == null ? [] : simTrainingData.where((s) => s.goal == _goal).toList();

  void _openSuggest() {
    final subject = Uri.encodeComponent('FPV Sim Training Guide Content');
    final body = Uri.encodeComponent(
      'Practice goal: ${_goal ?? ''}\n'
      'Simulator or DLC: \n'
      'Link to store (optional): \n'
      'Specific map or maps related to the goal: \n'
      'Instructions for location or settings (optional): \n'
      'Recommended drone models (optional): ',
    );
    _launch('mailto:fpv@miguelppais.com?subject=$subject&body=$body');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _kBg,
      appBar: AppBar(
        backgroundColor: _kBg,
        surfaceTintColor: Colors.transparent,
        foregroundColor: _kText,
        elevation: 0,
        centerTitle: false,
        title: RichText(
          text: const TextSpan(
            children: [
              TextSpan(
                text: 'SIM TRAINING ',
                style: TextStyle(
                  color: _kText,
                  fontSize: 13,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 1.5,
                ),
              ),
              TextSpan(
                text: 'GUIDE',
                style: TextStyle(
                  color: _kAccent,
                  fontSize: 13,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 1.5,
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const _AboutScreen()),
            ),
            child: const Text(
              'ABOUT',
              style: TextStyle(
                color: _kDim,
                fontSize: 10,
                fontWeight: FontWeight.w700,
                letterSpacing: 2,
              ),
            ),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 4, 16, 48),
        children: [
          // Badge
          Center(
            child: Container(
              margin: const EdgeInsets.symmetric(vertical: 16),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
              decoration: BoxDecoration(
                color: _kAccentBright.withOpacity(0.08),
                borderRadius: BorderRadius.circular(100),
                border: Border.all(color: _kAccentBright.withOpacity(0.2)),
              ),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.sports_esports_rounded, color: _kAccent, size: 13),
                  SizedBox(width: 6),
                  Text(
                    'PC FPV REFERENCE 2026',
                    style: TextStyle(
                      color: _kAccent,
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 1.2,
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Intro
          const Padding(
            padding: EdgeInsets.fromLTRB(4, 0, 4, 20),
            child: Text(
              'Select your FPV practice goal and discover the simulators, maps and settings for your training.',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: _kMuted,
                fontSize: 14,
                height: 1.55,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),

          // Goal selector
          _GoalCard(
            goals: _goals,
            selectedGoal: _goal,
            onChanged: (g) => setState(() => _goal = g),
          ),
          const SizedBox(height: 24),

          // Results (animated on goal change)
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 320),
            switchInCurve: Curves.easeOut,
            switchOutCurve: Curves.easeIn,
            transitionBuilder: (child, animation) => FadeTransition(
              opacity: animation,
              child: SlideTransition(
                position: Tween<Offset>(
                  begin: const Offset(0, 0.04),
                  end: Offset.zero,
                ).animate(animation),
                child: child,
              ),
            ),
            child: _goal == null
                ? const SizedBox.shrink()
                : _ResultsList(
                    key: ValueKey(_goal),
                    scenarios: _filtered,
                    goal: _goal!,
                    onSuggest: _openSuggest,
                  ),
          ),
        ],
      ),
    );
  }
}

// ── Goal selector card ────────────────────────────────────────────────────────

class _GoalCard extends StatelessWidget {
  final List<String> goals;
  final String? selectedGoal;
  final ValueChanged<String?> onChanged;

  const _GoalCard({
    required this.goals,
    required this.selectedGoal,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: _kSurface,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: _kBorder),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.35),
            blurRadius: 24,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'I WANT TO PRACTICE...',
            style: TextStyle(
              color: _kDim,
              fontSize: 10,
              fontWeight: FontWeight.w700,
              letterSpacing: 2,
            ),
          ),
          const SizedBox(height: 12),
          Theme(
            data: Theme.of(context).copyWith(canvasColor: _kSurface),
            child: DropdownButton<String>(
              isExpanded: true,
              value: selectedGoal,
              hint: const Text(
                '— Choose a Goal —',
                style: TextStyle(
                  color: _kDim,
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                ),
              ),
              style: const TextStyle(
                color: _kText,
                fontSize: 15,
                fontWeight: FontWeight.w700,
              ),
              icon: const Icon(Icons.keyboard_arrow_down_rounded, color: _kDim),
              underline: Container(height: 1, color: _kBorder),
              dropdownColor: _kSurface,
              borderRadius: BorderRadius.circular(16),
              items: goals
                  .map((g) => DropdownMenuItem(value: g, child: Text(g)))
                  .toList(),
              onChanged: onChanged,
            ),
          ),
        ],
      ),
    );
  }
}

// ── Results list ──────────────────────────────────────────────────────────────

class _ResultsList extends StatelessWidget {
  final List<SimScenario> scenarios;
  final String goal;
  final VoidCallback onSuggest;

  const _ResultsList({
    super.key,
    required this.scenarios,
    required this.goal,
    required this.onSuggest,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Section header
        Padding(
          padding: const EdgeInsets.fromLTRB(4, 0, 4, 12),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  goal.toUpperCase(),
                  style: const TextStyle(
                    color: _kText,
                    fontSize: 15,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 0.5,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: _kSurface,
                  borderRadius: BorderRadius.circular(100),
                  border: Border.all(color: _kBorder),
                ),
                child: Text(
                  '${scenarios.length} SCENARIOS',
                  style: const TextStyle(
                    color: _kDim,
                    fontSize: 9,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 1.5,
                  ),
                ),
              ),
            ],
          ),
        ),

        // Scenario cards
        ...scenarios.map(
          (s) => Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: _ScenarioCard(scenario: s),
          ),
        ),

        // Suggest CTA
        Padding(
          padding: const EdgeInsets.fromLTRB(4, 20, 4, 4),
          child: GestureDetector(
            onTap: onSuggest,
            child: const Text.rich(
              TextSpan(
                style: TextStyle(
                  color: _kDim,
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.3,
                  height: 1.6,
                ),
                children: [
                  TextSpan(text: 'Think something is missing? '),
                  TextSpan(
                    text: 'Send a suggestion →',
                    style: TextStyle(
                      color: _kAccent,
                      decoration: TextDecoration.underline,
                      decorationColor: _kAccent,
                    ),
                  ),
                ],
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ),
      ],
    );
  }
}

// ── Scenario card ─────────────────────────────────────────────────────────────

class _ScenarioCard extends StatelessWidget {
  final SimScenario scenario;
  const _ScenarioCard({required this.scenario});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: _kSurface,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: _kBorder),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header: icon + sim name + category + store button
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: _kBg,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: _kBorder),
                ),
                child: Icon(scenario.icon, color: _kAccentBright, size: 22),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      scenario.sim,
                      style: const TextStyle(
                        color: _kText,
                        fontSize: 17,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 5),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: _kAccentBright.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        scenario.category.toUpperCase(),
                        style: const TextStyle(
                          color: _kAccent,
                          fontSize: 9,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 1.5,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              // Store button
              GestureDetector(
                onTap: () => _launch(scenario.link),
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: _kSurface2,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'STORE',
                        style: TextStyle(
                          color: _kText,
                          fontSize: 9,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 1.5,
                        ),
                      ),
                      SizedBox(width: 4),
                      Icon(Icons.open_in_new_rounded,
                          color: _kMuted, size: 11),
                    ],
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          // Map + Gear chips
          Row(
            children: [
              Expanded(
                child: _InfoChip(
                  label: 'MAP / LOCATION',
                  value: scenario.map,
                  valueColor: _kAccent.withOpacity(0.9),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _InfoChip(
                  label: 'RECOMMENDED GEAR',
                  value: scenario.drone,
                  valueColor: _kMuted,
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),

          // Tips
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Padding(
                padding: EdgeInsets.only(top: 1),
                child:
                    Icon(Icons.electric_bolt, color: _kDim, size: 12),
              ),
              const SizedBox(width: 6),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'STRATEGY & SETTINGS',
                      style: TextStyle(
                        color: _kDim,
                        fontSize: 9,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 1.5,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      scenario.tips,
                      style: const TextStyle(
                        color: _kMuted,
                        fontSize: 13,
                        height: 1.5,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ── Info chip (map / gear) ────────────────────────────────────────────────────

class _InfoChip extends StatelessWidget {
  final String label;
  final String value;
  final Color valueColor;

  const _InfoChip({
    required this.label,
    required this.value,
    required this.valueColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: _kBg.withOpacity(0.6),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: _kBorder.withOpacity(0.5)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              color: _kDim,
              fontSize: 8,
              fontWeight: FontWeight.w700,
              letterSpacing: 1.5,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              color: valueColor,
              fontSize: 12,
              fontWeight: FontWeight.w700,
              height: 1.3,
            ),
          ),
        ],
      ),
    );
  }
}

// ── About screen ──────────────────────────────────────────────────────────────

class _AboutScreen extends StatelessWidget {
  const _AboutScreen();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _kBg,
      appBar: AppBar(
        backgroundColor: _kBg,
        surfaceTintColor: Colors.transparent,
        foregroundColor: _kText,
        elevation: 0,
        title: const Text(
          'ABOUT & CONTACT',
          style: TextStyle(
            color: _kText,
            fontSize: 13,
            fontWeight: FontWeight.w900,
            letterSpacing: 1.5,
          ),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 48),
        children: [
          // Profile card
          Container(
            decoration: BoxDecoration(
              color: _kSurface,
              borderRadius: BorderRadius.circular(28),
              border: Border.all(color: _kBorder),
            ),
            padding: const EdgeInsets.all(28),
            child: Column(
              children: [
                // Profile photo — loads from live site; falls back to icon
                CircleAvatar(
                  radius: 52,
                  backgroundColor: _kSurface2,
                  backgroundImage: const NetworkImage(
                    'https://fpv.miguelppais.com/assets/Miguel_Pais_FPV_photo.jpg',
                  ),
                  onBackgroundImageError: (_, __) {},
                ),
                const SizedBox(height: 20),
                const Text(
                  'Miguel Pais',
                  style: TextStyle(
                    color: _kText,
                    fontSize: 26,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'FPV Pilot & Content Creator. This guide helps pilots bridge the gap between simulation and real-world high-stakes flight.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: _kMuted,
                    fontSize: 14,
                    height: 1.55,
                  ),
                ),
                const SizedBox(height: 24),
                // Email
                GestureDetector(
                  onTap: () => _launch('mailto:fpv@miguelppais.com'),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: const [
                      Icon(Icons.mail_outline_rounded,
                          color: _kDim, size: 16),
                      SizedBox(width: 8),
                      Text(
                        'fpv@miguelppais.com',
                        style: TextStyle(
                          color: _kMuted,
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                // Social buttons
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _SocialButton(
                      icon: Icons.music_note_rounded,
                      tooltip: 'TikTok',
                      onTap: () => _launch(
                          'https://www.tiktok.com/@miguelpais.fpv'),
                    ),
                    const SizedBox(width: 12),
                    _SocialButton(
                      icon: Icons.photo_camera_rounded,
                      tooltip: 'Instagram',
                      onTap: () => _launch(
                          'https://www.instagram.com/miguelpais.fpv'),
                    ),
                    const SizedBox(width: 12),
                    _SocialButton(
                      icon: Icons.play_circle_filled_rounded,
                      tooltip: 'YouTube',
                      onTap: () =>
                          _launch('https://youtube.com/@miguelpaisfpv'),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          // Disclaimer + License
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: _InfoCard(
                  title: 'DISCLAIMER',
                  body: 'The simulation database is under construction. New scenarios are added regularly as 2026 standards evolve.',
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _InfoCard(
                  title: 'LICENSE',
                  body: 'CC BY 4.0 — Free to share and adapt with attribution to Miguel Pais.',
                ),
              ),
            ],
          ),
          const SizedBox(height: 40),
          const Center(
            child: Text(
              '© 2026 MIGUEL PAIS',
              style: TextStyle(
                color: _kDim,
                fontSize: 9,
                fontWeight: FontWeight.w700,
                letterSpacing: 3,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SocialButton extends StatelessWidget {
  final IconData icon;
  final String tooltip;
  final VoidCallback onTap;

  const _SocialButton({
    required this.icon,
    required this.tooltip,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip,
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: _kBg,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: _kBorder),
          ),
          child: Icon(icon, color: _kMuted, size: 20),
        ),
      ),
    );
  }
}

class _InfoCard extends StatelessWidget {
  final String title;
  final String body;

  const _InfoCard({required this.title, required this.body});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _kSurface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: _kBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              color: _kText,
              fontSize: 9,
              fontWeight: FontWeight.w700,
              letterSpacing: 1.5,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            body,
            style: const TextStyle(
              color: _kDim,
              fontSize: 11,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }
}
