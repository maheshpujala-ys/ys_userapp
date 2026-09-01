import 'package:flutter/material.dart';
import 'package:yellowspotuser/core/config/app_config.dart';
import 'package:yellowspotuser/core/theme/app_colors.dart';

class EnvironmentBanner extends StatelessWidget {
  final Widget child;

  const EnvironmentBanner({
    super.key,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    final env = AppConfig.current.environment;

    if (env == AppEnvironment.production) {
      return child;
    }

    final isDev = env == AppEnvironment.development;
    final label = isDev ? '⚡ DEMO DATA (SIMULATION)' : '⚠️ STAGING ENVIRONMENT';
    final bgColor = isDev ? AppColors.warningDark : AppColors.infoDark;

    return Column(
      children: [
        Container(
          width: double.infinity,
          color: bgColor,
          padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
          child: SafeArea(
            bottom: false,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.info_outline_rounded, size: 12, color: Colors.white),
                const SizedBox(width: 6),
                Text(
                  label,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 10,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 0.8,
                  ),
                ),
              ],
            ),
          ),
        ),
        Expanded(child: child),
      ],
    );
  }
}
