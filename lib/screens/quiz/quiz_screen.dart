// lib/screens/quiz/quiz_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../providers/quiz_provider.dart';
import '../../providers/audio_provider.dart';
import '../../models/quiz.dart';
import '../../utils/constants.dart';
import '../../widgets/common/loading_widget.dart';
import '../../widgets/quiz/quiz_question.dart';
import '../../widgets/quiz/answer_option.dart';

class QuizScreen extends StatefulWidget {
  final int? quizId;
  final int? lessonId;

  const QuizScreen({
    Key? key,
    this.quizId,
    this.lessonId,
  }) : super(key: key);

  @override
  State<QuizScreen> createState() => _QuizScreenState();
}

class _QuizScreenState extends State<QuizScreen>
    with TickerProviderStateMixin {
  late AnimationController _fadeController;
  late AnimationController _timerController;
  late AnimationController _progressController;
  late AnimationController _pulseController;

  late Animation<double> _fadeAnimation;
  late Animation<double> _timerAnimation;
  late Animation<double> _progressAnimation;
  late Animation<double> _pulseAnimation;

  final PageController _pageController = PageController();
  bool _showResults = false;
  bool _canSubmit = false;
  QuizProvider get quizProvider => Provider.of<QuizProvider>(context, listen: false);

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _loadQuizData();
  }

  void _initializeAnimations() {
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _timerController = AnimationController(
      duration: const Duration(seconds: 1),
      vsync: this,
    );

    _progressController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );

    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0)
        .animate(CurvedAnimation(parent: _fadeController, curve: Curves.easeOut));

    _timerAnimation = Tween<double>(begin: 0.0, end: 1.0)
        .animate(CurvedAnimation(parent: _timerController, curve: Curves.linear));

    _progressAnimation = Tween<double>(begin: 0.0, end: 1.0)
        .animate(CurvedAnimation(parent: _progressController, curve: Curves.easeInOut));

    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.1)
        .animate(CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut));

    _fadeController.forward();
    _timerController.repeat();
    _pulseController.repeat(reverse: true);
  }

  void _loadQuizData() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final quizProvider = Provider.of<QuizProvider>(context, listen: false);

      if (widget.quizId != null) {
        quizProvider.loadQuizDetail(widget.quizId!);
      } else if (widget.lessonId != null) {
        // Load quiz for specific lesson
        final quiz = quizProvider.getQuizByLessonId(widget.lessonId!);
        if (quiz != null) {
          quizProvider.loadQuizDetail(quiz.id);
        }
      }
    });
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _timerController.dispose();
    _progressController.dispose();
    _pulseController.dispose();
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<QuizProvider>(
        builder: (context, quizProvider, child) {
      if (quizProvider.isLoadingQuizDetail) {
        return const Scaffold(
          body: Center(child: LoadingWidget()),
        );
      }

      if (quizProvider.error != null) {
        return _buildErrorState(quizProvider.error!);
      }

      final quiz = quizProvider.currentQuiz;
      if (quiz == null) {
        return const Scaffold(
          body: Center(child: Text('Quiz not found')),
        );
      }

      if (_showResults || quizProvider.lastResult != null) {
        return _buildResultsScreen(quizProvider.lastResult!);
      }

      if (!quizProvider.isQuizActive) {
        return _buildQuizIntro(quiz);
      }

      return _buildQuizInterface(quiz);
    });
  }

  Widget _buildErrorState(String error) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Quiz Error'),
        backgroundColor: const Color(AppConstants.primaryGreen),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFFF0FDF4),
              Color(0xFFFFFFFF),
            ],
          ),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.error_outline,
                size: 64,
                color: Color(0xFFEF4444),
              ),
              const SizedBox(height: 24),
              Text(
                'Error Loading Quiz',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Color(AppConstants.darkText),
                  fontFamily: 'Poppins',
                ),
              ),
              const SizedBox(height: 12),
              Text(
                error,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey[600],
                  fontFamily: 'Poppins',
                ),
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () => Navigator.pop(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(AppConstants.primaryGreen),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                child: const Text('Go Back'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildQuizIntro(QuizDetail quiz) {
    return Scaffold(
      appBar: AppBar(
        title: Text(quiz.title),
        backgroundColor: const Color(AppConstants.primaryGreen),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFFF0FDF4),
              Color(0xFFFFFFFF),
            ],
          ),
        ),
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: const Color(AppConstants.primaryGreen).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(24),
                  ),
                  child: Icon(
                    Icons.quiz_outlined,
                    size: 64,
                    color: const Color(AppConstants.primaryGreen),
                  ),
                ),
                const SizedBox(height: 32),
                Text(
                  quiz.title,
                  style: const TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Color(AppConstants.darkText),
                    fontFamily: 'Poppins',
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                Text(
                  quiz.description,
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey[600],
                    fontFamily: 'Poppins',
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 32),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _buildInfoCard(
                      Icons.question_answer,
                      '${quiz.questions.length} Questions',
                      const Color(AppConstants.primaryGreen),
                    ),
                    _buildInfoCard(
                      Icons.access_time,
                      '${quiz.estimatedDurationMinutes} min',
                      const Color(AppConstants.accentOrange),
                    ),
                    _buildInfoCard(
                      Icons.star,
                      '${quiz.difficulty}',
                      const Color(0xFF8B5CF6),
                    ),
                  ],
                ),
                const SizedBox(height: 48),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      final quizProvider = Provider.of<QuizProvider>(context, listen: false);
                      quizProvider.startQuiz();
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(AppConstants.primaryGreen),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    child: const Text(
                      'Start Quiz',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        fontFamily: 'Poppins',
                      ),
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

  Widget _buildInfoCard(IconData icon, String text, Color color) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: color, size: 24),
        ),
        const SizedBox(height: 8),
        Text(
          text,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: color,
            fontFamily: 'Poppins',
          ),
        ),
      ],
    );
  }

  Widget _buildQuizInterface(QuizDetail quiz) {
    return Scaffold(
      appBar: AppBar(
        title: Text('${quiz.title} - Quiz'),
        backgroundColor: const Color(AppConstants.primaryGreen),
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => _showExitDialog(),
        ),
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 16),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Text(
              '${quizProvider.currentQuestionIndex + 1}/${quiz.questions.length}',
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontFamily: 'Poppins',
              ),
            ),
          ),
        ],
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFFF0FDF4),
              Color(0xFFFFFFFF),
            ],
          ),
        ),
        child: Column(
          children: [
            // Progress Bar
            LinearProgressIndicator(
              value: (quizProvider.currentQuestionIndex + 1) / quiz.questions.length,
              backgroundColor: Colors.grey[200],
              valueColor: AlwaysStoppedAnimation<Color>(const Color(AppConstants.primaryGreen)),
            ),

            // Quiz Content
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: quiz.questions.length,
                itemBuilder: (context, index) {
                  final question = quiz.questions[index];
                  return FadeTransition(
                    opacity: _fadeAnimation,
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Question Number
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              color: const Color(AppConstants.primaryGreen).withOpacity(0.1),
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Text(
                              'Question ${index + 1}',
                              style: const TextStyle(
                                color: Color(AppConstants.primaryGreen),
                                fontWeight: FontWeight.w600,
                                fontFamily: 'Poppins',
                              ),
                            ),
                          ),
                          const SizedBox(height: 24),

                          // Question Text
                          Text(
                            question.questionText,
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Color(AppConstants.darkText),
                              fontFamily: 'Poppins',
                              height: 1.4,
                            ),
                          ),
                          const SizedBox(height: 32),

                          // Answer Options
                          Expanded(
                            child: ListView.builder(
                              itemCount: question.answers.length,
                              itemBuilder: (context, optionIndex) {
                                final option = question.answers[optionIndex];
                                final isSelected = quizProvider.selectedAnswers[index] == optionIndex;

                                return Padding(
                                  padding: const EdgeInsets.only(bottom: 12),
                                  child: AnimatedContainer(
                                    duration: const Duration(milliseconds: 200),
                                    transform: Matrix4.identity()..scale(isSelected ? 1.02 : 1.0),
                                    child: GestureDetector(
                                      onTap: () {
                                        quizProvider.selectAnswer(index, optionIndex);
                                        setState(() {
                                          _canSubmit = true;
                                        });
                                      },
                                      child: Container(
                                        padding: const EdgeInsets.all(16),
                                        decoration: BoxDecoration(
                                          color: isSelected
                                              ? const Color(AppConstants.primaryGreen)
                                              : Colors.white,
                                          borderRadius: BorderRadius.circular(12),
                                          border: Border.all(
                                            color: isSelected
                                                ? const Color(AppConstants.primaryGreen)
                                                : Colors.grey[300]!,
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
                                                  color: isSelected
                                                      ? Colors.white
                                                      : Colors.grey[400]!,
                                                  width: 2,
                                                ),
                                                color: isSelected ? Colors.white : Colors.transparent,
                                              ),
                                              child: isSelected
                                                  ? const Icon(
                                                      Icons.check,
                                                      size: 16,
                                                      color: Color(AppConstants.primaryGreen),
                                                    )
                                                  : null,
                                            ),
                                            const SizedBox(width: 12),
                                            Expanded(
                                              child: Text(
                                                option.answerText,
                                                style: TextStyle(
                                                  color: isSelected ? Colors.white : Color(AppConstants.darkText),
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
                              },
                            ),
                          ),

                          // Submit Button
                          const SizedBox(height: 24),
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              onPressed: _canSubmit ? _submitAnswer : null,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: _canSubmit
                                    ? const Color(AppConstants.primaryGreen)
                                    : Colors.grey[300],
                                foregroundColor: _canSubmit ? Colors.white : Colors.grey[500],
                                padding: const EdgeInsets.symmetric(vertical: 16),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16),
                                ),
                              ),
                              child: const Text(
                                'Submit Answer',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  fontFamily: 'Poppins',
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _submitAnswer() {
    final quizProvider = Provider.of<QuizProvider>(context, listen: false);
    quizProvider.submitCurrentAnswer();

    setState(() {
      _canSubmit = false;
    });

    // Move to next question or show results
    if (quizProvider.currentQuestionIndex < quizProvider.currentQuiz!.questions.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      // Show results after a delay
      Future.delayed(const Duration(seconds: 1), () {
        setState(() {
          _showResults = true;
        });
      });
    }
  }

  void _showExitDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Exit Quiz'),
        content: const Text('Are you sure you want to exit? Your progress will be lost.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context), // This will pop the dialog
            child: const Text('Continue'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context); // Pop dialog
              Navigator.pop(context); // Pop quiz screen
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Exit'),
          ),
        ],
      ),
    );
  }

  Widget _buildResultsScreen(QuizResult result) {
    final quiz = result.quiz;
    final score = result.score;
    final totalQuestions = quiz.questions.length;
    final percentage = (score / totalQuestions * 100).round();

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFFF0FDF4),
              Color(0xFFFFFFFF),
            ],
          ),
        ),
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Result Icon
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: percentage >= 70
                        ? const Color(0xFF10B981).withOpacity(0.1)
                        : const Color(AppConstants.accentOrange).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(24),
                  ),
                  child: Icon(
                    percentage >= 70 ? Icons.celebration : Icons.trending_up,
                    size: 64,
                    color: percentage >= 70
                        ? const Color(0xFF10B981)
                        : const Color(AppConstants.accentOrange),
                  ),
                ),
                const SizedBox(height: 32),

                // Result Text
                Text(
                  percentage >= 70 ? 'Congratulations!' : 'Good Effort!',
                  style: const TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Color(AppConstants.darkText),
                    fontFamily: 'Poppins',
                  ),
                ),
                const SizedBox(height: 16),

                // Score
                Text(
                  '$score/$totalQuestions',
                  style: TextStyle(
                    fontSize: 48,
                    fontWeight: FontWeight.bold,
                    color: percentage >= 70
                        ? const Color(0xFF10B981)
                        : const Color(AppConstants.accentOrange),
                    fontFamily: 'Poppins',
                  ),
                ),
                Text(
                  '$percentage% Correct',
                  style: TextStyle(
                    fontSize: 18,
                    color: Colors.grey[600],
                    fontFamily: 'Poppins',
                  ),
                ),
                const SizedBox(height: 32),

                // Action Buttons
                Column(
                  children: [
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () {
                          final quizProvider = Provider.of<QuizProvider>(context, listen: false);
                          quizProvider.resetQuiz();
                          setState(() {
                            _showResults = false;
                          });
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(AppConstants.primaryGreen),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                        child: const Text(
                          'Try Again',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            fontFamily: 'Poppins',
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton(
                        onPressed: () => Navigator.pop(context),
                        style: OutlinedButton.styleFrom(
                          side: const BorderSide(color: Color(AppConstants.primaryGreen)),
                          foregroundColor: const Color(AppConstants.primaryGreen),
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                        child: const Text(
                          'Back to Home',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            fontFamily: 'Poppins',
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}