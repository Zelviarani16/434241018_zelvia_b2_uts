import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ticketing_434241018_zelvia_b2_uts/features/auth/presentation/providers/auth_provider.dart';
import 'package:ticketing_434241018_zelvia_b2_uts/features/ticket/data/models/ticket_model.dart';
import 'package:ticketing_434241018_zelvia_b2_uts/features/ticket/data/repositories/ticket_repository.dart';

// Provider token — ambil dari SharedPreferences
final tokenProvider = Provider<String>((ref) {
  final auth = ref.watch(authProvider);
  return auth.token ?? '';
});

final ticketRepositoryProvider = Provider<TicketRepository>((ref) {
  return TicketRepository();
});

class TicketNotifier extends StateNotifier<AsyncValue<List<TicketModel>>> {
  final TicketRepository _repository;
  final String? _userId;
  final String _token;

  TicketNotifier(this._repository, this._userId, this._token)
      : super(const AsyncValue.loading()) {
    loadTickets();
  }

  Future<void> loadTickets({String? status}) async {
    state = const AsyncValue.loading();
    try {
      final data = await _repository.getTickets(
        status: status,
        userId: _userId,
        token: _token,
      );
      state = AsyncValue.data(data);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> refresh() async => await loadTickets();
}

final ticketNotifierProvider =
    StateNotifierProvider<TicketNotifier, AsyncValue<List<TicketModel>>>((ref) {
  final repository = ref.watch(ticketRepositoryProvider);
  final auth = ref.watch(authProvider);
  final token = ref.watch(tokenProvider);
  return TicketNotifier(repository, auth.user?.id, token);
});

final ticketStatsProvider = FutureProvider<TicketStatsModel>((ref) async {
  final repository = ref.watch(ticketRepositoryProvider);
  final token = ref.watch(tokenProvider);
  return repository.getTicketStats(token: token);
});

/// Statistik khusus helpdesk — hanya tiket yang ditugaskan ke mereka
final helpdeskStatsProvider = FutureProvider<TicketStatsModel>((ref) async {
  final repository = ref.watch(ticketRepositoryProvider);
  final token = ref.watch(tokenProvider);
  final auth = ref.watch(authProvider);
  final helpdeskId = auth.user?.id ?? '';
  return repository.getHelpdeskStats(helpdeskId: helpdeskId, token: token);
});

/// Notifier khusus helpdesk — hanya tiket yang di-assign ke mereka
class HelpdeskTicketNotifier extends StateNotifier<AsyncValue<List<TicketModel>>> {
  final TicketRepository _repository;
  final String _helpdeskId;
  final String _token;

  HelpdeskTicketNotifier(this._repository, this._helpdeskId, this._token)
      : super(const AsyncValue.loading()) {
    loadTickets();
  }

  Future<void> loadTickets({String? status}) async {
    state = const AsyncValue.loading();
    try {
      final data = await _repository.getAssignedTickets(
        helpdeskId: _helpdeskId,
        status: status,
        token: _token,
      );
      state = AsyncValue.data(data);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> refresh() async => await loadTickets();
}

final helpdeskTicketNotifierProvider =
    StateNotifierProvider<HelpdeskTicketNotifier, AsyncValue<List<TicketModel>>>((ref) {
  final repository = ref.watch(ticketRepositoryProvider);
  final auth = ref.watch(authProvider);
  final token = ref.watch(tokenProvider);
  return HelpdeskTicketNotifier(repository, auth.user?.id ?? '', token);
});

final helpdeskUsersProvider = FutureProvider<List<Map<String, dynamic>>>((ref) async {
  final repository = ref.watch(ticketRepositoryProvider);
  final token = ref.watch(tokenProvider);
  return repository.getHelpdeskUsers(token: token);
});

final ticketDetailProvider =
    FutureProvider.family<TicketModel, String>((ref, id) async {
  final repository = ref.watch(ticketRepositoryProvider);
  final token = ref.watch(tokenProvider);
  return repository.getTicketDetail(id, token: token);
});

final themeModeProvider = StateProvider<bool>((ref) => false);