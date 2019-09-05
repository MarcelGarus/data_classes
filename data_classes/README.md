Hey there!
If you're reading this and want data classes to become a language-level feature
of Dart, consider giving [this issue] a thumbs up.

This library generates data classes for your classes.

Simply add it to your dependencies like this:

```yaml
dependencies:
  data_classes: any

dev_dependencies:
  data_classes_generator: any
```

Then, you can implement blueprints of classes by making their name start with
a '$' sign and annotating them with `@DataClass()`, like this:

```dart
import 'package:data_classes/data_classes.dart';

part 'my_file.g.dart';

@DataClass()
class $User {
  String firstName;
  String lastName;
  @Nullable() String photoUrl;
}
```

By running `flutter pub run build_runner build` in the command line, the
following code is automatically generated:

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

  int get hashCode => hashValues(firstName, lastName, photoUrl);

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
