import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../shared/widgets/mascot_helper.dart';
import '../../shared/widgets/tactile_components.dart';
import 'providers/auth_provider.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _handleLogin() async {
    if (_formKey.currentState?.validate() ?? false) {
      final success = await ref.read(authProvider.notifier).signIn(
            _emailController.text,
            _passwordController.text,
          );
      if (success && mounted) {
        context.go('/');
      }
    }
  }

  void _showForgotPasswordDialog() {
    final emailResetController = TextEditingController();
    showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: const Text(
          'Lupa Kata Sandi?',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Masukkan email kamu untuk menerima tautan pemulihan kata sandi.',
              style: TextStyle(fontSize: 13, height: 1.4),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: emailResetController,
              decoration: InputDecoration(
                labelText: 'Email',
                filled: true,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              keyboardType: TextInputType.emailAddress,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Batal', style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold)),
          ),
          ElevatedButton(
            onPressed: () async {
              final email = emailResetController.text.trim();
              if (email.isNotEmpty) {
                await ref.read(authProvider.notifier).sendPasswordReset(email);
                if (context.mounted) {
                  Navigator.of(context).pop();
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Tautan pemulihan telah dikirim ke email kamu.'),
                      backgroundColor: Colors.green,
                    ),
                  );
                }
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF1CB0F6),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            child: const Text('Kirim', style: TextStyle(fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    // Dynamic Mascot message and state based on Auth state
    String mascotMessage = 'Halo! Senang melihatmu kembali. Yuk, lanjutkan kebiasaan sehatmu!';
    MascotMood mascotMood = MascotMood.wink;

    if (authState.isLoading) {
      mascotMessage = 'Menghubungkan ke server... Harap tunggu sebentar!';
      mascotMood = MascotMood.loading;
    } else if (authState.errorMessage != null) {
      mascotMessage = authState.errorMessage!;
      mascotMood = MascotMood.think;
    }

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF0F172A) : Colors.white,
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  minHeight: constraints.maxHeight - 32.0,
                ),
                child: IntrinsicHeight(
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        const SizedBox(height: 24),
                        // 1. Top Section - Logo & Branding
                        const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              '🌳',
                              style: TextStyle(fontSize: 42),
                            ),
                            SizedBox(width: 10),
                            Text(
                              'VitaTree',
                              style: TextStyle(
                                fontSize: 32,
                                fontWeight: FontWeight.w900,
                                letterSpacing: 0.5,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 24),

                        // Interactive Mascot Bubble Section
                        MascotBubble(
                          message: mascotMessage,
                          mood: mascotMood,
                          bubbleColor: isDark ? const Color(0xFF1E293B) : const Color(0xFFF1F5F9),
                          textColor: isDark ? Colors.white : Colors.black87,
                          borderColor: isDark ? Colors.white10 : Colors.black12,
                        ),
                        const SizedBox(height: 32),

                        // 2. Form Fields Section
                        TactileTextField(
                          controller: _emailController,
                          labelText: 'Email',
                          hintText: 'nama@domain.com',
                          keyboardType: TextInputType.emailAddress,
                          prefixIcon: Icon(
                            Icons.mail_outline_rounded,
                            color: isDark ? Colors.white54 : Colors.grey,
                          ),
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return 'Email tidak boleh kosong';
                            }
                            if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value.trim())) {
                              return 'Format email tidak valid';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 20),
                        TactileTextField(
                          controller: _passwordController,
                          labelText: 'Kata Sandi',
                          obscureText: _obscurePassword,
                          prefixIcon: Icon(
                            Icons.lock_outline_rounded,
                            color: isDark ? Colors.white54 : Colors.grey,
                          ),
                          suffixIcon: IconButton(
                            icon: Icon(
                              _obscurePassword
                                  ? Icons.visibility_outlined
                                  : Icons.visibility_off_outlined,
                              color: isDark ? Colors.white54 : Colors.grey,
                            ),
                            onPressed: () {
                              setState(() => _obscurePassword = !_obscurePassword);
                            },
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Kata sandi tidak boleh kosong';
                            }
                            if (value.length < 6) {
                              return 'Kata sandi minimal 6 karakter';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 10),

                        // Forgot Password Link
                        Align(
                          alignment: Alignment.centerRight,
                          child: TextButton(
                            onPressed: _showForgotPasswordDialog,
                            child: const Text(
                              'Lupa kata sandi?',
                              style: TextStyle(
                                color: Color(0xFF1CB0F6),
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                              ),
                            ),
                          ),
                        ),
                        const Spacer(),

                        // 3. Actions Section
                        Tactile3DButton(
                          onPressed: authState.isLoading ? null : _handleLogin,
                          backgroundColor: const Color(0xFF58CC02), // Duolingo green
                          shadowColor: const Color(0xFF46A302),
                          child: authState.isLoading
                              ? const SizedBox(
                                  width: 24,
                                  height: 24,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 3,
                                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                  ),
                                )
                              : const Text(
                                  'MASUK',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 16,
                                    fontWeight: FontWeight.w900,
                                    letterSpacing: 0.8,
                                  ),
                                ),
                        ),
                        const SizedBox(height: 16),
                        Tactile3DButton(
                          onPressed: authState.isLoading
                              ? null
                              : () => context.push('/register'),
                          backgroundColor: isDark ? const Color(0xFF334155) : Colors.white,
                          shadowColor: isDark ? const Color(0xFF1E293B) : const Color(0xFFE5E5E5),
                          child: Text(
                            'DAFTAR BARU',
                            style: TextStyle(
                              color: isDark ? Colors.white : const Color(0xFF1CB0F6),
                              fontSize: 16,
                              fontWeight: FontWeight.w900,
                              letterSpacing: 0.8,
                            ),
                          ),
                        ),
                        const SizedBox(height: 24),
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
