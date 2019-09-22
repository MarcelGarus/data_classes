## 2.0.1 - 2019-09-20

- Code generation throws error if problems occur.

## 2.0.0 - 2019-09-20

- Change `@DataClass()` annotation to `@GenerateDataClassFor()`.
- `GeneratedClass.fromMutable()` is now a normal constructor instead of a
  factory constructor.

## 1.1.1 - 2019-09-05

- Fix newline issue in `toString()`.

## 1.1.0 - 2019-09-05

- Change `@Nullable()` annotation to `@nullable`.
- Add `toString()` method to generated class.
- Make sure there are no `final` fields in the mutable class.

## 1.0.3 - 2019-09-04

- Relax those version constraints even further.

## 1.0.2 - 2019-09-04

- Relax version constraints on `analyzer` and `build_runner` in the
  `pubspec.yaml`.

## 1.0.1 - 2019-09-04

- Change blueprint prefix from `$` to the more intuitive `Mutable`.

## 1.0.0 - 2019-09-04

- Initial release: Supporting creation of data classes with fields,
  constructor, converter to and from the original mutable class, custom `==`,
  and `hashCode` implementations as well as `copyWith`.
