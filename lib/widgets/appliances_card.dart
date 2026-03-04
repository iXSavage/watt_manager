import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/power_provider.dart';
import 'appliance_list_tile.dart';

class AppliancesCard extends StatelessWidget {
  const AppliancesCard({super.key});

  @override
  Widget build(BuildContext context) {
    final power = context.watch<PowerProvider>();

    return LayoutBuilder(
      builder: (context, constraints) {
        double cardHeight =
            MediaQuery.of(context).size.height > 800 ? 400 : 350;
        double titleSize =
            constraints.maxWidth > 300 ? 20.0 : constraints.maxWidth * 0.06;

        return SizedBox(
          height: cardHeight,
          child: Card(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            elevation: 2,
            clipBehavior: Clip.hardEdge,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Connected Appliances',
                    style: TextStyle(fontSize: titleSize),
                  ),
                  const Divider(),
                  power.appliances.isNotEmpty
                      ? Expanded(
                        child: ListView.builder(
                          itemCount: power.appliances.length,
                          itemBuilder: (context, index) {
                            final appliance = power.appliances[index];
                            return ApplianceListTile(
                              appliance: appliance,
                              index: index,
                            );
                          },
                        ),
                      )
                      : const Expanded(
                        child: Center(
                          child: Text(
                            'No appliances connected',
                            style: TextStyle(fontSize: 18),
                          ),
                        ),
                      ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
