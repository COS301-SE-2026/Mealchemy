import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mealchemy/core/shared_widgets/atoms/app_button.dart';
import 'package:mealchemy/core/shared_widgets/atoms/app_card.dart';
import 'package:mealchemy/core/shared_widgets/atoms/app_text_field.dart';
import 'package:mealchemy/core/theme/app_colours.dart';
import 'package:mealchemy/core/theme/app_typography.dart';
import 'package:mealchemy/core/utils/validators.dart';
import '../providers/auth_provider.dart';

class SignupForm extends ConsumerStatefulWidget {
  const SignupForm({super.key});

  @override
  ConsumerState<SignupForm> createState() => _SignupFormState();
}

class _SignupFormState extends ConsumerState<SignupForm> {
  // Input controllers for the signup fields
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  bool _isLoading = false;
  //Validation error variables
  String? _nameError;
  String? _emailError;
  String? _passwordError;
  String? _confirmPasswordError;

  @override
  void dispose() {
    //Frees memory once the widget is removed
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  bool _validate() {
    setState(() {
      _nameError = Validators.textField(_nameController.text);
      _emailError = Validators.email(_emailController.text);
      _passwordError = Validators.password(_passwordController.text);
      _confirmPasswordError = Validators.confirmPassword(
          _passwordController.text, _confirmPasswordController.text);
    });
    return _nameError == null &&
        _emailError == null &&
        _passwordError == null &&
        _confirmPasswordError == null;
  }

  //On click register button logic
  Future<void> _handleRegister() async {
    if (!_validate()) return;
    setState(() => _isLoading = true);
    final success = await ref.read(authProvider.notifier).register(
          _emailController.text.trim(),
          _passwordController.text,
          _nameController.text,
        );
    if (!mounted) return;
    setState(() => _isLoading = false);
    if (success) {
      context.go('/preference');
    } else {
      final error = ref.read(authProvider).errorMessage;
      setState(() => _confirmPasswordError = error);
    }
  }

  //OR CONTINUE WITH divider row
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
            //Create Account heading
            Text(
              'Create Account',
              textAlign: TextAlign.center,
              style: AppTextStyles.heading1.copyWith(
                color: AppColors.primary,
              ),
            ),
            const SizedBox(height: 8),

            //Subtitle
            Text(
              'Join Mealchemy and start your culinary journey',
              textAlign: TextAlign.center,
              style: AppTextStyles.body.copyWith(
                color: AppColors.textMuted,
              ),
            ),
            const SizedBox(height: 32),

            //Display name input field
            AppTextField.standard(
              hint: 'e.g. Karen Smith',
              label: 'Display Name',
              controller: _nameController,
              keyboardType: TextInputType.name,
              prefixIcon: Icons.person_outline,
              errorText: _nameError,
              onChanged: (_) {
                if (_nameError != null) setState(() => _nameError = null);
              },
            ),
            const SizedBox(height: 16),

            //Email input field
            AppTextField.standard(
              hint: 'chef@mealchemy.com',
              label: 'Email Address',
              controller: _emailController,
              keyboardType: TextInputType.emailAddress,
              prefixIcon: Icons.email_outlined,
              errorText: _emailError,
              onChanged: (_) {
                if (_emailError != null) setState(() => _emailError = null);
              },
            ),
            const SizedBox(height: 16),

            //Password label
            Text(
              'Password',
              style: AppTextStyles.bodySmall.copyWith(
                color: AppColors.textLight,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 6),

            //Password input field (hiding the text)
            AppTextField.private(
              hint: '........',
              controller: _passwordController,
              errorText: _passwordError,
              onChanged: (_) {
                if (_passwordError != null) {
                  setState(() => _passwordError = null);
                }
              },
            ),
            const SizedBox(height: 16),

            //Confirm password label
            Text(
              'Confirm Password',
              style: AppTextStyles.bodySmall.copyWith(
                color: AppColors.textLight,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 6),

            //Confirm password input field (hiding the text)
            AppTextField.private(
              hint: '........',
              controller: _confirmPasswordController,
              errorText: _confirmPasswordError,
              onChanged: (_) {
                if (_confirmPasswordError != null) {
                  setState(() => _confirmPasswordError = null);
                }
              },
            ),
            const SizedBox(height: 24),

            //Register button with loading state
            AppButton.primary(
              label: 'Create Account',
              onPressed: _isLoading ? null : _handleRegister,
              isLoading: _isLoading,
              isFullWidth: true,
              isRounded: true,
              rightIcon: Icons.arrow_forward,
            ),
            const SizedBox(height: 24),

            //OR CONTINUE WITH divider
            _buildDivider(),
            const SizedBox(height: 24),

            //Google sign up button
            AppButton.outlined(
              label: 'Sign up with Google',
              onPressed: () {},
              isFullWidth: true,
              isRounded: true,
              customColor: AppColors.accentMuted,
              customBorderColor: AppColors.accent,
            ),
            const SizedBox(height: 24),

            //Already have account link row
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'Already have an account? ',
                  style: AppTextStyles.body.copyWith(
                    color: AppColors.textMuted,
                  ),
                ),
                AppButton.text(
                  label: 'Sign In',
                  onPressed: () => context.go('/login'),
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
