import 'package:flutter_riverpod/legacy.dart';

import '../../../../core/network/api_result.dart';
import '../../data/models/queue_models.dart';
import '../../domain/repositories/queue_repository.dart';

class QueueState {
  const QueueState({
    this.entries = const [],
    this.selectedEntry,
    this.events = const [],
    this.prediction,
    this.lastUpdatedAt,
    this.isLoading = false,
    this.errorMessage,
  });

  final List<QueueEntry> entries;
  final QueueEntry? selectedEntry;
  final List<QueueEntryEvent> events;
  final WaitTimePrediction? prediction;
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
    List<QueueEntryEvent>? events,
    WaitTimePrediction? prediction,
    bool clearPrediction = false,
    DateTime? lastUpdatedAt,
    bool? isLoading,
    String? errorMessage,
    bool clearError = false,
  }) {
    return QueueState(
      entries: entries ?? this.entries,
      selectedEntry: selectedEntry ?? this.selectedEntry,
      events: events ?? this.events,
      prediction: clearPrediction ? null : prediction ?? this.prediction,
      lastUpdatedAt: lastUpdatedAt ?? this.lastUpdatedAt,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: clearError ? null : errorMessage ?? this.errorMessage,
    );
  }
}

class QueueController extends StateNotifier<QueueState> {
  QueueController({required this.repository}) : super(const QueueState());

  final QueueRepository repository;

  Future<void> loadPatientQueue(String patientId, {bool quiet = false}) async {
    if (!quiet) state = state.copyWith(isLoading: true, clearError: true);
    final result = await repository.listQueueEntries(
      patientId: patientId,
      activeOnly: true,
    );
    switch (result) {
      case ApiSuccess(data: final entries):
        final current = entries.isEmpty ? null : _latestActive(entries);
        state = state.copyWith(
          entries: entries,
          selectedEntry: current,
          lastUpdatedAt: DateTime.now(),
          isLoading: false,
          clearError: true,
        );
        if (current != null) {
          await _loadEvents(current.id);
          await _loadPrediction(current.id);
        }
      case ApiFailure(message: final message):
        state = state.copyWith(
          isLoading: false,
          errorMessage: _friendlyQueueError(message),
        );
    }
  }

  Future<void> loadEntry(String queueEntryId, {bool quiet = false}) async {
    if (!quiet) state = state.copyWith(isLoading: true, clearError: true);
    final entryResult = await repository.getQueueEntry(queueEntryId);
    switch (entryResult) {
      case ApiSuccess(data: final entry):
        final eventsResult = await repository.listEvents(queueEntryId);
        state = state.copyWith(
          selectedEntry: entry,
          events: eventsResult is ApiSuccess<List<QueueEntryEvent>>
              ? eventsResult.data
              : state.events,
          lastUpdatedAt: DateTime.now(),
          isLoading: false,
          clearError: true,
        );
        await _loadPrediction(queueEntryId);
      case ApiFailure(message: final message):
        state = state.copyWith(
          isLoading: false,
          errorMessage: _friendlyQueueError(message),
        );
    }
  }

  QueueEntry _latestActive(List<QueueEntry> entries) {
    final active = entries.where((entry) => entry.isActive).toList();
    final source = active.isEmpty ? entries : active;
    source.sort((a, b) => b.joinedAt.compareTo(a.joinedAt));
    return source.first;
  }

  Future<void> _loadPrediction(String queueEntryId) async {
    final result = await repository.getLatestPrediction(queueEntryId);
    if (result is ApiSuccess<WaitTimePrediction?>) {
      state = state.copyWith(
        prediction: result.data,
        clearPrediction: result.data == null,
      );
    }
  }

  Future<void> _loadEvents(String queueEntryId) async {
    final result = await repository.listEvents(queueEntryId);
    if (result is ApiSuccess<List<QueueEntryEvent>>) {
      state = state.copyWith(events: result.data);
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
