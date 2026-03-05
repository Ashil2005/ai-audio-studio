import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/router/app_router.dart';
import '../../../services/auth_service.dart';
import '../../../repositories/auth_repository.dart';
import '../widgets/glass_card.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});
  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _isPasswordVisible = false;
  bool _isLoading = false;
  String? _errorMessage;

  final _authRepo = AuthRepository(AuthService());

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _register() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    final result = await _authRepo.register(
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_rounded,
              color: AppTheme.textPrimary),
          onPressed: () => context.go(AppRoutes.login),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 16),

              Text(
                'Create account',
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ).animate().fadeIn(duration: 400.ms),

              const SizedBox(height: 8),

              Text(
                'Start creating AI-powered content',
                style: Theme.of(context).textTheme.bodyMedium,
              ).animate().fadeIn(delay: 100.ms),

              const SizedBox(height: 32),

              GlassCard(
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
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
                            return 'Enter a valid email';
                          }
                          return null;
                        },
                      ),

                      const SizedBox(height: 16),

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

                      const SizedBox(height: 16),

                      TextFormField(
                        controller: _confirmPasswordController,
                        obscureText: true,
                        style: const TextStyle(color: AppTheme.textPrimary),
                        decoration: const InputDecoration(
                          hintText: 'Confirm password',
                          prefixIcon: Icon(Icons.lock_outline,
                              color: AppTheme.textSecondary),
                        ),
                        validator: (v) {
                          if (v != _passwordController.text) {
                            return 'Passwords do not match';
                          }
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
                            style:
                                const TextStyle(color: AppTheme.error, fontSize: 13),
                          ),
                        ),
                      ],

                      const SizedBox(height: 24),

                      ElevatedButton(
                        onPressed: _isLoading ? null : _register,
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
                            : const Text('Create Account'),
                      ),
                    ],
                  ),
                ),
              ).animate().fadeIn(delay: 200.ms, duration: 400.ms).slideY(begin: 0.1, end: 0),

              const SizedBox(height: 20),

              Center(
                child: TextButton(
                  onPressed: () => context.go(AppRoutes.login),
                  child: RichText(
                    text: TextSpan(
                      text: 'Already have an account? ',
                      style: Theme.of(context).textTheme.bodyMedium,
                      children: const [
                        TextSpan(
                          text: 'Sign in',
                          style: TextStyle(
                            color: AppTheme.primary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ).animate().fadeIn(delay: 350.ms),
            ],
          ),
        ),
      ),
    );
  }
}
