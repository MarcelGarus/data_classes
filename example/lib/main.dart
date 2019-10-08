import 'package:data_classes/data_classes.dart';
import 'package:example/types.dart' as ty;

part 'main.g.dart';

void main() {
  var freshApple = new Fruit(type: 'apple', color: 'green', baz: new List<String>());
  var someApple = freshApple.copy((fruit) => fruit..color = null);
  var kiwi = someApple.copy((fruit) => fruit
    ..type = 'Kiwi'
    ..color = 'brown');
  print(kiwi);
}

@GenerateDataClassFor()
class MutableFruit {
  String type;

  @nullable
  String color;

  List<String> baz;

  ty.T t;

  int foo() {
    return baz.length + type.length;
  }
}

// @DataClass
mixin _User {
  List<String> get firstNames;
  String get lastName;
  @nullable String get photoUrl;
}

class Foo {

}
