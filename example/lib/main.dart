import 'package:data_classes/data_classes.dart';

import 'colors.dart' as colors;

part 'main.g.dart';

enum Shape { round, curved }

/// A fruit with a doc comment.
@GenerateDataClass()
class MutableFruit {
  String name;

  /// The color of this fruit.
  @GenerateValueGetters(generateNegations: true)
  colors.Color color;

  @GenerateValueGetters(usePrefix: true)
  @nullable
  Shape shape;

  List<String> likedBy;
}

void main() {
  var freshApple = Fruit(
    name: 'apple',
    color: colors.Color.green,
    likedBy: <String>[],
  );
  var someApple = freshApple.copy((fruit) => fruit..color = null);
  var kiwi = someApple.copy((fruit) => fruit
    ..name = 'Kiwi'
    ..color = colors.Color.brown);
  print(kiwi);
}
