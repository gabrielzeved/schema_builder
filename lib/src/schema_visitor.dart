import 'package:analyzer/dart/constant/value.dart';
import 'package:analyzer/dart/element/element.dart';
import 'package:analyzer/dart/element/type.dart';
import 'package:analyzer/dart/element/visitor.dart';
import 'package:schema_builder/src/annotation_helper.dart';
import 'package:schema_builder/src/json_schema.dart';

final Map<String, String> jsonTypes = {
  "String": "string",
  "int": "number",
  "double": "number",
  "bool": "boolean"
};

class SchemaVisitor extends SimpleElementVisitor<void> {
  late JsonSchemaDefinition schemaDefinition;
  Map<String, JsonSchemaBuffer> fields = {};

  @override
  void visitClassElement(ClassElement element) {
    schemaDefinition = JsonSchemaDefinition();
  }

  @override
  void visitFieldElement(FieldElement element) {
    if (!element.isPublic || element.isStatic) return;

    JsonSchemaBuffer? buffer = _parse(element.type, element);
    if (buffer == null) return;

    fields[element.name] = buffer;
  }

  JsonSchemaBuffer? _parse(DartType type, Element annotatedElement) {
    DartObject? schemaProperties =
        AnnotationHelper.object<SchemaValue>(annotatedElement);

    if (shouldIgnore(schemaProperties)) return null;

    bool isNested = AnnotationHelper.object<JsonSchema>(type.element!) != null;

    if (isNested) {
      String extendClass = type.getDisplayString(withNullability: false);
      return ExtendedSchemaBuffer(clazz: extendClass);
    }

    DartObject? converter = schemaProperties?.getField("converter");

    if (converter != null && !converter.isNull) {
      String converterName =
          converter.type!.getDisplayString(withNullability: false);
      return ConverterSchemaBuffer(converter: converterName);
    }

    bool isList = type.isDartCoreList;

    JsonSchemaBuffer? buffer;

    if (isList) {
      buffer = _parseList(type, annotatedElement, schemaProperties);
    } else {
      buffer = _parsePrimitive(type);
    }

    if (buffer != null) {
      fillMetadata(schemaProperties, buffer);
    }

    return buffer;
  }

  JsonSchemaDefinition _parsePrimitive(DartType type) {
    JsonSchemaDefinition buffer = JsonSchemaDefinition();
    String jsonType =
        jsonTypes[type.getDisplayString(withNullability: false)] ?? "string";
    buffer.type = jsonType;
    return buffer;
  }

  JsonSchemaDefinition? _parseList(
    DartType type,
    Element parent,
    DartObject? schemaProperties,
  ) {
    if (type is! InterfaceType) return null;

    DartType itemType = type.typeArguments.first;
    JsonSchemaBuffer? itemsBuffer = _parse(itemType, parent);

    DartObject? eachProperties = schemaProperties?.getField("each");

    if (itemsBuffer != null) {
      fillMetadata(eachProperties, itemsBuffer);
    }

    JsonSchemaDefinition buffer = JsonSchemaDefinition();

    buffer.items = itemsBuffer;
    buffer.type = 'array';
    return buffer;
  }

  fillMetadata(DartObject? schemaProperties, JsonSchemaBuffer buffer) {
    if (buffer is! JsonSchemaDefinition) return;

    String? title = schemaProperties?.getField("title")?.toStringValue();
    if (title != null) buffer.title = title;

    String? description =
        schemaProperties?.getField("description")?.toStringValue();
    if (description != null) buffer.description = description;
  }

  bool shouldIgnore(DartObject? schemaProperties) {
    if (schemaProperties == null) return false;
    bool? ignore = schemaProperties.getField("ignore")?.toBoolValue();

    return ignore ?? false;
  }
}
