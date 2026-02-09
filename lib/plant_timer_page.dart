import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:confetti/confetti.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'progress_service.dart';

enum FlowerType { sunflower, rose, lotus }

class PlantTheme {
  final String name;
  final Color color;
  final String soundPath;
  final IconData icon;

  PlantTheme({
    required this.name,
    required this.color,
    required this.soundPath,
    required this.icon,
  });
}

class PlantTimerPage extends StatefulWidget {
  const PlantTimerPage({super.key});

  @override
  State<PlantTimerPage> createState() => _PlantTimerPageState();
}

class _PlantTimerPageState extends State<PlantTimerPage>
    with TickerProviderStateMixin, WidgetsBindingObserver {
  late AnimationController _growthController;
  late Animation<double> _growth;
  late AnimationController _rainController;
  late AnimationController _backgroundController;
  late AnimationController _seedFallController;

  AnimationController? _timerController;
  late ConfettiController _confettiController;
  final AudioPlayer _audioPlayer = AudioPlayer();

  int _hours = 0;
  int _minutes = 0;
  int _seconds = 0;
  int _totalSeconds = 0;
  int _currentSeconds = 0;
  bool _isRunning = false;
  bool _isSeeding = false;

  String _motivationalMessage = "";
  String _lastQuote = "";

  bool _milestone25 = false;
  bool _milestone50 = false;
  bool _milestone75 = false;
  bool _milestone100 = false;

  // Theme Logic
  int _currentThemeIndex = 0;
  final List<PlantTheme> _themes = [
    PlantTheme(
      name: "Quiet Night",
      color: const Color(0xFF1A1C19),
      soundPath:
          "https://raw.githubusercontent.com/atharvamahabal/QuietSpace/main/assets/sounds/night.mp3",
      icon: Icons.nightlight_round,
    ),
    PlantTheme(
      name: "Rainy Day",
      color: const Color(0xFF263238), // Dark Blue Grey
      soundPath:
          "https://raw.githubusercontent.com/atharvamahabal/QuietSpace/main/assets/sounds/rain.mp3",
      icon: Icons.water_drop,
    ),
    PlantTheme(
      name: "Sunny Morning",
      color: const Color(0xFFF57F17), // Darker Orange for contrast
      soundPath:
          "https://raw.githubusercontent.com/atharvamahabal/QuietSpace/main/assets/sounds/sunny.mp3",
      icon: Icons.wb_sunny,
    ),
    PlantTheme(
      name: "Ocean Breeze",
      color: const Color(0xFF006064), // Cyan 900
      soundPath:
          "https://raw.githubusercontent.com/atharvamahabal/QuietSpace/main/assets/sounds/beach.mp3",
      icon: Icons.waves,
    ),
  ];

  final List<String> _quotes = [
    "Small steps every day lead to big changes.",
    "Stay patient and trust your journey.",
    "Focus on progress, not perfection.",
    "Great things never came from comfort zones.",
    "Breathe in calm. Breathe out stress.",
    "Discipline is self-respect in action.",
    "Growth is quiet but powerful.",
    "The best time to plant a tree was 20 years ago. The second best time is now.",
    "Growth takes time. Be patient.",
    "Every flower blooms in its own time.",
    "Consistency is the key to growth.",
    "Don't watch the clock; do what it does. Keep going.",
    "Believe you can and you're halfway there.",
    "Your potential is endless.",
    "One day at a time.",
  ];

  FlowerType get _flowerType {
    if (_hours > 0) return FlowerType.lotus;
    if (_minutes > 0) return FlowerType.rose;
    return FlowerType.sunflower;
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);

    _growthController =
        AnimationController(vsync: this, duration: const Duration(seconds: 1));

    _growth = CurvedAnimation(
      parent: _growthController,
      curve: Curves.easeOutCubic,
    );

    _confettiController =
        ConfettiController(duration: const Duration(seconds: 3));

    _rainController =
        AnimationController(vsync: this, duration: const Duration(seconds: 2))
          ..repeat();

    _backgroundController =
        AnimationController(vsync: this, duration: const Duration(seconds: 10))
          ..repeat();

    _seedFallController = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 1500));

    _checkFirstRun();
    _checkRunningTimer();
  }

  void _checkFirstRun() async {
    final prefs = await SharedPreferences.getInstance();
    final hasShown = prefs.getBool('hasShownOnboarding') ?? false;

    if (!hasShown && mounted) {
      // Delay slightly to let the UI build
      Future.delayed(const Duration(seconds: 1), () {
        if (!mounted) return;
        _showOnboardingTooltip();
        prefs.setBool('hasShownOnboarding', true);
      });
    }
  }

  void _showOnboardingTooltip() {
    OverlayEntry? entry;

    entry = OverlayEntry(
      builder: (context) => Stack(
        children: [
          // Invisible dismiss layer
          Positioned.fill(
            child: GestureDetector(
              onTap: () {
                entry?.remove();
              },
              behavior: HitTestBehavior.translucent,
              child: Container(color: Colors.transparent),
            ),
          ),
          Positioned(
            top: MediaQuery.of(context).padding.top + kToolbarHeight - 10,
            right: 10,
            child: Material(
              color: Colors.transparent,
              child: Container(
                width: 200,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.3),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    // Arrow pointing up
                    const Icon(Icons.arrow_upward,
                        size: 20, color: Colors.black),
                    const SizedBox(height: 4),
                    const Text(
                      "Change View",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      "🔊 Volume Up for Sound Effects",
                      textAlign: TextAlign.right,
                      style: TextStyle(
                        color: Colors.black87,
                        fontSize: 12,
                      ),
                    ),
                    const SizedBox(height: 8),
                    GestureDetector(
                      onTap: () {
                        entry?.remove();
                      },
                      child: const Text(
                        "Got it!",
                        style: TextStyle(
                          color: Colors.blue,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );

    Overlay.of(context).insert(entry);

    // Auto dismiss after 6 seconds
    Future.delayed(const Duration(seconds: 6), () {
      if (entry != null && entry.mounted) {
        entry.remove();
      }
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _growthController.dispose();
    _timerController?.dispose();
    _rainController.dispose();
    _backgroundController.dispose();
    _confettiController.dispose();
    _seedFallController.dispose();
    _audioPlayer.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused) {
      if (_isRunning) {
        _saveTimerState();
      }
    } else if (state == AppLifecycleState.resumed) {
      _checkRunningTimer();
    }
  }

  void _saveTimerState() async {
    final prefs = await SharedPreferences.getInstance();
    if (_isRunning) {
      final targetTime = DateTime.now().add(Duration(seconds: _currentSeconds));
      prefs.setInt('target_time', targetTime.millisecondsSinceEpoch);
      prefs.setInt('total_duration', _totalSeconds);
      prefs.setBool('is_timer_running', true);
      prefs.setInt('current_theme_index', _currentThemeIndex);
    } else {
      prefs.setBool('is_timer_running', false);
    }
  }

  void _checkRunningTimer() async {
    final prefs = await SharedPreferences.getInstance();
    final isRunning = prefs.getBool('is_timer_running') ?? false;

    if (isRunning) {
      final targetTimeMs = prefs.getInt('target_time') ?? 0;
      final totalDuration = prefs.getInt('total_duration') ?? 0;
      final themeIndex = prefs.getInt('current_theme_index') ?? 0;

      final targetTime = DateTime.fromMillisecondsSinceEpoch(targetTimeMs);
      final now = DateTime.now();

      if (now.isBefore(targetTime)) {
        final remaining = targetTime.difference(now).inSeconds;
        setState(() {
          _currentThemeIndex = themeIndex;
          _totalSeconds = totalDuration;
          _currentSeconds = remaining;
          _isRunning = true;
          _motivationalMessage = "Welcome back! Keep focusing...";
        });

        // Resume audio
        _playThemeSound();

        // Calculate progress
        double progress = 1.0 - (remaining / totalDuration);

        // Setup controllers
        _growthController.duration = Duration(seconds: totalDuration);
        _growthController.forward(from: progress);

        _timerController?.dispose();
        _timerController = AnimationController(
          vsync: this,
          duration: Duration(seconds: totalDuration),
        );
        _timerController!.reverse(from: 1.0 - progress);
        _setupTimerListener();
      } else {
        // Timer finished
        setState(() {
          _isRunning = false;
          _currentSeconds = 0;
          _motivationalMessage = "Timer completed while you were away!";
        });
        prefs.setBool('is_timer_running', false);
        _growthController.value = 1.0;
        _milestone100 = true;
        _confettiController.play();
      }
    }
  }

  Future<void> _minimizeApp() async {
    const channel = MethodChannel('com.mindgarden.quietspace/app_controls');
    try {
      await channel.invokeMethod('minimizeApp');
    } on PlatformException catch (e) {
      debugPrint("Failed to minimize app: '${e.message}'.");
    }
  }

  void _startTimer() {
    final duration = (_hours * 3600) + (_minutes * 60) + _seconds;
    if (duration == 0) return;

    // Trigger Seed Animation
    setState(() {
      _isSeeding = true;
    });

    _seedFallController.forward(from: 0).then((_) {
      setState(() {
        _isSeeding = false;
        _startGrowthCycle(duration);
      });
    });
  }

  void _startGrowthCycle(int duration) {
    setState(() {
      _totalSeconds = duration;
      _currentSeconds = duration;
      _isRunning = true;
      _motivationalMessage = "Focus & breathe…";
      _milestone25 = _milestone50 = _milestone75 = _milestone100 = false;
    });

    // Start ambient music based on current theme
    _playThemeSound();

    _growthController.duration = Duration(seconds: duration);
    _growthController.forward(from: 0);

    _timerController?.dispose();
    _timerController = AnimationController(
      vsync: this,
      duration: Duration(seconds: duration),
    );

    _timerController!.reverse(from: 1.0);
    _setupTimerListener();
  }

  void _setupTimerListener() {
    _timerController!.addListener(() {
      setState(() {
        _currentSeconds =
            max(0, (_timerController!.value * _totalSeconds).round());

        final progress = 1.0 - _timerController!.value;

        if (progress >= 1.0 && !_milestone100) {
          _milestone100 = true;
          _confettiController.play();
          _setQuote("100%");
        } else if (progress >= 0.75 && !_milestone75) {
          _milestone75 = true;
          _setQuote("75%");
        } else if (progress >= 0.50 && !_milestone50) {
          _milestone50 = true;
          _setQuote("50%");
        } else if (progress >= 0.25 && !_milestone25) {
          _milestone25 = true;
          _setQuote("25%");
        }
      });
    });

    _timerController!.addStatusListener((status) {
      if (status == AnimationStatus.dismissed) {
        _audioPlayer.stop(); // Stop audio when timer finishes

        // Save progress
        ProgressService.saveSession(_totalSeconds);

        setState(() {
          _isRunning = false;
          _currentSeconds = 0;
          // Keep the flower and time settings visible after completion
          // _hours = 0;
          // _minutes = 0;
          // _seconds = 0;

          // Ensure flower stays fully grown
          _growthController.stop();
          _growthController.value = 1.0;
          // _growthController.reset(); // COMMENTED OUT TO PREVENT DISAPPEARING

          // Reset milestone flags
          _milestone25 = false;
          _milestone50 = false;
          _milestone75 = false;
          _milestone100 = false;
          // _motivationalMessage = ""; // Keep the final quote visible
        });
      }
    });
  }

  void _playThemeSound() async {
    _audioPlayer.setReleaseMode(ReleaseMode.loop);
    try {
      await _audioPlayer.stop(); // Stop any current sound

      final soundPath = _themes[_currentThemeIndex].soundPath;

      if (soundPath.startsWith("http")) {
        // Play from URL (GitHub Raw, Internet Archive, etc.)
        debugPrint("Playing audio from URL: $soundPath");
        await _audioPlayer.play(UrlSource(soundPath));
      } else {
        // Play from local assets
        await _audioPlayer.play(AssetSource(soundPath));
      }
    } catch (e) {
      debugPrint("Error playing audio: $e");
    }
  }

  void _setQuote(String prefix) {
    String q;
    do {
      q = _quotes[Random().nextInt(_quotes.length)];
    } while (q == _lastQuote);

    _lastQuote = q;
    _motivationalMessage = "$prefix complete\n\n$q";
  }

  String _formatTime(int t) {
    final h = t ~/ 3600;
    final m = (t % 3600) ~/ 60;
    final s = t % 60;
    return "${h.toString().padLeft(2, '0')}:${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}";
  }

  void _showThemePicker() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.grey[900],
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                "Choose Atmosphere",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 20),
              SizedBox(
                height: 120,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: _themes.length,
                  itemBuilder: (context, index) {
                    final theme = _themes[index];
                    final isSelected = index == _currentThemeIndex;
                    return GestureDetector(
                      onTap: () {
                        setState(() {
                          _currentThemeIndex = index;
                        });
                        if (_isRunning) {
                          _playThemeSound();
                        }
                        Navigator.pop(context);
                      },
                      child: Container(
                        width: 100,
                        margin: const EdgeInsets.only(right: 15),
                        decoration: BoxDecoration(
                          color: theme.color,
                          borderRadius: BorderRadius.circular(15),
                          border: isSelected
                              ? Border.all(color: Colors.white, width: 3)
                              : null,
                          boxShadow: [
                            if (isSelected)
                              BoxShadow(
                                color: theme.color.withOpacity(0.6),
                                blurRadius: 10,
                                spreadRadius: 2,
                              ),
                          ],
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(theme.icon, color: Colors.white, size: 30),
                            const SizedBox(height: 10),
                            Text(
                              theme.name,
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 10),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvoked: (didPop) {
        if (didPop) return;
        _handlePopInvoked();
      },
      child: Scaffold(
        backgroundColor: _themes[_currentThemeIndex].color,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () => Navigator.maybePop(context),
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.style, color: Colors.white),
              tooltip: 'Change Theme',
              onPressed: _showThemePicker,
            ),
          ],
        ),
        body: Stack(
          children: [
            // Moon Animation (Quiet Night)
            if (_themes[_currentThemeIndex].name == "Quiet Night")
              Positioned.fill(
                child: CustomPaint(
                  painter: MoonPainter(),
                ),
              ),

            // Background Animation (Sun or Beach)
            if (_themes[_currentThemeIndex].name == "Sunny Morning")
              Positioned.fill(
                child: AnimatedBuilder(
                  animation: _backgroundController,
                  builder: (context, child) {
                    return CustomPaint(
                      painter: SunPainter(
                        animationValue: _backgroundController.value,
                      ),
                    );
                  },
                ),
              ),
            if (_themes[_currentThemeIndex].name == "Ocean Breeze")
              Positioned.fill(
                child: AnimatedBuilder(
                  animation: _backgroundController,
                  builder: (context, child) {
                    return CustomPaint(
                      painter: BeachPainter(
                        animationValue: _backgroundController.value,
                      ),
                    );
                  },
                ),
              ),

            // Rain Animation (only for Rainy Day theme)
            if (_themes[_currentThemeIndex].name == "Rainy Day")
              Positioned.fill(
                child: IgnorePointer(
                  child: AnimatedBuilder(
                    animation: _rainController,
                    builder: (context, child) {
                      return CustomPaint(
                        painter: RainPainter(
                          animationValue: _rainController.value,
                        ),
                      );
                    },
                  ),
                ),
              ),

            SafeArea(
              child: Column(
                children: [
                  const SizedBox(height: 10),
                  Text(
                    _isRunning ? "Focus & Grow" : "Set Timer",
                    style: const TextStyle(color: Colors.white, fontSize: 24),
                  ),
                  Expanded(
                    child: Stack(
                      alignment: Alignment.bottomCenter,
                      children: [
                        // Motivational Message
                        if (_motivationalMessage.isNotEmpty)
                          Positioned(
                            top: 20,
                            child: ConstrainedBox(
                              constraints: BoxConstraints(
                                maxWidth:
                                    MediaQuery.of(context).size.width - 40,
                                maxHeight: 120,
                              ),
                              child: SingleChildScrollView(
                                child: Container(
                                  padding: const EdgeInsets.all(14),
                                  decoration: BoxDecoration(
                                    color: Colors.black54,
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                  child: Text(
                                    _motivationalMessage,
                                    textAlign: TextAlign.center,
                                    style: const TextStyle(
                                      color: Colors.white,
                                      height: 1.4,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),

                        // Plant Animation
                        // Use LayoutBuilder to ensure painter gets correct size
                        LayoutBuilder(builder: (context, constraints) {
                          return Container(
                            width: constraints.maxWidth,
                            height: constraints.maxHeight,
                            alignment: Alignment.bottomCenter,
                            child: AnimatedBuilder(
                              animation: _growth,
                              builder: (_, __) {
                                return CustomPaint(
                                  // Use the full available size
                                  size: Size(constraints.maxWidth,
                                      constraints.maxHeight),
                                  painter: PlantPainter(
                                    growth: _growth.value,
                                    type: _flowerType,
                                  ),
                                );
                              },
                            ),
                          );
                        }),

                        // Falling Seed Animation
                        if (_isSeeding)
                          Positioned.fill(
                            child: AnimatedBuilder(
                              animation: _seedFallController,
                              builder: (context, child) {
                                return CustomPaint(
                                  painter: SeedPainter(
                                      progress: _seedFallController.value),
                                );
                              },
                            ),
                          ),
                      ],
                    ),
                  ),

                  // Bottom Control Panel
                  Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.3), // Transparent panel
                      borderRadius:
                          const BorderRadius.vertical(top: Radius.circular(30)),
                    ),
                    child: Column(
                      children: [
                        if (_isRunning)
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              _buildTimerItem(
                                  _formatTimePart(_currentSeconds, 0), "HH"),
                              const Text(":",
                                  style: TextStyle(
                                      color: Colors.white, fontSize: 42)),
                              _buildTimerItem(
                                  _formatTimePart(_currentSeconds, 1), "MM"),
                              const Text(":",
                                  style: TextStyle(
                                      color: Colors.white, fontSize: 42)),
                              _buildTimerItem(
                                  _formatTimePart(_currentSeconds, 2), "SS"),
                            ],
                          )
                        else
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              _timePicker("HOURS", _hours, (val) {
                                setState(() => _hours = val);
                              }),
                              _timePicker("MINUTES", _minutes, (val) {
                                setState(() => _minutes = val);
                              }),
                              _timePicker("SECONDS", _seconds, (val) {
                                setState(() => _seconds = val);
                              }),
                            ],
                          ),
                        const SizedBox(height: 30),

                        // Start/Stop Button
                        SizedBox(
                          width: double.infinity,
                          height: 55,
                          child: ElevatedButton(
                            onPressed: _isRunning ? _stopTimer : _startTimer,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: _isRunning
                                  ? Colors.redAccent
                                  : Colors.greenAccent[700],
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(15),
                              ),
                              elevation: 5,
                            ),
                            child: Text(
                              _isRunning ? "Give Up" : "Plant Seed",
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _handlePopInvoked() {
    if (_isRunning) {
      _showExitDialog();
    } else {
      Navigator.of(context).pop();
    }
  }

  void _showExitDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Timer is Running"),
          content: const Text(
              "Do you want to stop the timer or keep it running in the background?"),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close dialog
                _stopTimer();
                Navigator.of(context).pop(); // Close page
              },
              child: const Text("Stop & Exit",
                  style: TextStyle(color: Colors.red)),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close dialog
                _minimizeApp();
              },
              child: const Text("Run in Background"),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text("Cancel"),
            ),
          ],
        );
      },
    );
  }

  void _stopTimer() {
    _audioPlayer.stop(); // Stop audio when manually stopped
    _timerController?.stop();
    _growthController.stop();
    setState(() {
      _isRunning = false;
      _currentSeconds = 0;
      _hours = 0;
      _minutes = 0;
      _seconds = 0;
      _growthController.reset();
      // Reset milestone flags
      _milestone25 = false;
      _milestone50 = false;
      _milestone75 = false;
      _milestone100 = false;
      _motivationalMessage = "";
    });
  }

  String _formatTimePart(int t, int part) {
    final h = t ~/ 3600;
    final m = (t % 3600) ~/ 60;
    final s = t % 60;
    if (part == 0) return h.toString().padLeft(2, '0');
    if (part == 1) return m.toString().padLeft(2, '0');
    return s.toString().padLeft(2, '0');
  }

  Widget _buildTimerItem(String value, String label) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.1),
            borderRadius: BorderRadius.circular(4),
          ),
          child: Text(
            label,
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 12,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 42,
            fontFamily: "monospace",
          ),
        ),
      ],
    );
  }

  Widget _timePicker(String label, int value, Function(int) onChanged) {
    return Column(
      children: [
        Text(label,
            style: const TextStyle(
                color: Colors.white70,
                fontSize: 12,
                fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        SizedBox(
          width: 70,
          height: 100,
          child: Stack(
            alignment: Alignment.center,
            children: [
              // Highlight Block
              Container(
                width: 60,
                height: 40,
                decoration: BoxDecoration(
                  color: Colors.blueAccent.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.blueAccent, width: 2),
                ),
              ),
              // Wheel
              ListWheelScrollView.useDelegate(
                controller: FixedExtentScrollController(initialItem: value),
                itemExtent: 40,
                perspective: 0.005,
                diameterRatio: 1.2,
                physics: const FixedExtentScrollPhysics(),
                onSelectedItemChanged: onChanged,
                childDelegate: ListWheelChildBuilderDelegate(
                  childCount: 60,
                  builder: (_, i) => Center(
                    child: Text(
                      i.toString().padLeft(2, '0'),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class PlantPainter extends CustomPainter {
  final double growth;
  final FlowerType type;

  PlantPainter({required this.growth, required this.type});

  @override
  void paint(Canvas canvas, Size size) {
    final centerX = size.width / 2;
    final bottomY = size.height - 30;
    final stemHeight = 160 * growth;

    // Calculate the actual start of the plant stem (top of pot/soil)
    // Pot height is 70, so top is bottomY - 70. Soil is slightly curved above that.
    final soilLevelY = bottomY - 70;

    // Plant grows UP from soilLevelY
    // If growth is 0, plantStartY is at soilLevelY
    // As growth increases, plantStartY moves up
    final plantStartY = soilLevelY - stemHeight;

    // 1. Draw Soil/Pot/Pond Base
    if (type == FlowerType.lotus) {
      // 3D Pond for Lotus
      // 1. Bank/Soil edge (Darker)
      Paint soilPaint = Paint()
        ..color = const Color(0xFF3E2723); // Dark soil/mud
      canvas.drawOval(
        Rect.fromCenter(
            center: Offset(centerX, bottomY + 5), width: 230, height: 70),
        soilPaint,
      );

      // 2. Water (Gradient for depth)
      Paint waterPaint = Paint()
        ..shader = RadialGradient(
          colors: [
            const Color(0xFF4FC3F7), // Light Blue (Center)
            const Color(0xFF0288D1), // Deep Blue (Edge)
          ],
          radius: 0.8,
          center: Alignment.center,
        ).createShader(Rect.fromCenter(
            center: Offset(centerX, bottomY), width: 220, height: 60));

      canvas.drawOval(
        Rect.fromCenter(
            center: Offset(centerX, bottomY), width: 220, height: 60),
        waterPaint,
      );

      // 3. Ripples/Reflections
      Paint ripplePaint = Paint()
        ..color = Colors.white.withOpacity(0.2)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2;

      canvas.drawOval(
        Rect.fromCenter(
            center: Offset(centerX, bottomY), width: 180, height: 45),
        ripplePaint,
      );
    } else {
      _drawPot(canvas, centerX, bottomY);
    }

    if (growth <= 0) return;

    // 2. Draw Stem
    Paint stemPaint = Paint()
      ..color = const Color(0xFF2E7D32) // Darker green
      ..strokeWidth = 6
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    if (type != FlowerType.lotus) {
      // Draw stem from inside the pot (soil level) upwards
      canvas.drawLine(
        Offset(centerX, soilLevelY + 10), // Start slightly inside the pot
        Offset(centerX, plantStartY),
        stemPaint,
      );

      if (type == FlowerType.rose) {
        _drawThorns(canvas, centerX, soilLevelY, stemHeight, growth);
      }
    } else {
      // Lotus stem from water
      canvas.drawLine(
        Offset(centerX, bottomY + 10),
        Offset(centerX, plantStartY), // Use the new calculated plantStartY
        stemPaint,
      );
    }

    // 3. Grow Leaves
    if (growth > 0.3) {
      double leafGrowth = ((growth - 0.3) / 0.7).clamp(0.0, 1.0);

      if (type == FlowerType.lotus) {
        // Lily Pads scattered on the pond
        _drawLilyPad(canvas, centerX - 60, bottomY + 15, leafGrowth * 0.9);
        _drawLilyPad(canvas, centerX + 55, bottomY + 20, leafGrowth * 0.8);

        if (growth > 0.4) {
          // Foreground pad
          _drawLilyPad(canvas, centerX - 20, bottomY + 35, leafGrowth * 1.0);
        }
        if (growth > 0.6) {
          // Background pad
          _drawLilyPad(canvas, centerX + 30, bottomY + 5, leafGrowth * 0.7);
        }
      } else if (type == FlowerType.rose) {
        // More leaves for Rose - Dense foliage
        // Alternating sides, getting smaller towards top
        // Use plantStartY which is the TOP of the stem
        // stemHeight is the total length
        // Base of stem is at soilLevelY

        // Leaf positions should be relative to stem growth
        // 0.9 means 90% up the stem from the bottom
        double base = soilLevelY;

        _drawLeaf(canvas, centerX, base - (stemHeight * 0.9), 1,
            leafGrowth * 0.6, type);
        if (growth > 0.25) {
          _drawLeaf(canvas, centerX, base - (stemHeight * 0.75), -1,
              leafGrowth * 0.7, type);
        }
        if (growth > 0.4) {
          _drawLeaf(canvas, centerX, base - (stemHeight * 0.6), 1,
              leafGrowth * 0.8, type);
        }
        if (growth > 0.5) {
          _drawLeaf(canvas, centerX, base - (stemHeight * 0.5), -1,
              leafGrowth * 0.85, type);
        }
        if (growth > 0.6) {
          _drawLeaf(canvas, centerX, base - (stemHeight * 0.4), 1,
              leafGrowth * 0.9, type);
        }
        if (growth > 0.7) {
          _drawLeaf(canvas, centerX, base - (stemHeight * 0.3), -1,
              leafGrowth * 0.9, type);
        }
        if (growth > 0.8) {
          _drawLeaf(
              canvas, centerX, base - (stemHeight * 0.2), 1, leafGrowth, type);
          _drawLeaf(canvas, centerX, base - (stemHeight * 0.15), -0.5,
              leafGrowth * 0.8, type);
        }
      } else {
        // Sunflower leaves
        double base = soilLevelY;
        _drawLeaf(canvas, centerX, base - (stemHeight * 0.6), 1,
            leafGrowth * 0.8, type);
        _drawLeaf(
            canvas, centerX, base - (stemHeight * 0.4), -1, leafGrowth, type);
      }
    }

    // 4. Draw Flower Head
    if (growth > 0.85) {
      double bloom = ((growth - 0.85) / 0.15).clamp(0.0, 1.0);

      if (type == FlowerType.rose) {
        _drawRose(canvas, centerX, plantStartY, bloom);
      } else if (type == FlowerType.sunflower) {
        _drawSunflower(canvas, centerX, plantStartY, bloom);
      } else if (type == FlowerType.lotus) {
        // Lotus plantStartY might need adjustment as it uses bottomY in original code
        // But for Lotus, the stem starts deeper.
        // Let's keep Lotus logic relative to its water level if needed, but
        // the original code used plantStartY = bottomY - stemHeight.
        // For Lotus, bottomY is water surface.
        // So plantStartY is correct (height above water).
        _drawLotus(canvas, centerX, bottomY - stemHeight, bloom);
      }
    }
  }

  void _drawPot(Canvas canvas, double centerX, double bottomY) {
    double potWidthTop = 80;
    double potWidthBottom = 50;
    double potHeight = 70;
    double rimHeight = 15;
    double rimOverhang = 8;

    Paint potPaint = Paint()
      ..color = const Color(0xFFE65100); // Darker Orange/Terracotta

    // 1. Pot Body
    Path potBody = Path();
    potBody.moveTo(centerX - potWidthTop / 2, bottomY - potHeight); // Top Left
    potBody.lineTo(centerX + potWidthTop / 2, bottomY - potHeight); // Top Right
    // Slightly curved sides for realistic look
    potBody.quadraticBezierTo(
        centerX + potWidthTop / 2 + 2,
        bottomY - potHeight / 2,
        centerX + potWidthBottom / 2,
        bottomY); // Bottom Right
    // Curved bottom
    potBody.quadraticBezierTo(centerX, bottomY + 5,
        centerX - potWidthBottom / 2, bottomY); // Bottom Left
    potBody.quadraticBezierTo(
        centerX - potWidthTop / 2 - 2,
        bottomY - potHeight / 2,
        centerX - potWidthTop / 2,
        bottomY - potHeight); // Back to Top Left
    potBody.close();
    canvas.drawPath(potBody, potPaint);

    // 2. Pot Rim
    potPaint.color = const Color(0xFFEF6C00); // Slightly lighter for rim
    double rimTopY = bottomY - potHeight;
    double rimBottomY = rimTopY + rimHeight;
    double rimWidth = potWidthTop + (rimOverhang * 2);

    Path rimPath = Path();
    rimPath.moveTo(centerX - rimWidth / 2, rimTopY);
    rimPath.lineTo(centerX + rimWidth / 2, rimTopY);
    rimPath.lineTo(
        centerX + rimWidth / 2 - 2, rimBottomY); // Taper rim slightly
    rimPath.lineTo(centerX - rimWidth / 2 + 2, rimBottomY);
    rimPath.close();
    canvas.drawPath(rimPath, potPaint);

    // 3. Soil Mound
    Paint soilPaint = Paint()..color = const Color(0xFF5D4037);
    canvas.drawArc(
      Rect.fromCenter(
          center: Offset(centerX, rimTopY),
          width: potWidthTop - 10,
          height: 20),
      pi,
      pi,
      true,
      soilPaint,
    );
  }

  void _drawThorns(Canvas canvas, double centerX, double bottomY,
      double stemHeight, double growth) {
    Paint thornPaint = Paint()..color = const Color(0xFF1B5E20);
    // Simple thorns along the stem
    for (double i = 0.2; i < growth; i += 0.2) {
      // bottomY passed here is actually soilLevelY from the caller
      double y = bottomY - (stemHeight * i);
      double x = centerX + (i * 10 - 5); // Approximate position

      Path thorn = Path();
      // Use i * 5 to get 1, 2, 3... for alternating sides
      if ((i * 5).round() % 2 == 0) {
        // Right side thorn
        thorn.moveTo(x + 3, y);
        thorn.lineTo(x + 10, y - 5);
        thorn.lineTo(x + 3, y - 8);
      } else {
        // Left side thorn
        thorn.moveTo(x - 3, y);
        thorn.lineTo(x - 10, y - 5);
        thorn.lineTo(x - 3, y - 8);
      }
      thorn.close();
      canvas.drawPath(thorn, thornPaint);
    }
  }

  void _drawLeaf(Canvas canvas, double x, double y, double direction,
      double scale, FlowerType type) {
    if (scale <= 0) return;

    Paint leafPaint = Paint()
      ..color = type == FlowerType.rose
          ? const Color(0xFF2E7D32)
          : const Color(0xFF4CAF50);

    canvas.save();
    canvas.translate(x, y);
    canvas.scale(scale * direction, scale);

    Path leafPath = Path();
    leafPath.moveTo(0, 0);

    if (type == FlowerType.rose) {
      // Rose leaf (more serrated/pointed)
      leafPath.quadraticBezierTo(10, -5, 20, -20);
      leafPath.quadraticBezierTo(10, -15, 0, 0);
    } else {
      // Standard/Sunflower leaf
      leafPath.quadraticBezierTo(20, -10, 30, -30);
      leafPath.quadraticBezierTo(10, -20, 0, 0);
    }

    canvas.drawPath(leafPath, leafPaint);
    canvas.restore();
  }

  void _drawLilyPad(Canvas canvas, double x, double y, double scale) {
    if (scale <= 0) return;
    Paint padPaint = Paint()..color = const Color(0xFF43A047);

    canvas.save();
    canvas.translate(x, y);
    canvas.scale(scale);

    // Draw lily pad with a notch
    Path pad = Path();
    pad.addOval(Rect.fromCircle(center: Offset.zero, radius: 25));
    // Cutout
    pad.moveTo(0, 0);
    pad.lineTo(25, -5);
    pad.lineTo(25, 5);
    pad.close();

    canvas.drawPath(pad, padPaint);

    // Veins
    Paint veinPaint = Paint()
      ..color = const Color(0xFF2E7D32)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;
    canvas.drawLine(const Offset(0, 0), const Offset(0, -20), veinPaint);
    canvas.drawLine(const Offset(0, 0), const Offset(-18, -10), veinPaint);
    canvas.drawLine(const Offset(0, 0), const Offset(-18, 10), veinPaint);
    canvas.restore();
  }

  void _drawSunflower(Canvas canvas, double x, double y, double bloom) {
    Paint paint = Paint();

    // Petals
    paint.color = const Color(0xFFFFEB3B);
    int petalCount = 20;
    double petalLen = 35 * bloom;
    double petalWidth = 8 * bloom;

    for (int i = 0; i < petalCount; i++) {
      double angle = (i * 2 * pi) / petalCount;
      canvas.save();
      canvas.translate(x, y);
      canvas.rotate(angle);
      Path petal = Path();
      petal.moveTo(0, 0);
      petal.quadraticBezierTo(petalWidth, petalLen / 2, 0, petalLen);
      petal.quadraticBezierTo(-petalWidth, petalLen / 2, 0, 0);
      canvas.drawPath(petal, paint);
      canvas.restore();
    }

    // Center
    paint.color = const Color(0xFF3E2723);
    canvas.drawCircle(Offset(x, y), 12 * bloom, paint);
    paint.color = const Color(0xFF5D4037);
    canvas.drawCircle(Offset(x, y), 6 * bloom, paint);
  }

  void _drawRose(Canvas canvas, double x, double y, double bloom) {
    // 1. Sepals (Green leaves under the bloom)
    Paint sepalPaint = Paint()
      ..color = const Color(0xFF2E7D32)
      ..style = PaintingStyle.fill;

    for (int i = 0; i < 5; i++) {
      double angle = (i * 72 + 36) * pi / 180;
      double len = 28 * bloom;

      canvas.save();
      canvas.translate(x, y);
      canvas.rotate(angle);

      Path sepal = Path();
      sepal.moveTo(0, 0);
      sepal.quadraticBezierTo(8, len * 0.4, 0, len);
      sepal.quadraticBezierTo(-8, len * 0.4, 0, 0);

      canvas.drawPath(sepal, sepalPaint);
      canvas.restore();
    }

    // 2. Petals (Draw from Outside In for proper stacking)
    // Rose Red Palette
    List<Color> colors = [
      const Color(0xFFB71C1C), // Deepest Red (Outer Guard)
      const Color(0xFFC62828),
      const Color(0xFFD32F2F),
      const Color(0xFFE53935),
      const Color(0xFFF44336), // Brightest Red (Center)
    ];

    Paint strokePaint = Paint()
      ..color = const Color(0xFF5D0000) // Very dark red outline
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.5;

    // Layer 1: Outer Guard Petals (Largest)
    _drawRoseLayer(canvas, x, y, bloom, 5, 32, colors[0], strokePaint, 0);

    // Layer 2: Large Petals
    _drawRoseLayer(canvas, x, y, bloom, 6, 26, colors[1], strokePaint, pi / 6);

    // Layer 3: Medium Petals
    _drawRoseLayer(canvas, x, y, bloom, 5, 20, colors[2], strokePaint, 0);

    // Layer 4: Inner Petals
    _drawRoseLayer(canvas, x, y, bloom, 4, 14, colors[3], strokePaint, pi / 4);

    // Center Bud (Spiral-ish)
    Paint centerPaint = Paint()..color = colors[4];
    canvas.drawCircle(Offset(x, y), 8 * bloom, centerPaint);

    // Add detail to center
    Paint centerDetail = Paint()
      ..color = const Color(0xFFFFEBEE).withOpacity(0.3)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;

    canvas.drawArc(Rect.fromCircle(center: Offset(x, y), radius: 5 * bloom), 0,
        pi * 1.5, false, centerDetail);
  }

  void _drawRoseLayer(
      Canvas canvas,
      double x,
      double y,
      double bloom,
      int count,
      double radius,
      Color color,
      Paint strokePaint,
      double angleOffset) {
    Paint paint = Paint()..color = color;
    double r = radius * bloom;

    for (int i = 0; i < count; i++) {
      double angle = (i * 360 / count) * pi / 180 + angleOffset;

      canvas.save();
      canvas.translate(x, y);
      canvas.rotate(angle);

      Path petal = Path();
      // Heart-ish shape for petal
      petal.moveTo(0, 0);
      petal.quadraticBezierTo(r * 0.8, -r * 0.5, 0, -r);
      petal.quadraticBezierTo(-r * 0.8, -r * 0.5, 0, 0);

      // Shift petal out slightly so they overlap nicely
      canvas.translate(0, -r * 0.3);

      canvas.drawPath(petal, paint);
      canvas.drawPath(petal, strokePaint);

      canvas.restore();
    }
  }

  void _drawLotus(Canvas canvas, double x, double y, double bloom) {
    Paint paint = Paint();
    paint.color = const Color(0xFFF8BBD0); // Pink

    int layers = 3;
    for (int l = 0; l < layers; l++) {
      int petals = 5 + l * 2;
      double len = (30 + l * 5) * bloom;
      double width = (10 + l * 2) * bloom;
      paint.color = l == 0 ? const Color(0xFFF48FB1) : const Color(0xFFF8BBD0);

      for (int i = 0; i < petals; i++) {
        double angle =
            (i * 2 * pi) / petals + (l * pi / petals); // Offset layers
        canvas.save();
        canvas.translate(x, y + 10 - (l * 5)); // Stack vertically slightly
        canvas.rotate(angle);

        Path petal = Path();
        petal.moveTo(0, 0);
        // Pointed petal
        petal.quadraticBezierTo(width, -len / 2, 0, -len);
        petal.quadraticBezierTo(-width, -len / 2, 0, 0);

        canvas.drawPath(petal, paint);
        canvas.restore();
      }
    }

    // Center
    paint.color = const Color(0xFFFFEB3B);
    canvas.drawCircle(Offset(x, y), 5 * bloom, paint);
  }

  @override
  bool shouldRepaint(covariant PlantPainter oldDelegate) =>
      oldDelegate.growth != growth || oldDelegate.type != type;
}

class RainPainter extends CustomPainter {
  final double animationValue;
  final Random _random = Random(42); // Fixed seed for consistent patterns

  RainPainter({required this.animationValue});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withOpacity(0.3)
      ..strokeWidth = 1.0
      ..strokeCap = StrokeCap.round;

    // Draw multiple layers of rain for depth
    _drawRainLayer(canvas, size, paint, count: 80, speedMultiplier: 1.0);
    _drawRainLayer(canvas, size, paint, count: 40, speedMultiplier: 2.0);
  }

  void _drawRainLayer(Canvas canvas, Size size, Paint paint,
      {required int count, required double speedMultiplier}) {
    var r = Random(42 + count); // Different seed for different layers

    for (int i = 0; i < count; i++) {
      double startX = r.nextDouble() * size.width;
      double startY = r.nextDouble() * size.height;
      double length = 10 + r.nextDouble() * 20;

      // Calculate Y position based on animation loop
      double fallDistance = size.height + length;
      double y = (startY + (animationValue * speedMultiplier * fallDistance)) %
          fallDistance;

      // To make it look continuous:
      y = y - length; // Shift up so 0 is -length (just entering)

      canvas.drawLine(Offset(startX, y), Offset(startX, y + length), paint);
    }
  }

  @override
  bool shouldRepaint(covariant RainPainter oldDelegate) =>
      oldDelegate.animationValue != animationValue;
}

class SunPainter extends CustomPainter {
  final double animationValue;

  SunPainter({required this.animationValue});

  @override
  void paint(Canvas canvas, Size size) {
    // Sun position: Top Left
    final center = Offset(size.width * 0.15, size.height * 0.15);
    final radius = 40.0;

    final paint = Paint()
      ..color = const Color(0xFFFFD54F) // Amber 300
      ..style = PaintingStyle.fill;

    // Draw Sun Body
    canvas.drawCircle(center, radius, paint);

    // Draw Rays
    final rayPaint = Paint()
      ..color = const Color(0xFFFFCA28).withOpacity(0.6)
      ..strokeWidth = 4.0
      ..style = PaintingStyle.stroke;

    final rayCount = 12;
    final rayLength = 20.0;
    final rotationOffset = animationValue * 2 * pi;

    for (int i = 0; i < rayCount; i++) {
      final angle = (i * 2 * pi / rayCount) + rotationOffset;
      final start = center + Offset(cos(angle), sin(angle)) * (radius + 5);
      final end =
          center + Offset(cos(angle), sin(angle)) * (radius + 5 + rayLength);
      canvas.drawLine(start, end, rayPaint);
    }

    // Glow
    final glowPaint = Paint()
      ..color = const Color(0xFFFFAB00).withOpacity(0.2)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 20);

    canvas.drawCircle(center, radius + 10, glowPaint);
  }

  @override
  bool shouldRepaint(covariant SunPainter oldDelegate) =>
      oldDelegate.animationValue != animationValue;
}

class BeachPainter extends CustomPainter {
  final double animationValue;

  BeachPainter({required this.animationValue});

  @override
  void paint(Canvas canvas, Size size) {
    // 1. Draw Sand (Bottom 25%)
    final sandHeight = size.height * 0.25;
    final sandY = size.height - sandHeight;

    final sandPaint = Paint()
      ..color = const Color(0xFFE6BF83); // Yellowish brown sand color

    canvas.drawRect(
      Rect.fromLTWH(0, sandY, size.width, sandHeight),
      sandPaint,
    );

    // 2. Draw Waves
    // We want waves coming "to" the beach.
    // From perspective, this usually means horizontal lines moving down or just stylized curves.
    // Let's draw stylized waves moving horizontally behind the sand line (simulating water hitting sand).
    // Actually, let's make the water occupy the area ABOVE the sand, up to horizon.

    final horizonY = size.height * 0.5;

    // Draw Water (Between horizon and sand)
    final waterPaint = Paint()
      ..shader = const LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [Color(0xFF006064), Color(0xFF00838F)],
      ).createShader(Rect.fromLTWH(0, horizonY, size.width, sandY - horizonY));

    canvas.drawRect(
      Rect.fromLTWH(0, horizonY, size.width, sandY - horizonY),
      waterPaint,
    );

    // Draw moving wave lines on the water
    final wavePaint = Paint()
      ..color = Colors.white.withOpacity(0.3)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;

    // Create 3 wave lines moving towards the sand (downwards)
    for (int i = 0; i < 3; i++) {
      double offset = (animationValue + i * 0.33) % 1.0;
      double waveY = horizonY + (sandY - horizonY) * offset;

      // Draw a sine wave horizontally at this Y
      Path wavePath = Path();
      wavePath.moveTo(0, waveY);

      for (double x = 0; x <= size.width; x += 10) {
        wavePath.lineTo(
            x, waveY + sin((x / 50) + (animationValue * 2 * pi)) * 5);
      }

      // Fade out as it approaches sand
      double opacity = 1.0 - offset; // Fade out near sand? Or fade IN?
      // Usually waves break at shore (sandY).
      // Let's fade in as they approach sand, then fade out quickly.
      if (offset > 0.8) opacity = (1.0 - offset) * 5;

      wavePaint.color = Colors.white.withOpacity(0.3 * opacity);
      canvas.drawPath(wavePath, wavePaint);
    }

    // Draw "foam" at the sand line
    final foamPaint = Paint()
      ..color =
          Colors.white.withOpacity(0.4 + 0.2 * sin(animationValue * 2 * pi))
      ..style = PaintingStyle.fill;

    // Irregular foam edge
    Path foamPath = Path();
    foamPath.moveTo(0, sandY);
    for (double x = 0; x <= size.width; x += 20) {
      foamPath.quadraticBezierTo(x + 10,
          sandY - 5 + sin(animationValue * 2 * pi + x) * 3, x + 20, sandY);
    }
    foamPath.lineTo(
        size.width, size.height); // Cover bottom to be safe? No, just a strip
    foamPath.lineTo(0, size.height);
    foamPath.close();

    // Just a thin strip
    canvas.drawPath(foamPath, foamPaint);
  }

  @override
  bool shouldRepaint(covariant BeachPainter oldDelegate) =>
      oldDelegate.animationValue != animationValue;
}

class MoonPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    // Moon position: Top Right
    final center = Offset(size.width * 0.8, size.height * 0.15);
    final radius = 35.0;

    // Glow
    final glowPaint = Paint()
      ..color = Colors.white.withOpacity(0.3)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 25);
    canvas.drawCircle(center, radius + 15, glowPaint);

    // Moon Body
    final paint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;
    canvas.drawCircle(center, radius, paint);

    // Subtle craters (optional details for "full moon" look)
    final craterPaint = Paint()
      ..color = Colors.grey.withOpacity(0.2)
      ..style = PaintingStyle.fill;

    canvas.drawCircle(center + const Offset(-10, -5), 8, craterPaint);
    canvas.drawCircle(center + const Offset(12, 8), 6, craterPaint);
    canvas.drawCircle(center + const Offset(5, -12), 4, craterPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class SeedPainter extends CustomPainter {
  final double progress; // 0.0 to 1.0

  SeedPainter({required this.progress});

  @override
  void paint(Canvas canvas, Size size) {
    // Start from top center, fall to bottom center (where the pot is)
    // Adjust targetY to match the pot location in PlantPainter
    // PlantPainter draws pot at (size.width / 2, size.height - 40)

    double startY = -50;
    double endY = size.height - 40;

    double currentY = startY + (endY - startY) * progress;
    double currentX = size.width / 2;

    Paint paint = Paint()
      ..color = const Color(0xFF8D6E63) // Brown seed
      ..style = PaintingStyle.fill;

    // Draw seed (oval shape)
    canvas.drawOval(
      Rect.fromCenter(
          center: Offset(currentX, currentY), width: 10, height: 15),
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant SeedPainter oldDelegate) =>
      oldDelegate.progress != progress;
}
