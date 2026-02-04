// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'appliance.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class ApplianceAdapter extends TypeAdapter<Appliance> {
  @override
  final typeId = 0;

  @override
  Appliance read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Appliance(
      name: fields[0] as String,
      watts: (fields[1] as num).toInt(),
      isOn: fields[2] == null ? false : fields[2] as bool,
    );
  }

  @override
  void write(BinaryWriter writer, Appliance obj) {
    writer
      ..writeByte(3)
      ..writeByte(0)
      ..write(obj.name)
      ..writeByte(1)
      ..write(obj.watts)
      ..writeByte(2)
      ..write(obj.isOn);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ApplianceAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
