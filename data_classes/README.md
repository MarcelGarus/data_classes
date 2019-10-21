Hey there!
If you're reading this and want data classes to become a language-level feature
of Dart, consider giving
[this issue](https://github.com/dart-lang/language/issues/314) a thumbs up. 👍

In the meantime, this library generates immutable data classes for you based on
simple mutable blueprint classes. Here's how to get started:

**1.** 📦 Add these packages to your dependencies:

```yaml
dependencies:
  data_classes: ^3.0.0

dev_dependencies:
  build_runner: ^1.7.1
  data_classes_generator: ^3.0.0
```

**2.** 🧬 Write a blueprint class. Let the name start with `Mutable` and
annotate it with `@GenerateDataClass()`:

```dart
import 'package:data_classes/data_classes.dart';

part 'my_file.g.dart';

@GenerateDataClass()
class MutableFruit {
  String name;
  @nullable String color;
}
```

By default, attributes are considered non-nullable. If you want an attribute to
be nullable, annotate it with `@nullable`.

**3.** 🏭 Run `pub run build_runner build` in the command line (or
`flutter pub run build_runner build`, if you're using Flutter). The
implementation based on your mutable class will automatically be generated.

## copy & copyWith

By default, a `copy` method will be generated that takes a mutating function:

```dart
var freshApple = const Fruit(
  name: 'apple',
  color: 'green',
);
var banana = freshApple.copy((fruit) =>
  fruit
    ..name = 'banana'
    ..color = 'yellow'
);
```

Sometimes, you have classes that are guaranteed to only have non-nullable variables. For those, you can opt in to generate a `copyWith` method!

```dart
@GenerateDataClass(generateCopyWith = true)
class MutableFruit {
  String name;
  String color;
}

var oldApple = freshApple.copyWith(
  color: 'brown',
);
```

If you're wondering why all fields have to be non-nullable, [here](https://github.com/marcelgarus/data_classes/issues/3)'s a discussion about that.

## value getters

Sometimes, you have enum values as fields. In that case, you have the option to generate getters directly on the immutable class:

```dart
enum Color { red, yellow, green, brown }
enum Shape { round, curved }

@GenerateDataClass()
class MutableFruit {
  @GenerateValueGetters(generateNegations = true)
  Color color;

  @GenerateValueGetters(usePrefix = true)
  Shape theShape;
}

var banana = Fruit(color: Color.yellow, theShape: Shape.curved);

banana.isYellow; // true
banana.isNotGreen; // true
banana.isTheShapeRound; // false
```

## full example

Here's an example with all the features (except nullability, so `copyWith` works). To showcase prefixed type imports, the `Color` enum from above has been moved to a file named `colors.dart`.

```dart
import 'package:data_classes/data_classes.dart';

import 'colors.dart' as colors;

part 'main.g.dart';

enum Shape { round, curved }

/// A fruit with a doc comment.
@GenerateDataClass(generateCopyWith: true)
class MutableFruit {
  String name;

  /// The color of this fruit.
  @GenerateValueGetters(generateNegations: true)
  colors.Color color;

  @GenerateValueGetters(usePrefix: true)
  Shape shape;

  List<String> likedBy;
}
```

And here's the generated code:

```dart

/// A fruit with a doc comment.
@immutable
class Fruit {
  final String name;

  /// The color of this fruit.
  final colors.Color color;

  final Shape shape;

  final List<String> likedBy;

  // Value getters.
  bool get isRed => this.color == colors.Color.red;
  bool get isNotRed => this.color != colors.Color.red;
  bool get isYellow => this.color == colors.Color.yellow;
  bool get isNotYellow => this.color != colors.Color.yellow;
  bool get isGreen => this.color == colors.Color.green;
  bool get isNotGreen => this.color != colors.Color.green;
  bool get isBrown => this.color == colors.Color.brown;
  bool get isNotBrown => this.color != colors.Color.brown;
  bool get isShapeRound => this.shape == Shape.round;
  bool get isShapeCurved => this.shape == Shape.curved;

  /// Default constructor that creates a new [Fruit] with the given
  /// attributes.
  const Fruit({
    @required this.name,
    @required this.color,
    @required this.shape,
    @required this.likedBy,
  })  : assert(name != null),
        assert(color != null),
        assert(shape != null),
        assert(likedBy != null);

  /// Creates a [Fruit] from a [MutableFruit].
  Fruit.fromMutable(MutableFruit mutable)
      : name = mutable.name,
        color = mutable.color,
        shape = mutable.shape,
        likedBy = mutable.likedBy;

  /// Turns this [Fruit] into a [MutableFruit].
  MutableFruit toMutable() {
    return MutableFruit()
      ..name = name
      ..color = color
      ..shape = shape
      ..likedBy = likedBy;
  }

  /// Checks if this [Fruit] is equal to the other one.
  bool operator ==(Object other) {
    return other is Fruit &&
        name == other.name &&
        color == other.color &&
        shape == other.shape &&
        likedBy == other.likedBy;
  }

  int get hashCode {
    return hashList([name, color, shape, likedBy]);
  }

  /// Copies this [Fruit] with some changed attributes.
  Fruit copy(void Function(MutableFruit mutable) changeAttributes) {
    assert(
        changeAttributes != null,
        "You called Fruit.copy, but didn't provide a function for changing "
        "the attributes.\n"
        "If you just want an unchanged copy: You don't need one, just use "
        "the original. The whole point of data classes is that they can't "
        "change anymore, so there's no harm in using the original class.");
    final mutable = this.toMutable();
    changeAttributes(mutable);
    return Fruit.fromMutable(mutable);
  }

  /// Copies this [Fruit] with some changed attributes.
  Fruit copyWith({
    String name,
    colors.Color color,
    Shape shape,
    List<String> likedBy,
  }) {
    return Fruit(
      name: name ?? this.name,
      color: color ?? this.color,
      shape: shape ?? this.shape,
      likedBy: likedBy ?? this.likedBy,
    );
  }

  /// Converts this [Fruit] into a [String].
  String toString() {
    return 'Fruit(\n'
        '  name: $name\n'
        '  color: $color\n'
        '  shape: $shape\n'
        '  likedBy: $likedBy\n'
        ')';
  }
}
```
