import 'package:flutter/material.dart';
import 'package:avalokan/providers/data_provider.dart';

class NotificationTile extends StatelessWidget {
  final AppNotification notification;

  const NotificationTile({super.key, required this.notification});

  @override
  Widget build(BuildContext context) {
    final n = notification;
    final (icon, iconColor) = switch (n.type) {
      NotificationType.docExpiry => (
          Icons.description_outlined,
          n.isUrgent ? Colors.amber.shade700 : Colors.blue.shade600,
        ),
      NotificationType.funding => (
          Icons.monetization_on_outlined,
          Colors.green.shade700,
        ),
      NotificationType.milestone => (
          Icons.celebration_outlined,
          Colors.purple.shade600,
        ),
    };

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: n.isUrgent
            ? Border.all(color: Colors.amber.shade400, width: 1.5)
            : Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(10),
            blurRadius: 4,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: iconColor.withAlpha(26),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: iconColor, size: 18),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        n.businessName,
                        style: const TextStyle(fontSize: 10, color: Colors.grey),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    Text(
                      _relativeDate(n.date),
                      style: const TextStyle(fontSize: 10, color: Colors.grey),
                    ),
                  ],
                ),
                const SizedBox(height: 2),
                Text(
                  n.title,
                  style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
                ),
                if (n.subtitle.isNotEmpty) ...[
                  const SizedBox(height: 2),
                  Text(
                    n.subtitle,
                    style: const TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _relativeDate(DateTime date) {
    final now = DateTime.now();
    final diff = now.difference(date);
    if (diff.isNegative) {
      final futureDiff = date.difference(now);
      if (futureDiff.inDays == 0) return 'today';
      if (futureDiff.inDays == 1) return 'tomorrow';
      return 'in ${futureDiff.inDays}d';
    }
    if (diff.inDays == 0) return 'today';
    if (diff.inDays == 1) return 'yesterday';
    if (diff.inDays < 30) return '${diff.inDays}d ago';
    if (diff.inDays < 365) return '${(diff.inDays / 30).floor()}mo ago';
    return '${(diff.inDays / 365).floor()}y ago';
  }
}
