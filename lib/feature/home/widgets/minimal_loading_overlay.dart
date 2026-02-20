import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:ecommece_site_1688/core/const/app_colors.dart';

class MinimalLoadingOverlay extends StatelessWidget {
  final bool isLoading;
  final Widget child;
  final String? loadingText;
  final double? blurStrength;

  const MinimalLoadingOverlay({
    super.key,
    required this.isLoading,
    required this.child,
    this.loadingText,
    this.blurStrength,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        child,
        if (isLoading)
          Positioned.fill(
            child: AnimatedOpacity(
              duration: const Duration(milliseconds: 300),
              opacity: isLoading ? 1.0 : 0.0,
              child: BackdropFilter(
                filter: ImageFilter.blur(
                  sigmaX: blurStrength ?? 5,
                  sigmaY: blurStrength ?? 5,
                ),
                child: Container(
                  color: Colors.transparent,
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // Minimal spinner
                        SizedBox(
                          width: 40,
                          height: 40,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              AppColors.primaryColor,
                            ),
                          ),
                        ),
                        if (loadingText != null) ...[
                          const SizedBox(height: 16),
                          Text(
                            loadingText ?? "Loading...",
                            style: TextStyle(
                              color: AppColors.textPrimaryColor,
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 0.3,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }
}