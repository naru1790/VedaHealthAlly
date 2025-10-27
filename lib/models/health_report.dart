class HealthReport {
  final String reportId;
  final String userId;
  final String reportTitle;
  final String generatedAt;
  final String persona;
  final List<KeyMetric> keyMetrics;
  final AtAGlanceSummary atAGlanceSummary;
  final RiskAnalysis riskAnalysis;
  final ActionPlan actionPlan;
  final SupplementPrescription supplementPrescription;
  final MotivationalSummary motivationalSummary;

  HealthReport({
    required this.reportId,
    required this.userId,
    required this.reportTitle,
    required this.generatedAt,
    required this.persona,
    required this.keyMetrics,
    required this.atAGlanceSummary,
    required this.riskAnalysis,
    required this.actionPlan,
    required this.supplementPrescription,
    required this.motivationalSummary,
  });

  factory HealthReport.fromJson(Map<String, dynamic> json) {
    return HealthReport(
      reportId: json['reportId'],
      userId: json['userId'],
      reportTitle: json['reportTitle'],
      generatedAt: json['generatedAt'],
      persona: json['persona'],
      keyMetrics: (json['keyMetrics'] as List)
          .map((e) => KeyMetric.fromJson(e))
          .toList(),
      atAGlanceSummary: AtAGlanceSummary.fromJson(json['atAGlanceSummary']),
      riskAnalysis: RiskAnalysis.fromJson(json['riskAnalysis']),
      actionPlan: ActionPlan.fromJson(json['actionPlan']),
      supplementPrescription:
          SupplementPrescription.fromJson(json['supplementPrescription']),
      motivationalSummary:
          MotivationalSummary.fromJson(json['motivationalSummary']),
    );
  }
}

class KeyMetric {
  final String metricId;
  final String label;
  final double value;
  final String unit;
  final String normalRange;
  final String status;

  KeyMetric({
    required this.metricId,
    required this.label,
    required this.value,
    required this.unit,
    required this.normalRange,
    required this.status,
  });

  factory KeyMetric.fromJson(Map<String, dynamic> json) {
    return KeyMetric(
      metricId: json['metricId'],
      label: json['label'],
      value: (json['value'] as num).toDouble(),
      unit: json['unit'],
      normalRange: json['normalRange'],
      status: json['status'],
    );
  }
}

class AtAGlanceSummary {
  final String title;
  final List<SummaryPoint> negatives;
  final List<SummaryPoint> positives;

  AtAGlanceSummary({
    required this.title,
    required this.negatives,
    required this.positives,
  });

  factory AtAGlanceSummary.fromJson(Map<String, dynamic> json) {
    return AtAGlanceSummary(
      title: json['title'],
      negatives: (json['negatives'] as List)
          .map((e) => SummaryPoint.fromJson(e))
          .toList(),
      positives: (json['positives'] as List)
          .map((e) => SummaryPoint.fromJson(e))
          .toList(),
    );
  }
}

class SummaryPoint {
  final String title;
  final String description;

  SummaryPoint({
    required this.title,
    required this.description,
  });

  factory SummaryPoint.fromJson(Map<String, dynamic> json) {
    return SummaryPoint(
      title: json['title'],
      description: json['description'],
    );
  }
}

class RiskAnalysis {
  final String title;
  final String summary;
  final List<RiskFactor> riskFactors;

  RiskAnalysis({
    required this.title,
    required this.summary,
    required this.riskFactors,
  });

  factory RiskAnalysis.fromJson(Map<String, dynamic> json) {
    return RiskAnalysis(
      title: json['title'],
      summary: json['summary'],
      riskFactors: (json['riskFactors'] as List)
          .map((e) => RiskFactor.fromJson(e))
          .toList(),
    );
  }
}

class RiskFactor {
  final String factorId;
  final String title;
  final MetricInfo? metric;
  final String summary;
  final List<String> causes;
  final List<String> effects;

