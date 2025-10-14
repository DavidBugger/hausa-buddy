class PaginatedResponse<T> {
  final int count;
  final String? next;
  final String? previous;
  final int totalPages;
  final int currentPage;
  final List<T> results;

  PaginatedResponse({
    required this.count,
    this.next,
    this.previous,
    required this.totalPages,
    required this.currentPage,
    required this.results,
  });

  factory PaginatedResponse.fromJson(
      Map<String, dynamic> json,
      T Function(Map<String, dynamic>) fromJsonT,
      ) {
    return PaginatedResponse<T>(
      count: json['count'],
      next: json['next'],
      previous: json['previous'],
      totalPages: json['total_pages'],
      currentPage: json['current_page'],
      results: (json['results'] as List)
          .map((item) => fromJsonT(item as Map<String, dynamic>))
          .toList(),
    );
  }

  bool get hasNext => next != null;
  bool get hasPrevious => previous != null;
  bool get isEmpty => results.isEmpty;
  int get length => results.length;
}

late final String name;
late final int level;
late final String color;


class Difficulty {
  final int id; // Added id as it's used in your intended constructor
  final String name;
  final int level;
  final String color;

  // Constructor using initializing formal parameters
  Difficulty({
    required this.id,
    required this.name,
    required this.level,
    required this.color,
  });

  // You can add other methods or factory constructors here if needed
  // For example, a fromJson factory constructor:
  factory Difficulty.fromJson(Map<String, dynamic> json) {
    return Difficulty(
      id: json['id'] as int,
      name: json['name'] as String,
      level: json['level'] as int,
      color: json['color'] as String,
    );
  }

  // Example: toJson method
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'level': level,
      'color': color,
    };
  }

  // Example: a copyWith method for immutability (optional but good practice)
  Difficulty copyWith({
    int? id,
    String? name,
    int? level,
    String? color,
  }) {
    return Difficulty(
        id: id ?? this.id,
        name: name ?? this.name,
        level: level ?? this.level,
        color: color ?? this.color,
    );
  }
}