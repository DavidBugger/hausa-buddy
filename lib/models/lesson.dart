import 'package:hive/hive.dart';

@HiveType(typeId: 3)
class Category {
  @HiveField(0)
  final int id;
  @HiveField(1)
  final String name;
  @HiveField(2)
  final String slug;
  @HiveField(3)
  final String description;
  @HiveField(4)
  final String? icon;
  @HiveField(5)
  final String color;
  @HiveField(6)
  final int order;
  @HiveField(7)
  final bool isActive;
  @HiveField(8)
  final int lessonsCount;

  Category({
    required this.id,
    required this.name,
    required this.slug,
    required this.description,
    this.icon,
    required this.color,
    required this.order,
    required this.isActive,
    required this.lessonsCount,
  });

  factory Category.fromJson(Map<String, dynamic> json) {
    return Category(
      id: json['id'],
      name: json['name'],
      slug: json['slug'],
      description: json['description'] ?? '',
      icon: json['icon'],
      color: json['color'],
      order: json['order'],
      isActive: json['is_active'],
      lessonsCount: json['lessons_count'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'slug': slug,
      'description': description,
      'icon': icon,
      'color': color,
      'order': order,
      'is_active': isActive,
      'lessons_count': lessonsCount,
    };
  }
}

class Difficulty {
  final int id;
  final String name;
  final int level;
  final String color;

  Difficulty({
    required this.id,
    required this.name,
    required this.level,
    required this.color,
  });

  factory Difficulty.fromJson(Map<String, dynamic> json) {
    return Difficulty(
      id: json['id'],
      name: json['name'],
      level: json['level'],
      color: json['color'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'level': level,
      'color': color,
    };
  }
}

@HiveType(typeId: 4)
class Lesson {
  @HiveField(0)
  final int id;
  @HiveField(1)
  final String title;
  @HiveField(2)
  final String slug;
  @HiveField(3)
  final String description;
  @HiveField(4)
  final String categoryName;
  @HiveField(5)
  final String difficultyName;
  @HiveField(6)
  final int estimatedDurationMinutes;
  @HiveField(7)
  final bool isPremium;
  @HiveField(8)
  final bool isCompleted;
  @HiveField(9)
  final String difficulty;
  @HiveField(10)
  final double rating;

  Lesson({
    required this.id,
    required this.title,
    required this.slug,
    required this.description,
    required this.categoryName,
    required this.difficultyName,
    required this.estimatedDurationMinutes,
    required this.isPremium,
    required this.isCompleted,
    required this.difficulty,
    required this.rating,
  });

  factory Lesson.fromJson(Map<String, dynamic> json) {
    return Lesson(
      id: json['id'],
      title: json['title'],
      slug: json['slug'],
      description: json['description'],
      categoryName: json['category_name'] ?? '',
      difficultyName: json['difficulty_name'] ?? '',
      estimatedDurationMinutes: json['estimated_duration_minutes'] ?? 5,
      isPremium: json['is_premium'] ?? false,
      isCompleted: json['is_completed'] ?? false,
      difficulty: json['difficulty'] ?? 'Beginner',
      rating: (json['rating'] ?? 0).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'slug': slug,
      'description': description,
      'category_name': categoryName,
      'difficulty_name': difficultyName,
      'estimated_duration_minutes': estimatedDurationMinutes,
      'is_premium': isPremium,
      'is_completed': isCompleted,
      'difficulty': difficulty,
      'rating': rating,
    };
  }
}

class LessonDetail {
  final int id;
  final String title;
  final String slug;
  final String description;
  final String content;
  final Category category;
  final Difficulty difficulty;
  final int order;
  final int estimatedDurationMinutes;
  final bool isPremium;
  final bool isPublished;
  final List<LessonContent> lessonContent;
  final List<Vocabulary> vocabulary;
  final DateTime createdAt;
  final DateTime updatedAt;

  LessonDetail({
    required this.id,
    required this.title,
    required this.slug,
    required this.description,
    required this.content,
    required this.category,
    required this.difficulty,
    required this.order,
    required this.estimatedDurationMinutes,
    required this.isPremium,
    required this.isPublished,
    required this.lessonContent,
    required this.vocabulary,
    required this.createdAt,
    required this.updatedAt,
  });

  factory LessonDetail.fromJson(Map<String, dynamic> json) {
    return LessonDetail(
      id: json['id'],
      title: json['title'],
      slug: json['slug'],
      description: json['description'],
      content: json['content'],
      category: Category.fromJson(json['category']),
      difficulty: Difficulty.fromJson(json['difficulty']),
      order: json['order'],
      estimatedDurationMinutes: json['estimated_duration_minutes'],
      isPremium: json['is_premium'],
      isPublished: json['is_published'],
      lessonContent: (json['lesson_content'] as List)
          .map((item) => LessonContent.fromJson(item))
          .toList(),
      vocabulary: (json['vocabulary'] as List)
          .map((item) => Vocabulary.fromJson(item))
          .toList(),
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
    );
  }
}

class LessonContent {
  final int id;
  final String hausaText;
  final String englishTranslation;
  final String pronunciationGuide;
  final String? audioFile;
  final String? image;
  final int order;
  final String contentType;

  LessonContent({
    required this.id,
    required this.hausaText,
    required this.englishTranslation,
    required this.pronunciationGuide,
    this.audioFile,
    this.image,
    required this.order,
    required this.contentType,
  });

  factory LessonContent.fromJson(Map<String, dynamic> json) {
    return LessonContent(
      id: json['id'],
      hausaText: json['hausa_text'],
      englishTranslation: json['english_translation'],
      pronunciationGuide: json['pronunciation_guide'] ?? '',
      audioFile: json['audio_file'],
      image: json['image'],
      order: json['order'],
      contentType: json['content_type'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'hausa_text': hausaText,
      'english_translation': englishTranslation,
      'pronunciation_guide': pronunciationGuide,
      'audio_file': audioFile,
      'image': image,
      'order': order,
      'content_type': contentType,
    };
  }
}

class Vocabulary {
  final int id;
  final String hausaWord;
  final String englishMeaning;
  final String pronunciation;
  final String? audioFile;
  final String exampleSentenceHausa;
  final String exampleSentenceEnglish;
  final String wordType;

  Vocabulary({
    required this.id,
    required this.hausaWord,
    required this.englishMeaning,
    required this.pronunciation,
    this.audioFile,
    required this.exampleSentenceHausa,
    required this.exampleSentenceEnglish,
    required this.wordType,
  });

  factory Vocabulary.fromJson(Map<String, dynamic> json) {
    return Vocabulary(
      id: json['id'],
      hausaWord: json['hausa_word'],
      englishMeaning: json['english_meaning'],
      pronunciation: json['pronunciation'] ?? '',
      audioFile: json['audio_file'],
      exampleSentenceHausa: json['example_sentence_hausa'] ?? '',
      exampleSentenceEnglish: json['example_sentence_english'] ?? '',
      wordType: json['word_type'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'hausa_word': hausaWord,
      'english_meaning': englishMeaning,
      'pronunciation': pronunciation,
      'audio_file': audioFile,
      'example_sentence_hausa': exampleSentenceHausa,
      'example_sentence_english': exampleSentenceEnglish,
      'word_type': wordType,
    };
  }
}
