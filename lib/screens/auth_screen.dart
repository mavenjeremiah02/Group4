import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../models/healthcare_models.dart';
import '../services/firebase_auth_service.dart';
import '../services/session_service.dart';
import '../widgets/app_widgets.dart';
import 'dashboards_screen.dart';

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  static const routeName = '/auth';

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  final _authService = FirebaseAuthService();
  final _sessionService = SessionService();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLogin = true;
  bool _isLoading = false;
  bool _keepLoggedIn = true;
  String? _errorMessage;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isFirebaseReady = _authService.isConfigured;

    return Scaffold(
      body: AppGradientBackground(
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(
                    Icons.health_and_safety_rounded,
                    color: primaryTeal,
                    size: 48,
                  ),
                  const SizedBox(height: 18),
                  Text(
                    _isLogin ? 'Welcome back' : 'Create your account',
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      color: deepBlue,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _isLogin
                        ? (isFirebaseReady
                            ? 'Sign in with your email and password.'
                            : 'Sign in to access hospitals, pharmacies, and emergency care.')
                        : 'Create a patient account.',
                    style: const TextStyle(color: Color(0xFF5B7280), height: 1.4),
                  ),
                  const SizedBox(height: 26),
                  Container(
                    padding: const EdgeInsets.all(18),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(28),
                      boxShadow: const [
                        BoxShadow(
                          color: Color(0x1200737A),
                          blurRadius: 28,
                          offset: Offset(0, 16),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        if (!_isLogin) ...[
                          TextField(
                            controller: _nameController,
                            decoration: const InputDecoration(
                              labelText: 'Full name',
                              prefixIcon: Icon(Icons.person_rounded),
                            ),
                          ),
                          const SizedBox(height: 14),
                        ],
                        TextField(
                          controller: _emailController,
                          keyboardType: TextInputType.emailAddress,
                          decoration: const InputDecoration(
                            labelText: 'Email address',
                            prefixIcon: Icon(Icons.email_rounded),
                          ),
                        ),
                        const SizedBox(height: 14),
                        TextField(
                          controller: _passwordController,
                          obscureText: true,
                          decoration: const InputDecoration(
                            labelText: 'Password',
                            prefixIcon: Icon(Icons.lock_rounded),
                          ),
                        ),
                        CheckboxListTile(
                          value: _keepLoggedIn,
                          onChanged: (value) => setState(
                            () => _keepLoggedIn = value ?? true,
                          ),
                          controlAffinity: ListTileControlAffinity.leading,
                          activeColor: primaryTeal,
                          contentPadding: EdgeInsets.zero,
                          title: const Text(
                            'Keep me logged in',
                            style: TextStyle(
                              color: deepBlue,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                        if (_errorMessage != null) ...[
                          const SizedBox(height: 14),
                          Text(
                            _errorMessage!,
                            style: const TextStyle(
                              color: accentRed,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                        const SizedBox(height: 20),
                        SizedBox(
                          width: double.infinity,
                          child: FilledButton(
                            onPressed: _isLoading ? null : _submit,
                            child: _isLoading
                                ? const SizedBox(
                                    width: 18,
                                    height: 18,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                    ),
                                  )
                                : Text(_isLogin ? 'Login' : 'Register account'),
                          ),
                        ),
                        TextButton(
                          onPressed: () => setState(() => _isLogin = !_isLogin),
                          child: Text(
                            _isLogin
                                ? 'Need an account? Register'
                                : 'Already registered? Login',
                          ),
                        ),
                        if (!isFirebaseReady) ...[
                          const Divider(height: 20),
                          TextButton.icon(
                            onPressed: () => _continuePreview(),
                            icon: const Icon(Icons.visibility_rounded),
                            label: const Text('Continue as Patient'),
                          ),
                        ],
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _submit() async {
    if (!_authService.isConfigured) {
      setState(
        () => _errorMessage =
            'Sign-in is not available offline. Connect to the internet and try again.',
      );
      return;
    }

    final email = _emailController.text.trim();
    final password = _passwordController.text;
    if (email.isEmpty || password.isEmpty) {
      setState(() => _errorMessage = 'Enter email and password.');
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final role = _isLogin
          ? await _authService.signIn(email: email, password: password)
          : await _authService.register(
              name: _nameController.text,
              email: email,
              password: password,
              role: UserRole.patient,
            );

      try {
        await _persistSession(role);
      } catch (_) {
        // Login should still succeed if local session storage is unavailable.
      }

      if (!mounted) return;
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => DashboardScreen(role: role)),
      );
    } on FirebaseAuthException catch (error) {
      if (!mounted) return;
      setState(() => _errorMessage = error.message ?? error.code);
    } catch (error) {
      if (!mounted) return;
      setState(() => _errorMessage = 'Login failed: $error');
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _continuePreview() async {
    const role = UserRole.patient;
    try {
      await _persistSession(role);
    } catch (_) {
      // Preview mode should still open when storage is unavailable.
    }

    if (!mounted) return;
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => DashboardScreen(role: role)),
    );
  }

  Future<void> _persistSession(UserRole role) async {
    await _sessionService.setKeepLoggedIn(_keepLoggedIn);
    if (!_keepLoggedIn) {
      return;
    }
    if (_authService.isConfigured) {
      await _sessionService.clearPreviewRole();
    } else {
      await _sessionService.savePreviewRole(role);
    }
  }
}
