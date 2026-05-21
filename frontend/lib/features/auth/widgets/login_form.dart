import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:mealchemy/core/shared_widgets/atoms/app_button.dart';
import 'package:mealchemy/core/shared_widgets/atoms/app_card.dart';
import 'package:mealchemy/core/shared_widgets/atoms/app_text_field.dart';
import 'package:mealchemy/core/theme/app_colours.dart';
import 'package:mealchemy/core/theme/app_typography.dart';
import 'package:mealchemy/core/utils/validators.dart';
import '../providers/auth_provider.dart';

class LoginForm extends ConsumerStatefulWidget {
  const LoginForm({super.key});

  @override
  ConsumerState<LoginForm> createState() => _LoginFormState();
}

class _LoginFormState extends ConsumerState<LoginForm> {
  // Input controllers for the email and password fields
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  bool _isLoading = false;
  // Validation error variables
  String? _emailError;
  String? _passwordError;

  @override
  void dispose() {
    // Frees memory once the widget is removed
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  bool _validate() {
    setState(() {
      _emailError = Validators.email(_emailController.text);
      _passwordError = Validators.password(_passwordController.text);
    });
    return _emailError == null && _passwordError == null;
  }

  // On click login button logic
  Future<void> _handleLogin() async {
    if (!_validate()) return;

    setState(() => _isLoading = true);

    final success = await ref.read(authProvider.notifier).login(
      _emailController.text.trim(),
      _passwordController.text,
    );

    if (!mounted) return;
    setState(() => _isLoading = false);

    if (success) {
      context.go('/vault');
    } else {
      final error = ref.read(authProvider).errorMessage;
      setState(() => _emailError = error);
    }
  }

  // OR CONTINUE WITH divider row
  Widget _buildDivider() {
    return Row(
      children: [
        Expanded(child: Divider(color: AppColors.divider)),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Text(
            'OR CONTINUE WITH',
            style: AppTextStyles.label.copyWith(
              color: AppColors.textMuted,
              letterSpacing: 1,
            ),
          ),
        ),
        Expanded(child: Divider(color: AppColors.divider)),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: AppCard.light(
        borderRadius: 24,
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Welcome Back heading
            Text(
              'Welcome Back',
              textAlign: TextAlign.center,
              style: AppTextStyles.heading1.copyWith(
                color: AppColors.primary,
              ),
            ),
            const SizedBox(height: 8),

            // Subtitle
            Text(
              'Sign in to access your digital pantry',
              textAlign: TextAlign.center,
              style: AppTextStyles.body.copyWith(
                color: AppColors.textMuted,
              ),
            ),
            const SizedBox(height: 32),

            // Email input field
            AppTextField.standard(
              hint: 'chef@mealchemy.com',
              label: 'Email Address',
              controller: _emailController,
              keyboardType: TextInputType.emailAddress,
              prefixIcon: Icons.email_outlined,
            ),
            const SizedBox(height: 16),

            // Password label and forgot password link row
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Password',
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.textLight,
                  ),
                ),
                AppButton.text(
                  label: 'Forgot Password?',
                  onPressed: () {},
                  customColor: AppColors.primary,
                ),
              ],
            ),
            const SizedBox(height: 6),

            // Password input field
            AppTextField.private(
              hint: '........',
              controller: _passwordController,
              onChanged: (_) {
                if (_passwordError != null) {
                  setState(() => _passwordError = null);
                }
              },
            ),
            const SizedBox(height: 24),

            // Login button with loading state
            AppButton.primary(
              label: 'Log In',
              onPressed: _isLoading ? null : _handleLogin,
              isLoading: _isLoading,
              isFullWidth: true,
              isRounded: true,
              rightIcon: Icons.arrow_forward,
            ),
            const SizedBox(height: 24),

            // OR CONTINUE WITH divider
            _buildDivider(),
            const SizedBox(height: 24),

            // Google sign in button
            AppButton.outlined(
              label: 'Sign in with Google',
              onPressed: () {},
              isFullWidth: true,
              isRounded: true,
              customColor: AppColors.accentMuted,
              customBorderColor: AppColors.accent,
            ),
            const SizedBox(height: 24),

            // Create account link row
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'New to Mealchemy? ',
                  style: AppTextStyles.body.copyWith(
                    color: AppColors.textMuted,
                  ),
                ),
                AppButton.text(
                  label: 'Create Account',
                  onPressed: () => context.go('/signup'),
                  customColor: AppColors.primary,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}