class AppliancePreset {
  final String name;
  final int watts;
  bool isOn;

  AppliancePreset({required this.name, required this.watts, this.isOn = false});

}