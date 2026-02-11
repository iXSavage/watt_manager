import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/power_provider.dart';
import 'battery_percentage_sheet.dart';

class BatteryCard extends StatelessWidget {
  const BatteryCard({super.key});

  @override
  Widget build(BuildContext context) {
    final power = context.watch<PowerProvider>();

    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Stack(
              alignment: Alignment.center,
              children: [
                SizedBox(
                  width: 90,
                  height: 90,
                  child: CircularProgressIndicator(
                    value: power.batteryPercent / 100,
                    strokeWidth: 10,
                    backgroundColor: Colors.blue.shade100,
                    valueColor: AlwaysStoppedAnimation(power.batteryColor),
                  ),
                ),
                GestureDetector(
                  onTap: () => _showBatteryPercentageSheet(context, power),
                  child: Text(
                    '${power.batteryPercent}%',
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(width: 20),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Battery Status',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 6),
                  const Divider(color: Colors.grey),
                  Text(
                    'Estimated Runtime: ${power.estimatedRuntime}',
                    style: const TextStyle(color: Colors.black54),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showBatteryPercentageSheet(BuildContext context, PowerProvider power) {
    showModalBottomSheet(
      isScrollControlled: true,
      context: context,
      builder: (BuildContext context) {
        return BatteryPercentageSheet(
          onSave: (percentage) {
            power.setBatteryPercent(percentage);
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