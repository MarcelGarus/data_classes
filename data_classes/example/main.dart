// ignore_for_file: undefined_class, uri_has_not_been_generated

import 'package:data_classes/data_classes.dart';

part 'main.g.dart';

void main() {
  const freshApple = const Fruit(type: 'apple', color: 'green');
  var someApple = freshApple.copy((fruit) => fruit..color = null);
  var kiwi = someApple.copy((fruit) => fruit
    ..type = 'Kiwi'
    ..color = 'brown');
  print(kiwi);
}

@GenerateDataClass()
class MutableFruit {
  String type;

  @nullable
  String color;
}
