import 'package:analyzer/dart/constant/value.dart';
import 'package:analyzer/dart/element/element.dart';
import 'package:source_gen/source_gen.dart';

class AnnotationHelper {
  const AnnotationHelper();

  static DartObject? object<T>(Element element) {
    try {
      var annotationValue = element.metadata.firstWhere(
        (element) {
          var constant = element.computeConstantValue();

          if (constant == null || constant.type == null) return false;

          bool isValidAnnotation =
              TypeChecker.fromRuntime(T).isAssignableFromType(constant.type!);

          return isValidAnnotation;
        },
      ).computeConstantValue()!;

      return annotationValue;
    } catch (e) {
      return null;
    }
  }
}
