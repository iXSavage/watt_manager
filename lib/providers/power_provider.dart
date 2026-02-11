import 'dart:async';
import 'package:flutter/material.dart';
import 'package:hive_ce/hive.dart';
import '../models/appliance.dart';
import '../services/notification_service.dart';

class PowerProvider extends ChangeNotifier {
  static const int warningThreshold = 150;
  Timer? _drainTimer;
  DateTime? _lastSaveTime;
  final double inverterEfficiency = 0.9; // 90%

  int _inverterCapacity = 0;
  int _batteryCapacityWh = 0;
  String _deviceName = '';
  double _remainingWh = 0;

  // Add this line
  bool _notificationsEnabled = true;

  // These are references to our Hive boxes
  // We get them once and reuse them — no need to open them again
  final Box _settingsBox = Hive.box('settings');
  final Box<Appliance> _appliancesBox = Hive.box<Appliance>('appliances');
  final NotificationService _notificationService = NotificationService();  // Add this


  // Track notification states to avoid spam
  bool _hasShownLowBatteryWarning = false;
  bool _hasShownCriticalBatteryWarning = false;
  bool _hasShownOverloadWarning = false;

  int get inverterCapacity => _inverterCapacity;
  int get batteryCapacityWh => _batteryCapacityWh;
  String get deviceName => _deviceName;
  List<Appliance> get appliances => List.unmodifiable(_appliancesBox.values.toList());
  bool get notificationsEnabled => _notificationsEnabled;


  PowerProvider() {
    _loadSettings();
    recalculateLoadAndStartTimer();
  }

  void _loadSettings() {
    _deviceName = _settingsBox.get('deviceName', defaultValue: '');
    _inverterCapacity = _settingsBox.get('inverterCapacity', defaultValue: 0);
    _batteryCapacityWh = _settingsBox.get('batteryCapacityWh', defaultValue: 0);
    _remainingWh = _settingsBox.get('remainingWh', defaultValue: batteryCapacityWh.toDouble());
    _notificationsEnabled = _settingsBox.get('notificationsEnabled', defaultValue: true);


  }

  void updateSettings(int inverterCapacity, int batteryCapacityWh, String deviceName) {
    _inverterCapacity = inverterCapacity;
    _batteryCapacityWh = batteryCapacityWh;
    _deviceName = deviceName;
    _remainingWh = batteryCapacityWh.toDouble(); //start at 100%


    // Save to Hive — this persists the data to the device
    _settingsBox.put('inverterCapacity', inverterCapacity);
    _settingsBox.put('batteryCapacityWh', batteryCapacityWh);
    _settingsBox.put('deviceName', deviceName);
    _settingsBox.put('remainingWh', _remainingWh);

    notifyListeners();
  }

  void addAppliance(Appliance appliance) {
    _appliancesBox.add(appliance);
    recalculateLoadAndStartTimer();
    notifyListeners();
  }

  void editAppliance(int key, {String? name, int? watts}) {
    final oldAppliance = _appliancesBox.get(key);
    if (oldAppliance == null) return;

    final updated = Appliance(
      name: name ?? oldAppliance.name,
      watts: watts ?? oldAppliance.watts,
      isOn: oldAppliance.isOn,
    );

    _appliancesBox.put(key, updated); // replaces object
    recalculateLoadAndStartTimer();
    notifyListeners();
  }

  void removeAppliance(int index) {
    _appliancesBox.deleteAt(index); //Hive removes it from storage
    recalculateLoadAndStartTimer();
    notifyListeners();
  }

  void toggleAppliance(int index) {
    if (index >= 0 && index < _appliancesBox.length) {
      final appliance = _appliancesBox.getAt(index) as Appliance;
      appliance.isOn = !appliance.isOn;
      _appliancesBox.putAt(index, appliance); // Use putAt instead of appliance.save()

      recalculateLoadAndStartTimer();
      notifyListeners();
    }
  }

  int get batteryPercent {
    if (_batteryCapacityWh == 0) return 0;
    return ((_remainingWh / _batteryCapacityWh) * 100).clamp(0, 100).round();
  }

  void startBatteryDrain() {
    _drainTimer?.cancel();

    _drainTimer = Timer.periodic(
      const Duration(seconds: 1),
          (_) => _drainBattery(),
    );
  }

