import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/router/app_router.dart';
import '../../../repositories/auth_repository.dart';
import '../../../services/auth_service.dart';
import '../widgets/glass_card.dart';

final _authRepoProvider = Provider(
    (ref) => AuthRepository(ref.read(Provider((ref) => AuthService()))));

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});
  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isPasswordVisible = false;
  bool _isLoading = false;
  bool _isGoogleLoading = false;
  String? _errorMessage;

  late final AuthRepository _authRepo;

  @override
  void initState() {
    super.initState();
    _authRepo = AuthRepository(AuthService());
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _signIn() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    final result = await _authRepo.signIn(
      _emailController.text.trim(),
      _passwordController.text,
    );

    if (mounted) {
      setState(() => _isLoading = false);
      if (!result.success) {
        setState(() => _errorMessage = result.error);
      }
    }
  }

  Future<void> _signInWithGoogle() async {
    setState(() {
      _isGoogleLoading = true;
      _errorMessage = null;
    });

    final result = await _authRepo.signInWithGoogle();

    if (mounted) {
      setState(() => _isGoogleLoading = false);
      if (!result.success) {
        setState(() => _errorMessage = result.error);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 40),

              // Logo + Title
              Row(
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(14),
                      gradient: const LinearGradient(
                        colors: [AppTheme.primary, AppTheme.secondary],
                      ),
                    ),
                    child: const Icon(Icons.mic_rounded,
                        color: Colors.white, size: 26),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    'PocketAudio',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                ],
              ).animate().fadeIn(duration: 500.ms).slideY(begin: -0.2, end: 0),

              const SizedBox(height: 48),

              Text(
                'Welcome back',
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ).animate().fadeIn(delay: 100.ms, duration: 500.ms),

              const SizedBox(height: 8),

              Text(
                'Sign in to your AI Studio',
                style: Theme.of(context).textTheme.bodyMedium,
              ).animate().fadeIn(delay: 150.ms, duration: 500.ms),

              const SizedBox(height: 36),

              GlassCard(
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Email field
                      TextFormField(
                        controller: _emailController,
                        keyboardType: TextInputType.emailAddress,
                        style: const TextStyle(color: AppTheme.textPrimary),
                        decoration: const InputDecoration(
                          hintText: 'Email address',
                          prefixIcon: Icon(Icons.email_outlined,
                              color: AppTheme.textSecondary),
                        ),
                        validator: (v) {
                          if (v == null || v.isEmpty) return 'Email required';
                          if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(v)) {
                            return 'Please enter a valid email';
                          }
                          return null;
                        },
                      ),

                      const SizedBox(height: 16),

                      // Password field
                      TextFormField(
                        controller: _passwordController,
                        obscureText: !_isPasswordVisible,
                        style: const TextStyle(color: AppTheme.textPrimary),
                        decoration: InputDecoration(
                          hintText: 'Password',
                          prefixIcon: const Icon(Icons.lock_outline,
                              color: AppTheme.textSecondary),
                          suffixIcon: IconButton(
                            icon: Icon(
                              _isPasswordVisible
                                  ? Icons.visibility_off_outlined
                                  : Icons.visibility_outlined,
                              color: AppTheme.textSecondary,
                            ),
                            onPressed: () => setState(
                                () => _isPasswordVisible = !_isPasswordVisible),
                          ),
                        ),
                        validator: (v) {
                          if (v == null || v.isEmpty) return 'Password required';
                          if (v.length < 6) return 'Minimum 6 characters';
                          return null;
                        },
                      ),

                      if (_errorMessage != null) ...[
                        const SizedBox(height: 12),
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: AppTheme.error.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(
                                color: AppTheme.error.withOpacity(0.3)),
                          ),
                          child: Text(
                            _errorMessage!,
                            style: const TextStyle(
                                color: AppTheme.error, fontSize: 13),
                          ),
                        ),
                      ],

                      const SizedBox(height: 24),

                      // Sign In Button
                      ElevatedButton(
                        onPressed: _isLoading ? null : _signIn,
                        child: _isLoading
                            ? const SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                      Colors.white),
                                ),
                              )
                            : const Text('Sign In'),
                      ),

                      const SizedBox(height: 16),

                      // Divider
                      Row(
                        children: [
                          const Expanded(
                              child:
                                  Divider(color: AppTheme.glassBorder)),
                          Padding(
                            padding:
                                const EdgeInsets.symmetric(horizontal: 12),
                            child: Text('or',
                                style: Theme.of(context).textTheme.bodySmall),
                          ),
                          const Expanded(
                              child:
                                  Divider(color: AppTheme.glassBorder)),
                        ],
                      ),

                      const SizedBox(height: 16),

                      // Google Sign-In
                      OutlinedButton.icon(
                        onPressed: _isGoogleLoading ? null : _signInWithGoogle,
                        icon: _isGoogleLoading
                            ? const SizedBox(
                                height: 18,
                                width: 18,
                                child: CircularProgressIndicator(
                                    strokeWidth: 2),
                              )
                            : const Icon(Icons.g_mobiledata_rounded, size: 28),
                        label: const Text('Continue with Google'),
                      ),
                    ],
                  ),
                ),
              ).animate().fadeIn(delay: 200.ms, duration: 500.ms).slideY(begin: 0.15, end: 0),

              const SizedBox(height: 24),

              // Register link
              Center(
                child: TextButton(
                  onPressed: () => context.go(AppRoutes.register),
                  child: RichText(
                    text: TextSpan(
                      text: "Don't have an account? ",
                      style: Theme.of(context).textTheme.bodyMedium,
                      children: [
                        TextSpan(
                          text: 'Create one',
                          style: const TextStyle(
                            color: AppTheme.primary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ).animate().fadeIn(delay: 400.ms, duration: 500.ms),
            ],
          ),
        ),
      ),
    );
  }
}
