@TestOn('vm')
library;

import 'package:schema_builder/json_schema.dart';
import 'package:schema_builder/schema_builder.dart';
import 'package:source_gen_test/source_gen_test.dart';
import 'package:test/test.dart';

Future<void> main() async {
  final reader = await initializeLibraryReaderForDirectory(
    'test_files',
    'example_test_src.dart',
  );

  initializeBuildLogTracking();
  testAnnotatedElements<JsonSchema>(
    reader,
    SchemaBuilder(),
  );
}
