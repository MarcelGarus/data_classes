import 'package:analyzer/dart/element/element.dart';
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

class DataClassGenerator extends GeneratorForAnnotation<GenerateDataClassFor> {
  @override
  generateForAnnotatedElement(
    Element element,
    ConstantReader annotation,
    BuildStep _,
  ) {
    if (element is! ClassElement) {
      throw CodeGenError(
          'You can only annotate classes with @GenerateDataClassFor(), but '
          '"${element.name}" isn\'t a class.');
    }
    if (!element.name.startsWith('Mutable')) {
      throw CodeGenError(
          'The names of classes annotated with @GenerateDataClassFor() should '
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
            annotation.element.enclosingElement.name == 'GenerateDataClassFor')
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

    // Actually generate the class.
    final buffer = StringBuffer();
    buffer.writeAll([
      // Start of the class.
      originalClass.documentationComment ??
          '/// This class is the immutable pendant of the [Mutable$name] class.',
      '@immutable',
      'class $name {',

      // The field members.
      for (final field in fields)
        'final ${_fieldToTypeAndName(field, qualifiedImports)};',

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

  /// Turns the [field] into type and the field name, separated by a space.
  String _fieldToTypeAndName(
    FieldElement field,
    Map<String, String> qualifiedImports,
  ) {
    assert(field != null);
    assert(qualifiedImports != null);

    var typeLibrary = field.type.element.library;
    var prefixOrNull = qualifiedImports[typeLibrary.identifier];
    var prefix = (prefixOrNull != null) ? (prefixOrNull + ".") : "";
    return '${prefix}${field.type} ${field.name}';
  }
}
