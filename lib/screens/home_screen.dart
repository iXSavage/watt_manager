import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:watt_manager/widgets/battery_card.dart';
import 'package:watt_manager/widgets/power_load_card.dart';
import '../providers/power_provider.dart';
import '../widgets/add_appliance.dart';
import '../widgets/appliances_card.dart';
import 'onboarding_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with WidgetsBindingObserver {

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    WidgetsBinding.instance.addObserver(this);

    // Calculate any missed drain time when app first opens
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<PowerProvider>().resumeDrain();
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    // TODO: implement dispose
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    final provider = context.read<PowerProvider>();

    switch (state) {
      case AppLifecycleState.resumed:
      // App came back to foreground
        provider.resumeDrain();
        break;
      case AppLifecycleState.paused:
      // App went to background (user switched apps or locked phone)
        provider.pauseDrain();
        break;
      case AppLifecycleState.inactive:
      // Temporary state (e.g., phone call incoming)
        break;
      case AppLifecycleState.hidden:
      // App is hidden but still in memory (iOS specific)
        //provider.pauseDrain();
        break;
      case AppLifecycleState.detached:
      // App is being closed
        provider.pauseDrain();
        break;
    }
  }

  bool isOn = false;


  @override
  Widget build(BuildContext context) {
    final power = context.watch<PowerProvider>();

    return Scaffold(
      appBar: AppBar(
        title: Text(power.deviceName.toUpperCase()),
        actions: [
          IconButton(onPressed: () async {
           await context.read<PowerProvider>().reset();
            // Go back to onboarding and clear the navigation stack
            Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (context) => OnboardingScreen()),(route) => false,);
          },
              icon: Icon(Icons.logout))
        ]
      ),

      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              BatteryCard(),

              SizedBox(height: 15,),

              PowerLoadCard(),

              SizedBox(height: 15,),

              AppliancesCard(),

              SizedBox(height: 15,),

              AddApplianceButton(),

              SizedBox(height: 20,)
            ],
          ),
        ),
      ),
    );
  }
}

