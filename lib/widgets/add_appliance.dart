import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:watt_manager/widgets/preset_list.dart';
import '../models/appliance.dart';
import '../providers/power_provider.dart';
import 'appliance_form_sheet.dart';

class AddApplianceButton extends StatelessWidget {
  const AddApplianceButton({super.key});

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        minimumSize: const Size(double.infinity, 50),
        foregroundColor: Colors.black,
        textStyle: const TextStyle(fontSize: 18),
      ),
      onPressed: () => _showAddApplianceSheet(context),
      child: const Text('Add new appliance'),
    );
  }

  void _showAddApplianceSheet(BuildContext context) {
    final power = context.read<PowerProvider>();

    showModalBottomSheet(
      isScrollControlled: true,
      context: context,
      builder: (BuildContext context) {
        return ApplianceFormSheet(
          title: 'Add New Appliance',
          onSave: (name, watts) {
            power.addAppliance(
              Appliance(name: name, watts: watts),
            );
            Navigator.pop(context);
          },
          onCancel: () {
            Navigator.pop(context);
          },
          addPreset: () {
            Navigator.pop(context);
            showPresetSheet(context);
          },
        );
      },
    );
  }
}