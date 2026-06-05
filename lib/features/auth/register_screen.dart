import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../shared/widgets/mascot_helper.dart';
import '../../shared/widgets/tactile_components.dart';
import 'providers/auth_provider.dart';

class RegisterScreen extends ConsumerStatefulWidget {
  const RegisterScreen({super.key});

  @override
  ConsumerState<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends ConsumerState<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _handleRegister() async {
    if (_formKey.currentState?.validate() ?? false) {
      final success = await ref.read(authProvider.notifier).signUp(
            _emailController.text,
            _passwordController.text,
            _nameController.text.trim(),
          );
      if (success && mounted) {
        context.go('/');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    // Dynamic Mascot message based on Auth state
    String mascotMessage = 'Bagus! Ayo daftarkan akun baru untuk menanam pohon vitalitas pertamamu!';
    MascotMood mascotMood = MascotMood.wink;

    if (authState.isLoading) {
      mascotMessage = 'Membuat akun barumu... Jangan tinggalkan layar ya!';
      mascotMood = MascotMood.loading;
    } else if (authState.errorMessage != null) {
      mascotMessage = authState.errorMessage!;
      mascotMood = MascotMood.think;
    }

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF0F172A) : Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_ios_new_rounded,
            color: isDark ? Colors.white : Colors.black87,
          ),
          onPressed: () {
            ref.read(authProvider.notifier).clearError();
            context.pop();
          },
        ),
      ),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 8.0),
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  minHeight: constraints.maxHeight - 16.0,
                ),
                child: IntrinsicHeight(
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        const Text(
                          'Buat Profil',
                          style: TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 0.5,
                          ),
                        ),
                        const SizedBox(height: 20),

                        // Interactive Mascot Bubble
                        MascotBubble(
                          message: mascotMessage,
                          mood: mascotMood,
                          bubbleColor: isDark ? const Color(0xFF1E293B) : const Color(0xFFF1F5F9),
                          textColor: isDark ? Colors.white : Colors.black87,
                          borderColor: isDark ? Colors.white10 : Colors.black12,
                        ),
                        const SizedBox(height: 28),

                        // Form Inputs
                        TactileTextField(
                          controller: _nameController,
                          labelText: 'Nama Lengkap',
                          hintText: 'Masukkan namamu',
                          prefixIcon: Icon(
                            Icons.person_outline_rounded,
                            color: isDark ? Colors.white54 : Colors.grey,
                          ),
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return 'Nama tidak boleh kosong';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 20),
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
                        const Spacer(),
                        const SizedBox(height: 24),

                        // Create Profile Primary Button
                        Tactile3DButton(
                          onPressed: authState.isLoading ? null : _handleRegister,
                          backgroundColor: const Color(0xFF1CB0F6), // Duolingo blue
                          shadowColor: const Color(0xFF1899D6),
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
                                  'BUAT AKUN',
                                  style: TextStyle(
                                    color: Colors.white,
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
