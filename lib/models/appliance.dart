import 'package:hive_ce/hive.dart';

part 'appliance.g.dart';

@HiveType(typeId: 0)
class Appliance extends HiveObject{

  @HiveField(0)
  final String name;

  @HiveField(1)
  final int watts;

  @HiveField(2)
  bool isOn;

  Appliance({
    required this.name,
    required this.watts,
    this.isOn = false,
  });
}