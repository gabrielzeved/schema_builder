import 'package:schema_builder/src/json_schema.dart';
import 'package:source_gen_test/annotations.dart';

@ShouldGenerate(r'''
extension $ShouldGenerateForSimplePrimitiveTypesSchema
    on ShouldGenerateForSimplePrimitiveTypes {
  static $schema([BuildContext? context]) {
    return _$ShouldGenerateForSimplePrimitiveTypesSchema(context);
  }
}

Map<String, dynamic> _$ShouldGenerateForSimplePrimitiveTypesSchema([
  BuildContext? context,
]) {
  return {
    "type": "object",
    "properties": {
      "vString": {"type": "string"},
      "vInteger": {"type": "number"},
      "vDouble": {"type": "number"},
      "vBoolean": {"type": "boolean"},
    },
  };
}
''')
@JsonSchema()
class ShouldGenerateForSimplePrimitiveTypes {
  final String vString;
  final int vInteger;
  final double vDouble;
  final bool vBoolean;

  ShouldGenerateForSimplePrimitiveTypes({
    required this.vString,
    required this.vInteger,
    required this.vDouble,
    required this.vBoolean,
  });
}

@ShouldGenerate(r'''
extension $ShouldGenerateWithRootTitleAndDescriptionSchema
    on ShouldGenerateWithRootTitleAndDescription {
  static $schema([BuildContext? context]) {
    return _$ShouldGenerateWithRootTitleAndDescriptionSchema(context);
  }
}

Map<String, dynamic> _$ShouldGenerateWithRootTitleAndDescriptionSchema([
  BuildContext? context,
]) {
  return {
    "type": "object",
    "title": "Title Default",
    "description": "Description Default",
    "properties": {
      "vString": {"type": "string"},
    },
  };
}
''')
@JsonSchema(title: 'Title Default', description: 'Description Default')
class ShouldGenerateWithRootTitleAndDescription {
  final String vString;

  ShouldGenerateWithRootTitleAndDescription({
    required this.vString,
  });
}

@ShouldGenerate(r'''
extension $ShouldGenerateWithPropertyTitleAndDescriptionSchema
    on ShouldGenerateWithPropertyTitleAndDescription {
  static $schema([BuildContext? context]) {
    return _$ShouldGenerateWithPropertyTitleAndDescriptionSchema(context);
  }
}

Map<String, dynamic> _$ShouldGenerateWithPropertyTitleAndDescriptionSchema([
  BuildContext? context,
]) {
  return {
    "type": "object",
    "properties": {
      "vString": {
        "type": "string",
        "title": "Title default",
        "description": "Description default",
      },
    },
  };
}
''')
@JsonSchema()
class ShouldGenerateWithPropertyTitleAndDescription {
  @SchemaValue(title: 'Title default', description: 'Description default')
  final String vString;

  ShouldGenerateWithPropertyTitleAndDescription({
    required this.vString,
  });
}

// @ShouldGenerate(r'''
// Map<String, dynamic> _$SimpleSchemaSchema(BuildContext context) {
//   return {
//     "type": "object",
//     "title": "Simple Schema",
//     "description": "Simple Description",
//     "properties": {
//       "simpleText": {"type": "string", "title": "Simple Text"}
//     }
//   };
// }
// ''')
// @JsonSchema(title: 'Simple Schema', description: 'Simple Description')
// class SimpleSchema {
//   @SchemaValue(title: 'Simple Text')
//   final String simpleText;

//   SimpleSchema({required this.simpleText});
// }
