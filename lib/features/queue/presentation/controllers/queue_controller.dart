import 'package:flutter_riverpod/legacy.dart';

import '../../../../core/network/api_result.dart';
import '../../data/models/queue_models.dart';
import '../../domain/repositories/queue_repository.dart';

class QueueState {
  const QueueState({
    this.entries = const [],
    this.selectedEntry,
    this.lastUpdatedAt,
    this.isLoading = false,
    this.errorMessage,
  });

  final List<QueueEntry> entries;
  final QueueEntry? selectedEntry;
  final DateTime? lastUpdatedAt;
  final bool isLoading;
  final String? errorMessage;

  QueueEntry? get currentEntry {
    final active = entries.where((entry) => entry.isActive).toList();
    if (active.isEmpty) return entries.isEmpty ? null : entries.first;
    active.sort((a, b) => b.joinedAt.compareTo(a.joinedAt));
    return active.first;
  }

  QueueState copyWith({
    List<QueueEntry>? entries,
    QueueEntry? selectedEntry,
    DateTime? lastUpdatedAt,
    bool? isLoading,
    String? errorMessage,
    bool clearError = false,
  }) {
    return QueueState(
      entries: entries ?? this.entries,
      selectedEntry: selectedEntry ?? this.selectedEntry,
      lastUpdatedAt: lastUpdatedAt ?? this.lastUpdatedAt,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: clearError ? null : errorMessage ?? this.errorMessage,
    );
  }
}

class QueueController extends StateNotifier<QueueState> {
  QueueController({required this.repository}) : super(const QueueState());

  final QueueRepository repository;

  Future<void> loadCurrentQueue({bool quiet = false}) async {
    if (!quiet) state = state.copyWith(isLoading: true, clearError: true);
    final currentResult = await repository.getCurrentQueue();
    final historyResult = await repository.listQueueHistory();
    switch (currentResult) {
      case ApiSuccess(data: final current):
        state = state.copyWith(
          entries: historyResult is ApiSuccess<List<QueueEntry>>
              ? historyResult.data
              : state.entries,
          selectedEntry: current,
          lastUpdatedAt: DateTime.now(),
          isLoading: false,
          clearError: true,
        );
      case ApiFailure(message: final message):
        state = state.copyWith(
          isLoading: false,
          errorMessage: _friendlyQueueError(message),
        );
    }
  }

  String _friendlyQueueError(String message) {
    final normalized = message.toLowerCase();
    if (normalized.contains('permission')) {
      return 'You do not have permission to view this queue status.';
    }
    if (normalized.contains('not found')) return 'Queue status was not found.';
    if (normalized.contains('connect') || normalized.contains('server')) {
      return 'Could not connect to the server. Please try again.';
    }
    return 'Queue status could not be loaded. Please try again.';
  }
}
