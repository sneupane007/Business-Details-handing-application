import 'package:flutter/material.dart';
import 'package:avalokan/models/business_data.dart';

class OwnershipBar extends StatelessWidget {
  final Shareholding shareholding;

  const OwnershipBar({super.key, required this.shareholding});

  Color get _barColor => switch (shareholding.shareClass) {
        'Ordinary' => const Color(0xFF1565C0),
        'Preferred-A' => const Color(0xFF6A1B9A),
        'ESOP' => const Color(0xFF546E7A),
        _ => Colors.grey,
      };

  @override
  Widget build(BuildContext context) {
    final color = _barColor;
    final pct = (shareholding.ownershipPct / 100).clamp(0.0, 1.0);

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  shareholding.name,
                  style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: color.withAlpha(38),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  shareholding.shareClass,
                  style: TextStyle(fontSize: 10, color: color, fontWeight: FontWeight.w600),
                ),
              ),
              const SizedBox(width: 8),
              SizedBox(
                width: 44,
                child: Text(
                  '${shareholding.ownershipPct.toStringAsFixed(1)}%',
                  style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
                  textAlign: TextAlign.right,
                ),
              ),
            ],
          ),
          const SizedBox(height: 5),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: pct,
              backgroundColor: color.withAlpha(26),
              valueColor: AlwaysStoppedAnimation<Color>(color),
              minHeight: 8,
            ),
          ),
        ],
      ),
    );
  }
}
