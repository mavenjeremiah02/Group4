import 'package:flutter/material.dart';

import '../widgets/app_widgets.dart';
import 'auth_screen.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  static const routeName = '/onboarding';

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final _controller = PageController();
  int _page = 0;

  final _items = const [
    _OnboardingItem(
      title: 'Find care nearby',
      text:
          'Search nearby hospitals, clinics, pharmacies, and emergency providers from one simple app.',
      image:
          'https://images.unsplash.com/photo-1505751172876-fa1923c5c528?auto=format&fit=crop&w=900&q=80',
    ),
    _OnboardingItem(
      title: 'Request help quickly',
      text:
          'Send emergency assistance requests, receive alerts, and connect quickly with available medical teams.',
      image:
          'https://images.unsplash.com/photo-1584515933487-779824d29309?auto=format&fit=crop&w=900&q=80',
    ),
    _OnboardingItem(
      title: 'Manage healthcare services',
      text:
          'Patients, doctors, pharmacists, and admins each get a focused dashboard for their work.',
      image:
          'https://images.unsplash.com/photo-1576091160550-2173dba999ef?auto=format&fit=crop&w=900&q=80',
    ),
  ];

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AppGradientBackground(
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              children: [
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: _openAuth,
                    child: const Text('Skip'),
                  ),
                ),
                Expanded(
                  child: PageView.builder(
                    controller: _controller,
                    itemCount: _items.length,
                    onPageChanged: (value) => setState(() => _page = value),
                    itemBuilder: (context, index) {
                      final item = _items[index];
                      return LayoutBuilder(
                        builder: (context, constraints) {
                          final isCompact = constraints.maxHeight < 500;
                          final imageHeight = isCompact ? 170.0 : 260.0;

                          return SingleChildScrollView(
                            physics: const ClampingScrollPhysics(),
                            child: ConstrainedBox(
                              constraints: BoxConstraints(
                                minHeight: constraints.maxHeight,
                              ),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(
                                      isCompact ? 24 : 34,
                                    ),
                                    child: Image.network(
                                      item.image,
                                      height: imageHeight,
                                      width: double.infinity,
                                      fit: BoxFit.cover,
                                      errorBuilder: (_, _, _) => Container(
                                        height: imageHeight,
                                        color: const Color(0xFFE0F4F5),
                                        child: const Icon(
                                          Icons.health_and_safety_rounded,
                                          color: primaryTeal,
                                          size: 60,
                                        ),
                                      ),
                                    ),
                                  ),
                                  SizedBox(height: isCompact ? 20 : 34),
                                  Text(
                                    item.title,
                                    textAlign: TextAlign.center,
                                    style: Theme.of(context)
                                        .textTheme
                                        .headlineMedium
                                        ?.copyWith(
                                          color: deepBlue,
                                          fontWeight: FontWeight.w900,
                                        ),
                                  ),
                                  SizedBox(height: isCompact ? 10 : 14),
                                  Text(
                                    item.text,
                                    textAlign: TextAlign.center,
                                    style: Theme.of(context).textTheme.bodyLarge
                                        ?.copyWith(
                                          color: const Color(0xFF5B7280),
                                          height: 1.35,
                                        ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      );
                    },
                  ),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(
                    _items.length,
                    (index) => AnimatedContainer(
                      duration: const Duration(milliseconds: 220),
                      margin: const EdgeInsets.symmetric(horizontal: 4),
                      width: _page == index ? 26 : 8,
                      height: 8,
                      decoration: BoxDecoration(
                        color: _page == index
                            ? primaryTeal
                            : primaryTeal.withValues(alpha: 0.24),
                        borderRadius: BorderRadius.circular(999),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  child: FilledButton(
                    onPressed: _page == _items.length - 1
                        ? _openAuth
                        : () => _controller.nextPage(
                            duration: const Duration(milliseconds: 260),
                            curve: Curves.easeOut,
                          ),
                    child: Text(
                      _page == _items.length - 1 ? 'Continue to login' : 'Next',
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _openAuth() {
    Navigator.pushReplacementNamed(context, AuthScreen.routeName);
  }
}

class _OnboardingItem {
  const _OnboardingItem({
    required this.title,
    required this.text,
    required this.image,
  });

  final String title;
  final String text;
  final String image;
}
