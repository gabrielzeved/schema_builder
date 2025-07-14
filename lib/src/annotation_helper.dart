import 'package:analyzer/dart/constant/value.dart';
import 'package:analyzer/dart/element/element.dart';
import 'package:source_gen/source_gen.dart';

class AnnotationHelper {
  const AnnotationHelper();

  static DartObject? object<T>(Element element) {
    try {
      List<ElementAnnotation> allAnnotations = [];

      allAnnotations.addAll(element.metadata);

      if (element is FieldElement) {
        if (element.getter != null) {
          allAnnotations.addAll(element.getter!.metadata);
        }
        if (element.setter != null) {
          allAnnotations.addAll(element.setter!.metadata);
        }
      }

      if (element is PropertyAccessorElement) {
        allAnnotations.addAll(element.variable.metadata);
      }

      var annotationValue = allAnnotations.firstWhere(
        (annotation) {
          var constant = annotation.computeConstantValue();

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
