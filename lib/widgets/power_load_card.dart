import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/power_provider.dart';

class PowerLoadCard extends StatelessWidget {
  const PowerLoadCard({super.key});

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
            double fontSize =
                constraints.maxWidth > 300 ? 18.0 : constraints.maxWidth * 0.05;
            double titleSize =
                constraints.maxWidth > 300 ? 20.0 : constraints.maxWidth * 0.06;
            double barHeight = constraints.maxWidth > 300 ? 25.0 : 20.0;

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Power Load',
                  style: TextStyle(
                    fontSize: titleSize,
                    fontWeight: FontWeight.w600,
                  ),
                ),

                const Divider(color: Colors.grey),

                Text(
                  'Total Load: ${power.totalLoad}W',
                  style: TextStyle(fontSize: fontSize),
                ),

                const SizedBox(height: 5),

                Text(
                  'Headroom Left: ${power.headRoom}W',
                  style: TextStyle(fontSize: fontSize),
                ),

                const SizedBox(height: 10),

                Stack(
                  children: [
                    Container(
                      width: double.infinity,
                      height: barHeight,
                      decoration: BoxDecoration(
                        color: Colors.grey,
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),

                    FractionallySizedBox(
                      widthFactor: power.loadFraction,
                      child: Container(
                        height: barHeight,
                        decoration: BoxDecoration(
                          color: power.warningColor,
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),

                    Positioned.fill(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 10),
                        child: Center(
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Text(
                                power.warningMessage,
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: fontSize * 0.8,
                                ),
                              ),
                              Text(
                                '${power.inverterCapacity}W',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: fontSize * 0.8,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
