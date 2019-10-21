import 'package:data_classes/data_classes.dart';
import 'package:example/types.dart' as ty;

part 'main.g.dart';

void main() {
  var freshApple = Fruit(
    type: 'apple',
    color: Color.green,
    baz: <String>[],
  );
  var someApple = freshApple.copy((fruit) => fruit..color = null);
  var kiwi = someApple.copy((fruit) => fruit
    ..type = 'Kiwi'
    ..color = Color.brown);
  print(kiwi);
}

enum Color { red, green, yellow, blue, brown }

enum Shape { round, curved }

/// A fruit with a doc comment.
@GenerateDataClass(generateCopyWith: true)
class MutableFruit {
  String type;

  /// The color of this fruit.
  @GenerateValueGetters(generateNegations: true)
  Color color;

  @GenerateValueGetters(usePrefix: true)
  Shape shape;

  List<String> baz;

  ty.T t;

  int foo() {
    return baz.length + type.length;
  }
}
