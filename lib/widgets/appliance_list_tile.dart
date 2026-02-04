import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:provider/provider.dart';
import '../models/appliance.dart';
import '../providers/power_provider.dart';
import '../utils/utilities.dart';
import 'appliance_form_sheet.dart';

class ApplianceListTile extends StatelessWidget {
  final Appliance appliance;
  final int index;

  const ApplianceListTile({
    super.key,
    required this.appliance,
    required this.index,
  });

  @override
  Widget build(BuildContext context) {
    final power = context.read<PowerProvider>();

    return Slidable(
      key: ValueKey('${appliance.name}_$index'),
      startActionPane: ActionPane(
        dismissible: DismissiblePane(
          onDismissed: () {
            power.removeAppliance(index);
          },
        ),
        extentRatio: 0.25,
        motion: const ScrollMotion(),
        children: [
          SlidableAction(
            onPressed: (context) {
              power.removeAppliance(index);
            },
            icon: Icons.delete,
            label: 'Delete',
            backgroundColor: Colors.red,
          ),
        ],
      ),
      child: GestureDetector(
        onLongPress: () => _showEditDialog(context, appliance, power),
        child: SwitchListTile(
          title: Text(appliance.name.capitalize()),
          subtitle: Text('${appliance.watts}W'),
          value: appliance.isOn,
          onChanged: (bool value) {
            power.toggleAppliance(index);
          },
        ),
      ),
    );
  }

  void _showEditDialog(BuildContext context, Appliance appliance, PowerProvider power) {
    showModalBottomSheet(
      isScrollControlled: true,
      context: context,
      builder: (BuildContext context) {
        return ApplianceFormSheet(
          title: 'Edit Appliance',
          initialName: appliance.name,
          initialWatts: appliance.watts,
          onSave: (name, watts) {
            final key = appliance.key;
            power.editAppliance(key, name: name, watts: watts);
            Navigator.pop(context);
          },
          onCancel: () {
            Navigator.pop(context);
          },
        );
      },
    );
  }
}
