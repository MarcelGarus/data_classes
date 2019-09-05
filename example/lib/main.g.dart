// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'main.dart';

// **************************************************************************
// DataClassGenerator
// **************************************************************************

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
