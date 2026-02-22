/// The four phases of a breathing cycle.
///
/// Think of this like a TypeScript enum:
///   enum BreathingPhase { Inhale, HoldAfterInhale, Exhale, HoldAfterExhale }
///
/// The state machine flows:
///   inhale → holdAfterInhale → exhale → holdAfterExhale → (repeat)
enum BreathingPhase {
  inhale,
  holdAfterInhale,
  exhale,
  holdAfterExhale,
}

/// Helper: get the display label for each phase.
/// In React, you might write a switch or a map object for this.
String phaseLabel(BreathingPhase phase) {
  switch (phase) {
    case BreathingPhase.inhale:
      return 'Inhale';
    case BreathingPhase.holdAfterInhale:
      return 'Hold';
    case BreathingPhase.exhale:
      return 'Exhale';
    case BreathingPhase.holdAfterExhale:
      return 'Hold';
  }
}

/// Helper: get the duration (in seconds) for a phase, given a BreathingMode.
/// We import BreathingMode to look up the correct duration for each phase.
int phaseDuration(BreathingPhase phase, dynamic mode) {
  switch (phase) {
    case BreathingPhase.inhale:
      return mode.inhaleDuration;
    case BreathingPhase.holdAfterInhale:
      return mode.holdAfterInhale;
    case BreathingPhase.exhale:
      return mode.exhaleDuration;
    case BreathingPhase.holdAfterExhale:
      return mode.holdAfterExhale;
  }
}

/// Helper: get the next phase in the cycle.
/// After holdAfterExhale, it wraps back to inhale (the loop!).
BreathingPhase nextPhase(BreathingPhase current) {
  switch (current) {
    case BreathingPhase.inhale:
      return BreathingPhase.holdAfterInhale;
    case BreathingPhase.holdAfterInhale:
      return BreathingPhase.exhale;
    case BreathingPhase.exhale:
      return BreathingPhase.holdAfterExhale;
    case BreathingPhase.holdAfterExhale:
      return BreathingPhase.inhale; // Loop back!
  }
}
