import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class BatteryPercentageSheet extends StatefulWidget {
  final Function(int) onSave;
  final VoidCallback onCancel;

  const BatteryPercentageSheet({
    super.key,
    required this.onSave,
    required this.onCancel,
  });

  @override
  State<BatteryPercentageSheet> createState() => _BatteryPercentageSheetState();
}

class _BatteryPercentageSheetState extends State<BatteryPercentageSheet> {
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    final isTablet = mediaQuery.size.width > 600;

    return Padding(
      padding: EdgeInsets.only(bottom: mediaQuery.viewInsets.bottom),
      child: SafeArea(
        child: SizedBox(
          width: isTablet ? 400 : double.infinity,
          height: mediaQuery.size.height * 0.25,
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    "Set Battery Percentage",
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 15),
                  TextField(
                    onTapOutside: (event) {
                      FocusScope.of(context).unfocus();
                    },
                    controller: _controller,
                    inputFormatters: [
                      FilteringTextInputFormatter.digitsOnly,
                      LengthLimitingTextInputFormatter(3),
                    ],
                    keyboardType: TextInputType.number,
                    autofocus: true,
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      labelText: "Battery Percentage",
                      hintText: "0 - 100",
                      suffixText: "%",
                    ),
                  ),
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        onPressed: widget.onCancel,
                        child: const Text('Cancel'),
                      ),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        onPressed: () {
                          if (_controller.text.isEmpty) {
                            return;
                          }

                          final percentage = int.tryParse(_controller.text);
                          if (percentage != null &&
                              percentage >= 0 &&
                              percentage <= 100) {
                            widget.onSave(percentage);
                          }
                        },
                        child: const Text('Set'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
