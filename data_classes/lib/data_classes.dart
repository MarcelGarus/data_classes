export 'package:meta/meta.dart' show immutable, required;

import 'package:meta/meta.dart';

@immutable
class GenerateDataClass {
  const GenerateDataClass({
    this.generateCopyWith = true,
  }) : assert(generateCopyWith != null);

  final bool generateCopyWith;
}

@immutable
class GenerateValueGetters {
  const GenerateValueGetters({
    this.usePrefix = false,
    this.generateNegations = false,
  })  : assert(usePrefix != null),
        assert(generateNegations != null);

  final bool usePrefix;
  final bool generateNegations;
}

const String nullable = 'nullable';

/// Combines the [Object.hashCode] values of an arbitrary number of objects
/// from an [Iterable] into one value. This function will return the same
/// value if given [null] as if given an empty list.
// Borrowed from dart:ui.
int hashList(Iterable<Object> arguments) {
  var result = 0;
  if (arguments != null) {
    for (Object argument in arguments) {
      var hash = result;
      hash = 0x1fffffff & (hash + argument.hashCode);
      hash = 0x1fffffff & (hash + ((0x0007ffff & hash) << 10));
      result = hash ^ (hash >> 6);
    }
  }
  result = 0x1fffffff & (result + ((0x03ffffff & result) << 3));
  result = result ^ (result >> 11);
  return 0x1fffffff & (result + ((0x00003fff & result) << 15));
}
