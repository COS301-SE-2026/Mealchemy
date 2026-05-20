import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:mealchemy/core/shared_widgets/atoms/app_button.dart';
import 'package:mealchemy/core/shared_widgets/atoms/app_card.dart';
import 'package:mealchemy/core/shared_widgets/atoms/app_text_field.dart';
import 'package:mealchemy/core/theme/app_colours.dart';
import 'package:mealchemy/core/theme/app_typography.dart';

class SignupForm extends StatefulWidget {
  const SignupForm({super.key});

  @override
  State<SignupForm> createState() => _SignupFormState();
}

class _SignupFormState extends State<SignupForm> {
  // Input controllers for the signup fields
  final _nameController            = TextEditingController();
  final _emailController           = TextEditingController();
  final _passwordController        = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  bool _isLoading = false;

  @override
  void dispose() {
    //Frees memory once the widget is removed
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  //On click register button logic
  void _handleRegister() {
    setState(() => _isLoading = true);
    Future.delayed(const Duration(seconds: 1), () {
      if (mounted) {
        setState(() => _isLoading = false);
        // TODO: connect to auth provider then navigate to preference screen
        context.go('/preference');
      }
    });
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
              hint: 'e.g. Mutombo Kabau',
              label: 'Display Name',
              controller: _nameController,
              keyboardType: TextInputType.name,
              prefixIcon: Icons.person_outline,
            ),
            const SizedBox(height: 16),

            //Email input field
            AppTextField.standard(
              hint: 'chef@mealchemy.com',
              label: 'Email Address',
              controller: _emailController,
              keyboardType: TextInputType.emailAddress,
              prefixIcon: Icons.email_outlined,
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