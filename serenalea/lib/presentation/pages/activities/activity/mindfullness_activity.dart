import 'package:flutter/material.dart';
import 'dart:math';
import 'dart:async';
import 'package:audioplayers/audioplayers.dart';
import '../../../../core/constants/colors.dart';

class MindfulnessActivityPage extends StatefulWidget {
  const MindfulnessActivityPage({Key? key}) : super(key: key);

  @override
  State<MindfulnessActivityPage> createState() => _MindfulnessActivityPageState();
}

class _MindfulnessActivityPageState extends State<MindfulnessActivityPage> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;
  bool _isRunning = false;
  int _totalDuration = 5;
  int _phase = 0; // 0: Inhalar, 1: Aguantar, 2: Exhalar
  String _phaseText = '';
  Timer? _timer;
  final AudioPlayer _audioPlayer = AudioPlayer();

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    );
    _animation = Tween<double>(begin: 0.7, end: 1.2).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
    _controller.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        _controller.reverse();
      } else if (status == AnimationStatus.dismissed) {
        _controller.forward();
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    _timer?.cancel();
    _audioPlayer.dispose();
    super.dispose();
  }

  void _startBreathing() {
    setState(() {
      _isRunning = true;
      // Elige duración total entre 20, 30, 40 o 50 segundos
      _totalDuration = [20, 30, 40, 50][Random().nextInt(4)];
    });
    int cycleDuration = 10; // segundos por ciclo
    int inhale = 4;
    int hold = 2;
    int exhale = 4;
    int cycles = (_totalDuration / cycleDuration).floor();

    void runCycle(int cycle) {
      if (cycle >= cycles) {
        setState(() {
          _isRunning = false;
          _phaseText = '';
        });
        _controller.stop();
        _audioPlayer.play(AssetSource('lib/core/utils/assets/relax.mp3'));
        return;
      }
      setState(() {
        _phase = 0;
        _phaseText = 'Inhala';
      });
      _controller.duration = Duration(seconds: inhale);
      _controller.forward(from: 0);
      Future.delayed(Duration(seconds: inhale), () {
        setState(() {
          _phase = 1;
          _phaseText = 'Aguanta';
        });
        _controller.stop();
        Future.delayed(Duration(seconds: hold), () {
          setState(() {
            _phase = 2;
            _phaseText = 'Exhala';
          });
          _controller.duration = Duration(seconds: exhale);
          _controller.reverse(from: 1);
          Future.delayed(Duration(seconds: exhale), () {
            _controller.stop();
            runCycle(cycle + 1);
          });
        });
      });
    }
    runCycle(0);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Respiración Mindfulness'),
        backgroundColor: AppColors.color1,
        foregroundColor: AppColors.white,
        elevation: 0,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              AnimatedBuilder(
                animation: _animation,
                builder: (context, child) {
                  Color circleColor;
                  if (_phase == 0) {
                    circleColor = AppColors.color2;
                  } else if (_phase == 1) {
                    circleColor = AppColors.color3;
                  } else if (_phase == 2) {
                    circleColor = AppColors.color1;
                  } else {
                    circleColor = AppColors.color2;
                  }
                  return Transform.scale(
                    scale: _isRunning ? _animation.value : 1.0,
                    child: Container(
                      width: 200,
                      height: 200,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: RadialGradient(
                          colors: [circleColor.withOpacity(0.7), circleColor],
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: circleColor.withOpacity(0.2),
                            blurRadius: 32,
                            spreadRadius: 12,
                          ),
                        ],
                      ),
                      child: Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              _isRunning ? _phaseText : 'Listo para empezar',
                              style: TextStyle(
                                fontSize: 26,
                                fontWeight: FontWeight.bold,
                                color: AppColors.white,
                                shadows: [
                                  Shadow(
                                    color: AppColors.color1.withOpacity(0.3),
                                    blurRadius: 8,
                                  ),
                                ],
                              ),
                              textAlign: TextAlign.center,
                            ),
                            if (_isRunning)
                              Padding(
                                padding: const EdgeInsets.only(top: 12.0),
                                child: Icon(
                                  _phase == 0
                                      ? Icons.arrow_upward_rounded
                                      : _phase == 1
                                          ? Icons.pause_circle_filled_rounded
                                          : Icons.arrow_downward_rounded,
                                  color: AppColors.white,
                                  size: 38,
                                ),
                              ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
              const SizedBox(height: 40),
              if (_isRunning)
                Text(
                  'Duración total: $_totalDuration segundos',
                  style: TextStyle(
                    fontSize: 18,
                    color: AppColors.color1,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              const SizedBox(height: 32),
              ElevatedButton.icon(
                icon: const Icon(Icons.self_improvement_rounded),
                label: Text(_isRunning ? 'En curso...' : 'Iniciar respiración'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                  textStyle: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  backgroundColor: AppColors.color1,
                  foregroundColor: AppColors.white,
                  elevation: 4,
                ),
                onPressed: _isRunning ? null : _startBreathing,
              ),
              const SizedBox(height: 20),
              if (!_isRunning)
                Text(
                  'Al terminar sonará un sonido relajante.',
                  style: TextStyle(fontSize: 16, color: AppColors.color2),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
