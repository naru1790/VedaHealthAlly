import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:animate_do/animate_do.dart';
import '../models/health_report.dart';
import '../core/theme/app_colors.dart';

class HealthReportScreen extends StatefulWidget {
  const HealthReportScreen({super.key});

  @override
  State<HealthReportScreen> createState() => _HealthReportScreenState();
}

class _HealthReportScreenState extends State<HealthReportScreen>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late HealthReport report;
  final Map<int, bool> _expandedStates = {};

  // Hard-coded JSON data
  static const String reportJson = '''
{
  "reportId": "asmnt_initial_001",
  "userId": "narender_001",
  "reportTitle": "Your 30-Day Recovery Blueprint",
  "generatedAt": "2025-10-26T12:00:00Z",
  "persona": "The Direct Coach",
  "keyMetrics": [
    {
      "metricId": "m_triglycerides",
      "label": "Triglycerides",
      "value": 240.4,
      "unit": "mg/dL",
      "normalRange": "< 150",
      "status": "VERY_HIGH_RISK"
    },
    {
      "metricId": "m_ldl",
      "label": "LDL Cholesterol",
      "value": 194.12,
      "unit": "mg/dL",
      "normalRange": "< 100",
      "status": "VERY_HIGH_RISK"
    },
    {
      "metricId": "m_ggt",
      "label": "GGT (Liver Stress)",
      "value": 185.6,
      "unit": "U/L",
      "normalRange": "< 55",
      "status": "SEVERE"
    },
    {
      "metricId": "m_waist",
      "label": "Waist Size",
      "value": 41,
      "unit": "inches",
      "normalRange": "< 40",
      "status": "HIGH_RISK"
    },
    {
      "metricId": "m_total_chol",
      "label": "Total Cholesterol",
      "value": 300.9,
      "unit": "mg/dL",
      "normalRange": "< 200",
      "status": "VERY_HIGH_RISK"
    },
    {
      "metricId": "m_vit_d",
      "label": "Vitamin D",
      "value": 10.7,
      "unit": "ng/mL",
      "normalRange": "30-100",
      "status": "DEFICIENT"
    },
    {
      "metricId": "m_vit_b12",
      "label": "Vitamin B12",
      "value": 106,
      "unit": "pg/mL",
      "normalRange": "200-900",
      "status": "DEFICIENT"
    }
  ],
  "atAGlanceSummary": {
    "title": "Your Situation: Serious, But 100% Reversible",
    "negatives": [
      {
        "title": "High Immediate Risk",
        "description": "Your risk for a heart attack or stroke is high, right now. This isn't a problem for 'later.' Your smoking, 41-inch waist, and severe lipid numbers are a dangerous combination."
      }
    ],
    "positives": [
      {
        "title": "Proven Resilience",
        "description": "Your body is strong. Your blood sugar and kidney function are perfect. You have proven you can recover."
      },
      {
        "title": "Fast Liver Healing",
        "description": "Your 2023-2024 labs show that when you make changes, your liver heals fast (your GGT dropped from 289 to 146!)."
      }
    ]
  },
  "riskAnalysis": {
    "title": "Your Clinical Assessment: Connecting the Dots",
    "summary": "Your lab report tells a clear story. These three factors are driving your severe heart attack risk.",
    "riskFactors": [
      {
        "factorId": "rf_visceral_fat",
        "title": "High Visceral Fat (Belly Fat)",
        "metric": {
          "label": "Waist Size",
          "value": 41,
          "unit": "inches"
        },
        "summary": "This isn't just 'weight.' It's visceral fat packed around your organs. This fat is an active, 'angry' organ itself, pumping out inflammatory signals.",
        "causes": [
          "Late-night, large carb meals",
          "High-fat processed foods"
        ],
        "effects": [
          "Poisons your liver",
          "Damages blood vessels",
          "Increases inflammation"
        ]
      },
      {
        "factorId": "rf_blood_fat",
        "title": "High Blood Fat (Triglycerides)",
        "metric": {
          "label": "Triglycerides",
          "value": 240.4,
          "unit": "mg/dL",
          "normalRange": "< 150"
        },
        "summary": "This is pure, unburned fuel (fat) circulating in your blood. Your body has no chance to burn it, so it stores it as visceral fat and clogs your arteries.",
        "causes": [
          "Ordering high-fat foods (biryani, fried chicken)",
          "Large, late-night carb meals (e.g., 10 PM plate of dal rice)"
        ],
        "effects": [
          "Directly stores as visceral fat",
          "Clogs arteries",
          "Contributes to heart attack risk"
        ]
      },
      {
        "factorId": "rf_liver_stress",
        "title": "Severe Liver Stress",
        "metric": {
          "label": "GGT",
          "value": 185.6,
          "unit": "U/L",
          "normalRange": "< 55"
        },
        "summary": "This is your liver's alarm bell, ringing at over 3.5 times the normal level. It's a direct sign of toxicity.",
        "causes": [
          "Visceral fat creating a 'fatty liver'",
          "Weekend alcohol use on an already-stressed liver"
        ],
        "effects": [
          "Indicates liver damage",
          "Drives overall inflammation",
          "Reduces body's ability to detoxify"
        ]
      }
    ]
  },
  "actionPlan": {
    "title": "Our 30-Day 'Bootcamp' Strategy",
    "summary": "We will attack your risks on four fronts simultaneously. This is a 30-day plan to break old habits and build new ones. It is a prescription.",
    "focusAreas": [
      {
        "areaId": "plan_diet",
        "title": "Diet",
        "goal": "Fix meal content and timing to stop fueling fat storage.",
        "rules": [
          "No outside food for 30 days.",
          "Implement a structured meal plan (high protein/fiber).",
          "No more skipped breakfast.",
          "No more large, late-night dinners."
        ],
        "status": "HIGH_PRIORITY"
      },
      {
        "areaId": "plan_exercise",
        "title": "Exercise",
        "goal": "Build a 24/7 fat-burning engine.",
        "rules": [
          "Add structure to your cardio for stamina (beyond just walking).",
          "Introduce strength training to build muscle.",
          "Follow the personalized workout plan."
        ],
        "status": "HIGH_PRIORITY"
      },
      {
        "areaId": "plan_alcohol",
        "title": "Alcohol",
        "goal": "Allow your liver to heal.",
        "rules": [
          "Zero alcohol for these 30 days.",
          "No whiskey, no beer."
        ],
        "reason": "Your GGT of 185 is a medical warning. Your liver must heal.",
        "status": "NON_NEGOTIABLE"
      },
      {
        "areaId": "plan_smoking",
        "title": "Smoking",
        "goal": "Allow your heart and lungs to heal.",
        "rules": [
          "Implement a clear cessation strategy.",
          "Follow the 'Habit Swap' plan."
        ],
        "status": "NON_NEGOTIABLE"
      }
    ]
  },
  "supplementPrescription": {
    "title": "Immediate Supplementation",
    "summary": "Your new labs show severe deficiencies. Start these today.",
    "prescriptions": [
      {
        "supplementId": "sup_vit_d3",
        "title": "Vitamin D3 (60,000 IU)",
        "reason": "Severe Deficiency",
        "metric": {
          "label": "Vitamin D",
          "value": 10.7,
          "unit": "ng/mL"
        },
        "dosage": "One sachet, once per week (e.g., every Sunday).",
        "instructions": "Take with milk for 8 weeks."
      },
      {
        "supplementId": "sup_vit_b12",
        "title": "Vitamin B12 (1500 mcg)",
        "reason": "Severe Deficiency",
        "metric": {
          "label": "Vitamin B12",
          "value": 106,
          "unit": "pg/mL"
        },
        "dosage": "One tablet, every day.",
        "instructions": "Take for 30 days. This deficiency can cause fatigue."
      },
      {
        "supplementId": "sup_omega3",
        "title": "Omega-3 Fish Oil",
        "reason": "High Triglycerides",
        "metric": {
          "label": "Triglycerides",
          "value": 240.4,
          "unit": "mg/dL"
        },
        "dosage": "At least 1000mg of (EPA + DHA) combined, daily.",
        "instructions": "Take with lunch."
      }
    ]
  },
  "motivationalSummary": {
    "title": "Your Path Forward",
    "primaryMessage": "Narender, these numbers are not a life sentence. They are a warning. Your body is screaming for a change.",
    "proofOfSuccess": "You have already proven you can do this. Your GGT dropped from 289 to 146 between 2023 and 2024. That is a phenomenal recovery. You just didn't have the full plan to make it stick. Now you do.",
    "nextSteps": "This 30-day plan is your new blueprint. It's aggressive because your risk is aggressive. It will feel hard for the first week, but by Week 4, you will feel different.",
    "closingThought": "You have a strong heart and healthy metabolism waiting to be unburied. Let's get to work."
  }
}
''';

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat();

    // Parse JSON
    final jsonData = jsonDecode(reportJson);
    report = HealthReport.fromJson(jsonData);
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF0A0E1A) : const Color(0xFFF5F7FA),
      appBar: AppBar(
        backgroundColor: isDark ? const Color(0xFF1E1E1E) : Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_ios_new_rounded,
            color: AppColors.primaryLight,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'AI Insights',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: isDark ? Colors.white : const Color(0xFF1A1A1A),
              ),
            ),
            Text(
              'Your 30-Day Recovery Plan',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: AppColors.primaryLight,
              ),
            ),
          ],
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildKeyMetricsSection(isDark),
            const SizedBox(height: 24),
            _buildAtAGlanceSection(isDark),
            const SizedBox(height: 24),
            _buildRiskAnalysisSection(isDark),
            const SizedBox(height: 24),
            _buildActionPlanSection(isDark),
            const SizedBox(height: 24),
            _buildSupplementSection(isDark),
            const SizedBox(height: 24),
            _buildMotivationalSection(isDark),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  // KEY METRICS SECTION - Grid layout showing all metrics
  Widget _buildKeyMetricsSection(bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Key Health Metrics',
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.w800,
            color: isDark ? Colors.white : const Color(0xFF1A1A1A),
            letterSpacing: -0.5,
          ),
        ),
        const SizedBox(height: 16),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            childAspectRatio: 0.75,
            crossAxisSpacing: 14,
            mainAxisSpacing: 14,
          ),
          itemCount: report.keyMetrics.length,
          itemBuilder: (context, index) {
            return FadeInUp(
              delay: Duration(milliseconds: 100 * index),
              duration: const Duration(milliseconds: 500),
              child: _buildMetricCard(report.keyMetrics[index], isDark),
            );
          },
        ),
      ],
    );
  }

  // METRIC CARD - Modern design matching app theme
  Widget _buildMetricCard(KeyMetric metric, bool isDark) {
    final color = _getStatusColor(metric.status);
    final percentage = _calculatePercentage(metric);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark
            ? const Color(0xFF1E1E1E)
            : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark 
              ? color.withOpacity(0.3) 
              : const Color(0xFFE8ECF1),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: isDark 
                ? Colors.black.withOpacity(0.2)
                : Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Metric label and status badge
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Text(
                  metric.label,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: isDark ? Colors.white : const Color(0xFF1A1A1A),
                    letterSpacing: -0.2,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  color: color,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: color.withOpacity(0.3),
                      blurRadius: 4,
                      spreadRadius: 1,
                    ),
                  ],
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 12),
          
          // Value display with linear progress
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.baseline,
                textBaseline: TextBaseline.alphabetic,
                children: [
                  Text(
                    metric.value % 1 == 0 
                        ? '${metric.value.toInt()}'
                        : '${metric.value.toStringAsFixed(1)}',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.w900,
                      color: color,
                      letterSpacing: -1,
                    ),
                  ),
                  const SizedBox(width: 4),
                  Text(
                    metric.unit,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: isDark ? const Color(0xFF808080) : const Color(0xFF94A3B8),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              // Linear progress bar
              ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: LinearProgressIndicator(
                  value: percentage / 100,
                  minHeight: 6,
                  backgroundColor: isDark 
                      ? const Color(0xFF2A2A2A) 
                      : const Color(0xFFF1F5F9),
                  valueColor: AlwaysStoppedAnimation<Color>(color),
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 12),
          
          // Normal range badge
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: color.withOpacity(0.3),
                width: 1,
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.straighten_rounded,
                  size: 12,
                  color: color,
                ),
                const SizedBox(width: 4),
                Flexible(
                  child: Text(
                    'Normal: ${metric.normalRange}',
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                      color: color,
                      letterSpacing: 0.1,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // AT A GLANCE SECTION
  Widget _buildAtAGlanceSection(bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          report.atAGlanceSummary.title,
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.w800,
            color: isDark ? Colors.white : const Color(0xFF1A1A1A),
            letterSpacing: -0.5,
          ),
        ),
        const SizedBox(height: 16),
        ...report.atAGlanceSummary.negatives.map((item) {
          return FadeInLeft(
            duration: const Duration(milliseconds: 600),
            child: Container(
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: isDark 
                    ? const Color(0xFFDC2626).withOpacity(0.08)
                    : const Color(0xFFFEF2F2),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: isDark 
                      ? const Color(0xFFDC2626).withOpacity(0.3)
                      : const Color(0xFFFECACA),
                  width: 1.5,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.warning_rounded, 
                        color: const Color(0xFFDC2626), 
                        size: 20
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          item.title,
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: const Color(0xFFDC2626),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    item.description,
                    style: TextStyle(
                      fontSize: 14,
                      color: isDark ? const Color(0xFFD1D5DB) : const Color(0xFF475569),
                      height: 1.5,
                    ),
                  ),
                ],
              ),
            ),
          );
        }),
        const SizedBox(height: 8),
        ...report.atAGlanceSummary.positives.map((item) {
          return FadeInRight(
            duration: const Duration(milliseconds: 600),
            child: Container(
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: isDark 
                    ? const Color(0xFF059669).withOpacity(0.08)
                    : const Color(0xFFF0FDF4),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: isDark 
                      ? const Color(0xFF059669).withOpacity(0.3)
                      : const Color(0xFFBBF7D0),
                  width: 1.5,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.check_circle_rounded,
                        color: const Color(0xFF059669), 
                        size: 20
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          item.title,
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: const Color(0xFF059669),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    item.description,
                    style: TextStyle(
                      fontSize: 14,
                      color: isDark ? const Color(0xFFD1D5DB) : const Color(0xFF475569),
                      height: 1.5,
                    ),
                  ),
                ],
              ),
            ),
          );
        }),
      ],
    );
  }

  // RISK ANALYSIS SECTION - Smooth ExpansionTile with no black lines
  Widget _buildRiskAnalysisSection(bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          report.riskAnalysis.title,
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.w800,
            color: isDark ? Colors.white : const Color(0xFF1A1A1A),
            letterSpacing: -0.5,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          report.riskAnalysis.summary,
          style: TextStyle(
            fontSize: 14,
            color: isDark ? Colors.white70 : Colors.black87,
            height: 1.5,
          ),
        ),
        const SizedBox(height: 16),
        ...report.riskAnalysis.riskFactors.asMap().entries.map((entry) {
          final index = entry.key;
          final factor = entry.value;
          final isExpanded = _expandedStates[index] ?? false;

          return FadeInUp(
            delay: Duration(milliseconds: 100 * index),
            duration: const Duration(milliseconds: 500),
            child: Container(
              margin: const EdgeInsets.only(bottom: 12),
              decoration: BoxDecoration(
                color: isDark
                    ? const Color(0xFF1E1E1E)
                    : Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: isDark 
                      ? const Color(0xFFEA580C).withOpacity(0.3)
                      : const Color(0xFFFED7AA),
                  width: 1.5,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.04),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Theme(
                data: Theme.of(context).copyWith(
                  dividerColor: Colors.transparent,
                  splashColor: const Color(0xFFFFF7ED),
                  highlightColor: const Color(0xFFFFF7ED).withOpacity(0.5),
                ),
                child: ExpansionTile(
                  tilePadding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  childrenPadding: EdgeInsets.zero,
                  trailing: AnimatedRotation(
                    turns: isExpanded ? 0.5 : 0,
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.easeInOut,
                    child: Icon(
                      Icons.keyboard_arrow_down_rounded,
                      color: const Color(0xFFEA580C),
                      size: 28,
                    ),
                  ),
                  onExpansionChanged: (expanded) {
                    setState(() {
                      _expandedStates[index] = expanded;
                    });
                  },
                  title: Text(
                    factor.title,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: isDark ? Colors.white : const Color(0xFF1A1A1A),
                    ),
                  ),
                  subtitle: factor.metric != null
                      ? Padding(
                          padding: const EdgeInsets.only(top: 6),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 10, vertical: 4),
                                decoration: BoxDecoration(
                                  color: isDark 
                                      ? const Color(0xFFEA580C).withOpacity(0.15)
                                      : const Color(0xFFFFF7ED),
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(
                                    color: const Color(0xFFEA580C).withOpacity(0.3),
                                    width: 1,
                                  ),
                                ),
                                child: Text(
                                  '${factor.metric!.label}: ${factor.metric!.value} ${factor.metric!.unit}',
                                  style: const TextStyle(
                                    fontSize: 12,
                                    color: Color(0xFFEA580C),
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        )
                      : null,
                  children: [
                    Container(
                      padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Divider(
                            thickness: 1,
                            color: isDark 
                                ? const Color(0xFF2A2A2A)
                                : const Color(0xFFE8ECF1),
                          ),
                          const SizedBox(height: 12),
                          Text(
                            factor.summary,
                            style: TextStyle(
                              fontSize: 14,
                              color: isDark ? const Color(0xFFD1D5DB) : const Color(0xFF475569),
                              height: 1.5,
                            ),
                          ),
                          const SizedBox(height: 16),
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: isDark 
                                  ? const Color(0xFFDC2626).withOpacity(0.08)
                                  : const Color(0xFFFEF2F2),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: isDark 
                                    ? const Color(0xFFDC2626).withOpacity(0.3)
                                    : const Color(0xFFFECACA),
                                width: 1,
                              ),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    const Icon(
                                      Icons.warning_rounded,
                                      color: Color(0xFFDC2626),
                                      size: 18,
                                    ),
                                    const SizedBox(width: 8),
                                    const Text(
                                      'Causes:',
                                      style: TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w700,
                                        color: Color(0xFFDC2626),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 10),
                                ...factor.causes.map((cause) {
                                  return Padding(
                                    padding: const EdgeInsets.only(
                                        bottom: 6, left: 4),
                                    child: Row(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          '• ',
                                          style: TextStyle(
                                            fontSize: 14,
                                            color: isDark
                                                ? const Color(0xFFD1D5DB)
                                                : const Color(0xFF475569),
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                        Expanded(
                                          child: Text(
                                            cause,
                                            style: TextStyle(
                                              fontSize: 14,
                                              color: isDark
                                                  ? const Color(0xFFD1D5DB)
                                                  : const Color(0xFF475569),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  );
                                }),
                              ],
                            ),
                          ),
                          const SizedBox(height: 12),
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.orange.withOpacity(0.08),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: Colors.orange.withOpacity(0.2),
                                width: 1,
                              ),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Icon(
                                      Icons.trending_down_rounded,
                                      color: Colors.orange,
                                      size: 18,
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      'Effects:',
                                      style: TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w700,
                                        color: Colors.orange,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 10),
                                ...factor.effects.map((effect) {
                                  return Padding(
                                    padding: const EdgeInsets.only(
                                        bottom: 6, left: 4),
                                    child: Row(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          '• ',
                                          style: TextStyle(
                                            fontSize: 14,
                                            color: isDark
                                                ? const Color(0xFFD1D5DB)
                                                : const Color(0xFF475569),
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                        Expanded(
                                          child: Text(
                                            effect,
                                            style: TextStyle(
                                              fontSize: 14,
                                              color: isDark
                                                  ? const Color(0xFFD1D5DB)
                                                  : const Color(0xFF475569),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  );
                                }),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        }),
      ],
    );
  }

  // ACTION PLAN SECTION
  Widget _buildActionPlanSection(bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          report.actionPlan.title,
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.w800,
            color: isDark ? Colors.white : const Color(0xFF1A1A1A),
            letterSpacing: -0.5,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          report.actionPlan.summary,
          style: TextStyle(
            fontSize: 14,
            color: isDark ? const Color(0xFFD1D5DB) : const Color(0xFF475569),
            height: 1.5,
          ),
        ),
        const SizedBox(height: 16),
        ...report.actionPlan.focusAreas.map((area) {
          final isNonNegotiable = area.status == 'NON_NEGOTIABLE';
          final areaColor = isNonNegotiable ? const Color(0xFFDC2626) : const Color(0xFF059669);

          return FadeInUp(
            duration: const Duration(milliseconds: 600),
            child: Container(
              margin: const EdgeInsets.only(bottom: 16),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: isDark
                    ? const Color(0xFF1E1E1E)
                    : Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: isDark 
                      ? areaColor.withOpacity(0.3)
                      : (isNonNegotiable ? const Color(0xFFFECACA) : const Color(0xFFBBF7D0)),
                  width: 1.5,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.04),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        _getAreaIcon(area.title),
                        color: areaColor,
                        size: 24,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          area.title,
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                            color: isDark ? Colors.white : const Color(0xFF1A1A1A),
                          ),
                        ),
                      ),
                      if (isNonNegotiable)
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: isDark 
                                ? const Color(0xFFDC2626).withOpacity(0.15)
                                : const Color(0xFFFEF2F2),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: const Color(0xFFDC2626).withOpacity(0.3),
                              width: 1,
                            ),
                          ),
                          child: const Text(
                            'NON-NEGOTIABLE',
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w800,
                              color: Color(0xFFDC2626),
                            ),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    area.goal,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: areaColor,
                      height: 1.4,
                    ),
                  ),
                  if (area.reason != null) ...[
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: isDark 
                            ? areaColor.withOpacity(0.08)
                            : (isNonNegotiable ? const Color(0xFFFEF2F2) : const Color(0xFFF0FDF4)),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: areaColor.withOpacity(0.3),
                          width: 1,
                        ),
                      ),
                      child: Text(
                        area.reason!,
                        style: TextStyle(
                          fontSize: 13,
                          color: isDark ? const Color(0xFFD1D5DB) : const Color(0xFF475569),
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    ),
                  ],
                  const SizedBox(height: 12),
                  ...area.rules.map((rule) {
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            margin: const EdgeInsets.only(top: 4),
                            width: 6,
                            height: 6,
                            decoration: BoxDecoration(
                              color: areaColor,
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              rule,
                              style: TextStyle(
                                fontSize: 14,
                                color: isDark ? const Color(0xFFD1D5DB) : const Color(0xFF475569),
                                height: 1.4,
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  }),
                ],
              ),
            ),
          );
        }),
      ],
    );
  }

  // SUPPLEMENT SECTION
  Widget _buildSupplementSection(bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          report.supplementPrescription.title,
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.w800,
            color: isDark ? Colors.white : const Color(0xFF1A1A1A),
            letterSpacing: -0.5,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          report.supplementPrescription.summary,
          style: TextStyle(
            fontSize: 14,
            color: isDark ? const Color(0xFFD1D5DB) : const Color(0xFF475569),
            height: 1.5,
          ),
        ),
        const SizedBox(height: 16),
        ...report.supplementPrescription.prescriptions.map((prescription) {
          return FadeInUp(
            duration: const Duration(milliseconds: 600),
            child: Container(
              margin: const EdgeInsets.only(bottom: 16),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: isDark
                    ? const Color(0xFF1E1E1E)
                    : Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: isDark 
                      ? const Color(0xFF3B82F6).withOpacity(0.3)
                      : const Color(0xFFBFDBFE),
                  width: 1.5,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.04),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(
                        Icons.medication_rounded,
                        color: Color(0xFF3B82F6),
                        size: 24,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          prescription.title,
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                            color: isDark ? Colors.white : const Color(0xFF1A1A1A),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: isDark 
                          ? const Color(0xFFF59E0B).withOpacity(0.1)
                          : const Color(0xFFFEF3C7),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: const Color(0xFFF59E0B).withOpacity(0.3),
                        width: 1,
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${prescription.reason}${prescription.metric != null ? " - ${prescription.metric!.label}: ${prescription.metric!.value} ${prescription.metric!.unit}" : ""}',
                          style: const TextStyle(
                            fontSize: 13,
                            color: Color(0xFFF59E0B),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Icon(
                        Icons.schedule_rounded,
                        color: Color(0xFF3B82F6),
                        size: 18,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Dosage:',
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: isDark ? Colors.white : const Color(0xFF1A1A1A),
                              ),
                            ),
                            Text(
                              prescription.dosage,
                              style: TextStyle(
                                fontSize: 14,
                                color: isDark ? const Color(0xFFD1D5DB) : const Color(0xFF475569),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Icon(
                        Icons.info_outline_rounded,
                        color: Color(0xFF3B82F6),
                        size: 18,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Instructions:',
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: isDark ? Colors.white : const Color(0xFF1A1A1A),
                              ),
                            ),
                            Text(
                              prescription.instructions,
                              style: TextStyle(
                                fontSize: 14,
                                color: isDark ? const Color(0xFFD1D5DB) : const Color(0xFF475569),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        }),
      ],
    );
  }

  // MOTIVATIONAL SECTION
  Widget _buildMotivationalSection(bool isDark) {
    return FadeIn(
      duration: const Duration(milliseconds: 800),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: isDark 
                ? [
                    const Color(0xFF059669).withOpacity(0.15),
                    const Color(0xFF3B82F6).withOpacity(0.15),
                  ]
                : [
                    const Color(0xFFECFDF5),
                    const Color(0xFFEFF6FF),
                  ],
          ),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isDark 
                ? const Color(0xFF059669).withOpacity(0.3)
                : const Color(0xFFBBF7D0),
            width: 1.5,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(
                  Icons.favorite_rounded,
                  color: Color(0xFFDC2626),
                  size: 28,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    report.motivationalSummary.title,
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w800,
                      color: isDark ? Colors.white : const Color(0xFF1A1A1A),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              report.motivationalSummary.primaryMessage,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: isDark ? Colors.white : const Color(0xFF1A1A1A),
                height: 1.5,
              ),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: isDark 
                    ? const Color(0xFF059669).withOpacity(0.2)
                    : const Color(0xFFF0FDF4),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: const Color(0xFF059669).withOpacity(0.3),
                  width: 1,
                ),
              ),
              child: Text(
                report.motivationalSummary.proofOfSuccess,
                style: TextStyle(
                  fontSize: 14,
                  color: isDark ? const Color(0xFFD1D5DB) : const Color(0xFF475569),
                  height: 1.5,
                ),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              report.motivationalSummary.nextSteps,
              style: TextStyle(
                fontSize: 14,
                color: isDark ? const Color(0xFFD1D5DB) : const Color(0xFF475569),
                height: 1.5,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              report.motivationalSummary.closingThought,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                fontStyle: FontStyle.italic,
                color: Color(0xFF059669),
                height: 1.5,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // HELPER METHODS
  Color _getStatusColor(String status) {
    switch (status.toUpperCase()) {
      case 'VERY_HIGH_RISK':
      case 'SEVERE':
        return const Color(0xFFDC2626); // Professional red
      case 'HIGH_RISK':
        return const Color(0xFFEA580C); // Professional orange-red
      case 'MODERATE':
        return const Color(0xFFF59E0B); // Professional amber
      case 'DEFICIENT':
        return const Color(0xFF7C3AED); // Professional purple
      case 'NORMAL':
        return const Color(0xFF059669); // Professional emerald green
      default:
        return const Color(0xFF64748B); // Professional slate gray
    }
  }

  double _calculatePercentage(KeyMetric metric) {
    // Simple calculation for visualization - you can make this more sophisticated
    switch (metric.status.toUpperCase()) {
      case 'VERY_HIGH_RISK':
      case 'SEVERE':
        return 90;
      case 'HIGH_RISK':
        return 75;
      case 'MODERATE':
        return 60;
      case 'DEFICIENT':
        return 30;
      case 'NORMAL':
        return 100;
      default:
        return 50;
    }
  }

  IconData _getAreaIcon(String title) {
    if (title.toLowerCase().contains('diet')) {
      return Icons.restaurant_menu_rounded;
    } else if (title.toLowerCase().contains('exercise')) {
      return Icons.fitness_center_rounded;
    } else if (title.toLowerCase().contains('alcohol')) {
      return Icons.no_drinks_rounded;
    } else if (title.toLowerCase().contains('smoking')) {
      return Icons.smoke_free_rounded;
    }
    return Icons.check_circle_outline_rounded;
  }
}
