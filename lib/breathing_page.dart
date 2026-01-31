import 'dart:async';
import 'package:flutter/material.dart';

class BreathingPage extends StatefulWidget {
  const BreathingPage({super.key});

  @override
  State<BreathingPage> createState() => _BreathingPageState();
}

class _BreathingPageState extends State<BreathingPage>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _sizeAnimation;
  Timer? _timer;
  double _durationSeconds = 5.0;
  int _countdown = 5;

  // Base size of the circle
  static const double _minSize = 100.0;
  // Maximum size of the circle
  static const double _maxSize = 300.0;

  String _instruction = 'Tap and Breathe';

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: (_durationSeconds * 1000).toInt()),
    );

    // Linear animation from 0.0 to 1.0 mapping to minSize to maxSize
    _sizeAnimation = Tween<double>(
      begin: _minSize,
      end: _maxSize,
    ).animate(_controller);
  }

  @override
  void dispose() {
    _timer?.cancel();
    _controller.dispose();
    super.dispose();
  }

  void _startTimer() {
    _timer?.cancel();
    setState(() {
      _countdown = _durationSeconds.toInt();
    });
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        if (_countdown > 0) {
          _countdown--;
        } else {
          timer.cancel();
        }
      });
    });
  }

  void _startGrowing() {
    setState(() {
      _instruction = 'Breathe In';
    });
    // Grow for selected duration
    _controller.duration = Duration(
      milliseconds: (_durationSeconds * 1000).toInt(),
    );
    _controller.forward();
    _startTimer();
  }

  void _startShrinking() {
    setState(() {
      _instruction = 'Breathe Out';
    });
    // Return to normal over selected duration
    _controller.reverseDuration = Duration(
      milliseconds: (_durationSeconds * 1000).toInt(),
    );
    _controller.reverse();
    _startTimer();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTapDown: (_) => _startGrowing(),
              onTapUp: (_) => _startShrinking(),
              onTapCancel: () => _startShrinking(),
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      _instruction,
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.8),
                        fontSize: 24,
                        fontWeight: FontWeight.w300,
                        letterSpacing: 1.5,
                      ),
                    ),
                    const SizedBox(height: 40),
                    Text(
                      '$_countdown',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 48,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 40),
                    AnimatedBuilder(
                      animation: _sizeAnimation,
                      builder: (context, child) {
                        return Container(
                          width: _sizeAnimation.value,
                          height: _sizeAnimation.value,
                          decoration: const BoxDecoration(
                            color: Colors.blue,
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.blueAccent,
                                blurRadius: 20,
                                spreadRadius: 5,
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
          ),
          // Settings Section
          Container(
            padding: const EdgeInsets.all(20.0),
            decoration: BoxDecoration(
              color: Colors.grey[900],
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(20),
              ),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'Breath Duration (Seconds)',
                  style: TextStyle(color: Colors.white70, fontSize: 16),
                ),
                const SizedBox(height: 20),
                SizedBox(
                  height: 100,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      // Highlight Block
                      Container(
                        width: 80,
                        height: 50,
                        decoration: BoxDecoration(
                          color: Colors.blueAccent.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                            color: Colors.blueAccent,
                            width: 2,
                          ),
                        ),
                      ),
                      // Wheel Selector
                      ListWheelScrollView.useDelegate(
                        itemExtent: 50,
                        perspective: 0.005,
                        diameterRatio: 1.2,
                        physics: const FixedExtentScrollPhysics(),
                        onSelectedItemChanged: (index) {
                          setState(() {
                            // index 0 -> 2 seconds
                            _durationSeconds = (index + 2).toDouble();
                            if (!_controller.isAnimating) {
                              _countdown = _durationSeconds.ceil();
                            }
                          });
                        },
                        childDelegate: ListWheelChildBuilderDelegate(
                          childCount: 4, // 2 to 5
                          builder: (context, index) {
                            final value = index + 2;
                            return Center(
                              child: Text(
                                '$value',
                                style: TextStyle(
                                  fontSize: 28,
                                  fontWeight: FontWeight.bold,
                                  color: value == _durationSeconds.toInt()
                                      ? Colors.white
                                      : Colors.grey,
                                ),
                              ),
                            );
                          },
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
    );
  }
}
