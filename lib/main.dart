import 'package:flutter/material.dart';
import 'package:hive_ce_flutter/adapters.dart';
import 'package:watt_manager/providers/power_provider.dart';
import 'package:watt_manager/screens/home_screen.dart';
import 'package:provider/provider.dart';
import 'package:watt_manager/screens/onboarding_screen.dart';
import 'models/appliance.dart';


void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Hive.initFlutter();

  Hive.registerAdapter(ApplianceAdapter());

  await Hive.openBox('settings');

  await Hive.openBox<Appliance>('appliances');

  // Check if onboarding was already completed
  final settingsBox = Hive.box('settings');
  final bool hasSetup = settingsBox.get('deviceName', defaultValue: '').isNotEmpty;

  runApp(ChangeNotifierProvider(
    create: (context) => PowerProvider(),
      child: MyApp(hasSetup: hasSetup,),
  )
  );
}

class MyApp extends StatelessWidget {
  final bool hasSetup;
  const MyApp({super.key, required this.hasSetup});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter Demo',
      theme: ThemeData(
      ),
      home:hasSetup ? HomeScreen() : OnboardingScreen(),
    );
  }
}
