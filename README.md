# QuietSpace – Grow Calm Moments


A minimalist, production-ready Android breathing app built with Flutter. Designed to help users reduce anxiety through guided visual breathing.

## Features

- **Guided Breathing**: Visual circle expansion and contraction synchronized with breathing phases (Inhale, Hold, Exhale).
- **Press & Hold Interaction**: User initiates and maintains control via touch, fostering a sense of grounding.
- **Calming Visuals**: Animated gradient backgrounds (Deep Navy → Indigo → Teal) and glassmorphism effects.
- **Haptic Feedback**: Gentle vibrations during phase transitions.
- **Clean Architecture**: Well-structured code separating presentation, core, and widgets.

## Getting Started

### Prerequisites

- Flutter SDK (Latest Stable)
- Android Studio / VS Code

### Installation

1.  **Initialize the project** (if not already done):
    Since the `android`, `ios`, and `web` folders were not generated, you need to recreate the Flutter scaffolding:

    ```bash
    flutter create .
    ```

    *Note: If prompted to overwrite `lib/`, choose **NO** or backup the `lib/` folder first.*

2.  **Install dependencies**:

    ```bash
    flutter pub get
    ```

3.  **Run the app**:

    ```bash
    flutter run
    ```

## Project Structure

```
lib/
├── core/
│   └── theme/           # App colors, theme data, typography
├── features/
│   └── breathing/
│       ├── presentation/
│       │   ├── breathing_screen.dart       # Main logic and state
│       │   └── widgets/
│       │       ├── animated_background.dart # Gradient background animation
│       │       └── breathing_circle.dart    # The breathing circle UI
└── main.dart            # Entry point
```

## Customization

- **Sound**: To add breathing sounds, add audio files to `assets/sounds/` and uncomment the sound playback logic in `BreathingScreen`.
- **Timing**: Adjust `_inhaleDuration`, `_holdDuration`, and `_exhaleDuration` in `BreathingScreen` to customize the breathing pattern.

## License

MIT
