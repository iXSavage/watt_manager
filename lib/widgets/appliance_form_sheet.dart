import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class ApplianceFormSheet extends StatefulWidget {
  final String title;
  final String? initialName;
  final int? initialWatts;
  final Function(String name, int watts) onSave;
  final VoidCallback onCancel;

  const ApplianceFormSheet({
    super.key,
    required this.title,
    this.initialName,
    this.initialWatts,
    required this.onSave,
    required this.onCancel,
  });

  @override
  State<ApplianceFormSheet> createState() => _ApplianceFormSheetState();
}

class _ApplianceFormSheetState extends State<ApplianceFormSheet> {
  late final TextEditingController _nameController;
  late final TextEditingController _wattController;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.initialName);
    _wattController = TextEditingController(
      text: widget.initialWatts?.toString(),
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _wattController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: SizedBox(
        height: 300,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                widget.title,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 15),
              TextField(
                onTapOutside: (event) {
                  FocusScope.of(context).unfocus();
                },
                controller: _nameController,
                textCapitalization: TextCapitalization.words,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: "Appliance Name (e.g. Fridge)",
                ),
              ),
              const SizedBox(height: 20),
              TextField(
                onTapOutside: (event) {
                  FocusScope.of(context).unfocus();
                },
                controller: _wattController,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: "Wattage (W)",
                  suffixText: "W",
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
                      if (_nameController.text.trim().isEmpty ||
                          _wattController.text.isEmpty) {
                        return;
                      }

                      final watts = int.tryParse(_wattController.text);
                      if (watts != null && watts > 0) {
                        widget.onSave(_nameController.text.trim(), watts);
                      }
                    },
                    child: Text(widget.title.contains('Edit') ? 'Save' : 'Add'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}