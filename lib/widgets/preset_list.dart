import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:watt_manager/models/appliance_preset.dart';
import '../models/appliance.dart';
import '../providers/power_provider.dart';

class PresetList extends StatelessWidget {
  const PresetList({super.key});

  @override
  Widget build(BuildContext context) {
    final power = context.read<PowerProvider>();

    List<AppliancePreset> presets = [
      AppliancePreset(name: 'Fridge', watts: 110),
      AppliancePreset(name: 'Television', watts: 60),
      AppliancePreset(name: 'Laptop', watts: 180),
      AppliancePreset(name: 'Monitor', watts: 45),
      AppliancePreset(name: 'Microwave', watts: 2000),
      AppliancePreset(name: 'Standing Fan', watts: 50),
      AppliancePreset(name: 'LED Bulb', watts: 12),
      AppliancePreset(name: 'Soundbar', watts: 150),
      AppliancePreset(name: 'Game Console', watts: 200),
      AppliancePreset(name: 'Router', watts: 15),
      AppliancePreset(name: 'Phone Charger', watts: 25),
    ];

    return Padding(padding: EdgeInsets.only(
      bottom: MediaQuery.of(context).viewInsets.bottom,),
      child: SizedBox(
        height: 300,
        width: double.infinity,
        child: Padding(
          padding: const EdgeInsets.all(10.0),
          child: Wrap(
            alignment: WrapAlignment.center,
            spacing: 8,
            runSpacing: 8,
            children:
              presets.map((preset) {
                return ActionChip(
                  label: Text('${preset.name} ${preset.watts}W'),
                  onPressed: () {
                    power.addAppliance(Appliance(name: preset.name, watts: preset.watts));
                    Navigator.pop(context);
                  },
                );
              }).toList(),
          ),
        )
      ),
    );
  }
}


void showPresetSheet(BuildContext context) {

  showModalBottomSheet(
    isScrollControlled: true,
    context: context,
    builder: (BuildContext context) {
      return PresetList();
    },
  );
}
