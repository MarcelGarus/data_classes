Hey there!
If you're reading this and want data classes to become a language-level feature
of Dart, consider giving
[this issue](https://github.com/dart-lang/language/issues/314) a thumbs up. 👍

In the meantime, this library generates immutable data classes for you based on
simple mutable blueprint classes. Here's how to get started:

**1.** 📦 Add these packages to your dependencies:

```yaml
dependencies:
  data_classes: [insert newest version here]

dev_dependencies:
  build_runner: ^1.0.0
  data_classes_generator: [insert newest version here]
```

**2.** 🧬 Write a blueprint class. Let the name start with `Mutable` and
annotate it with `@GenerateDataClassFor()`:

```dart
import 'package:data_classes/data_classes.dart';

part 'my_file.g.dart';

@GenerateDataClassFor()
class MutableFruit {
  String type;
  @nullable String color;
}
```

By default, attributes are considered non-nullable. If you want an attribute to
be nullable, annotate it with `@nullable`.

**3.** 🏭 Run `pub run build_runner build` in the command line (or
`flutter pub run build_runner build`, if you're using Flutter). The
implementation based on your mutable class will automatically get generated.

The immutable class contains

* a constructor with named parameters and assertions for values that shouldn't
  be `null`,
* method/constructor for converting the immutable class to the mutable class
  and the other way around,
* custom implementations of `==` and `hashCode` as well as `toString()`,
* a `copy` method.

For example, here's the generated code of our 5-line-class above:

```dart
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
```
