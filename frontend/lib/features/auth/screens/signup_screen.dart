//handles ui login

import 'package:flutter/material.dart';
import 'package:mealchemy/core/theme/app_colours.dart';
import 'package:mealchemy/features/auth/widgets/section_header.dart';

class SignupScreen extends StatelessWidget {
  const SignupScreen({super.key});

@override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgLight,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              const SectionHeader(),
              //const RegistrationForm(),
              // const RegistrationFooter(),
            ],
          ),
        ),
      ),
    );
  }
}