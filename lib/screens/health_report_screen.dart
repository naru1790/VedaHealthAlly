import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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
  HealthReport? report;
  final Map<int, bool> _expandedStates = {};
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat();

    _loadHealthReport();
  }

  Future<void> _loadHealthReport() async {
    try {
      // Load JSON from assets
      final String jsonString = await rootBundle.loadString('bdata/HealthReport.json');
      final jsonData = jsonDecode(jsonString);
      setState(() {
        report = HealthReport.fromJson(jsonData);
        _isLoading = false;
      });
    } catch (e) {
      print('Error loading health report: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    // Show loading indicator while data is being loaded
    if (_isLoading || report == null) {
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
                'Loading...',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: AppColors.primaryLight,
                ),
              ),
            ],
          ),
        ),
        body: Center(
          child: CircularProgressIndicator(
            color: AppColors.primaryLight,
          ),
        ),
      );
    }

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
          itemCount: report!.keyMetrics.length,
          itemBuilder: (context, index) {
            return FadeInUp(
              delay: Duration(milliseconds: 100 * index),
              duration: const Duration(milliseconds: 500),
              child: _buildMetricCard(report!.keyMetrics[index], isDark),
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
          report!.atAGlanceSummary.title,
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.w800,
            color: isDark ? Colors.white : const Color(0xFF1A1A1A),
            letterSpacing: -0.5,
          ),
        ),
        const SizedBox(height: 16),
        ...report!.atAGlanceSummary.negatives.map((item) {
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
        ...report!.atAGlanceSummary.positives.map((item) {
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
          report!.riskAnalysis.title,
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.w800,
            color: isDark ? Colors.white : const Color(0xFF1A1A1A),
            letterSpacing: -0.5,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          report!.riskAnalysis.summary,
          style: TextStyle(
            fontSize: 14,
            color: isDark ? Colors.white70 : Colors.black87,
            height: 1.5,
          ),
        ),
        const SizedBox(height: 16),
        ...report!.riskAnalysis.riskFactors.asMap().entries.map((entry) {
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
          report!.actionPlan.title,
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.w800,
            color: isDark ? Colors.white : const Color(0xFF1A1A1A),
            letterSpacing: -0.5,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          report!.actionPlan.summary,
          style: TextStyle(
            fontSize: 14,
            color: isDark ? const Color(0xFFD1D5DB) : const Color(0xFF475569),
            height: 1.5,
          ),
        ),
        const SizedBox(height: 16),
        ...report!.actionPlan.focusAreas.map((area) {
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
          report!.supplementPrescription.title,
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.w800,
            color: isDark ? Colors.white : const Color(0xFF1A1A1A),
            letterSpacing: -0.5,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          report!.supplementPrescription.summary,
          style: TextStyle(
            fontSize: 14,
            color: isDark ? const Color(0xFFD1D5DB) : const Color(0xFF475569),
            height: 1.5,
          ),
        ),
        const SizedBox(height: 16),
        ...report!.supplementPrescription.prescriptions.map((prescription) {
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
                    report!.motivationalSummary.title,
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
              report!.motivationalSummary.primaryMessage,
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
                report!.motivationalSummary.proofOfSuccess,
                style: TextStyle(
                  fontSize: 14,
                  color: isDark ? const Color(0xFFD1D5DB) : const Color(0xFF475569),
                  height: 1.5,
                ),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              report!.motivationalSummary.nextSteps,
              style: TextStyle(
                fontSize: 14,
                color: isDark ? const Color(0xFFD1D5DB) : const Color(0xFF475569),
                height: 1.5,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              report!.motivationalSummary.closingThought,
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
