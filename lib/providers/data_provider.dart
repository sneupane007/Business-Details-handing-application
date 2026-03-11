import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:avalokan/models/business_data.dart';
import 'package:avalokan/services/data_service.dart';
import 'package:avalokan/utils/format.dart';

final dataServiceProvider = Provider<DataService>((_) => DataService());

final appDataProvider = FutureProvider<AppData>((ref) async {
  return ref.read(dataServiceProvider).loadAppData();
});

final businessesProvider = Provider<List<Business>>((ref) {
  return ref.watch(appDataProvider).valueOrNull?.businesses ?? [];
});

final portfoliosProvider = Provider<List<Portfolio>>((ref) {
  return ref.watch(appDataProvider).valueOrNull?.portfolios ?? [];
});

final currentUserProvider = Provider<AppUser?>((ref) {
  return ref.watch(appDataProvider).valueOrNull?.users.firstOrNull;
});

// ---------- Notification model ----------

enum NotificationType { docExpiry, funding, milestone }

class AppNotification {
  final String businessName;
  final String title;
  final String subtitle;
  final NotificationType type;
  final DateTime date;
  final bool isUrgent;

  const AppNotification({
    required this.businessName,
    required this.title,
    required this.subtitle,
    required this.type,
    required this.date,
    required this.isUrgent,
  });
}

final notificationsProvider = Provider<List<AppNotification>>((ref) {
  final data = ref.watch(appDataProvider).valueOrNull;
  if (data == null) return [];

  final List<AppNotification> notifications = [];

  for (final biz in data.businesses) {
    final name = biz.coreIdentity.tradeName;

    // Document expiry notifications
    for (final doc in biz.operations.documents) {
      if (doc.expiryDate != null) {
        final expiry = DateTime.tryParse(doc.expiryDate!);
        if (expiry != null) {
          final daysLeft = expiry.difference(DateTime.now()).inDays;
          final isUrgent = daysLeft <= 90;
          final withLabel = doc.withParty != null ? ' with ${doc.withParty}' : '';
          notifications.add(AppNotification(
            businessName: name,
            title: '${doc.type}$withLabel expires',
            subtitle: daysLeft > 0
                ? 'Expires ${doc.expiryDate} ($daysLeft days left)'
                : 'Expired on ${doc.expiryDate}',
            type: NotificationType.docExpiry,
            date: expiry,
            isUrgent: isUrgent,
          ));
        }
      }
    }

    // Funding history notifications
    for (final round in biz.financials.fundingHistory) {
      final date = DateTime.tryParse(round.date) ?? DateTime.now();
      notifications.add(AppNotification(
        businessName: name,
        title: '${round.round} round closed — ${formatUsd(round.amountUsd)}',
        subtitle: round.investors.join(', '),
        type: NotificationType.funding,
        date: date,
        isUrgent: false,
      ));
    }
  }

  // Sort: urgent first, then newest first
  notifications.sort((a, b) {
    if (a.isUrgent && !b.isUrgent) return -1;
    if (!a.isUrgent && b.isUrgent) return 1;
    return b.date.compareTo(a.date);
  });

  return notifications;
});
