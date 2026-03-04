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
        child: LayoutBuilder(
          builder: (context, constraints) {
            double indicatorSize =
                constraints.maxWidth > 300 ? 90.0 : constraints.maxWidth * 0.25;
            double fontSize =
                constraints.maxWidth > 300 ? 20.0 : constraints.maxWidth * 0.06;

            return Row(
              children: [
                Stack(
                  alignment: Alignment.center,
                  children: [
                    SizedBox(
                      width: indicatorSize,
                      height: indicatorSize,
                      child: CircularProgressIndicator(
                        value: power.batteryPercent / 100,
                        strokeWidth: indicatorSize * 0.1,
                        backgroundColor: Colors.blue.shade100,
                        valueColor: AlwaysStoppedAnimation(power.batteryColor),
                      ),
                    ),
                    GestureDetector(
                      onTap: () => _showBatteryPercentageSheet(context, power),
                      child: Text(
                        '${power.batteryPercent}%',
                        style: TextStyle(
                          fontSize: fontSize,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(width: constraints.maxWidth * 0.05),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Battery Status',
                        style: TextStyle(
                          fontSize: fontSize * 0.8,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 6),
                      const Divider(color: Colors.grey),
                      Text(
                        'Estimated Runtime: ${power.estimatedRuntime}',
                        style: TextStyle(
                          fontSize: fontSize * 0.7,
                          color: Colors.black54,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            );
          },
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
