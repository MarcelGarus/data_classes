import 'package:data_classes/data_classes.dart';
import 'package:json_annotation/json_annotation.dart';

import 'colors.dart';

part 'main.g.dart';

enum Shape { round, curved }

@GenerateDataClass()
class MutableFruit {
  Color color;
  Shape shape;

  MutableFruit({
    @required this.color,
    @required this.shape,
  })  : assert(color != null),
        assert(shape != null);
}

// --- generated code ---

void main() {
  final a = Fruit();
  a.doubleShape;
  a.doubleLine;
}
