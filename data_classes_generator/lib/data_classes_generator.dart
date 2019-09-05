import 'package:analyzer/dart/element/element.dart';
import 'package:build/build.dart';
import 'package:build/src/builder/build_step.dart';
import 'package:source_gen/source_gen.dart';
import 'package:data_classes/data_classes.dart';

Builder generateDataClass(BuilderOptions options) =>
    SharedPartBuilder([DataClassGenerator()], 'data_classes');

class DataClassGenerator extends GeneratorForAnnotation<DataClass> {
  @override
  generateForAnnotatedElement(
      Element element, ConstantReader annotation, BuildStep _) {
    assert(element is ClassElement, 'Only annotate classes with @DataClass.');
    assert(
        element.name.startsWith('Mutable'),
        'The names of classes annotated with @DataClass should start with '
        '`Mutable`, for example `MutableUser`. The immutable class will then '
        'get automatically generated for you by running '
        '`pub run build_runner build` (or `flutter pub run build_runner build` '
        'if you\'re on Flutter).');

    var e = element as ClassElement;
    var name = e.name.substring('Mutable'.length);
    var fields = <FieldElement>{};
    var getters = <FieldElement>{};

    for (var field in e.fields) {
      if (field.setter == null) {
        assert(field.getter != null);
        getters.add(field);
      } else if (field.getter == null) {
        throw 'Setter-only fields not supported';
      } else
        fields.add(field);
    }

    return '''
    /// This class is the immutable pendant of the Mutable$name class.
    @immutable
    class $name {
      ${fields.map((field) => 'final ${_fieldToTypeAndName(field)};').join()}

      /// Default constructor that creates a $name.
      const $name({${fields.map((field) => '${_isNullable(field) ? '' : '@required'} this.${field.name},').join()}}) : ${fields.where((field) => !_isNullable(field)).map((field) => 'assert(${field.name} != null)').join(',')};

      /// Creates a $name from a Mutable$name.
      factory $name.fromMutable(Mutable$name mutable) {
        return $name(${fields.map((field) => '${field.name}: mutable.${field.name},').join()});
      }

      /// Turns this $name into a Mutable$name.
      Mutable$name toMutable() {
        return Mutable$name()
          ${fields.map((field) => '..${field.name} = ${field.name}').join()};
      }

      /// Checks if this $name is equal to the other one.
      bool operator ==(Object other) {
        return other is $name &&
            ${fields.map((field) => '${field.name} == other.${field.name}').join('&&')};
      }

      int get hashCode => hashList([${fields.map((field) => '${field.name},').join()}]);

      $name copyWith({
        ${fields.map((field) => '${_fieldToTypeAndName(field)},').join()}
      }) {
        return $name(${fields.map((field) => field.name).map((fieldName) => '$fieldName: $fieldName ?? this.$fieldName,').join()});
      }
    }
    ''';
  }

  bool _isNullable(FieldElement field) => field.metadata.any((annotation) =>
      annotation.element is ConstructorElement &&
      annotation.element.enclosingElement.name == 'Nullable');

  String _fieldToTypeAndName(FieldElement field) =>
      '${field.type.name} ${field.name}';
}
