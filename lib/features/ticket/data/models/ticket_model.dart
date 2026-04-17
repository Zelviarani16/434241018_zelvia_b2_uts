class TicketModel {
  final String id;
  final String title;
  final String description;
  final String status;
  final String priority;
  final String category;
  final String createdBy;
  final String? assignedTo;
  final DateTime createdAt;
  final DateTime updatedAt;
  final List<TicketComment> comments;
  final List<String> attachments;

  TicketModel({
    required this.id,
    required this.title,
    required this.description,
    required this.status,
    required this.priority,
    required this.category,
    required this.createdBy,
    this.assignedTo,
    required this.createdAt,
    required this.updatedAt,
    this.comments = const [],
    this.attachments = const [],
  });

  factory TicketModel.fromJson(Map<String, dynamic> json) {
    return TicketModel(
      id: json['id']?.toString() ?? '',
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      status: json['status'] ?? 'open',
      priority: json['priority'] ?? 'medium',
      category: json['category'] ?? '',
      createdBy: json['created_by']?.toString() ?? '',
      assignedTo: json['assigned_to']?.toString(),
      createdAt: DateTime.tryParse(json['created_at'] ?? '') ?? DateTime.now(),
      updatedAt: DateTime.tryParse(json['updated_at'] ?? '') ?? DateTime.now(),
      comments: (json['comments'] as List?)
          ?.map((e) => TicketComment.fromJson(e))
          .toList() ??
          [],
      attachments: List<String>.from(json['attachments'] ?? []),
    );
  }
}

class TicketComment {
  final String id;
  final String content;
  final String authorName;
  final String authorRole;
  final DateTime createdAt;

  TicketComment({
    required this.id,
    required this.content,
    required this.authorName,
    required this.authorRole,
    required this.createdAt,
  });

  factory TicketComment.fromJson(Map<String, dynamic> json) {
    return TicketComment(
      id: json['id']?.toString() ?? '',
      content: json['content'] ?? '',
      authorName: json['author_name'] ?? '',
      authorRole: json['author_role'] ?? 'user',
      createdAt:
      DateTime.tryParse(json['created_at'] ?? '') ?? DateTime.now(),
    );
  }
}

class TicketStatsModel {
  final int total;
  final int open;
  final int inProgress;
  final int resolved;
  final int closed;

  TicketStatsModel({
    required this.total,
    required this.open,
    required this.inProgress,
    required this.resolved,
    required this.closed,
  });
}