import 'dart:async'; // For Timer
import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart'; // For tick sound
import '../models/breathing_mode.dart';
import '../models/breathing_phase.dart';
import '../theme/app_colors.dart';

class BreathingScreen extends StatefulWidget {
  final BreathingMode mode;

  const BreathingScreen({super.key, required this.mode});

  @override
  State<BreathingScreen> createState() => _BreathingScreenState();
}

// NOTE: We added "with SingleTickerProviderStateMixin" here.
// This mixin gives our State class a "ticker" — a clock that ticks every frame
// (about 60 times per second). The AnimationController needs this clock to
// smoothly animate values over time.
//
// In React terms, imagine attaching a requestAnimationFrame loop to your component.
// The mixin does that automatically.
class _BreathingScreenState extends State<BreathingScreen>
    with SingleTickerProviderStateMixin {

  // ---- STATE VARIABLES ----
  BreathingPhase _currentPhase = BreathingPhase.inhale;
  int _secondsRemaining = 4;
  Timer? _timer;

  // ---- AUDIO PLAYERS ----
  // We use two separate players and keep them hot in memory (ReleaseMode.stop)
  // so there is absolutely ZERO delay when we want to play the sounds.
  final AudioPlayer _inhalePlayer = AudioPlayer()..setReleaseMode(ReleaseMode.stop);
  final AudioPlayer _exhalePlayer = AudioPlayer()..setReleaseMode(ReleaseMode.stop);

  // ---- GET READY COUNTDOWN ----
  // Like adding: const [isGettingReady, setIsGettingReady] = useState(true) in React.
  // While true, we show a "Get Ready" screen instead of the breathing UI.
  bool _isGettingReady = true;
  int _readyCountdown = 5;

  // ---- ANIMATION VARIABLES (NEW!) ----
  // AnimationController: produces values from 0.0 to 1.0 over a duration.
  // Think of it like a progress bar that smoothly fills up.
  //   0.0 = animation start (circle at minimum size)
  //   1.0 = animation end (circle at maximum size)
  // "late" means: "I promise to initialize this before using it" (in initState).
  late AnimationController _animationController;

  // Tween + Animation: maps the controller's 0.0→1.0 to actual pixel sizes.
  // Tween stands for "in-between" — it calculates the in-between values.
  //   0.0 → 100.0 (min circle diameter)
  //   1.0 → 250.0 (max circle diameter)
  late Animation<double> _sizeAnimation;

  // Circle size range
  static const double _minSize = 100.0;
  static const double _maxSize = 250.0;

  // Use the shared accent color from our theme
  static const Color _circleColor = AppColors.accent;

  @override
  void initState() {
    super.initState();

    // ---- PRELOAD AUDIO BUFFERS ----
    // By setting the sources now, the audio is loaded into memory instantly.
    if (widget.mode.name == 'Box Breathing' || widget.mode.name == 'Resonant Breathing') {
      _inhalePlayer.setSource(AssetSource('sounds/inhale_4seconds.mp3'));
      _exhalePlayer.setSource(AssetSource('sounds/exhale_4seconds.mp3'));
    } else if (widget.mode.name == '4-7-8 Breathing') {
      _inhalePlayer.setSource(AssetSource('sounds/inhale_4seconds.mp3'));
      _exhalePlayer.setSource(AssetSource('sounds/exhale_8seconds.mp3'));
    }

    // Create the AnimationController.
    // "vsync: this" connects it to the ticker from SingleTickerProviderStateMixin.
    // We set an initial duration — it will be updated for each phase.
    _animationController = AnimationController(
      vsync: this,
      duration: Duration(seconds: widget.mode.inhaleDuration),
    );

    // Create the Tween that maps 0.0→1.0 to minSize→maxSize.
    // .animate() connects it to our controller.
    // CurvedAnimation adds easing (like CSS ease-in-out) for a natural feel.
    _sizeAnimation = Tween<double>(begin: _minSize, end: _maxSize).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );

    // Start the "Get Ready" countdown instead of breathing immediately
    _startReadyCountdown();
  }

  @override
  void dispose() {
    _timer?.cancel();
    _animationController.dispose();
    _inhalePlayer.dispose();
    _exhalePlayer.dispose();
    super.dispose();
  }

  // ---- GET READY COUNTDOWN ----
  // Counts down from 5 to 1, then starts the actual breathing session.
  void _startReadyCountdown() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        if (_readyCountdown > 1) {
          _readyCountdown--;
        } else {
          // Ready countdown done! Switch to breathing mode.
          timer.cancel(); // Stop the ready timer
          _isGettingReady = false;
          _secondsRemaining = phaseDuration(_currentPhase, widget.mode);
          _startPhaseAnimation();
          _startTimer(); // Start the breathing timer
        }
      });
    });
  }

  // ---- AUDIO LOGIC ----
  void _onPhaseStart() {
    if (widget.mode.name == 'Box Breathing' ||
        widget.mode.name == '4-7-8 Breathing' ||
        widget.mode.name == 'Resonant Breathing') {
      if (_currentPhase == BreathingPhase.inhale) {
        // seek(0) rewinds the sound if it played before.
        // resume() instantly plays the preloaded buffer in memory.
        _inhalePlayer.seek(Duration.zero);
        _inhalePlayer.resume();
      } else if (_currentPhase == BreathingPhase.exhale) {
        _exhalePlayer.seek(Duration.zero);
        _exhalePlayer.resume();
      }
    }
  }

  // ---- NEW: Start the appropriate animation for the current phase ----
  void _startPhaseAnimation() {
    // Trigger sound at the start of the phase
    _onPhaseStart();

    switch (_currentPhase) {
      case BreathingPhase.inhale:
        // Expand: animate from current value → 1.0 (min → max size)
        _animationController.duration = Duration(
          seconds: widget.mode.inhaleDuration,
        );
        _animationController.forward(from: 0.0);
        // forward(from: 0.0) means: go from 0.0 to 1.0 (expand)
        break;

      case BreathingPhase.holdAfterInhale:
        // Stay big: stop the animation at max (1.0)
        _animationController.value = 1.0; // Snap to max
        // No animation — circle just stays at full size
        break;

      case BreathingPhase.exhale:
        // Shrink: animate from 1.0 → 0.0 (max → min size)
        _animationController.duration = Duration(
          seconds: widget.mode.exhaleDuration,
        );
        _animationController.reverse(from: 1.0);
        // reverse(from: 1.0) means: go from 1.0 back to 0.0 (shrink)
        break;

      case BreathingPhase.holdAfterExhale:
        // Stay small: stop the animation at min (0.0)
        _animationController.value = 0.0; // Snap to min
        // No animation — circle just stays at minimum size
        break;
    }
  }

  // ---- TIMER LOGIC (same as before, plus triggers animation on phase change) ----
  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        if (_secondsRemaining > 1) {
          _secondsRemaining--;
        } else {
          // Move to next phase (skip 0-duration phases)
          _currentPhase = nextPhase(_currentPhase);
          while (phaseDuration(_currentPhase, widget.mode) == 0) {
            _currentPhase = nextPhase(_currentPhase);
          }
          _secondsRemaining = phaseDuration(_currentPhase, widget.mode);

          // NEW: Start the animation for the new phase!
          _startPhaseAnimation();
        }
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Background & AppBar colors now come from the global theme in main.dart
      appBar: AppBar(
        title: Text(widget.mode.name),
      ),
      // Conditionally render either the "Get Ready" UI or the breathing UI.
      // In React, this is like: {isGettingReady ? <ReadyUI /> : <BreathingUI />}
      body: Center(
        child: _isGettingReady ? _buildReadyUI() : _buildBreathingUI(),
      ),
    );
  }

  // ---- GET READY UI ----
  Widget _buildReadyUI() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // Static circle at minimum size during countdown
        SizedBox(
          width: _maxSize,
          height: _maxSize,
          child: Stack(
            alignment: Alignment.center,
            children: [
              Container(
                width: _maxSize,
                height: _maxSize,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: _circleColor.withOpacity(0.25),
                    width: 2,
                  ),
                ),
              ),
              Container(
                width: _minSize,
                height: _minSize,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: _circleColor.withOpacity(0.85),
                  boxShadow: [
                    BoxShadow(
                      color: _circleColor.withOpacity(0.4),
                      blurRadius: _minSize * 0.3,
                      spreadRadius: _minSize * 0.05,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 40),

        // "Get Ready" label
        const Text(
          'Get Ready',
          style: TextStyle(
            fontSize: 32,
            fontWeight: FontWeight.bold,
            color: Colors.white,
            letterSpacing: 2,
          ),
        ),
        const SizedBox(height: 12),

        // Ready countdown number
        Text(
          '$_readyCountdown',
          style: TextStyle(
            fontSize: 52,
            fontWeight: FontWeight.w200,
            color: Colors.white.withOpacity(0.6),
          ),
        ),
        const SizedBox(height: 50),

        // Stop button (available even during countdown)
        ElevatedButton(
          onPressed: () {
            Navigator.pop(context);
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.redAccent.withOpacity(0.8),
            padding: const EdgeInsets.symmetric(horizontal: 36, vertical: 14),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(25),
            ),
          ),
          child: const Text(
            'Stop Session',
            style: TextStyle(color: Colors.white, fontSize: 16),
          ),
        ),
      ],
    );
  }

  // ---- BREATHING UI ----
  Widget _buildBreathingUI() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        SizedBox(
          width: _maxSize,
          height: _maxSize,
          child: Stack(
            alignment: Alignment.center,
            children: [
              Container(
                width: _maxSize,
                height: _maxSize,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: _circleColor.withOpacity(0.25),
                    width: 2,
                  ),
                ),
              ),
              AnimatedBuilder(
                animation: _animationController,
                builder: (context, child) {
                  final size = _sizeAnimation.value;
                  return Container(
                    width: size,
                    height: size,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: _circleColor.withOpacity(0.85),
                      boxShadow: [
                        BoxShadow(
                          color: _circleColor.withOpacity(0.4),
                          blurRadius: size * 0.3,
                          spreadRadius: size * 0.05,
                        ),
                      ],
                    ),
                  );
                },
              ),
            ],
          ),
        ),
        const SizedBox(height: 40),

        // Phase label
        Text(
          phaseLabel(_currentPhase),
          style: const TextStyle(
            fontSize: 32,
            fontWeight: FontWeight.bold,
            color: Colors.white,
            letterSpacing: 2,
          ),
        ),
        const SizedBox(height: 12),

        // Countdown
        Text(
          '$_secondsRemaining',
          style: TextStyle(
            fontSize: 52,
            fontWeight: FontWeight.w200,
            color: Colors.white.withOpacity(0.6),
          ),
        ),
        const SizedBox(height: 50),

        // Stop button
        ElevatedButton(
          onPressed: () {
            Navigator.pop(context);
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.redAccent.withOpacity(0.8),
            padding: const EdgeInsets.symmetric(horizontal: 36, vertical: 14),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(25),
            ),
          ),
          child: const Text(
            'Stop Session',
            style: TextStyle(color: Colors.white, fontSize: 16),
          ),
        ),
      ],
    );
  }
}
