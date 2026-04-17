import 'package:ticketing_434241018_zelvia_b2_uts/features/ticket/data/models/ticket_model.dart';

// Global list agar CRUD tampil real-time di semua halaman
List<TicketModel> globalTickets = [
  TicketModel(
    id: '1',
    title: 'Komputer tidak bisa menyala',
    description: 'Komputer di ruang lab 3 tiba-tiba tidak bisa dinyalakan sejak pagi.',
    status: 'open',
    priority: 'high',
    category: 'Hardware',
    createdBy: '1', // milik user id=1
    createdAt: DateTime.now().subtract(const Duration(hours: 2)),
    updatedAt: DateTime.now().subtract(const Duration(hours: 2)),
  ),
  TicketModel(
    id: '2',
    title: 'Internet lambat di gedung A',
    description: 'Koneksi internet sangat lambat dan sering terputus.',
    status: 'in_progress',
    priority: 'medium',
    category: 'Network',
    createdBy: '1',
    assignedTo: '2',
    createdAt: DateTime.now().subtract(const Duration(days: 1)),
    updatedAt: DateTime.now().subtract(const Duration(hours: 5)),
    comments: [
      TicketComment(
        id: 'c1',
        content: 'Sedang dalam pengecekan jaringan.',
        authorName: 'Admin Helpdesk',
        authorRole: 'admin',
        createdAt: DateTime.now().subtract(const Duration(hours: 5)),
      ),
    ],
  ),
  TicketModel(
    id: '3',
    title: 'Software tidak bisa diinstall',
    description: 'Error saat menginstall aplikasi AutoCAD.',
    status: 'resolved',
    priority: 'low',
    category: 'Software',
    createdBy: '1',
    assignedTo: '2',
    createdAt: DateTime.now().subtract(const Duration(days: 3)),
    updatedAt: DateTime.now().subtract(const Duration(days: 1)),
  ),
  TicketModel(
    id: '4',
    title: 'Printer error di ruang TU',
    description: 'Printer di ruang TU tidak bisa print.',
    status: 'open',
    priority: 'critical',
    category: 'Hardware',
    createdBy: '1',
    createdAt: DateTime.now().subtract(const Duration(minutes: 30)),
    updatedAt: DateTime.now().subtract(const Duration(minutes: 30)),
  ),
];

class TicketRepository {
  // Ambil semua tiket (admin/helpdesk) atau filter by userId (user)
  Future<List<TicketModel>> getTickets({String? status, String? userId}) async {
    await Future.delayed(const Duration(milliseconds: 300));
    var list = List<TicketModel>.from(globalTickets);
    if (userId != null) {
      list = list.where((t) => t.createdBy == userId).toList();
    }
    if (status != null) {
      list = list.where((t) => t.status == status).toList();
    }
    return list;
  }

  Future<TicketModel> getTicketDetail(String id) async {
    await Future.delayed(const Duration(milliseconds: 200));
    return globalTickets.firstWhere((t) => t.id == id);
  }

  Future<TicketStatsModel> getTicketStats({String? userId}) async {
    await Future.delayed(const Duration(milliseconds: 200));
    var list = List<TicketModel>.from(globalTickets);
    if (userId != null) {
      list = list.where((t) => t.createdBy == userId).toList();
    }
    return TicketStatsModel(
      total: list.length,
      open: list.where((t) => t.status == 'open').length,
      inProgress: list.where((t) => t.status == 'in_progress').length,
      resolved: list.where((t) => t.status == 'resolved').length,
      closed: list.where((t) => t.status == 'closed').length,
    );
  }

  Future<TicketModel> createTicket({
    required String title,
    required String description,
    required String priority,
    required String category,
    required String createdBy,
  }) async {
    await Future.delayed(const Duration(milliseconds: 500));
    final newTicket = TicketModel(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      title: title,
      description: description,
      status: 'open',
      priority: priority,
      category: category,
      createdBy: createdBy,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
    globalTickets.add(newTicket); // Tambah ke global list
    return newTicket;
  }

  Future<void> updateTicketStatus({
    required String ticketId,
    required String status,
  }) async {
    await Future.delayed(const Duration(milliseconds: 300));
    final idx = globalTickets.indexWhere((t) => t.id == ticketId);
    if (idx != -1) {
      final old = globalTickets[idx];
      globalTickets[idx] = TicketModel(
        id: old.id,
        title: old.title,
        description: old.description,
        status: status, // Update status
        priority: old.priority,
        category: old.category,
        createdBy: old.createdBy,
        assignedTo: old.assignedTo,
        createdAt: old.createdAt,
        updatedAt: DateTime.now(),
        comments: old.comments,
        attachments: old.attachments,
      );
    }
  }

  Future<void> assignTicket({
    required String ticketId,
    required String? assignedTo,
  }) async {
    await Future.delayed(const Duration(milliseconds: 300));
    final idx = globalTickets.indexWhere((t) => t.id == ticketId);
    if (idx != -1) {
      final old = globalTickets[idx];
      globalTickets[idx] = TicketModel(
        id: old.id,
        title: old.title,
        description: old.description,
        status: old.status,
        priority: old.priority,
        category: old.category,
        createdBy: old.createdBy,
        assignedTo: assignedTo, // Update assignedTo
        createdAt: old.createdAt,
        updatedAt: DateTime.now(),
        comments: old.comments,
        attachments: old.attachments,
      );
    }
  }

  Future<void> addComment({
    required String ticketId,
    required String content,
    required String authorName,
    required String authorRole,
  }) async {
    await Future.delayed(const Duration(milliseconds: 300));
    final idx = globalTickets.indexWhere((t) => t.id == ticketId);
    if (idx != -1) {
      final old = globalTickets[idx];
      final newComment = TicketComment(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        content: content,
        authorName: authorName,
        authorRole: authorRole,
        createdAt: DateTime.now(),
      );
      globalTickets[idx] = TicketModel(
        id: old.id,
        title: old.title,
        description: old.description,
        status: old.status,
        priority: old.priority,
        category: old.category,
        createdBy: old.createdBy,
        assignedTo: old.assignedTo,
        createdAt: old.createdAt,
        updatedAt: DateTime.now(),
        comments: [...old.comments, newComment],
        attachments: old.attachments,
      );
    }
  }
}