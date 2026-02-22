/// BreathingMode defines a single breathing pattern.
///
/// Think of this like a TypeScript interface:
///   interface BreathingMode {
///     name: string;
///     inhaleDuration: number;  // in seconds
///     holdAfterInhaleDuration: number;
///     exhaleDuration: number;
///     holdAfterExhaleDuration: number;
///   }
class BreathingMode {
  final String name;
  final int inhaleDuration;       // seconds
  final int holdAfterInhale;      // seconds
  final int exhaleDuration;       // seconds
  final int holdAfterExhale;      // seconds

  // Constructor with named parameters (like destructured props in React)
  const BreathingMode({
    required this.name,
    required this.inhaleDuration,
    required this.holdAfterInhale,
    required this.exhaleDuration,
    required this.holdAfterExhale,
  });
}

// Pre-defined breathing modes (like exporting constants in React)

const boxBreathing = BreathingMode(
  name: 'Box Breathing',
  inhaleDuration: 4,
  holdAfterInhale: 4,
  exhaleDuration: 4,
  holdAfterExhale: 4,
);

// 4-7-8 Breathing: A relaxation technique.
// Inhale 4s → Hold 7s → Exhale 8s → (no hold) → Repeat
// holdAfterExhale is 0 because this mode skips that phase.
const relaxing478 = BreathingMode(
  name: '4-7-8 Breathing',
  inhaleDuration: 4,
  holdAfterInhale: 7,
  exhaleDuration: 8,
  holdAfterExhale: 0, // No hold after exhale in this mode!
);
