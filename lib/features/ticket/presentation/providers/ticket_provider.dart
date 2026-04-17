import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ticketing_434241018_zelvia_b2_uts/features/auth/presentation/providers/auth_provider.dart';
import 'package:ticketing_434241018_zelvia_b2_uts/features/ticket/data/models/ticket_model.dart';
import 'package:ticketing_434241018_zelvia_b2_uts/features/ticket/data/repositories/ticket_repository.dart';

final ticketRepositoryProvider = Provider<TicketRepository>((ref) {
  return TicketRepository();
});

// TicketNotifier — aware of role (user hanya lihat tiketnya sendiri)
class TicketNotifier extends StateNotifier<AsyncValue<List<TicketModel>>> {
  final TicketRepository _repository;
  final String? _userId;
  final String? _role;

  TicketNotifier(this._repository, this._userId, this._role)
      : super(const AsyncValue.loading()) {
    loadTickets();
  }

  Future<void> loadTickets({String? status}) async {
    state = const AsyncValue.loading();
    try {
      // User hanya lihat tiket miliknya sendiri
      final userId = _role == 'user' ? _userId : null;
      final data = await _repository.getTickets(status: status, userId: userId);
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
  return TicketNotifier(repository, auth.user?.id, auth.user?.role);
});

// Stats provider — juga role-aware
final ticketStatsProvider = FutureProvider<TicketStatsModel>((ref) async {
  final repository = ref.watch(ticketRepositoryProvider);
  final auth = ref.watch(authProvider);
  final userId = auth.user?.role == 'user' ? auth.user?.id : null;
  return repository.getTicketStats(userId: userId);
});

// Detail provider
final ticketDetailProvider =
    FutureProvider.family<TicketModel, String>((ref, id) async {
  final repository = ref.watch(ticketRepositoryProvider);
  return repository.getTicketDetail(id);
});

// Theme provider
final themeModeProvider = StateProvider<bool>((ref) => false);