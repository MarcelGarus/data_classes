## [3.0.0] - 2019-10-21

- Support value getters by annotating the corresponding field with
  `@GenerateValueGetters()`. You can optionally set `generateNegations` and
  `usePrefix` to `true`.
- Update readme.

## [2.1.0] - 2019-10-20

- Make example not show any errors by ignoring `undefined_class` and
  `uri_has_nont_been_generated`.
- Replace unused `generateCopy` field of `GenerateDataClassFor` class with
  `generateCopyWith`.
- `copyWith` method now gets generated if you opt-in. Only works if all the
  fields are non-nullable.
- Make code more helpful by adding helpful comments at some places and using a
  `StringBuffer` instead of returning the output right away.

## [2.0.2] - 2019-10-09

- Support classes with fields that have types which were imported qualified
  (using `import '...' as ...;`).
- Type-promote fields that take generic type arguments.
- Make `freshApple` in example `const`.

## [2.0.1] - 2019-09-20

- Revise readme: Little typo fixes and document `build_runner` dependency.
- Code generation now throws error if problems occur.

## [2.0.0] - 2019-09-20

- Change `@DataClass()` annotation to `@GenerateDataClassFor()`.
- `GeneratedClass.fromMutable()` is now a normal constructor instead of a
  factory constructor.
- Provide new example.
- Revise readme.
- New license.

## [1.1.1] - 2019-09-05

- Fix newline issue in `toString()`.

## [1.1.0] - 2019-09-05

- Change `@Nullable()` annotation to `@nullable`.
- Add `toString()` method to generated class.
- Make sure there are no `final` fields in the mutable class.

## [1.0.3] - 2019-09-04

- Relax those version constraints even further.

## [1.0.2] - 2019-09-04

- Rename example's mutable class to `MutableUser`.
- Relax version constraints on `analyzer` and `build_runner` in the
  `pubspec.yaml`.

## [1.0.1] - 2019-09-04

- Add example.
- Change blueprint prefix from `$` to the more intuitive `Mutable`.

## [1.0.0] - 2019-09-04

- Initial release: Support `DataClass` and `Nullable` annotations. Using the
  `data_classes_generator` package, classes with fields, a constructor,
  converter to and from the original mutable class, custom `==`, `hashCode` and
  `copyWith` can get generated.
