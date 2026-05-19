//handles ui login

import 'package:flutter/material.dart';
import 'package:mealchemy/core/theme/app_colours.dart';
import 'package:mealchemy/features/auth/widgets/section_header.dart';
import 'package:mealchemy/features/auth/widgets/signup_form.dart';
import 'package:mealchemy/features/auth/widgets/section_footer.dart';

class SignupScreen extends StatelessWidget {
  const SignupScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgLight,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Stack(
            children: [
              const SectionHeader(),
              Padding(
                padding: const EdgeInsets.only(top: 275),
                child: Column(
                  children: [
                    const SignupForm(),
                    const SectionFooter(),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
