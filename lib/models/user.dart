import 'package:hive/hive.dart';

@HiveType(typeId: 0)
class User {
  @HiveField(0)
  final int id;
  @HiveField(1)
  final String email;
  @HiveField(2)
  final String username;
  @HiveField(3)
  final String firstName;
  @HiveField(4)
  final String lastName;
  @HiveField(5)
  final String? profilePicture;
  @HiveField(6)
  final int learningStreak;
  @HiveField(7)
  final int totalLessonsCompleted;
  @HiveField(8)
  final int totalPoints;
  @HiveField(9)
  final UserProfile? profile;
  @HiveField(10)
  final DateTime dateJoined;

  User({
    required this.id,
    required this.email,
    required this.username,
    required this.firstName,
    required this.lastName,
    this.profilePicture,
    required this.learningStreak,
    required this.totalLessonsCompleted,
    required this.totalPoints,
    this.profile,
    required this.dateJoined,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] ?? 0,
      email: json['email'] ?? '',
      username: json['username'] ?? '',
      firstName: json['first_name'] ?? '',
      lastName: json['last_name'] ?? '',
      profilePicture: json['profile_picture'],
      learningStreak: json['learning_streak'] ?? 0,
      totalLessonsCompleted: json['total_lessons_completed'] ?? 0,
      totalPoints: json['total_points'] ?? 0,
      profile: json['profile'] != null
          ? UserProfile.fromJson(Map<String, dynamic>.from(json['profile']))
          : null,
      dateJoined: json['date_joined'] != null
          ? DateTime.parse(json['date_joined'])
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'username': username,
      'first_name': firstName,
      'last_name': lastName,
      'profile_picture': profilePicture,
      'learning_streak': learningStreak,
      'total_lessons_completed': totalLessonsCompleted,
      'total_points': totalPoints,
      'profile': profile?.toJson(),
      'date_joined': dateJoined.toIso8601String(),
    };
  }

  String get fullName => '$firstName $lastName';
  String get initials => '${firstName.isNotEmpty ? firstName[0] : ''}${lastName.isNotEmpty ? lastName[0] : ''}';
}

@HiveType(typeId: 1)
class UserProfile {
  @HiveField(0)
  final String bio;
  @HiveField(1)
  final String preferredLanguage;
  @HiveField(2)
  final String learningGoal;
  @HiveField(3)
  final int dailyGoalMinutes;
  @HiveField(4)
  final bool notificationsEnabled;
  @HiveField(5)
  final DateTime? lastLessonDate;

  UserProfile({
    required this.bio,
    required this.preferredLanguage,
    required this.learningGoal,
    required this.dailyGoalMinutes,
    required this.notificationsEnabled,
    this.lastLessonDate,
  });

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    return UserProfile(
      bio: json['bio'] ?? '',
      preferredLanguage: json['preferred_language'] ?? 'en',
      learningGoal: json['learning_goal'] ?? 'basic',
      dailyGoalMinutes: json['daily_goal_minutes'] ?? 15,
      notificationsEnabled: json['notifications_enabled'] ?? true,
      lastLessonDate: json['last_lesson_date'] != null
          ? DateTime.parse(json['last_lesson_date'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'bio': bio,
      'preferred_language': preferredLanguage,
      'learning_goal': learningGoal,
      'daily_goal_minutes': dailyGoalMinutes,
      'notifications_enabled': notificationsEnabled,
      'last_lesson_date': lastLessonDate?.toIso8601String(),
    };
  }
}

@HiveType(typeId: 5)
class UserProgress {
  @HiveField(0)
  final int id;
  @HiveField(1)
  final int lessonId;
  @HiveField(2)
  final String lessonTitle;
  @HiveField(3)
  final bool completed;
  @HiveField(4)
  final DateTime? completionDate;
  @HiveField(5)
  final int? score;
  @HiveField(6)
  final int timeSpentMinutes;

  UserProgress({
    required this.id,
    required this.lessonId,
    required this.lessonTitle,
    required this.completed,
    this.completionDate,
    this.score,
    required this.timeSpentMinutes,
  });

  factory UserProgress.fromJson(Map<String, dynamic> json) {
    return UserProgress(
      id: json['id'] ?? 0,
      lessonId: json['lesson'] ?? 0,
      lessonTitle: json['lesson_title'] ?? '',
      completed: json['completed'] ?? false,
      completionDate: json['completion_date'] != null
          ? DateTime.parse(json['completion_date'])
          : null,
      score: json['score'],
      timeSpentMinutes: json['time_spent_minutes'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'lesson': lessonId,
      'lesson_title': lessonTitle,
      'completed': completed,
      'completion_date': completionDate?.toIso8601String(),
      'score': score,
      'time_spent_minutes': timeSpentMinutes,
    };
  }
}

class UserStatistics {
  final int learningStreak;
  final int totalLessonsCompleted;
  final int totalPoints;
  final int weeklyLessons;
  final QuizStatistics quizStatistics;
  final DateTime joinDate;
  final DateTime? lastActivity;

  UserStatistics({
    required this.learningStreak,
    required this.totalLessonsCompleted,
    required this.totalPoints,
    required this.weeklyLessons,
    required this.quizStatistics,
    required this.joinDate,
    this.lastActivity,
  });

  factory UserStatistics.fromJson(Map<String, dynamic> json) {
    return UserStatistics(
      learningStreak: json['learning_streak'] ?? 0,
      totalLessonsCompleted: json['total_lessons_completed'] ?? 0,
      totalPoints: json['total_points'] ?? 0,
      weeklyLessons: json['weekly_lessons'] ?? 0,
      quizStatistics: QuizStatistics.fromJson(Map<String, dynamic>.from(json['quiz_statistics'] ?? {})),
      joinDate: json['join_date'] != null
          ? DateTime.parse(json['join_date'])
          : DateTime.now(),
      lastActivity: json['last_activity'] != null
          ? DateTime.parse(json['last_activity'])
          : null,
    );
  }
}

class QuizStatistics {
  final int totalQuizzes;
  final double averageScore;

  QuizStatistics({
    required this.totalQuizzes,
    required this.averageScore,
  });

  factory QuizStatistics.fromJson(Map<String, dynamic> json) {
    return QuizStatistics(
      totalQuizzes: json['total_quizzes'] ?? 0,
      averageScore: (json['avg_score'] ?? 0.0).toDouble(),
    );
  }
}