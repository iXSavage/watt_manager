import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class DeviceNameSheet extends StatefulWidget {
  final Function(String) onSave;
  final VoidCallback onCancel;
  final String? deviceName;

  const DeviceNameSheet({
    super.key,
    required this.onSave,
    required this.onCancel,
    this.deviceName,
  });

  @override
  State<DeviceNameSheet> createState() => _DeviceNameSheetState();
}

class _DeviceNameSheetState extends State<DeviceNameSheet> {
  late final TextEditingController _deviceNameController;

  @override
  void initState() {
    super.initState();
    _deviceNameController = TextEditingController(text: widget.deviceName);
  }

  @override
  void dispose() {
    _deviceNameController.dispose();
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
          height: mediaQuery.size.height * 0.35,
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    'Edit Device Name',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 15),
                  TextField(
                    onTapOutside: (event) {
                      FocusScope.of(context).unfocus();
                    },
                    controller: _deviceNameController,
                    autofocus: true,
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      labelText: "Device Name",
                      hintText: "Enter a device name",
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
                          if (_deviceNameController.text.isEmpty) {
                            return;
                          }
                          widget.onSave(_deviceNameController.text);
                        },
                        child: const Text('Save'),
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
