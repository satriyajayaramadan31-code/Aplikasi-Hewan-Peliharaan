import 'dart:async';
import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import 'pet_list_page.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  static const String _title = 'Pet Care';
  late final List<String> _chars;
  late List<bool> _visibleChars;

  Timer? _startTimer;    // 2s black screen
  Timer? _revealTimer;   // reveal letters
  int _charIndex = 0;

  bool _contentVisible = false; // becomes true after 2s
  bool _navigating = false;

  @override
  void initState() {
    super.initState();
    _chars = _title.split('');
    _visibleChars = List<bool>.filled(_chars.length, false);

    // 1) Start with full black screen for 2 seconds
    _startTimer = Timer(const Duration(seconds: 2), () {
      if (!mounted) return;
      setState(() {
        _contentVisible = true; // start showing icon + animated text
      });

      // 2) Start revealing letters (typing effect)
      _revealTimer = Timer.periodic(const Duration(milliseconds: 160), (t) {
        if (!mounted) {
          t.cancel();
          return;
        }

        // reveal next character (skip immediate space handling)
        if (_charIndex < _chars.length) {
          // if current char is space, reveal it immediately and advance
          if (_chars[_charIndex] == ' ') {
            setState(() {
              _visibleChars[_charIndex] = true;
              _charIndex++;
            });
            // continue (next tick will reveal next)
            return;
          }

          setState(() {
            _visibleChars[_charIndex] = true;
            _charIndex++;
          });

          if (_charIndex >= _chars.length) {
            // finished revealing
            t.cancel();
            _revealTimer = null;
            // wait a bit then navigate
            Future.delayed(const Duration(milliseconds: 700), _navigateToHome);
          }
        } else {
          t.cancel();
          _revealTimer = null;
          Future.delayed(const Duration(milliseconds: 700), _navigateToHome);
        }
      });
    });
  }

  void _navigateToHome() {
    if (!mounted || _navigating) return;
    _navigating = true;
    Navigator.of(context).pushReplacement(PageRouteBuilder(
      transitionDuration: const Duration(milliseconds: 420),
      pageBuilder: (_, __, ___) => const PetListPage(),
      transitionsBuilder: (_, anim, __, child) => FadeTransition(opacity: anim, child: child),
    ));
  }

  @override
  void dispose() {
    _startTimer?.cancel();
    _revealTimer?.cancel();
    super.dispose();
  }

  Widget _buildAnimatedText() {
    final letters = <Widget>[];
    for (int i = 0; i < _chars.length; i++) {
      final ch = _chars[i];
      if (ch == ' ') {
        letters.add(const SizedBox(width: 10));
        continue;
      }

      letters.add(AnimatedOpacity(
        opacity: _visibleChars[i] ? 1.0 : 0.0,
        duration: const Duration(milliseconds: 220),
        curve: Curves.easeOut,
        child: AnimatedScale(
          scale: _visibleChars[i] ? 1.0 : 0.8,
          duration: const Duration(milliseconds: 220),
          curve: Curves.decelerate,
          child: Text(
            ch,
            style: TextStyle(
              fontSize: 34,
              fontWeight: FontWeight.w900,
              color: AppColors.greenFresh.withValues(alpha: 1.0),
              letterSpacing: 1.2,
            ),
          ),
        ),
      ));
    }
    return Row(mainAxisSize: MainAxisSize.min, children: letters);
  }

  @override
  Widget build(BuildContext context) {
    // Background animates from pure black (initial) to dark app bg when contentVisible = true
    return Scaffold(
      body: AnimatedContainer(
        duration: const Duration(milliseconds: 420),
        curve: Curves.easeInOut,
        color: _contentVisible ? AppColors.darkBg : Colors.black,
        child: SafeArea(
          child: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Icon circle: hidden during black screen, fade+scale when contentVisible true
                AnimatedOpacity(
                  opacity: _contentVisible ? 1.0 : 0.0,
                  duration: const Duration(milliseconds: 420),
                  curve: Curves.easeOut,
                  child: AnimatedScale(
                    scale: _contentVisible ? 1.0 : 0.7,
                    duration: const Duration(milliseconds: 420),
                    curve: Curves.decelerate,
                    child: Container(
                      width: 120,
                      height: 120,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            AppColors.limeLight.withValues(alpha: 1.0),
                            AppColors.greenFresh.withValues(alpha: 1.0)
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(color: Colors.black.withOpacity(0.25), blurRadius: 12, offset: const Offset(0, 8)),
                        ],
                      ),
                      child: const Center(
                        child: Icon(Icons.pets, size: 64, color: Colors.white),
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 22),

                // Animated title; invisible before contentVisible
                AnimatedOpacity(
                  opacity: _contentVisible ? 1.0 : 0.0,
                  duration: const Duration(milliseconds: 350),
                  child: _buildAnimatedText(),
                ),

                const SizedBox(height: 8),

                AnimatedOpacity(
                  opacity: _contentVisible ? 1.0 : 0.0,
                  duration: const Duration(milliseconds: 350),
                  child: Text(
                    'Selamat datang',
                    style: TextStyle(color: AppColors.bgLight.withValues(alpha: 0.88)),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
