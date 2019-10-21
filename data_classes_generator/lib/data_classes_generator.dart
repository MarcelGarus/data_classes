import 'package:analyzer/dart/element/element.dart';
import 'package:analyzer/dart/element/type.dart';
import 'package:build/build.dart';
import 'package:build/src/builder/build_step.dart';
import 'package:source_gen/source_gen.dart';
import 'package:data_classes/data_classes.dart';

Builder generateDataClass(BuilderOptions options) =>
    SharedPartBuilder([DataClassGenerator()], 'data_classes');

class CodeGenError extends Error {
  CodeGenError(this.message);
  final String message;
  String toString() => message;
}

class DataClassGenerator extends GeneratorForAnnotation<GenerateDataClass> {
  @override
  generateForAnnotatedElement(
    Element element,
    ConstantReader annotation,
    BuildStep _,
  ) {
    if (element is! ClassElement) {
      throw CodeGenError(
          'You can only annotate classes with @GenerateDataClass(), but '
          '"${element.name}" isn\'t a class.');
    }
    if (!element.name.startsWith('Mutable')) {
      throw CodeGenError(
          'The names of classes annotated with @GenerateDataClass() should '
          'start with "Mutable", for example Mutable${element.name}. The '
          'immutable class (in that case, ${element.name}) will then get '
          'automatically generated for you by running "pub run build_runner '
          'build" (or "flutter pub run build_runner build" if you\'re using '
          'Flutter).');
    }

    final originalClass = element as ClassElement;
    final name = originalClass.name.substring('Mutable'.length);

    // When import prefixes (`import '...' as '...';`) are used in the mutable
    // class's file, then in the generated file, we need to use the right
    // prefix in front of the type in the immutable class too. So here, we map
    // the module identifiers to their import prefixes.
    Map<String, String> qualifiedImports = {
      for (final import in originalClass.library.imports)
        if (import.prefix != null)
          import.importedLibrary.identifier: import.prefix.name,
    };

    // Collect all the fields and getters from the original class.
    final fields = <FieldElement>{};
    final getters = <FieldElement>{};

    for (final field in originalClass.fields) {
      if (field.isFinal) {
        throw CodeGenError(
            'Mutable classes shouldn\'t have final fields, but the class '
            'Mutable$name has the final field ${field.name}.');
      } else if (field.setter == null) {
        assert(field.getter != null);
        getters.add(field);
      } else if (field.getter == null) {
        assert(field.setter != null);
        throw CodeGenError(
            'Mutable classes shouldn\'t have setter-only fields, but the '
            'class Mutable$name has the field ${field.name}, which only has a '
            'setter.');
      } else {
        fields.add(field);
      }
    }

    // Check whether we should generate a `copyWith` method. Also ensure that
    // there are no nullable fields.
    final generateCopyWith = originalClass.metadata
        .firstWhere((annotation) =>
            annotation.element?.enclosingElement?.name == 'GenerateDataClass')
        .constantValue
        .getField('generateCopyWith')
        .toBoolValue();
    if (generateCopyWith && fields.any(_isNullable)) {
      final exampleField = fields.firstWhere(_isNullable).name;
      throw CodeGenError(
          'You tried to generate a copyWith method for the $name class (which '
          'gets generated based on the Mutable$name class). Unfortunately, '
          'you can only generate this method if all the fields are '
          'non-nullable, but for example, the $exampleField field is marked '
          'with @nullable. If you really want a copyWith method, you should '
          'consider removing that annotation.\n'
          'Why does this rule exist? Let\'s say, we would allow the copyWith '
          'method to get generated. If you would call it, it would have no '
          'way of knowing whether you just didn\'t pass in a $exampleField as '
          'a parameter or you intentionally tried to set it to null, because '
          'in both cases, the function parameter would be null. That makes '
          'the code vulnerable to subtle bugs when passing variables to the '
          'copyWith method. '
          'For more information about this, see the following GitHub issue: '
          'https://github.com/marcelgarus/data_classes/issues/3');
    }

    // Users can annotate fields that hold an enum value with
    // `@GenerateValueGetters()` to generate value getters on the immutable
    // class. Here, we prepare a map from the getter name to its code content.
    final valueGetters = <String, String>{};
    for (final field in fields) {
      final annotation = field.metadata
          .firstWhere(
              (annotation) =>
                  annotation.element?.enclosingElement?.name ==
                  'GenerateValueGetters',
              orElse: () => null)
          ?.computeConstantValue();
      if (annotation == null) continue;

      final usePrefix = annotation.getField('usePrefix').toBoolValue();
      final generateNegations =
          annotation.getField('generateNegations').toBoolValue();

      final enumClass = field.type.element as ClassElement;
      if (enumClass?.isEnum == false) {
        throw CodeGenError(
            'You annotated the Mutable$name\'s ${field.name} with '
            '@GenerateValueGetters(), but that\'s of '
            '${enumClass == null ? 'an unknown type' : 'the type ${enumClass.name}'}, '
            'which is not an enum. @GenerateValueGetters() should only be '
            'used on fields of an enum type.');
      }

      final prefix = 'is${usePrefix ? _capitalize(field.name) : ''}';
      final enumValues = enumClass.fields
          .where((field) => !['values', 'index'].contains(field.name));

      for (final value in enumValues) {
        for (final negate in generateNegations ? [false, true] : [false]) {
          final getter =
              '$prefix${negate ? 'Not' : ''}${_capitalize(value.name)}';
          final content = 'this.${field.name} ${negate ? '!=' : '=='} '
              '${_qualifiedType(value.type, qualifiedImports)}.${value.name}';

          if (valueGetters.containsKey(getter)) {
            throw CodeGenError(
                'A conflict occurred while generating value getters. The two '
                'conflicting value getters of the Mutable$name class are:\n'
                '- $getter, which tests if ${valueGetters[getter]}\n'
                '- $getter, which tests if $content');
          }

          valueGetters[getter] = content;
        }
      }
    }

    // Actually generate the class.
    final buffer = StringBuffer();
    buffer.writeAll([
      // Start of the class.
      originalClass.documentationComment ??
          '/// This class is the immutable pendant of the [Mutable$name] class.',
      '@immutable',
      'class $name {',

      // The field members.
      for (final field in fields) ...[
        if (field.documentationComment != null) field.documentationComment,
        'final ${_fieldToTypeAndName(field, qualifiedImports)};\n',
      ],

      // The value getters.
      '\n  // Value getters.',
      for (final getter in valueGetters.entries)
        'bool get ${getter.key} => ${getter.value};',

      // The default constructor.
      '/// Default constructor that creates a new [$name] with the given',
      '/// attributes.',
      'const $name({',
      for (final field in fields) ...[
        if (!_isNullable(field)) '@required ',
        'this.${field.name},'
      ],
      '}) : ',
      fields
          .where((field) => !_isNullable(field))
          .map((field) => 'assert(${field.name} != null)')
          .join(','),
      ';\n',

      // Converters (fromMutable and toMutable).
      '/// Creates a [$name] from a [Mutable$name].',
      '$name.fromMutable(Mutable$name mutable) : ',
      fields.map((field) => '${field.name} = mutable.${field.name}').join(','),
      ';\n',
      '/// Turns this [$name] into a [Mutable$name].',
      'Mutable$name toMutable() {',
      'return Mutable$name()',
      fields.map((field) => '..${field.name} = ${field.name}').join(),
      ';',
      '}\n',

      // Equality stuff (== and hashCode).
      '/// Checks if this [$name] is equal to the other one.',
      'bool operator ==(Object other) {',
      'return other is $name &&',
      fields
          .map((field) => '${field.name} == other.${field.name}')
          .join(' &&\n'),
      ';\n}\n',
      'int get hashCode {',
      'return hashList([',
      fields.map((field) => field.name).join(', '),
      ']);\n',
      '}\n',

      // copy
      '/// Copies this [$name] with some changed attributes.',
      '$name copy(void Function(Mutable$name mutable) changeAttributes) {',
      'assert(changeAttributes != null,',
      '"You called $name.copy, but didn\'t provide a function for changing "',
      '"the attributes.\\n"',
      '"If you just want an unchanged copy: You don\'t need one, just use "',
      '"the original. The whole point of data classes is that they can\'t "',
      '"change anymore, so there\'s no harm in using the original class."',
      ');',
      'final mutable = this.toMutable();',
      'changeAttributes(mutable);',
      'return $name.fromMutable(mutable);',
      '}\n',

      // copyWith
      if (generateCopyWith) ...[
        '/// Copies this [$name] with some changed attributes.',
        '$name copyWith({',
        for (final field in fields)
          '${_fieldToTypeAndName(field, qualifiedImports)},',
        '}) {',
        'return $name(',
        for (final field in fields)
          '${field.name}: ${field.name} ?? this.${field.name},',
        ');',
        '}',
      ],

      // toString converter.
      '/// Converts this [$name] into a [String].',
      'String toString() {',
      "return '$name(\\n'",
      for (final field in fields) "'  ${field.name}: \$${field.name}\\n'",
      "')';",
      '}',

      // End of the class.
      '}',
    ].expand((line) => [line, '\n']));

    return buffer.toString();
  }

  /// Whether the [field] is nullable.
  bool _isNullable(FieldElement field) {
    assert(field != null);

    return field.metadata
        .any((annotation) => annotation.element.name == nullable);
  }

  /// Capitalizes the first letter of a string.
  String _capitalize(String string) {
    assert(string.isNotEmpty);
    return string[0].toUpperCase() + string.substring(1);
  }

  /// Turns the [field] into type and the field name, separated by a space.
  String _fieldToTypeAndName(
    FieldElement field,
    Map<String, String> qualifiedImports,
  ) {
    assert(field != null);
    assert(qualifiedImports != null);

    return '${_qualifiedType(field.type, qualifiedImports)} ${field.name}';
  }

  /// Turns the [type] into a type with prefix.
  String _qualifiedType(DartType type, Map<String, String> qualifiedImports) {
    final typeLibrary = type.element.library;
    final prefixOrNull = qualifiedImports[typeLibrary.identifier];
    final prefix = (prefixOrNull != null) ? '$prefixOrNull.' : '';
    return '$prefix$type';
  }
}
