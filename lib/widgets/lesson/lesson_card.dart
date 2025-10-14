import 'package:flutter/material.dart';
import '../../models/lesson.dart';
import '../../utils/constants.dart';

class LessonCard extends StatelessWidget {
  final Lesson lesson;
  final bool isCompleted;
  final VoidCallback onTap;

  const LessonCard({
    super.key,
    required this.lesson,
    required this.isCompleted,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isCompleted
                ? const Color(AppConstants.primaryGreen).withOpacity(0.3)
                : const Color(0xFFE5E7EB),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            // Lesson Icon/Indicator
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isCompleted
                    ? const Color(AppConstants.primaryGreen).withOpacity(0.1)
                    : const Color(0xFFF3F4F6),
              ),
              child: Icon(
                isCompleted ? Icons.check_circle : Icons.play_circle_fill,
                color: isCompleted
                    ? const Color(AppConstants.primaryGreen)
                    : const Color(0xFF6B7280),
                size: 24,
              ),
            ),

            const SizedBox(width: 16),

            // Lesson Details
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title
                  Text(
                    lesson.title,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: const Color(AppConstants.darkText),
                      fontFamily: 'Poppins',
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),

                  const SizedBox(height: 4),

                  // Category and Duration
                  Row(
                    children: [
                      // Category
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF3F4F6),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          lesson.categoryName,
                          style: const TextStyle(
                            fontSize: 12,
                            color: Color(0xFF6B7280),
                            fontFamily: 'Poppins',
                          ),
                        ),
                      ),

                      const SizedBox(width: 8),

                      // Duration
                      Row(
                        children: [
                          const Icon(
                            Icons.schedule,
                            size: 12,
                            color: Color(0xFF6B7280),
                          ),
                          const SizedBox(width: 4),
                          Text(
                            '${lesson.estimatedDurationMinutes}m',
                            style: const TextStyle(
                              fontSize: 12,
                              color: Color(0xFF6B7280),
                              fontFamily: 'Poppins',
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(width: 8),

                      // Difficulty
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: lesson.isPremium
                              ? const Color(AppConstants.accentOrange).withOpacity(0.1)
                              : const Color(0xFFDCFCE7),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          lesson.isPremium ? 'Premium' : 'Free',
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                            color: lesson.isPremium
                                ? const Color(AppConstants.accentOrange)
                                : const Color(AppConstants.primaryGreen),
                            fontFamily: 'Poppins',
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 4),

                  // Description
                  Text(
                    lesson.description,
                    style: const TextStyle(
                      fontSize: 14,
                      color: Color(0xFF6B7280),
                      fontFamily: 'Poppins',
                      height: 1.3,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),

            // Arrow Icon
            Icon(
              Icons.arrow_forward_ios,
              size: 16,
              color: const Color(0xFF9CA3AF),
            ),
          ],
        ),
      ),
    );
  }
}