import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:avalokan/providers/data_provider.dart';
import 'package:avalokan/widgets/notification_tile.dart';

class NotificationsPage extends ConsumerWidget {
  const NotificationsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notifications = ref.watch(notificationsProvider);

    final deadlines =
        notifications.where((n) => n.type == NotificationType.docExpiry).toList();
    final funding =
        notifications.where((n) => n.type == NotificationType.funding).toList();
    final milestones =
        notifications.where((n) => n.type == NotificationType.milestone).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Activity & Notifications'),
        backgroundColor: const Color(0xFFAB4545),
        foregroundColor: Colors.white,
      ),
      body: notifications.isEmpty
          ? const Center(
              child: Text('No notifications', style: TextStyle(color: Colors.grey)),
            )
          : ListView(
              padding: const EdgeInsets.all(16),
              children: [
                if (deadlines.isNotEmpty) ...[
                  _GroupHeader(
                    title: 'Upcoming Deadlines',
                    icon: Icons.schedule_outlined,
                  ),
                  const SizedBox(height: 8),
                  ...deadlines.map((n) => NotificationTile(notification: n)),
                  const SizedBox(height: 16),
                ],
                if (funding.isNotEmpty) ...[
                  _GroupHeader(
                    title: 'Funding History',
                    icon: Icons.monetization_on_outlined,
                  ),
                  const SizedBox(height: 8),
                  ...funding.map((n) => NotificationTile(notification: n)),
                  const SizedBox(height: 16),
                ],
                if (milestones.isNotEmpty) ...[
                  _GroupHeader(
                    title: 'Milestones',
                    icon: Icons.celebration_outlined,
                  ),
                  const SizedBox(height: 8),
                  ...milestones.map((n) => NotificationTile(notification: n)),
                ],
              ],
            ),
    );
  }
}

class _GroupHeader extends StatelessWidget {
  final String title;
  final IconData icon;

  const _GroupHeader({required this.title, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 16, color: Colors.grey.shade700),
        const SizedBox(width: 6),
        Text(
          title,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: Colors.grey.shade700,
          ),
        ),
      ],
    );
  }
}
