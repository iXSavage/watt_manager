import 'dart:async';
import 'package:flutter/material.dart';
import 'package:hive_ce/hive.dart';
import '../models/appliance.dart';

class PowerProvider extends ChangeNotifier {
  static const int warningThreshold = 150;
  Timer? _drainTimer;
  DateTime? _lastSaveTime;
  final double inverterEfficiency = 0.9; // 90%

  int _inverterCapacity = 0;
  int _batteryCapacityWh = 0;
  String _deviceName = '';
  double _remainingWh = 0;

  // These are references to our Hive boxes
  // We get them once and reuse them — no need to open them again
  final Box _settingsBox = Hive.box('settings');
  final Box<Appliance> _appliancesBox = Hive.box<Appliance>('appliances');

  int get inverterCapacity => _inverterCapacity;
  int get batteryCapacityWh => _batteryCapacityWh;
  String get deviceName => _deviceName;
  List<Appliance> get appliances => List.unmodifiable(_appliancesBox.values.toList());

  PowerProvider() {
    _loadSettings();
    recalculateLoadAndStartTimer();
  }

  void _loadSettings() {
    _deviceName = _settingsBox.get('deviceName', defaultValue: '');
    _inverterCapacity = _settingsBox.get('inverterCapacity', defaultValue: 0);
    _batteryCapacityWh = _settingsBox.get('batteryCapacityWh', defaultValue: 0);
    _remainingWh = _settingsBox.get('remainingWh', defaultValue: batteryCapacityWh.toDouble());
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

    if (_remainingWh <= 0) {
      stopBatteryDrain();
      _turnOffAllAppliances();
    }
    notifyListeners();
  }

  void pauseDrain() {
    if (totalLoad > 0 && _remainingWh > 0) {
      _lastSaveTime = DateTime.now();
      _settingsBox.put('lastSaveTime', _lastSaveTime!.millisecondsSinceEpoch);
    }
    stopBatteryDrain();
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

  void setBatteryPercent(int percent) {
    _remainingWh = ((percent.clamp(0, 100)) / 100) * _batteryCapacityWh;
    _settingsBox.put('remainingWh', _remainingWh);
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