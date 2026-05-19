//handles ui login

import 'package:flutter/material.dart';
import 'package:mealchemy/core/theme/app_colours.dart';
import 'package:mealchemy/features/auth/widgets/login_header.dart';
import 'package:mealchemy/features/auth/widgets/login_form.dart';
import 'package:mealchemy/features/auth/widgets/login_footer.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

@override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgLight,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              const LoginHeader(),
              const LoginForm(),
              // const LoginFooter(),
            ],
          ),
        ),
      ),
    );
  }
}