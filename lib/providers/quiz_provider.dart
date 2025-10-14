import 'dart:async';
import 'package:flutter/material.dart';
import '../models/quiz.dart';
import '../services/quiz_service.dart';

class QuizProvider with ChangeNotifier {
  final QuizService _quizService = QuizService();

  List<Quiz> _quizzes = [];
  QuizDetail? _currentQuiz;
  QuizAttempt? _currentAttempt;
  List<UserAnswer> _userAnswers = [];
  QuizResult? _lastResult;

  bool _isLoading = false;
  bool _isLoadingQuizDetail = false;
  bool _isSubmitting = false;
  String? _error;

  // Quiz state
  int _currentQuestionIndex = 0;
  Timer? _quizTimer;
  int _timeRemainingSeconds = 0;
  bool _isQuizActive = false;
  List<int> _selectedAnswers = [];

  // Getters
  List<Quiz> get quizzes => _quizzes;
  QuizDetail? get currentQuiz => _currentQuiz;
  QuizAttempt? get currentAttempt => _currentAttempt;
  List<UserAnswer> get userAnswers => _userAnswers;
  QuizResult? get lastResult => _lastResult;
  bool get isLoading => _isLoading;
  bool get isLoadingQuizDetail => _isLoadingQuizDetail;
  bool get isSubmitting => _isSubmitting;
  String? get error => _error;

  // Quiz state getters
  int get currentQuestionIndex => _currentQuestionIndex;
  int get timeRemainingSeconds => _timeRemainingSeconds;
  bool get isQuizActive => _isQuizActive;
  List<int> get selectedAnswers => _selectedAnswers;

  // Question navigation
  Question? get currentQuestion => _currentQuiz?.questions.isNotEmpty == true
      ? _currentQuiz!.questions[_currentQuestionIndex]
      : null;
  bool get canGoToNextQuestion => _currentQuestionIndex < (_currentQuiz?.questions.length ?? 0) - 1;
  bool get canGoToPreviousQuestion => _currentQuestionIndex > 0;

  // Progress
  double get quizProgress => _currentQuiz?.questions.isNotEmpty == true
      ? (_currentQuestionIndex + 1) / _currentQuiz!.questions.length
      : 0.0;
  int get answeredQuestionsCount => _userAnswers.length;
  bool get isQuizComplete => _userAnswers.length == (_currentQuiz?.questions.length ?? 0);

  // Initialize quiz data
  Future<void> initialize() async {
    await loadQuizzes();
  }

  // Load all quizzes
  Future<void> loadQuizzes() async {
    _setLoading(true);
    _clearError();

    try {
      final response = await _quizService.getQuizzes();
      if (response.isSuccess) {
        _quizzes = response.data!;
        notifyListeners();
      } else {
        _setError(response.error!);
      }
    } catch (e) {
      _setError('Failed to load quizzes: ${e.toString()}');
    } finally {
      _setLoading(false);
    }
  }

  // Load quiz detail
  Future<void> loadQuizDetail(int quizId) async {
    _setLoadingQuizDetail(true);
    _clearError();

    try {
      final response = await _quizService.getQuizDetail(quizId);
      if (response.isSuccess) {
        _currentQuiz = response.data!;
        _resetQuizState();
        notifyListeners();
      } else {
        _setError(response.error!);
      }
    } catch (e) {
      _setError('Failed to load quiz: ${e.toString()}');
    } finally {
      _setLoadingQuizDetail(false);
    }
  }

  // Start quiz attempt
  Future<bool> startQuizAttempt(int quizId) async {
    _clearError();

    try {
      final response = await _quizService.startQuizAttempt(quizId);
      if (response.isSuccess) {
        _currentAttempt = response.data!;
        _startTimer();
        _isQuizActive = true;
        notifyListeners();
        return true;
      } else {
        _setError(response.error!);
        return false;
      }
    } catch (e) {
      _setError('Failed to start quiz: ${e.toString()}');
      return false;
    }
  }

