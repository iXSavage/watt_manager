import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:lottie/lottie.dart';
import 'package:provider/provider.dart';

import '../providers/power_provider.dart';
import 'home_screen.dart';

class OnboardingScreen extends StatefulWidget {
  OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final TextEditingController _deviceNameController = TextEditingController();

  final TextEditingController _inverterCapacityController = TextEditingController();

  final TextEditingController _batteryCapacityController = TextEditingController();

  @override
  void dispose() {
    _deviceNameController.dispose();
    _inverterCapacityController.dispose();
    _batteryCapacityController.dispose();
    //TODO: implement dispose
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              SizedBox(height: 20,),

              Lottie.asset('assets/lottie/Solar_Animation.json'),

              Text('Watt Manager',
                style: TextStyle(
                  fontSize: 35,
                  fontWeight: FontWeight.bold,
                ),
              ),

              SizedBox(height: 20,),

              TextField(
                onTapOutside: (event) {
                  FocusScope.of(context).unfocus();
                },
                controller: _deviceNameController,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: "Enter Device Name",
                ),
              ),

              SizedBox(height: 20,),

              TextField(
                onTapOutside: (event) {
                  FocusScope.of(context).unfocus();
                },
                controller: _inverterCapacityController,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: "Enter Inverter Capacity",
                  suffix: Text('W')
                ),
              ),

              SizedBox(height: 20,),

              TextField(
                onTapOutside: (event) {
                  FocusScope.of(context).unfocus();
                },
                controller: _batteryCapacityController,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: "Enter Battery Capacity",
                  suffix: Text('Wh')
                ),
              ),

              SizedBox(height: 20,),

              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  minimumSize: Size(double.infinity,50),
                  textStyle: TextStyle(fontSize: 20),
                  foregroundColor: Colors.black,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  )
                ),
                onPressed: (){
                  if (_deviceNameController.text.isEmpty || _inverterCapacityController.text.isEmpty || _batteryCapacityController.text.isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        duration: Duration(milliseconds: 500),
                        content: Text('Fill in all details correctly'),
                      ),
                    );
                    return;
                  }
                  if (int.parse(_inverterCapacityController.text) <= 0 || int.parse(_batteryCapacityController.text) <= 0) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        duration: Duration(seconds: 2),
                        content: Text(
                            'Capacity values must be greater than zero'),
                      ),
                    );
                    return;
                  }
                  context.read<PowerProvider>().updateSettings(
                    int.parse(_inverterCapacityController.text),
                    int.parse(_batteryCapacityController.text),
                    _deviceNameController.text,
                    );
                  Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => HomeScreen()));
                },
                child: Text('Proceed'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
