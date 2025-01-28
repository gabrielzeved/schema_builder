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

/// Annotation to mark a Dart class for JSON schema generation.
///
/// Use this annotation to define metadata (e.g., title, description)
/// for the generated JSON schema.
///
/// Example:
/// ```dart
/// @JsonSchema(
///   title: 'Person',
///   description: 'A person with a name and age.',
/// )
/// class Person {
///   final String name;
///   final int age;
///
///   Person(this.name, this.age);
/// }
/// ```
class JsonSchema {
  /// The title of the JSON schema.
  ///
  /// This will be included in the generated schema as the `title` property.
  final String? title;

  /// A description of the JSON schema.
  ///
  /// This will be included in the generated schema as the `description` property.
  final String? description;

  /// A custom converter to generate the schema for this field.
  ///
  /// Use this to define custom schema generation logic for complex types.
  final SchemaConverter? converter;

  /// Creates a [JsonSchema] annotation.
  ///
  /// - [title]: The title of the schema.
  /// - [description]: A description of the schema.
  const JsonSchema({
    this.title,
    this.description,
    this.converter,
  });
}

/// Annotation to customize the JSON schema for a specific field.
///
/// Use this annotation to define metadata (e.g., title, description, custom converters)
/// for individual fields in a Dart class.
///
/// Example:
/// ```dart
/// @JsonSchema()
/// class Person {
///   @SchemaValue(
///     title: 'Full Name',
///     description: 'The full name of the person.',
///   )
///   final String name;
///
///   @SchemaValue(ignore: true) // This field will be ignored in the schema
///   final String secret;
///
///   Person(this.name, this.secret);
/// }
/// ```
class SchemaValue {
  /// The title of the field in the JSON schema.
  ///
  /// This will be included in the generated schema as the `title` property.
  final String? title;

  /// A description of the field in the JSON schema.
  ///
  /// This will be included in the generated schema as the `description` property.
  final String? description;

  /// A custom converter to generate the schema for this field.
  ///
  /// Use this to define custom schema generation logic for complex types.
  final SchemaConverter? converter;

  /// Whether to ignore this field in the generated schema.
  ///
  /// If `true`, the field will not be included in the schema.
  final bool? ignore;

  /// The schema for each item in a list (if the field is a list).
  ///
  /// Use this to define the schema for individual items in a list field.
  final SchemaValue? each;

  /// Creates a [SchemaValue] annotation.
  ///
  /// - [title]: The title of the field.
  /// - [description]: A description of the field.
  /// - [converter]: A custom converter for the field.
  /// - [ignore]: Whether to ignore the field in the schema.
  /// - [each]: The schema for each item in a list field.
  const SchemaValue({
    this.title,
    this.description,
    this.converter,
    this.ignore,
    this.each,
  });
}

/// Abstract class for defining custom schema generation logic.
///
/// Implement this class to create custom converters for specific types.
/// The [schema] method should return a `Map<String, dynamic>` representing
/// the JSON schema for the type.
///
/// Example:
/// ```dart
/// class CustomTypeConverter extends SchemaConverter {
///   const CustomTypeConverter();
///
///   @override
///   Map<String, dynamic> schema(dynamic context) {
///     return {
///       'type': 'object',
///       'properties': {
///         'customField': {'type': 'string'},
///       },
///     };
///   }
/// }
/// ```
abstract class SchemaConverter {
  /// Creates a [SchemaConverter].
  const SchemaConverter();

  /// Generates a JSON schema for the type.
  ///
  /// - [context]: The context for schema generation (e.g., a field or class).
  /// - Returns: A `Map<String, dynamic>` representing the JSON schema.
  Map<String, dynamic> schema(dynamic context);
}
