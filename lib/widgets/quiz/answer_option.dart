import 'package:flutter/material.dart';
import '../../utils/constants.dart';

class AnswerOption extends StatelessWidget {
  final String text;
  final bool isSelected;
  final bool isCorrect;
  final VoidCallback onTap;
  final int optionIndex;

  const AnswerOption({
    Key? key,
    required this.text,
    required this.isSelected,
    required this.isCorrect,
    required this.onTap,
    required this.optionIndex,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        transform: Matrix4.identity()..scale(isSelected ? 1.02 : 1.0),
        child: GestureDetector(
          onTap: onTap,
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: _getBackgroundColor(),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: _getBorderColor(),
                width: 2,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              children: [
                Container(
                  width: 24,
                  height: 24,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: _getCheckBorderColor(),
                      width: 2,
                    ),
                    color: _getCheckBackgroundColor(),
                  ),
                  child: _getCheckIcon(),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    text,
                    style: TextStyle(
                      color: _getTextColor(),
                      fontSize: 16,
                      fontFamily: 'Poppins',
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Color _getBackgroundColor() {
    if (isSelected) {
      return const Color(AppConstants.primaryGreen);
    }
    return Colors.white;
  }

  Color _getBorderColor() {
    if (isSelected) {
      return const Color(AppConstants.primaryGreen);
    }
    return Colors.grey[300]!;
  }

  Color _getTextColor() {
    if (isSelected) {
      return Colors.white;
    }
    return Color(AppConstants.darkText);
  }

  Color _getCheckBorderColor() {
    if (isSelected) {
      return Colors.white;
    }
    return Colors.grey[400]!;
  }

  Color _getCheckBackgroundColor() {
    if (isSelected) {
      return Colors.white;
    }
    return Colors.transparent;
  }

  Widget? _getCheckIcon() {
    if (isSelected) {
      return const Icon(
        Icons.check,
        size: 16,
        color: Color(AppConstants.primaryGreen),
      );
    }
    return null;
  }
}
