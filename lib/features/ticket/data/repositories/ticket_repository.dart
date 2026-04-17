import 'package:ticketing_434241018_zelvia_b2_uts/features/ticket/data/models/ticket_model.dart';

class TicketRepository {
  // Data dummy tickets
  final List<TicketModel> _dummyTickets = [
    TicketModel(
      id: '1',
      title: 'Komputer tidak bisa menyala',
      description: 'Komputer di ruang lab 3 tiba-tiba tidak bisa dinyalakan sejak pagi.',
      status: 'open',
      priority: 'high',
      category: 'Hardware',
      createdBy: '1',
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
      title: 'Printer error',
      description: 'Printer di ruang TU tidak bisa print.',
      status: 'open',
      priority: 'critical',
      category: 'Hardware',
      createdBy: '1',
      createdAt: DateTime.now().subtract(const Duration(minutes: 30)),
      updatedAt: DateTime.now().subtract(const Duration(minutes: 30)),
    ),
  ];

  Future<List<TicketModel>> getTickets({String? status}) async {
    await Future.delayed(const Duration(seconds: 1));
    if (status != null) {
      return _dummyTickets.where((t) => t.status == status).toList();
    }
    return _dummyTickets;
  }

  Future<TicketModel> getTicketDetail(String id) async {
    await Future.delayed(const Duration(milliseconds: 500));
    return _dummyTickets.firstWhere((t) => t.id == id);
  }

  Future<TicketStatsModel> getTicketStats() async {
    await Future.delayed(const Duration(milliseconds: 500));
    return TicketStatsModel(
      total: _dummyTickets.length,
      open: _dummyTickets.where((t) => t.status == 'open').length,
      inProgress: _dummyTickets.where((t) => t.status == 'in_progress').length,
      resolved: _dummyTickets.where((t) => t.status == 'resolved').length,
      closed: _dummyTickets.where((t) => t.status == 'closed').length,
    );
  }

  Future<TicketModel> createTicket({
    required String title,
    required String description,
    required String priority,
    required String category,
  }) async {
    await Future.delayed(const Duration(seconds: 1));
    final newTicket = TicketModel(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      title: title,
      description: description,
      status: 'open',
      priority: priority,
      category: category,
      createdBy: '1',
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
    _dummyTickets.add(newTicket);
    return newTicket;
  }

  Future<void> addComment({
    required String ticketId,
    required String content,
  }) async {
    await Future.delayed(const Duration(milliseconds: 500));
  }

  Future<void> updateTicketStatus({
    required String ticketId,
    required String status,
  }) async {
    await Future.delayed(const Duration(milliseconds: 500));
  }
}