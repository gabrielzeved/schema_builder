# Schema Builder - A Flutter JSON Schema Generator

A Flutter library for generating **JSON schemas** from Dart classes using annotations. This library allows you to define custom schemas for your Dart classes and fields, making it easy to generate structured JSON schemas for validation, documentation, or API integration.

---

## Features

- **Annotations**: Use `@JsonSchema` and `@SchemaValue` to define JSON schemas for your Dart classes and fields.
- **Custom Converters**: Implement `SchemaConverter` to define custom schema generation logic for specific types.
- **Flexible Configuration**: Add titles, descriptions, and ignore fields as needed.
- **Code Generation**: Automatically generate JSON schemas using `build_runner`.

---

## Installation

Add the library to your `pubspec.yaml` file:

```yaml
dependencies:
  flutter:
    sdk: flutter
  schema_builder: ^0.1.0

dev_dependencies:
  build_runner: ^2.1.0
```

## Usage

### Step 1: Annotate Your Classes

Use the `@JsonSchema` annotation to mark a class for JSON schema generation. You can also use the `@SchemaValue` annotation to customize individual fields.

```dart
import 'package:schema_builder/json_schema.dart';

@JsonSchema(
  title: 'Person',
  description: 'A person with a name and age.',
)
class Person {
  @SchemaValue(
    title: 'Full Name',
    description: 'The full name of the person.',
  )
  final String name;

  @SchemaValue(
    title: 'Age',
    description: 'The age of the person.',
  )
  final int age;

  @SchemaValue(ignore: true) // This field will be ignored in the schema
  final String secret;

  Person({
    required this.name,
    required this.age,
    required this.secret,
  });
}
```

### Step 2: Define Custom Converters (Optional)

If you need custom schema generation logic for specific types, implement the `SchemaConverter` interface.

```dart
class CustomTypeConverter extends SchemaConverter {
  const CustomTypeConverter();

  @override
  Map<String, dynamic> schema(dynamic context) {
    return {
      'type': 'object',
      'properties': {
        'customField': {'type': 'string'},
      },
    };
  }
}

@JsonSchema()
class CustomClass {
  @SchemaValue(converter: CustomTypeConverter())
  final CustomType customField;

  CustomClass(this.customField);
}
```

### Step 3: Run the Code Generator

Use `build_runner` to generate the JSON schemas:

```bash
dart run build_runner build
```

This will generate a `.g.dart` file containing the JSON schema for your annotated classes.

### Step 4: Access the Generated Schema

The generated schema will be available in the `.g.dart` file. For example:

```dart
// **************************************************************************
// Generator: SchemaBuilder
// **************************************************************************

Map<String, dynamic> _$PersonSchema(BuildContext context) {
  return {
    "type": "object",
    "title": "Person",
    "description": "A person with a name and age.",
    "properties": {
      "name": {
        "type": "string",
        "title": "Full Name",
        "description": "The full name of the person."
      },
      "age": {
        "type": "number",
        "title": "Age",
        "description": "The age of the person."
      }
    }
  };
}
```

You can now use this schema for validation, documentation, or API integration.

> **NOTE:** Private and static fields are ignored by default.

---

## API Reference

### `@JsonSchema`

| Parameter     | Type   | Description                          |
|---------------|--------|--------------------------------------|
| `title`       | String | The title of the JSON schema.        |
| `description` | String | A description of the JSON schema.    |

### `@SchemaValue`

| Parameter     | Type            | Description                          |
|---------------|-----------------|--------------------------------------|
| `title`       | String          | The title of the field.              |
| `description` | String          | A description of the field.          |
| `converter`   | SchemaConverter | A custom converter for the field.    |
| `ignore`      | bool            | Whether to ignore the field.         |
| `each`        | SchemaValue     | Schema for each item in a list.      |

### `SchemaConverter`

An abstract class for defining custom schema generation logic. Implement the `schema` method to return a `Map<String, dynamic>` representing the schema.

---

## Contributing

Contributions are welcome! Please open an issue or submit a pull request on [GitHub](https://github.com/gabrielzeved/schema_builder).

---

## License

This project is licensed under the MIT License. See the [LICENSE](LICENSE) file for details.

---

Let me know if you need further adjustments or additional sections! 🚀