  void _drainBattery() {
    if (totalLoad == 0 || _remainingWh <= 0) {
      stopBatteryDrain();
      return;
    }

    final usedWh = (totalLoad / inverterEfficiency) / 3600;
    _remainingWh = (_remainingWh - usedWh).clamp(0, _batteryCapacityWh.toDouble());

    _settingsBox.put('remainingWh', _remainingWh);
    _checkBatteryNotifications();


    if (_remainingWh <= 0) {
      stopBatteryDrain();
      _turnOffAllAppliances();
      _showBatteryDeadNotification();
    }
    notifyListeners();
  }

  void _checkBatteryNotifications() {
    if (!_notificationsEnabled) return;

    // Critical battery (10%)
    if (batteryPercent <= 10 && !_hasShownCriticalBatteryWarning) {
      _notificationService.showNotification(
        id: 1,
        title: '🔋 Battery Critical!',
        body: 'Only $batteryPercent% remaining. Estimated runtime: $estimatedRuntime',
      );
      _hasShownCriticalBatteryWarning = true;
    }

    // Low battery (20%)
    else if (batteryPercent <= 20 && !_hasShownLowBatteryWarning) {
      _notificationService.showNotification(
        id: 2,
        title: '⚠️ Low Battery',
        body: 'Battery at $batteryPercent%. Consider reducing load.',
      );
      _hasShownLowBatteryWarning = true;
    }

    // Reset critical warning when battery goes above 10%
    if (batteryPercent > 10) {
      _hasShownCriticalBatteryWarning = false;
    }

    // Reset low battery warning when battery goes above 20%
    if (batteryPercent > 20) {
      _hasShownLowBatteryWarning = false;
    }
  }

  void toggleNotifications(bool enabled) {
    _notificationsEnabled = enabled;
    _settingsBox.put('notificationsEnabled', enabled);

    if (!enabled) {
      _notificationService.cancelAll();
    }

    notifyListeners();
  }

  void _showBatteryDeadNotification() {
    _notificationService.showNotification(
      id: 3,
      title: '💀 Battery Depleted',
      body: 'All appliances have been turned off automatically.',
    );
  }

  void pauseDrain() {
    if (totalLoad > 0 && _remainingWh > 0) {
      _lastSaveTime = DateTime.now();
      _settingsBox.put('lastSaveTime', _lastSaveTime!.millisecondsSinceEpoch);
    }

    // Always re-schedule based on current state (even if load is 0)
    _scheduleBackgroundNotifications();

    stopBatteryDrain();
  }

  void _scheduleBackgroundNotifications() {
    if (!_notificationsEnabled) return;

    // ALWAYS cancel existing notifications first
    _notificationService.cancel(10);
    _notificationService.cancel(11);
    _notificationService.cancel(12);

    // If no load, don't schedule anything (battery won't drain)
    if (totalLoad == 0) {
      return; // Exit early - no notifications needed
    }

    final currentPercent = batteryPercent;

    // Only schedule if battery will actually drain
    if (_remainingWh <= 0) {
      return; // Battery already dead
    }

    // Time to reach 20%
    if (currentPercent > 20) {
      final whTo20 = _remainingWh - (0.20 * _batteryCapacityWh);
      final secondsTo20 = (whTo20 / totalLoad * 3600).round();

      if (secondsTo20 > 0) {
        _notificationService.scheduleNotification(
          id: 10,
          title: '⚠️ Low Battery',
          body: 'Battery running low. Check your power usage.',
          delay: Duration(seconds: secondsTo20),
        );
      }
    }

    // Time to reach 10%
    if (currentPercent > 10) {
      final whTo10 = _remainingWh - (0.10 * _batteryCapacityWh);
      final secondsTo10 = (whTo10 / totalLoad * 3600).round();

      if (secondsTo10 > 0) {
        _notificationService.scheduleNotification(
          id: 11,
          title: '🔋 Battery Critical',
          body: 'Battery critically low. Turn off appliances soon.',
          delay: Duration(seconds: secondsTo10),
        );
      }
    }

    // Time to reach 0%
    final secondsTo0 = (_remainingWh / totalLoad * 3600).round();
    if (secondsTo0 > 0) {
      _notificationService.scheduleNotification(
        id: 12,
        title: '💀 Battery Dying',
        body: 'Battery will die soon. Save your work!',
        delay: Duration(seconds: secondsTo0),
      );
    }
  }

