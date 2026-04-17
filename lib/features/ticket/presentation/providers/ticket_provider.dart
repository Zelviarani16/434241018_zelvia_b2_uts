import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ticketing_434241018_zelvia_b2_uts/features/ticket/data/models/ticket_model.dart';
import 'package:ticketing_434241018_zelvia_b2_uts/features/ticket/data/repositories/ticket_repository.dart';

final ticketRepositoryProvider = Provider<TicketRepository>((ref) {
  return TicketRepository();
});

// Provider list tiket
class TicketNotifier extends StateNotifier<AsyncValue<List<TicketModel>>> {
  final TicketRepository _repository;

  TicketNotifier(this._repository) : super(const AsyncValue.loading()) {
    loadTickets();
  }

  Future<void> loadTickets({String? status}) async {
    state = const AsyncValue.loading();
    try {
      final data = await _repository.getTickets(status: status);
      state = AsyncValue.data(data);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> refresh() async => await loadTickets();
}

final ticketNotifierProvider =
StateNotifierProvider<TicketNotifier, AsyncValue<List<TicketModel>>>(
      (ref) {
    final repository = ref.watch(ticketRepositoryProvider);
    return TicketNotifier(repository);
  },
);

// Provider stats
final ticketStatsProvider = FutureProvider<TicketStatsModel>((ref) async {
  final repository = ref.watch(ticketRepositoryProvider);
  return repository.getTicketStats();
});

// Provider detail tiket
final ticketDetailProvider =
FutureProvider.family<TicketModel, String>((ref, id) async {
  final repository = ref.watch(ticketRepositoryProvider);
  return repository.getTicketDetail(id);
});

// Provider theme
final themeModeProvider = StateProvider<bool>((ref) => false);