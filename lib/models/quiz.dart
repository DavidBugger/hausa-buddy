class Quiz {
  final int id;
  final String title;
  final String description;
  final String lessonTitle;
  final int timeLimitMinutes;
  final int passingScore;
  final int questionsCount;
  final int? userBestScore;
  final int estimatedDurationMinutes;
  final String difficulty;
  final List<Question> questions;

  Quiz({
    required this.id,
    required this.title,
    required this.description,
    required this.lessonTitle,
    required this.timeLimitMinutes,
    required this.passingScore,
    required this.questionsCount,
    this.userBestScore,
    required this.estimatedDurationMinutes,
    required this.difficulty,
    required this.questions,
  });

  factory Quiz.fromJson(Map<String, dynamic> json) {
    return Quiz(
      id: json['id'],
      title: json['title'],
      description: json['description'],
      lessonTitle: json['lesson_title'] ?? '',
      timeLimitMinutes: json['time_limit_minutes'],
      passingScore: json['passing_score'],
      questionsCount: json['questions_count'] ?? 0,
      userBestScore: json['user_best_score'],
      estimatedDurationMinutes: json['estimated_duration_minutes'] ?? 10,
      difficulty: json['difficulty'] ?? 'Beginner',
      questions: (json['questions'] as List)
          .map((item) => Question.fromJson(item))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'lesson_title': lessonTitle,
      'time_limit_minutes': timeLimitMinutes,
      'passing_score': passingScore,
      'questions_count': questionsCount,
      'user_best_score': userBestScore,
      'estimated_duration_minutes': estimatedDurationMinutes,
      'difficulty': difficulty,
      'questions': questions.map((question) => question.toJson()).toList(),
    };
  }
}

class QuizDetail {
  final int id;
  final String title;
  final String description;
  final int lessonId;
  final int timeLimitMinutes;
  final int passingScore;
  final bool isActive;
  final List<Question> questions;
  final DateTime createdAt;
  final DateTime updatedAt;
  final int estimatedDurationMinutes;
  final String difficulty;

  QuizDetail({
    required this.id,
    required this.title,
    required this.description,
    required this.lessonId,
    required this.timeLimitMinutes,
    required this.passingScore,
    required this.isActive,
    required this.questions,
    required this.createdAt,
    required this.updatedAt,
    required this.estimatedDurationMinutes,
    required this.difficulty,
  });

  factory QuizDetail.fromJson(Map<String, dynamic> json) {
    return QuizDetail(
      id: json['id'],
      title: json['title'],
      description: json['description'],
      lessonId: json['lesson'],
      timeLimitMinutes: json['time_limit_minutes'],
      passingScore: json['passing_score'],
      isActive: json['is_active'],
      questions: (json['questions'] as List)
          .map((item) => Question.fromJson(item))
          .toList(),
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
      estimatedDurationMinutes: json['estimated_duration_minutes'] ?? 10,
      difficulty: json['difficulty'] ?? 'Beginner',
    );
  }
}

class Question {
  final int id;
  final String questionText;
  final String? questionAudio;
  final String questionType;
  final int points;
  final int order;
  final List<Answer> answers;

  Question({
    required this.id,
    required this.questionText,
    this.questionAudio,
    required this.questionType,
    required this.points,
    required this.order,
    required this.answers,
  });

  factory Question.fromJson(Map<String, dynamic> json) {
    return Question(
      id: json['id'],
      questionText: json['question_text'],
      questionAudio: json['question_audio'],
      questionType: json['question_type'],
      points: json['points'],
      order: json['order'],
      answers: (json['answers'] as List)
          .map((item) => Answer.fromJson(item))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'question_text': questionText,
      'question_audio': questionAudio,
      'question_type': questionType,
      'points': points,
      'order': order,
      'answers': answers.map((answer) => answer.toJson()).toList(),
    };
  }
}

class Answer {
  final int id;
  final String answerText;
  final bool isCorrect;
  final int order;

  Answer({
    required this.id,
    required this.answerText,
    required this.isCorrect,
    required this.order,
  });

  factory Answer.fromJson(Map<String, dynamic> json) {
    return Answer(
      id: json['id'],
      answerText: json['answer_text'],
      isCorrect: json['is_correct'] ?? false,
      order: json['order'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'answer_text': answerText,
      'is_correct': isCorrect,
      'order': order,
    };
  }
}

class QuizAttempt {
  final int id;
  final int quizId;
  final int score;
  final int totalQuestions;
  final int timeSpentMinutes;
  final bool completed;
  final DateTime? completedAt;
  final DateTime createdAt;

  QuizAttempt({
    required this.id,
    required this.quizId,
    required this.score,
    required this.totalQuestions,
    required this.timeSpentMinutes,
    required this.completed,
    this.completedAt,
    required this.createdAt,
  });

  factory QuizAttempt.fromJson(Map<String, dynamic> json) {
    return QuizAttempt(
      id: json['id'],
      quizId: json['quiz'],
      score: json['score'] ?? 0,
      totalQuestions: json['total_questions'],
      timeSpentMinutes: json['time_taken_minutes'] ?? 0,
      completed: json['completed'],
      completedAt: json['completed_at'] != null
          ? DateTime.parse(json['completed_at'])
          : null,
      createdAt: DateTime.parse(json['created_at']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'quiz': quizId,
      'score': score,
      'total_questions': totalQuestions,
      'time_taken_minutes': timeSpentMinutes,
      'completed': completed,
      'completed_at': completedAt?.toIso8601String(),
      'created_at': createdAt.toIso8601String(),
    };
  }
}

class UserAnswer {
  final int questionId;
  final int? selectedAnswerId;
  final String? textAnswer;

  UserAnswer({
    required this.questionId,
    this.selectedAnswerId,
    this.textAnswer,
  });

  factory UserAnswer.fromJson(Map<String, dynamic> json) {
    return UserAnswer(
      questionId: json['question'],
      selectedAnswerId: json['selected_answer'],
      textAnswer: json['text_answer'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'question': questionId,
      'selected_answer': selectedAnswerId,
      'text_answer': textAnswer ?? '',
    };
  }
}

class QuizResult {
  final double score;
  final bool passed;
  final int totalQuestions;
  final int correctAnswers;
  final int timeSpent;
  final String message;
  final Quiz quiz;

  QuizResult({
    required this.score,
    required this.passed,
    required this.totalQuestions,
    required this.correctAnswers,
    required this.timeSpent,
    required this.message,
    required this.quiz,
  });

  factory QuizResult.fromJson(Map<String, dynamic> json) {
    return QuizResult(
      score: json['score'].toDouble(),
      passed: json['passed'],
      totalQuestions: json['total_questions'],
      correctAnswers: json['correct_answers'] ?? 0,
      timeSpent: json['time_taken'],
      message: json['message'],
      quiz: Quiz.fromJson(json['quiz']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'score': score,
      'passed': passed,
      'total_questions': totalQuestions,
      'correct_answers': correctAnswers,
      'time_taken': timeSpent,
      'message': message,
      'quiz': quiz.toJson(),
    };
  }
}
