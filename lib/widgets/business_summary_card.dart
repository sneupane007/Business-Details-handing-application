import 'package:flutter/material.dart';
import 'package:avalokan/models/business_data.dart';
import 'package:avalokan/utils/format.dart';

class BusinessSummaryCard extends StatelessWidget {
  final Business business;
  final String userId;
  final VoidCallback onTap;

  const BusinessSummaryCard({
    super.key,
    required this.business,
    required this.userId,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final identity = business.coreIdentity;
    final latestPnL = business.latestPnL;
    final ownership = business.ownershipFor(userId);
    final isGrowth = identity.stage.toLowerCase() == 'growth';
    final accentColor = identity.primaryColor;
    final headcount = business.operations.orgChart.totalHeadcount;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border(left: BorderSide(color: accentColor, width: 4)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withAlpha(15),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        padding: const EdgeInsets.fromLTRB(14, 14, 14, 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    identity.tradeName,
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ),
                _StageBadge(stage: identity.stage, isGrowth: isGrowth),
              ],
            ),
            const SizedBox(height: 2),
            Text(identity.industry, style: const TextStyle(color: Colors.grey, fontSize: 12)),
            if (identity.tagline != null) ...[
              const SizedBox(height: 3),
              Text(
                identity.tagline!,
                style: TextStyle(
                  color: accentColor,
                  fontSize: 12,
                  fontStyle: FontStyle.italic,
                ),
              ),
            ],
            const SizedBox(height: 12),
            if (latestPnL != null) ...[
              Row(
                children: [
                  _MetricItem(
                    label: 'Revenue (${latestPnL.fiscalYear})',
                    value: formatNpr(latestPnL.revenueNpr),
                    valueColor: Colors.black87,
                  ),
                  const SizedBox(width: 20),
                  _MetricItem(
                    label: 'Net Profit',
                    value: formatNpr(latestPnL.netProfitNpr),
                    valueColor: latestPnL.netProfitNpr >= 0
                        ? Colors.green.shade700
                        : Colors.red.shade700,
                  ),
                ],
              ),
              const SizedBox(height: 8),
            ],
            Row(
              children: [
                _MetricItem(
                  label: 'Your Ownership',
                  value: '${ownership.toStringAsFixed(1)}%',
                  valueColor: accentColor,
                ),
                const SizedBox(width: 20),
                _MetricItem(
                  label: 'Headcount',
                  value: '$headcount people',
                  valueColor: Colors.black87,
                ),
              ],
            ),
            const SizedBox(height: 10),
            Align(
              alignment: Alignment.centerRight,
              child: Text(
                'View Details →',
                style: TextStyle(
                  color: accentColor,
                  fontWeight: FontWeight.w600,
                  fontSize: 13,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StageBadge extends StatelessWidget {
  final String stage;
  final bool isGrowth;

  const _StageBadge({required this.stage, required this.isGrowth});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: isGrowth ? Colors.green.shade100 : Colors.amber.shade100,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        stage,
        style: TextStyle(
          color: isGrowth ? Colors.green.shade800 : Colors.amber.shade800,
          fontSize: 11,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

class _MetricItem extends StatelessWidget {
  final String label;
  final String value;
  final Color valueColor;

  const _MetricItem({
    required this.label,
    required this.value,
    required this.valueColor,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 11, color: Colors.grey)),
        Text(
          value,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: valueColor,
          ),
        ),
      ],
    );
  }
}
