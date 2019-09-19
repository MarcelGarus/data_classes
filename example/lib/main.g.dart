// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'main.dart';

// **************************************************************************
// DataClassGenerator
// **************************************************************************

/// This class is the immutable pendant of the [MutableFruit] class.
@immutable
class Fruit {
  final String type;
  final String color;

  /// Default constructor that creates a new [Fruit] with the given attributes.
  const Fruit({
    @required this.type,
    this.color,
  }) : assert(type != null);

  /// Creates a [Fruit] from a [MutableFruit].
  Fruit.fromMutable(MutableFruit mutable)
      : type = mutable.type,
        color = mutable.color;

  /// Turns this [Fruit] into a [MutableFruit].
  MutableFruit toMutable() {
    return MutableFruit()
      ..type = type
      ..color = color;
  }

  /// Checks if this [Fruit] is equal to the other one.
  bool operator ==(Object other) {
    return other is Fruit && type == other.type && color == other.color;
  }

  int get hashCode => hashList([
        type,
        color,
      ]);

  /// Copies this [Fruit] with some changed attributes.
  Fruit copy(void Function(MutableFruit mutable) changeAttributes) {
    assert(
        changeAttributes != null,
        "You called Fruit.copy, but didn't provide a function for changing "
        "the attributes.\n"
        "If you just want an unchanged copy: You don't need one, just use "
        "the original.");
    var mutable = this.toMutable();
    changeAttributes(mutable);
    return Fruit.fromMutable(mutable);
  }

  /// Converts this [Fruit] into a [String].
  String toString() {
    return 'Fruit(\n'
        '  type: $type\n'
        '  color: $color\n'
        ')';
  }
}
