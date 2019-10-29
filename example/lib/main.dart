import 'package:data_classes/data_classes.dart';
import 'package:json_annotation/json_annotation.dart';

import 'colors.dart';

part 'main.g.dart';

enum Shape { round, curved }

abstract class _Statement {
  int get line;
  int get doubleLine => line * 2;
}

abstract class ColorGettable {
  Color get color;
}

/// A fruit with a doc comment.
@JsonSerializable()
//@GenerateDataClass()
abstract class _Fruit extends _Statement implements ColorGettable {
  Color get color;
  @nullable
  Shape get shape;

  List<Shape> get doubleShape => [shape, shape];
}

// --- generated code ---

@immutable
class Statement extends _Statement {
  final int line;
  Statement(this.line);
}

@immutable
class Fruit extends _Fruit {
  final Color color;
  final Shape shape;

  Fruit({
    @required this.color,
    this.shape,
  });
}

void main() {
  final a = Fruit();
  a.doubleShape;
  a.doubleLine;
}
