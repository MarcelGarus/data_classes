import 'package:data_classes/data_classes.dart';

part 'main.g.dart';

void main() {
  var freshApple = const Fruit(type: 'apple', color: 'green');
  var someApple = freshApple.copy((fruit) => fruit..color = null);
  var kiwi = someApple.copy((fruit) => fruit
    ..type = 'Kiwi'
    ..color = 'brown');
  print(kiwi);
}

@GenerateDataClassFor()
class SomeMutableFruit {
  String type;

  @nullable
  String color;
}
