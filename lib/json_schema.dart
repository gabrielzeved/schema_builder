abstract class JsonSchemaBuffer {
  String getStringDefinition();
}

class JsonSchemaDefinition extends JsonSchemaBuffer {
  String? type;
  Map<String, JsonSchemaBuffer> properties = <String, JsonSchemaBuffer>{};
  List<String>? required;
  JsonSchemaBuffer? items;

  String? title;
  String? description;
  Map<String, dynamic> additionalProperties = <String, dynamic>{};

  @override
  String getStringDefinition() {
    Map<String, dynamic> schema = {};

    if (type != null) {
      schema['"type"'] = '"$type"';
    }

    if (required != null) {
      schema['"required"'] = '"$required"';
    }

    if (title != null) {
      schema['"title"'] = '"$title"';
    }

    if (description != null) {
      schema['"description"'] = '"$description"';
    }

    if (properties.isNotEmpty) {
      schema['"properties"'] ??= {};
      for (var property in properties.entries) {
        schema['"properties"']['"${property.key}"'] =
            property.value.getStringDefinition();
      }
    }

    if (items != null) {
      schema['"items"'] = items!.getStringDefinition();
    }

    return schema.toString();
  }
}

class ConverterSchemaBuffer extends JsonSchemaBuffer {
  final String converter;

  ConverterSchemaBuffer({required this.converter});

  @override
  String getStringDefinition() {
    return "const $converter().schema(context)";
  }
}

class ExtendedSchemaBuffer extends JsonSchemaBuffer {
  final String clazz;

  ExtendedSchemaBuffer({required this.clazz});

  @override
  String getStringDefinition() {
    return "_\$${clazz.replaceAll("?", "")}Schema(context)";
  }
}

class JsonSchema {
  final String? title;
  final String? description;
  final SchemaConverter? converter;

  const JsonSchema({
    this.title,
    this.description,
    this.converter,
  });
}

class SchemaValue {
  final String? title;
  final String? description;
  final SchemaConverter? converter;
  final bool? ignore;
  final SchemaValue? each;

  const SchemaValue({
    this.title,
    this.description,
    this.converter,
    this.each,
    this.ignore,
  });
}

abstract class SchemaConverter {
  const SchemaConverter();
  // TODO: Try to solve this
  // For some reason if I use the correct type "BuildContext" the code generation library breaks, so I'm using dynamic as a workaround
  Map<String, dynamic> schema(dynamic context);
}
