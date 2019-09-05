Hey there!
If you're reading this and want data classes to become a language-level feature
of Dart, consider giving
[this issue](https://github.com/dart-lang/language/issues/314) a thumbs up.

In the meantime, this library generates immutable data classes for you based on
simple mutable blueprint classes.

Simply add it to your dependencies like this:

```yaml
dependencies:
  data_classes: ^1.0.2

dev_dependencies:
  data_classes_generator: ^1.0.1
```

Then, you can write data classes by letting their name start with `Mutable` and
annotating them with `@DataClass()`, like this:

```dart
import 'package:data_classes/data_classes.dart';

part 'my_file.g.dart';

@DataClass()
class MutableUser {
  String firstName;
  String lastName;
  @Nullable() String photoUrl;
}
```

By default, attributes are considered non-nullable. If you want an attribute to
be nullable, annotate it with `@Nullable()`.

By running `pub run build_runner build` in the command line (or
`flutter pub run build_runner build`, if you're using Flutter), the
implementation based on your mutable class is automatically generated.

The immutable class contains

* a constructor with named parameters and assertion for values that shouldn't
  be [null],
* serialization method/constructor for converting the immutable class to the
  the mutable class and the other way around,
* custom implementations of `==` and `hashCode`,
* a `copyWith` function.

For example, here's the generated code of our 6-line-class above:

```dart
/// This class is the immutable data class pendant of the mutable $User class.
@immutable
class User {
  final String firstName;
  final String lastName;
  final String photoUrl;

  /// Default constructor that creates a User.
  const User({
    @required this.firstName,
    @required this.lastName,
    this.photoUrl,
  })  : assert(firstName != null),
        assert(lastName != null);

  /// Creates a User from a mutable $User;
  factory User.fromMutable($User mutable) {
    return User(
      firstName: mutable.firstName,
      lastName: mutable.lastName,
      photoUrl: mutable.photoUrl,
    );
  }

  /// Turns this User into a mutable $User.
  $User toMutable() {
    return $User()
      ..firstName = firstName
      ..lastName = lastName
      ..photoUrl = photoUrl;
  }

  /// Checks if this User is equal to the other one.
  bool operator ==(Object other) {
    return other is User &&
        firstName == other.firstName &&
        lastName == other.lastName &&
        photoUrl == other.photoUrl;
  }

  int get hashCode => hashList([firstName, lastName, photoUrl]);

  User copyWith({
    String firstName,
    String lastName,
    String photoUrl,
  }) {
    return User(
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      photoUrl: photoUrl ?? this.photoUrl,
    );
  }
}
```