  RiskFactor({
    required this.factorId,
    required this.title,
    this.metric,
    required this.summary,
    required this.causes,
    required this.effects,
  });

  factory RiskFactor.fromJson(Map<String, dynamic> json) {
    return RiskFactor(
      factorId: json['factorId'],
      title: json['title'],
      metric: json['metric'] != null
          ? MetricInfo.fromJson(json['metric'])
          : null,
      summary: json['summary'],
      causes: List<String>.from(json['causes']),
      effects: List<String>.from(json['effects']),
    );
  }
}

class MetricInfo {
  final String label;
  final double value;
  final String unit;
  final String? normalRange;

  MetricInfo({
    required this.label,
    required this.value,
    required this.unit,
    this.normalRange,
  });

  factory MetricInfo.fromJson(Map<String, dynamic> json) {
    return MetricInfo(
      label: json['label'],
      value: (json['value'] as num).toDouble(),
      unit: json['unit'],
      normalRange: json['normalRange'],
    );
  }
}

class ActionPlan {
  final String title;
  final String summary;
  final List<FocusArea> focusAreas;

  ActionPlan({
    required this.title,
    required this.summary,
    required this.focusAreas,
  });

  factory ActionPlan.fromJson(Map<String, dynamic> json) {
    return ActionPlan(
      title: json['title'],
      summary: json['summary'],
      focusAreas: (json['focusAreas'] as List)
          .map((e) => FocusArea.fromJson(e))
          .toList(),
    );
  }
}

class FocusArea {
  final String areaId;
  final String title;
  final String goal;
  final List<String> rules;
  final String? reason;
  final String status;

  FocusArea({
    required this.areaId,
    required this.title,
    required this.goal,
    required this.rules,
    this.reason,
    required this.status,
  });

  factory FocusArea.fromJson(Map<String, dynamic> json) {
    return FocusArea(
      areaId: json['areaId'],
      title: json['title'],
      goal: json['goal'],
      rules: List<String>.from(json['rules']),
      reason: json['reason'],
      status: json['status'],
    );
  }
}

class SupplementPrescription {
  final String title;
  final String summary;
  final List<Prescription> prescriptions;

  SupplementPrescription({
    required this.title,
    required this.summary,
    required this.prescriptions,
  });

  factory SupplementPrescription.fromJson(Map<String, dynamic> json) {
    return SupplementPrescription(
      title: json['title'],
      summary: json['summary'],
      prescriptions: (json['prescriptions'] as List)
          .map((e) => Prescription.fromJson(e))
          .toList(),
    );
  }
}

class Prescription {
  final String supplementId;
  final String title;
  final String reason;
  final MetricInfo? metric;
  final String dosage;
  final String instructions;

  Prescription({
    required this.supplementId,
    required this.title,
    required this.reason,
    this.metric,
    required this.dosage,
    required this.instructions,
  });

  factory Prescription.fromJson(Map<String, dynamic> json) {
    return Prescription(
      supplementId: json['supplementId'],
      title: json['title'],
      reason: json['reason'],
      metric: json['metric'] != null
          ? MetricInfo.fromJson(json['metric'])
          : null,
      dosage: json['dosage'],
      instructions: json['instructions'],
    );
  }
}

class MotivationalSummary {
  final String title;
  final String primaryMessage;
  final String proofOfSuccess;
  final String nextSteps;
  final String closingThought;

  MotivationalSummary({
    required this.title,
    required this.primaryMessage,
    required this.proofOfSuccess,
    required this.nextSteps,
    required this.closingThought,
  });

  factory MotivationalSummary.fromJson(Map<String, dynamic> json) {
    return MotivationalSummary(
      title: json['title'],
      primaryMessage: json['primaryMessage'],
      proofOfSuccess: json['proofOfSuccess'],
      nextSteps: json['nextSteps'],
      closingThought: json['closingThought'],
    );
  }
}