  void resumeDrain() {
    final savedTimestamp = _settingsBox.get('lastSaveTime');

    if (savedTimestamp != null && totalLoad > 0 && _remainingWh > 0) {
      final lastTime = DateTime.fromMillisecondsSinceEpoch(savedTimestamp);
      final now = DateTime.now();
      int elapsedSeconds = now.difference(lastTime).inSeconds;

      if (elapsedSeconds <= 0) elapsedSeconds = 0;

      // Optional: cap max elapsed to prevent sudden big drops
      elapsedSeconds = elapsedSeconds.clamp(0, 60); // max simulate 1 minutes

      // Drain battery for elapsed time
      final usedWh = (totalLoad / inverterEfficiency) * (elapsedSeconds / 3600);
      _remainingWh = (_remainingWh - usedWh).clamp(0, _batteryCapacityWh.toDouble());

      _settingsBox.put('remainingWh', _remainingWh);

      // Update lastSaveTime to now to avoid double-counting next resume
      _lastSaveTime = now;
      _settingsBox.put('lastSaveTime', now.millisecondsSinceEpoch);

      // Turn off appliances if battery dead
      if (_remainingWh <= 0) {
        _turnOffAllAppliances();
      }
    }

    // Resume real-time drain
    recalculateLoadAndStartTimer();
    notifyListeners();
  }

  Future<void> _turnOffAllAppliances() async {
    for (int i = 0; i < _appliancesBox.length; i++) {
      final appliance = _appliancesBox.getAt(i) as Appliance;
      if (appliance.isOn) {
        appliance.isOn = false;
        await _appliancesBox.putAt(i, appliance);
      }
    }
  }

  void stopBatteryDrain() {
    _drainTimer?.cancel();
    _drainTimer = null;
  }

  void editDeviceName(String editDeviceName) {
    _deviceName = editDeviceName;
    _settingsBox.put('deviceName', editDeviceName);

    notifyListeners();
  }

  void setBatteryPercent(int percent) {
    _remainingWh = ((percent.clamp(0, 100)) / 100) * _batteryCapacityWh;
    _settingsBox.put('remainingWh', _remainingWh);

    // Reset notification flags when battery is manually set
    if (percent > 20) {
      _hasShownLowBatteryWarning = false;
    }
    if (percent > 10) {
      _hasShownCriticalBatteryWarning = false;
    }
    recalculateLoadAndStartTimer(); // If battery was 0 and is now charged, resume
    notifyListeners();
  }

  int get totalLoad {
    int total = 0;
    for (final appliance in _appliancesBox.values) {
      if (appliance.isOn) {
        total += appliance.watts;
      }
    }
    return total;
  }

  void recalculateLoadAndStartTimer() {
    // Check for overload
    if (isOverloaded && !_hasShownOverloadWarning) {
      if (_notificationsEnabled) {
        _notificationService.showNotification(
          id: 4,
          title: '⚡ System Overload!',
          body: 'Load is ${totalLoad}W but capacity is ${inverterCapacity}W. Turn off ${totalLoad - inverterCapacity}W.',
        );
      }
      _hasShownOverloadWarning = true;
    } else if (!isOverloaded) {
      _hasShownOverloadWarning = false;
    }

    if (totalLoad > 0 && _remainingWh > 0) {
      startBatteryDrain();
    } else {
      stopBatteryDrain();
    }
  }
  int get headRoom => inverterCapacity - totalLoad;

  double get loadFraction =>
      inverterCapacity == 0 ? 0 : (totalLoad / inverterCapacity).clamp(0.0, 1.0);

  bool get isOverloaded => totalLoad > inverterCapacity;

  String get warningMessage {
    final remaining = inverterCapacity - totalLoad;

    if (remaining > warningThreshold) return "Safe";
    if (remaining > 0) return "Warning";
    return "Overload";
  }

  Color get warningColor {
    switch (warningMessage) {
      case "Safe":
        return Colors.green;
      case "Warning":
        return Colors.orange;
      default:
        return Colors.red;
    }
  }

  Color get batteryColor {
    if (batteryPercent > 70) return Colors.green;
    if (batteryPercent > 50) return Colors.yellow;
    if (batteryPercent > 30) return Colors.orange;
    return Colors.red;
  }

  String get estimatedRuntime {
    if (totalLoad == 0) return "∞";
    if (_remainingWh <= 0) return "0h 0m";

    final hours = _remainingWh / totalLoad;
    if (hours > 999) return "∞";

    final int wholeHours = hours.floor();
    final int minutes = ((hours - wholeHours) * 60).round();

    return "${wholeHours}h ${minutes}m";
  }

  Future<void> reset() async {
    stopBatteryDrain();
    await _appliancesBox.clear();
    await _settingsBox.clear();
    _inverterCapacity = 0;
    _batteryCapacityWh = 0;
    _deviceName = '';
    _remainingWh = 0;
    notifyListeners();
  }

  @override
  void dispose() {
    stopBatteryDrain();
    super.dispose();
  }

}