import 'package:flutter/material.dart';

import '../models/healthcare_models.dart';
import '../services/firebase_auth_service.dart';
import '../services/session_service.dart';
import '../widgets/app_widgets.dart';
import 'dashboards_screen.dart';
import 'onboarding_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  static const routeName = '/';

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  final _authService = FirebaseAuthService();
  final _sessionService = SessionService();
  late final AnimationController _controller;
  late final Animation<double> _fadeIn;
  late final Animation<double> _logoScale;
  late final Animation<Offset> _slideUp;
  bool _restoringSession = false;

  @override
  void initState() {
    super.initState();
    _restoreSession();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    )..forward();
    _fadeIn = CurvedAnimation(parent: _controller, curve: Curves.easeOut);
    _logoScale = Tween<double>(
      begin: 0.82,
      end: 1,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.elasticOut));
    _slideUp = Tween<Offset>(
      begin: const Offset(0, 0.18),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _restoreSession() async {
    final keepLoggedIn = await _sessionService.isKeepLoggedIn();
    if (!keepLoggedIn) {
      await _authService.signOut();
      return;
    }

    UserRole? role;
    if (_authService.isConfigured) {
      role = await _authService.currentUserRole();
    }
    role ??= await _sessionService.getPreviewRole();

    if (role == null || !mounted) {
      return;
    }

    setState(() => _restoringSession = true);
    await Future<void>.delayed(const Duration(milliseconds: 900));
    if (!mounted) {
      return;
    }

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => DashboardScreen(role: role!)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AppGradientBackground(
        child: Stack(
          children: [
            const Positioned(
              top: -110,
              right: -80,
              child: _GlowCircle(size: 260, color: Color(0x5532D3C6)),
            ),
            const Positioned(
              bottom: -130,
              left: -100,
              child: _GlowCircle(size: 310, color: Color(0x553B82F6)),
            ),
            SafeArea(
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final isCompact = constraints.maxHeight < 660;
                  final logoSize = isCompact ? 128.0 : 154.0;

                  return SingleChildScrollView(
                    physics: const ClampingScrollPhysics(),
                    child: ConstrainedBox(
                      constraints: BoxConstraints(
                        minHeight: constraints.maxHeight,
                      ),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 28),
                        child: FadeTransition(
                          opacity: _fadeIn,
                          child: SlideTransition(
                            position: _slideUp,
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                SizedBox(height: isCompact ? 28 : 36),
                                ScaleTransition(
                                  scale: _logoScale,
                                  child: _MedicalLogo(size: logoSize),
                                ),
                                SizedBox(height: isCompact ? 20 : 34),
                                Text(
                                  'MediQuick',
                                  textAlign: TextAlign.center,
                                  style: Theme.of(context)
                                      .textTheme
                                      .displaySmall
                                      ?.copyWith(
                                        color: deepBlue,
                                        fontWeight: FontWeight.w800,
                                        letterSpacing: -1.1,
                                      ),
                                ),
                                const SizedBox(height: 10),
                                Text(
                                  'Fast hospital access, trusted care, and emergency support when every second matters.',
                                  textAlign: TextAlign.center,
                                  style: Theme.of(context).textTheme.bodyLarge
                                      ?.copyWith(
                                        color: const Color(0xFF426170),
                                        height: 1.35,
                                      ),
                                ),
                                SizedBox(height: isCompact ? 18 : 30),
                                const _HeartbeatCard(),
                                if (!isCompact) ...[
                                  const SizedBox(height: 26),
                                  const Wrap(
                                    alignment: WrapAlignment.center,
                                    spacing: 10,
                                    runSpacing: 10,
                                    children: [
                                      _FeatureChip(
                                        icon: Icons.local_hospital_rounded,
                                        label: 'Hospitals',
                                      ),
                                      _FeatureChip(
                                        icon: Icons.emergency_rounded,
                                        label: 'Emergency',
                                      ),
                                      _FeatureChip(
                                        icon: Icons.health_and_safety_rounded,
                                        label: 'Care',
                                      ),
                                    ],
                                  ),
                                ],
                                SizedBox(height: isCompact ? 28 : 46),
                                if (_restoringSession)
                                  const Padding(
                                    padding: EdgeInsets.symmetric(vertical: 18),
                                    child: CircularProgressIndicator(),
                                  )
                                else
                                  FilledButton.icon(
                                    onPressed: () {
                                      Navigator.pushReplacementNamed(
                                        context,
                                        OnboardingScreen.routeName,
                                      );
                                    },
                                    icon: const Icon(
                                      Icons.arrow_forward_rounded,
                                    ),
                                    label: const Text('Get started'),
                                  ),
                                const SizedBox(height: 14),
                                Text(
                                  'Connecting you to quality healthcare',
                                  textAlign: TextAlign.center,
                                  style: Theme.of(context).textTheme.labelLarge
                                      ?.copyWith(
                                        color: const Color(0xFF5B7280),
                                        fontWeight: FontWeight.w600,
                                      ),
                                ),
                                SizedBox(height: isCompact ? 22 : 34),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MedicalLogo extends StatelessWidget {
  const _MedicalLogo({required this.size});

  final double size;

  @override
  Widget build(BuildContext context) {
    final iconSize = size * 0.73;
    final verticalBar = Size(size * 0.18, size * 0.51);
    final horizontalBar = Size(size * 0.51, size * 0.18);

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(size * 0.29),
        boxShadow: const [
          BoxShadow(
            color: Color(0x2600737A),
            blurRadius: 36,
            offset: Offset(0, 20),
          ),
        ],
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          Container(
            width: iconSize,
            height: iconSize,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Color(0xFF12B8A6), Color(0xFF1976D2)],
              ),
              borderRadius: BorderRadius.circular(size * 0.22),
            ),
          ),
          Container(
            width: verticalBar.width,
            height: verticalBar.height,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(size * 0.06),
            ),
          ),
          Container(
            width: horizontalBar.width,
            height: horizontalBar.height,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(size * 0.06),
            ),
          ),
        ],
      ),
    );
  }
}

class _HeartbeatCard extends StatelessWidget {
  const _HeartbeatCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.82),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.white),
        boxShadow: const [
          BoxShadow(
            color: Color(0x1400737A),
            blurRadius: 24,
            offset: Offset(0, 14),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: const Color(0xFFE8FFF9),
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Icon(
              Icons.monitor_heart_rounded,
              color: Color(0xFF08A88A),
              size: 28,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: SizedBox(
              height: 42,
              child: CustomPaint(painter: _HeartbeatPainter()),
            ),
          ),
          const SizedBox(width: 12),
          const Text(
            '24/7',
            style: TextStyle(
              color: deepBlue,
              fontSize: 18,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }
}

class _HeartbeatPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = accentRed
      ..strokeWidth = 4
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..style = PaintingStyle.stroke;

    final y = size.height * 0.55;
    final path = Path()
      ..moveTo(0, y)
      ..lineTo(size.width * 0.18, y)
      ..lineTo(size.width * 0.26, size.height * 0.32)
      ..lineTo(size.width * 0.33, size.height * 0.72)
      ..lineTo(size.width * 0.43, size.height * 0.18)
      ..lineTo(size.width * 0.54, y)
      ..lineTo(size.width, y);

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _FeatureChip extends StatelessWidget {
  const _FeatureChip({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.72),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: const Color(0xFFE1F1F4)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 18, color: primaryTeal),
          const SizedBox(width: 7),
          Text(
            label,
            style: const TextStyle(
              color: Color(0xFF244B5A),
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

class _GlowCircle extends StatelessWidget {
  const _GlowCircle({required this.size, required this.color});

  final double size;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(shape: BoxShape.circle, color: color),
    );
  }
}
