// lib/models/template_step.dart
import 'package:courrier_mobile/models/courrier/courrier.dart';

sealed class TemplateStep {}

class StepCourriers extends TemplateStep {}

class StepMessages extends TemplateStep {
  final Courrier courrier;
  StepMessages(this.courrier);
}

class StepDetail extends TemplateStep {
  final Courrier courrier;
  final MessageCourrier message;
  StepDetail(this.courrier, this.message);
}