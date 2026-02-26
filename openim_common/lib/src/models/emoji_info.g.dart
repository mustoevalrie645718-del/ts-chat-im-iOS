// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'emoji_info.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class EmojiInfoAdapter extends TypeAdapter<EmojiInfo> {
  @override
  final int typeId = 1;

  @override
  EmojiInfo read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return EmojiInfo(
      url: fields[1] as String?,
      width: fields[2] as int?,
      height: fields[3] as int?,
      path: fields[4] as String,
    );
  }

  @override
  void write(BinaryWriter writer, EmojiInfo obj) {
    writer
      ..writeByte(4)
      ..writeByte(1)
      ..write(obj.url)
      ..writeByte(2)
      ..write(obj.width)
      ..writeByte(3)
      ..write(obj.height)
      ..writeByte(4)
      ..write(obj.path);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is EmojiInfoAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
