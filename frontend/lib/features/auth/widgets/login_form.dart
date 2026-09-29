import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:mealchemy/core/shared_widgets/atoms/app_button.dart';
import 'package:mealchemy/core/shared_widgets/atoms/app_card.dart';
import 'package:mealchemy/core/shared_widgets/atoms/app_text_field.dart';
import 'package:mealchemy/core/theme/app_colours.dart';
import 'package:mealchemy/core/theme/app_typography.dart';
import 'package:mealchemy/core/utils/validators.dart';
import 'package:mealchemy/core/utils/scroll_helper.dart';
import '../providers/auth_provider.dart';
import '../providers/login_lockout_provider.dart';

class LoginForm extends ConsumerStatefulWidget {
  const LoginForm({super.key});
  @override
  ConsumerState<LoginForm> createState() => _LoginFormState();
}

class _LoginFormState extends ConsumerState<LoginForm>
    with ScrollHelper, WidgetsBindingObserver {
  // Input controllers for the email and password fields
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  final _emailKey = GlobalKey();
  final _passwordKey = GlobalKey();

  bool _isLoading = false;
  // Validation error variables
  String? _emailError;
  String? _passwordError;
  String? _authError;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed && mounted) {
      ref.read(loginLockoutProvider.notifier).refresh();
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    // Frees memory once the widget is removed
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  bool _validate() {
    setState(() {
      _authError = null;
      _emailError = Validators.email(_emailController.text);
      _passwordError = Validators.password(_passwordController.text);
    });
    return _emailError == null && _passwordError == null;
  }

  List<(GlobalKey, bool)> get _errorFields => [
        (_emailKey, _emailError != null || _authError != null),
        (_passwordKey, _passwordError != null || _authError != null),
      ];

  // On click login button logic
  Future<void> _handleLogin() async {
    final submittedEmail = _emailController.text.trim();

    if (_isLoading ||
        ref
                .read(loginLockoutProvider.notifier)
                .remainingSeconds(submittedEmail) >
            0) {
      return;
    }

    if (!_validate()) {
      scrollToFirstError(_errorFields);
      return;
    }

    setState(() => _isLoading = true);

    final success = await ref.read(authProvider.notifier).login(
          submittedEmail,
          _passwordController.text,
        );

    if (!mounted) return;
    setState(() => _isLoading = false);

    if (success) {
      context.go('/dashboard');
      return;
    }

    //don't attach response for one email to a newly entered address
    if (_emailController.text.trim() != submittedEmail) return;

    final remaining = ref
        .read(loginLockoutProvider.notifier)
        .remainingSeconds(submittedEmail);

    setState(() {
      _authError = remaining > 0
          ? null
          : ref.read(authProvider).errorMessage ?? 'Invalid email or password';
    });

    if (_authError != null) {
      scrollToFirstError(_errorFields);
    }
  }

  @override
  Widget build(BuildContext context) {
    ref.watch(loginLockoutProvider);

    final remaining = ref
        .read(loginLockoutProvider.notifier)
        .remainingSeconds(_emailController.text);

    final locked = remaining > 0;
    final minutes = remaining ~/ 60;
    final seconds = (remaining % 60).toString().padLeft(2, '0');

    final message = locked
        ? 'Too many failed attempts. Try again in $minutes:$seconds.'
        : _authError ?? 'Sign in to access your digital pantry';
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

            // Shows the countdown, login error, or default subtitle.
            Text(
              message,
              textAlign: TextAlign.center,
              style: locked || _authError != null
                  ? AppTextStyles.bodyBold.copyWith(color: AppColors.error)
                  : AppTextStyles.body.copyWith(color: AppColors.textMuted),
            ),
            const SizedBox(height: 32),

            // Email input field
            AppTextField.standard(
              key: _emailKey,
              hint: 'chef@mealchemy.com',
              label: 'Email Address',
              controller: _emailController,
              keyboardType: TextInputType.emailAddress,
              prefixIcon: Icons.email_outlined,
              errorText: _emailError,
              hasError: _authError != null,
              onChanged: (_) {
                setState(() {
                  _emailError = null;
                  _authError = null;
                });
              },
            ),
            const SizedBox(height: 16),

            // Password input field
            AppTextField.private(
              key: _passwordKey,
              hint: '........',
              label: 'Password',
              controller: _passwordController,
              errorText: _passwordError,
              hasError: _authError != null,
              onChanged: (_) {
                if (_passwordError != null || _authError != null) {
                  setState(() {
                    _passwordError = null;
                    _authError = null;
                  });
                }
              },
            ),
            const SizedBox(height: 24),

            // Login button with loading state
            AppButton.primary(
              label: 'Log In',
              onPressed: _isLoading || locked ? null : _handleLogin,
              isLoading: _isLoading,
              isFullWidth: true,
              isRounded: true,
              rightIcon: Icons.arrow_forward,
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
