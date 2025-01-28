import 'dart:async';

import 'package:analyzer/dart/element/element.dart';
import 'package:build/build.dart';
import 'package:schema_builder/json_schema.dart';
import 'package:schema_builder/schema_visitor.dart';
import 'package:source_gen/source_gen.dart';

Builder build(BuilderOptions options) {
  return SharedPartBuilder([SchemaBuilder()], 'schema_builder');
}

class SchemaBuilder extends GeneratorForAnnotation<JsonSchema> {
  @override
  FutureOr<String> generateForAnnotatedElement(
    Element element,
    ConstantReader annotation,
    BuildStep buildStep,
  ) async {
    if (element is! ClassElement) {
      throw InvalidGenerationSourceError(
        '`@JsonSchema` can only be applied to classes.',
        element: element,
      );
    }

    //TODO: REFACTOR IMPLEMENTATION, TRY NO UNIFY WITH THE _parse FUNCTION FROM SCHEMA_VISITOR

    SchemaVisitor visitor = SchemaVisitor();
    element.visitChildren(visitor);

    JsonSchemaDefinition schemaBuffer = JsonSchemaDefinition();
    schemaBuffer.type = 'object';

    ConstantReader converter = annotation.read('converter');

    if (!converter.isNull) {
      ConverterSchemaBuffer converteSchemaBuffer = ConverterSchemaBuffer(
        converter: converter.objectValue.type?.getDisplayString() ?? '',
      );

      return '''Map<String, dynamic> _\$${element.name}Schema(BuildContext context){
  return ${converteSchemaBuffer.getStringDefinition()};
}''';
    }

    ConstantReader title = annotation.read('title');
    ConstantReader description = annotation.read('description');

    if (!title.isNull) {
      schemaBuffer.title = title.stringValue;
    }

    if (!description.isNull) {
      schemaBuffer.description = description.stringValue;
    }

    for (MapEntry<String, JsonSchemaBuffer> entry in visitor.fields.entries) {
      schemaBuffer.properties[entry.key] = entry.value;
    }

    return '''Map<String, dynamic> _\$${element.name}Schema(BuildContext context){
  return ${schemaBuffer.getStringDefinition()};
}''';
  }
}