  // Start quiz timer
  void _startTimer() {
    if (_currentQuiz == null) return;

    _timeRemainingSeconds = _currentQuiz!.timeLimitMinutes * 60;
    _quizTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_timeRemainingSeconds > 0) {
        _timeRemainingSeconds--;
        notifyListeners();
      } else {
        _submitQuiz(); // Auto-submit when time runs out
      }
    });
  }

  // Stop quiz timer
  void _stopTimer() {
    _quizTimer?.cancel();
    _quizTimer = null;
  }

  // Answer question
  void answerQuestion(int questionId, {int? selectedAnswerId, String? textAnswer}) {
    // Remove existing answer for this question
    _userAnswers.removeWhere((answer) => answer.questionId == questionId);

    // Add new answer
    _userAnswers.add(UserAnswer(
      questionId: questionId,
      selectedAnswerId: selectedAnswerId,
      textAnswer: textAnswer,
    ));

    notifyListeners();
  }

  // Get user answer for question
  UserAnswer? getUserAnswer(int questionId) {
    return _userAnswers
        .where((answer) => answer.questionId == questionId)
        .firstOrNull;
  }

  // Navigate to next question
  void nextQuestion() {
    if (canGoToNextQuestion) {
      _currentQuestionIndex++;
      notifyListeners();
    }
  }

  // Navigate to previous question
  void previousQuestion() {
    if (canGoToPreviousQuestion) {
      _currentQuestionIndex--;
      notifyListeners();
    }
  }

  // Go to specific question
  void goToQuestion(int index) {
    if (index >= 0 && index < (_currentQuiz?.questions.length ?? 0)) {
      _currentQuestionIndex = index;
      notifyListeners();
    }
  }

  // Submit quiz
  Future<bool> _submitQuiz() async {
    if (_currentAttempt == null) return false;

    _setSubmitting(true);
    _stopTimer();
    _isQuizActive = false;

    try {
      final timeSpentMinutes = _currentQuiz != null
          ? _currentQuiz!.timeLimitMinutes - (_timeRemainingSeconds ~/ 60)
          : 0;

      final response = await _quizService.submitQuiz(
        _currentAttempt!.id,
        _userAnswers,
        timeSpentMinutes,
      );

      if (response.isSuccess) {
        _lastResult = response.data!;
        notifyListeners();
        return true;
      } else {
        _setError(response.error!);
        return false;
      }
    } catch (e) {
      _setError('Failed to submit quiz: ${e.toString()}');
      return false;
    } finally {
      _setSubmitting(false);
    }
  }

  // Manual submit quiz
  Future<bool> submitQuiz() async {
    return await _submitQuiz();
  }

  // Start quiz
  void startQuiz() {
    _isQuizActive = true;
    _selectedAnswers = List.filled(_currentQuiz?.questions.length ?? 0, -1);
    _startTimer();
    notifyListeners();
  }

  // Select answer for current question
  void selectAnswer(int questionIndex, int answerIndex) {
    if (questionIndex >= 0 && questionIndex < _selectedAnswers.length) {
      _selectedAnswers[questionIndex] = answerIndex;
      notifyListeners();
    }
  }

  // Submit current answer
  void submitCurrentAnswer() {
    if (_currentQuestionIndex >= 0 && _currentQuestionIndex < _selectedAnswers.length) {
      final selectedAnswer = _selectedAnswers[_currentQuestionIndex];
      if (selectedAnswer >= 0 && _currentQuiz != null) {
        answerQuestion(
          _currentQuiz!.questions[_currentQuestionIndex].id,
          selectedAnswerId: _currentQuiz!.questions[_currentQuestionIndex].answers[selectedAnswer].id,
        );
      }
    }
  }

  // Reset quiz state
  void _resetQuizState() {
    _currentQuestionIndex = 0;
    _userAnswers.clear();
    _currentAttempt = null;
    _lastResult = null;
    _timeRemainingSeconds = 0;
    _isQuizActive = false;
    _selectedAnswers.clear();
    _stopTimer();
  }

  // Reset quiz state
  void resetQuiz() {
    _resetQuizState();
    notifyListeners();
  }

  // Exit quiz
  void exitQuiz() {
    _resetQuizState();
    _currentQuiz = null;
    notifyListeners();
  }

  // Get quiz by lesson ID
  Quiz? getQuizByLessonId(int lessonId) {
    // This would require the quiz model to have lessonId
    // For now, return first quiz as placeholder
    return _quizzes.isNotEmpty ? _quizzes.first : null;
  }

  // Format time remaining
  String get formattedTimeRemaining {
    final minutes = _timeRemainingSeconds ~/ 60;
    final seconds = _timeRemainingSeconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  // Check if quiz is passed
  bool get isQuizPassed => _lastResult?.passed ?? false;

  // Get quiz score percentage
  double get quizScorePercentage => _lastResult?.score ?? 0.0;

  // Private helper methods
  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void _setLoadingQuizDetail(bool loading) {
    _isLoadingQuizDetail = loading;
    notifyListeners();
  }

  void _setSubmitting(bool submitting) {
    _isSubmitting = submitting;
    notifyListeners();
  }

  void _setError(String error) {
    _error = error;
    notifyListeners();
  }

  void _clearError() {
    _error = null;
    notifyListeners();
  }

  @override
  void dispose() {
    _stopTimer();
    super.dispose();
  }
}