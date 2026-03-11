import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:avalokan/models/business_data.dart';
import 'package:avalokan/providers/data_provider.dart';
import 'package:avalokan/pages/business_detail_page.dart';
import 'package:avalokan/pages/notifications_page.dart';
import 'package:avalokan/widgets/business_summary_card.dart';
import 'package:avalokan/widgets/notification_tile.dart';

class DashboardPage extends ConsumerWidget {
  const DashboardPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final appDataAsync = ref.watch(appDataProvider);

    return appDataAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Text('Failed to load data:\n$e', textAlign: TextAlign.center),
        ),
      ),
      data: (appData) {
        final user = appData.users.first;
        final businesses = appData.businesses;
        final portfolios = appData.portfolios;
        final notifications = ref.watch(notificationsProvider);
        final topNotifications = notifications.take(5).toList();

        return ListView(
          padding: const EdgeInsets.all(16),
          children: [
            _GreetingSection(userName: user.displayName.split(' ').first),
            const SizedBox(height: 20),

            // Portfolios strip
            _SectionHeader(title: 'Portfolios (${portfolios.length})'),
            const SizedBox(height: 8),
            SizedBox(
              height: 76,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: portfolios.length,
                separatorBuilder: (_, __) => const SizedBox(width: 10),
                itemBuilder: (context, i) => _PortfolioChip(portfolio: portfolios[i]),
              ),
            ),
            const SizedBox(height: 24),

            // Businesses
            _SectionHeader(title: 'Your Businesses'),
            const SizedBox(height: 8),
            ...businesses.map(
              (biz) => Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: BusinessSummaryCard(
                  business: biz,
                  userId: user.id,
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => BusinessDetailPage(business: biz),
                    ),
                  ),
                ),
              ),
            ),

            // Recent Activity
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const _SectionHeader(title: 'Recent Activity'),
                TextButton(
                  onPressed: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const NotificationsPage()),
                  ),
                  child: const Text('View all →'),
                ),
              ],
            ),
            const SizedBox(height: 4),
            if (topNotifications.isEmpty)
              const Padding(
                padding: EdgeInsets.only(bottom: 16),
                child: Text('No recent activity.', style: TextStyle(color: Colors.grey)),
              )
            else
              ...topNotifications.map((n) => NotificationTile(notification: n)),
            const SizedBox(height: 16),
          ],
        );
      },
    );
  }
}

class _GreetingSection extends StatelessWidget {
  final String userName;

  const _GreetingSection({required this.userName});

  String get _greeting {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Good morning';
    if (hour < 17) return 'Good afternoon';
    return 'Good evening';
  }

  String _monthName(int month) {
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
    ];
    return months[month - 1];
  }

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final dateStr = '${_monthName(now.month)} ${now.day}, ${now.year}';
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '$_greeting, $userName',
          style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
        ),
        Text(dateStr, style: const TextStyle(color: Colors.grey, fontSize: 13)),
      ],
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;

  const _SectionHeader({required this.title});

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 15,
        fontWeight: FontWeight.bold,
        color: Colors.black87,
      ),
    );
  }
}

class _PortfolioChip extends StatelessWidget {
  final Portfolio portfolio;

  const _PortfolioChip({required this.portfolio});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: const Color(0xFFAB4545).withAlpha(20),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xFFAB4545).withAlpha(60)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            portfolio.name,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
          ),
          const SizedBox(height: 2),
          Text(
            '${portfolio.businessIds.length} '
            'business${portfolio.businessIds.length != 1 ? "es" : ""}',
            style: const TextStyle(fontSize: 11, color: Colors.grey),
          ),
        ],
      ),
    );
  }
}
