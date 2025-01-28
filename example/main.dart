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
