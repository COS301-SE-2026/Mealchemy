import 'package:flutter/material.dart';
import 'package:mealchemy/core/shared_widgets/atoms/app_button.dart';
import 'package:mealchemy/core/theme/app_colours.dart';
import 'package:mealchemy/core/theme/app_typography.dart';

class SectionFooter extends StatelessWidget {
  const SectionFooter({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      // the space between the footer and the page form
      padding: const EdgeInsets.only(top: 16, bottom: 32, left: 24, right: 24),
      child: Column(
        children: [

          //Kitchen Intelligence card
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.accentLight,
              borderRadius: BorderRadius.circular(16),
              border: Border(
                left: BorderSide(
                  color: AppColors.accent,
                  width: 3,
                ),
              ),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [

                //Sparkle icon
                //Icon need to be imported 
                //Text content
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [

                      //Kitchen Intelligence label
                      Text(
                        'KITCHEN INTELLIGENCE',
                        style: AppTextStyles.label.copyWith(
                          color: AppColors.accentMuted,
                          letterSpacing: 1,
                        ),
                      ),
                      const SizedBox(height: 6),

                      //Description
                      RichText(
                        text: TextSpan(
                          style: AppTextStyles.bodySmall.copyWith(
                            color: AppColors.textLight,
                            height: 1.5,
                          ),
                          children: [
                            const TextSpan(
                              text: 'Our algorithm learns from your taste profiles. Log in to see your ',
                            ),
                            TextSpan(
                              text: 'Smart Substitution',
                              style: AppTextStyles.bodySmall.copyWith(
                                color: AppColors.primary,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const TextSpan(
                              text: ' recommendations for tonight\'s dinner.',
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          //Copyright text
          //neeed to import c icon 
          Text(
            ' 2026 MEALCHEMY',
            style: AppTextStyles.label.copyWith(
              color: AppColors.textMuted,
              fontSize: 11,
              letterSpacing: 1,
            ),
          ),
          const SizedBox(height: 8),

          //Privacy and Terms link
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              AppButton.text(
                label: 'PRIVACY',
                onPressed: () {},
                customColor: AppColors.textMuted,
              ),
              Text(
                ' • ',
                style: TextStyle(
                  color: AppColors.textMuted,
                  fontSize: 11,
                  letterSpacing: 0,
                ),
              ),
              AppButton.text(
                label: 'TERMS',
                onPressed: () {},
                customColor: AppColors.textMuted,
              ),
            ],
          ),
        ],
      ),
    );
  }
}