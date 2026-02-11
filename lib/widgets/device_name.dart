import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/power_provider.dart';
import 'device_name_sheet.dart';

class DeviceName extends StatelessWidget {
  const DeviceName({super.key});

  @override
  Widget build(BuildContext context) {
    final power = context.watch<PowerProvider>();

    return GestureDetector(
      onTap: () {
        _showDeviceNameSheet(context, power);
      },
      child: Text(power.deviceName)
    );
  }


  void _showDeviceNameSheet(BuildContext context, PowerProvider power) {
    showModalBottomSheet(
      isScrollControlled: true,
      context: context,
      builder: (BuildContext context) {
        return DeviceNameSheet(
          deviceName: power.deviceName,
          onSave: (editDeviceName) {
            power.editDeviceName(editDeviceName);
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
