import 'dart:async';
import '../models/challan_model.dart';
import 'challan_service.dart';

/// Manages offline storage and synchronization for citations issued when cellular/Wi-Fi is unavailable.
class OfflineSyncService {
  static final OfflineSyncService instance = OfflineSyncService._internal();
  factory OfflineSyncService() => instance;
  OfflineSyncService._internal();

  bool _isOfflineModeSimulated = false;
  final List<ChallanModel> _pendingQueue = [];
  final StreamController<List<ChallanModel>> _queueController =
      StreamController<List<ChallanModel>>.broadcast();

  DateTime _lastSyncTime = DateTime.now().subtract(const Duration(minutes: 4));

  bool get isOfflineMode => _isOfflineModeSimulated;
  DateTime get lastSyncTime => _lastSyncTime;
  int get pendingCount => _pendingQueue.length;
  List<ChallanModel> get pendingChallans => List.unmodifiable(_pendingQueue);
  Stream<List<ChallanModel>> get queueStream => _queueController.stream;

  /// Toggles simulated offline mode (useful for on-field testing in basements/tunnels)
  void setOfflineMode(bool offline) {
    _isOfflineModeSimulated = offline;
  }

  /// Queues a citation locally when offline
  Future<void> queueOfflineChallan(ChallanModel challan) async {
    _pendingQueue.add(challan);
    _queueController.add(List.unmodifiable(_pendingQueue));
  }

  /// Synchronizes all queued offline citations to the remote/central repository
  Future<int> syncPendingQueue() async {
    if (_pendingQueue.isEmpty) return 0;

    final count = _pendingQueue.length;
    final toSync = List<ChallanModel>.from(_pendingQueue);

    for (final challan in toSync) {
      // Ingest into central ChallanService if not already there
      ChallanService.instance.addOfflineChallanToCentral(challan);
    }

    _pendingQueue.clear();
    _lastSyncTime = DateTime.now();
    _queueController.add(List.unmodifiable(_pendingQueue));
    return count;
  }

  void clearQueue() {
    _pendingQueue.clear();
    _queueController.add(List.unmodifiable(_pendingQueue));
  }
}
