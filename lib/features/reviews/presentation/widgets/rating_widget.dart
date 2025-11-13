import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';

class RatingWidget extends StatelessWidget {
  final double rating;
  final int maxRating;
  final double size;
  final bool showNumber;

  const RatingWidget({
    super.key,
    required this.rating,
    this.maxRating = 5,
    this.size = 20,
    this.showNumber = false,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        ...List.generate(maxRating, (index) {
          if (index < rating.floor()) {
            return Icon(
              Icons.star,
              size: size,
              color: AppColors.warning,
            );
          } else if (index < rating) {
            return Icon(
              Icons.star_half,
              size: size,
              color: AppColors.warning,
            );
          } else {
            return Icon(
              Icons.star_border,
              size: size,
              color: AppColors.textSecondaryLight,
            );
          }
        }),
        if (showNumber) ...[
          const SizedBox(width: 8),
          Text(
            rating.toStringAsFixed(1),
            style: TextStyle(
              fontSize: size * 0.7,
              color: AppColors.textPrimaryLight,
            ),
          ),
        ],
      ],
    );
  }
}

