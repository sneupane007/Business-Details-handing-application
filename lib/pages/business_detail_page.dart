import 'package:flutter/material.dart';
import 'package:avalokan/models/business_data.dart';
import 'package:avalokan/utils/format.dart';
import 'package:avalokan/widgets/stat_card.dart';
import 'package:avalokan/widgets/ownership_bar.dart';
import 'package:avalokan/widgets/financial_table.dart';

class BusinessDetailPage extends StatelessWidget {
  final Business business;

  const BusinessDetailPage({super.key, required this.business});

  @override
  Widget build(BuildContext context) {
    final accent = business.coreIdentity.primaryColor;
    return DefaultTabController(
      length: 5,
      child: Scaffold(
        appBar: AppBar(
          title: Text(business.coreIdentity.tradeName),
          backgroundColor: accent,
          foregroundColor: Colors.white,
          bottom: const TabBar(
            isScrollable: true,
            labelColor: Colors.white,
            unselectedLabelColor: Colors.white70,
            indicatorColor: Colors.white,
            tabAlignment: TabAlignment.start,
            tabs: [
              Tab(text: 'Overview'),
              Tab(text: 'Market'),
              Tab(text: 'Operations'),
              Tab(text: 'Financials'),
              Tab(text: 'Equity'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            _OverviewTab(business: business),
            _MarketTab(business: business),
            _OperationsTab(business: business),
            _FinancialsTab(business: business),
            _EquityTab(business: business),
          ],
        ),
      ),
    );
  }
}

// ─── Shared helpers ────────────────────────────────────────────────────────────

class _SectionTitle extends StatelessWidget {
  final String title;
  const _SectionTitle(this.title);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 20, bottom: 8),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.bold,
          color: Colors.black87,
        ),
      ),
    );
  }
}

class _InfoCard extends StatelessWidget {
  final String label;
  final String body;
  const _InfoCard(this.label, this.body);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label,
              style:
                  const TextStyle(fontSize: 11, color: Colors.grey, fontWeight: FontWeight.w500)),
          const SizedBox(height: 4),
          Text(body, style: const TextStyle(fontSize: 13, height: 1.4)),
        ],
      ),
    );
  }
}

class _HighlightCard extends StatelessWidget {
  final String label;
  final String body;
  final Color? color;
  const _HighlightCard(this.label, this.body, {this.color});

  @override
  Widget build(BuildContext context) {
    final c = color ?? const Color(0xFFAB4545);
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: c.withAlpha(15),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: c.withAlpha(60)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label,
              style: TextStyle(fontSize: 11, color: c, fontWeight: FontWeight.w600)),
          const SizedBox(height: 4),
          Text(body, style: const TextStyle(fontSize: 13, height: 1.4)),
        ],
      ),
    );
  }
}

// ─── Overview Tab ──────────────────────────────────────────────────────────────

class _OverviewTab extends StatelessWidget {
  final Business business;
  const _OverviewTab({required this.business});

  @override
  Widget build(BuildContext context) {
    final id = business.coreIdentity;
    final ms = business.marketDynamics.marketSize;
    final accent = id.primaryColor;
    final isGrowth = id.stage.toLowerCase() == 'growth';

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Hero card
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: accent,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        id.tradeName,
                        style: const TextStyle(
                            color: Colors.white,
                            fontSize: 22,
                            fontWeight: FontWeight.bold),
                      ),
                    ),
                    Container(
                      padding:
                          const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.white.withAlpha(50),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        id.stage,
                        style: TextStyle(
                          color: isGrowth
                              ? Colors.greenAccent.shade100
                              : Colors.amber.shade100,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(id.legalName,
                    style: TextStyle(
                        color: Colors.white.withAlpha(180), fontSize: 13)),
                if (id.tagline != null) ...[
                  const SizedBox(height: 6),
                  Text(
                    '"${id.tagline}"',
                    style: TextStyle(
                        color: Colors.white.withAlpha(200),
                        fontSize: 13,
                        fontStyle: FontStyle.italic),
                  ),
                ],
              ],
            ),
          ),

          _SectionTitle('Mission & Vision'),
          _InfoCard('Mission', id.mission),
          _InfoCard('Vision', id.vision),

          _SectionTitle('Market Size'),
          _MarketFunnel(marketSize: ms),
          const SizedBox(height: 10),
          Row(
            children: [
              Icon(Icons.trending_up, size: 16, color: Colors.green.shade700),
              const SizedBox(width: 6),
              Text(
                '${ms.growthRateYoyPct.toStringAsFixed(0)}% YoY market growth',
                style: TextStyle(
                    fontWeight: FontWeight.w600,
                    color: Colors.green.shade700,
                    fontSize: 13),
              ),
              const SizedBox(width: 12),
              Text(
                '${ms.currentMarketSharePct}% current share',
                style: const TextStyle(color: Colors.grey, fontSize: 12),
              ),
            ],
          ),

          if (id.website != null || id.socialMedia.isNotEmpty) ...[
            _SectionTitle('Links'),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                if (id.website != null)
                  _LinkChip(label: 'Website', icon: Icons.language),
                ...id.socialMedia.keys.map(
                  (platform) => _LinkChip(
                    label: platform[0].toUpperCase() + platform.substring(1),
                    icon: Icons.link,
                  ),
                ),
              ],
            ),
          ],
          const SizedBox(height: 16),
        ],
      ),
    );
  }
}

class _MarketFunnel extends StatelessWidget {
  final MarketSize marketSize;
  const _MarketFunnel({required this.marketSize});

  @override
  Widget build(BuildContext context) {
    final tam = marketSize.tamUsd;
    return Column(
      children: [
        _FunnelBar(
          label: 'TAM (Total Addressable)',
          value: formatUsd(marketSize.tamUsd),
          fraction: 1.0,
          color: Colors.blue.shade300,
        ),
        const SizedBox(height: 6),
        _FunnelBar(
          label: 'SAM (Serviceable)',
          value: formatUsd(marketSize.samUsd),
          fraction: marketSize.samUsd / tam,
          color: Colors.blue.shade500,
        ),
        const SizedBox(height: 6),
        _FunnelBar(
          label: 'SOM (Obtainable)',
          value: formatUsd(marketSize.somUsd),
          fraction: marketSize.somUsd / tam,
          color: Colors.blue.shade700,
        ),
      ],
    );
  }
}

class _FunnelBar extends StatelessWidget {
  final String label;
  final String value;
  final double fraction;
  final Color color;

  const _FunnelBar({
    required this.label,
    required this.value,
    required this.fraction,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label, style: const TextStyle(fontSize: 11, color: Colors.grey)),
            Text(value,
                style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
          ],
        ),
        const SizedBox(height: 3),
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(
            value: fraction.clamp(0.0, 1.0),
            backgroundColor: Colors.grey.shade100,
            valueColor: AlwaysStoppedAnimation<Color>(color),
            minHeight: 10,
          ),
        ),
      ],
    );
  }
}

class _LinkChip extends StatelessWidget {
  final String label;
  final IconData icon;

  const _LinkChip({required this.label, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: Colors.grey.shade600),
          const SizedBox(width: 4),
          Text(label, style: const TextStyle(fontSize: 12)),
        ],
      ),
    );
  }
}

// ─── Market Tab ────────────────────────────────────────────────────────────────

class _MarketTab extends StatelessWidget {
  final Business business;
  const _MarketTab({required this.business});

  @override
  Widget build(BuildContext context) {
    final md = business.marketDynamics;
    final td = md.targetDemographics;
    final cl = md.competitiveLandscape;
    final accent = business.coreIdentity.primaryColor;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _HighlightCard(
            'Problem Solved',
            business.coreIdentity.problemSolved,
            color: accent,
          ),

          _SectionTitle('Target Customers'),
          _InfoCard('Primary Customer', td.primaryCustomer),
          _InfoCard('Secondary Customer', td.secondaryCustomer),

          if (td.customerPainPoints.isNotEmpty) ...[
            _SectionTitle('Customer Pain Points'),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: td.customerPainPoints
                  .map((p) => _Chip(p, color: Colors.red.shade50, textColor: Colors.red.shade800))
                  .toList(),
            ),
          ],

          if (td.buyingTriggers.isNotEmpty) ...[
            _SectionTitle('Buying Triggers'),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: td.buyingTriggers
                  .map((t) => _Chip(t, color: Colors.green.shade50, textColor: Colors.green.shade800))
                  .toList(),
            ),
          ],

          _HighlightCard(
            'Unfair Advantage',
            cl.unfairAdvantage,
            color: Colors.purple,
          ),

          if (cl.topCompetitors.isNotEmpty) ...[
            _SectionTitle('Competitive Landscape'),
            _CompetitorTable(competitors: cl.topCompetitors),
          ],

          const SizedBox(height: 16),
        ],
      ),
    );
  }
}

class _Chip extends StatelessWidget {
  final String label;
  final Color color;
  final Color textColor;

  const _Chip(this.label, {required this.color, required this.textColor});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(label, style: TextStyle(fontSize: 12, color: textColor)),
    );
  }
}

class _CompetitorTable extends StatelessWidget {
  final List<Competitor> competitors;
  const _CompetitorTable({required this.competitors});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Table(
        columnWidths: const {
          0: FlexColumnWidth(1.2),
          1: FlexColumnWidth(1.5),
          2: FlexColumnWidth(1.5),
        },
        border: TableBorder(
          horizontalInside: BorderSide(color: Colors.grey.shade100),
        ),
        children: [
          TableRow(
            decoration: BoxDecoration(color: Colors.grey.shade50),
            children: [
              _tCell('Competitor', header: true),
              _tCell('Strength', header: true),
              _tCell('Weakness', header: true),
            ],
          ),
          ...competitors.map(
            (c) => TableRow(children: [
              _tCell(c.name, bold: true),
              _tCell(c.strength),
              _tCell(c.weakness),
            ]),
          ),
        ],
      ),
    );
  }

  Widget _tCell(String text, {bool header = false, bool bold = false}) {
    return Padding(
      padding: const EdgeInsets.all(10),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 12,
          fontWeight: (header || bold) ? FontWeight.w600 : FontWeight.normal,
          color: Colors.black87,
        ),
      ),
    );
  }
}

// ─── Operations Tab ────────────────────────────────────────────────────────────

class _OperationsTab extends StatelessWidget {
  final Business business;
  const _OperationsTab({required this.business});

  @override
  Widget build(BuildContext context) {
    final ops = business.operations;
    final org = ops.orgChart;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // CEO card
          _SectionTitle('Leadership'),
          _InfoCard(
            'CEO · ${org.ceo.name}',
            'Direct reports: ${org.ceo.directReports.join(", ")}',
          ),

          // Departments
          _SectionTitle('Departments'),
          ...org.departments.map(
            (d) => Container(
              margin: const EdgeInsets.only(bottom: 8),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.grey.shade200),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(d.name,
                            style: const TextStyle(
                                fontWeight: FontWeight.w600, fontSize: 13)),
                        const SizedBox(height: 2),
                        Text('Head: ${d.head}',
                            style: const TextStyle(
                                fontSize: 12, color: Colors.grey)),
                      ],
                    ),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        '${d.headcount}',
                        style: const TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      const Text('people',
                          style:
                              TextStyle(fontSize: 10, color: Colors.grey)),
                    ],
                  ),
                ],
              ),
            ),
          ),

          // Total headcount
          const SizedBox(height: 4),
          StatCard(
            label: 'Total Headcount',
            value: '${org.totalHeadcount} people',
            icon: Icons.people_outline,
          ),

          // Key partnerships
          if (ops.keyPartnerships.isNotEmpty) ...[
            _SectionTitle('Key Partnerships'),
            ...ops.keyPartnerships.map(
              (p) => _InfoCard(
                '${p.partner} · since ${p.since}',
                p.type,
              ),
            ),
          ],

          // Tech stack
          if (ops.techStack.isNotEmpty) ...[
            _SectionTitle('Tech Stack'),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: ops.techStack
                  .map((t) => _TechChip(category: t.category, tool: t.tool))
                  .toList(),
            ),
          ],

          // Documents
          if (ops.documents.isNotEmpty) ...[
            _SectionTitle('Documents'),
            ...ops.documents.map((doc) => _DocumentTile(doc: doc)),
          ],

          const SizedBox(height: 16),
        ],
      ),
    );
  }
}

class _TechChip extends StatelessWidget {
  final String category;
  final String tool;

  const _TechChip({required this.category, required this.tool});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.blueGrey.shade50,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: Colors.blueGrey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(category,
              style: TextStyle(
                  fontSize: 9,
                  color: Colors.blueGrey.shade600,
                  fontWeight: FontWeight.w600)),
          Text(tool, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }
}

class _DocumentTile extends StatelessWidget {
  final BusinessDocument doc;

  const _DocumentTile({required this.doc});

  @override
  Widget build(BuildContext context) {
    final hasExpiry = doc.expiryDate != null;
    final isExpired = doc.isExpired;
    final isExpiringSoon = doc.isExpiringSoon;

    Color statusColor = Colors.grey;
    String statusLabel = '';
    if (isExpired) {
      statusColor = Colors.red;
      statusLabel = 'Expired';
    } else if (isExpiringSoon) {
      statusColor = Colors.amber.shade700;
      statusLabel = '⚠ Expiring soon';
    } else if (hasExpiry) {
      statusColor = Colors.green.shade700;
      statusLabel = 'Active';
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: (isExpired || isExpiringSoon)
              ? Colors.amber.shade300
              : Colors.grey.shade200,
        ),
      ),
      child: Row(
        children: [
          Icon(Icons.description_outlined,
              size: 20, color: Colors.grey.shade600),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  doc.type + (doc.withParty != null ? ' · ${doc.withParty}' : ''),
                  style: const TextStyle(
                      fontWeight: FontWeight.w600, fontSize: 13),
                ),
                if (hasExpiry)
                  Text('Expires: ${doc.expiryDate}',
                      style:
                          const TextStyle(fontSize: 12, color: Colors.grey)),
              ],
            ),
          ),
          if (statusLabel.isNotEmpty)
            Text(statusLabel,
                style: TextStyle(
                    fontSize: 11,
                    color: statusColor,
                    fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}

// ─── Financials Tab ────────────────────────────────────────────────────────────

class _FinancialsTab extends StatelessWidget {
  final Business business;
  const _FinancialsTab({required this.business});

  @override
  Widget build(BuildContext context) {
    final fin = business.financials;
    final bs = fin.balanceSheet;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Revenue streams
          _SectionTitle('Revenue Streams'),
          ...fin.revenueStreams.map(
            (rs) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(rs.stream,
                            style: const TextStyle(
                                fontSize: 13, fontWeight: FontWeight.w500)),
                      ),
                      Text('${rs.pctOfRevenue}%',
                          style: const TextStyle(
                              fontSize: 13, fontWeight: FontWeight.bold)),
                    ],
                  ),
                  const SizedBox(height: 3),
                  Text(rs.model,
                      style: const TextStyle(
                          fontSize: 11, color: Colors.grey)),
                  const SizedBox(height: 4),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: LinearProgressIndicator(
                      value: rs.pctOfRevenue / 100,
                      backgroundColor: Colors.grey.shade100,
                      valueColor: AlwaysStoppedAnimation<Color>(
                          business.coreIdentity.primaryColor),
                      minHeight: 8,
                    ),
                  ),
                ],
              ),
            ),
          ),

          // P&L table
          _SectionTitle('Profit & Loss'),
          FinancialTable(pnlList: fin.profitAndLoss),

          // Balance sheet
          _SectionTitle('Balance Sheet (${bs.asOf})'),
          GridView.count(
            crossAxisCount: 2,
            crossAxisSpacing: 10,
            mainAxisSpacing: 10,
            childAspectRatio: 2.4,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            children: [
              StatCard(
                label: 'Total Assets',
                value: formatNpr(bs.totalAssetsNpr),
                icon: Icons.account_balance_outlined,
                color: Colors.blue.shade700,
              ),
              StatCard(
                label: 'Total Liabilities',
                value: formatNpr(bs.totalLiabilitiesNpr),
                icon: Icons.receipt_long_outlined,
                color: Colors.red.shade700,
              ),
              StatCard(
                label: 'Equity',
                value: formatNpr(bs.equityNpr),
                icon: Icons.pie_chart_outline,
                color: Colors.green.shade700,
              ),
              StatCard(
                label: 'Cash',
                value: formatNpr(bs.cashNpr),
                icon: Icons.payments_outlined,
                color: Colors.teal.shade700,
              ),
            ],
          ),

          // Cash flows
          _SectionTitle('Cash Flow Summary'),
          _CashFlowTable(cashFlows: fin.cashFlows),

          // Funding history
          if (fin.fundingHistory.isNotEmpty) ...[
            _SectionTitle('Funding History'),
            _FundingTimeline(rounds: fin.fundingHistory),
          ],

          const SizedBox(height: 16),
        ],
      ),
    );
  }
}

class _CashFlowTable extends StatelessWidget {
  final List<CashFlow> cashFlows;
  const _CashFlowTable({required this.cashFlows});

  @override
  Widget build(BuildContext context) {
    if (cashFlows.isEmpty) return const SizedBox();
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Table(
        columnWidths: const {0: FlexColumnWidth(1.6)},
        border: TableBorder(
            horizontalInside: BorderSide(color: Colors.grey.shade100)),
        children: [
          TableRow(
            decoration: BoxDecoration(color: Colors.grey.shade50),
            children: [
              _cfCell('', header: true),
              ...cashFlows.map((c) => _cfCell(c.fiscalYear, header: true)),
            ],
          ),
          TableRow(children: [
            _cfCell('Operating'),
            ...cashFlows.map((c) => _cfCell(
                  formatNprShort(c.operatingNpr),
                  color: c.operatingNpr >= 0
                      ? Colors.green.shade700
                      : Colors.red.shade700,
                )),
          ]),
          TableRow(children: [
            _cfCell('Investing'),
            ...cashFlows.map((c) => _cfCell(
                  formatNprShort(c.investingNpr),
                  color: c.investingNpr >= 0
                      ? Colors.green.shade700
                      : Colors.red.shade700,
                )),
          ]),
          TableRow(children: [
            _cfCell('Financing'),
            ...cashFlows.map((c) => _cfCell(
                  formatNprShort(c.financingNpr),
                  color: c.financingNpr >= 0
                      ? Colors.green.shade700
                      : Colors.red.shade700,
                )),
          ]),
        ],
      ),
    );
  }

  Widget _cfCell(String text, {bool header = false, Color? color}) {
    return Padding(
      padding: const EdgeInsets.all(9),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 12,
          fontWeight: header ? FontWeight.w600 : FontWeight.normal,
          color: color ?? Colors.black87,
        ),
      ),
    );
  }
}

class _FundingTimeline extends StatelessWidget {
  final List<FundingRound> rounds;
  const _FundingTimeline({required this.rounds});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: rounds.asMap().entries.map((entry) {
        final i = entry.key;
        final round = entry.value;
        final isLast = i == rounds.length - 1;
        return IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                width: 24,
                child: Column(
                  children: [
                    Container(
                      width: 12,
                      height: 12,
                      decoration: BoxDecoration(
                        color: const Color(0xFFAB4545),
                        shape: BoxShape.circle,
                      ),
                    ),
                    if (!isLast)
                      Expanded(
                        child: Container(
                          width: 2,
                          color: Colors.grey.shade300,
                        ),
                      ),
                  ],
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Padding(
                  padding: EdgeInsets.only(bottom: isLast ? 0 : 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            round.round,
                            style: const TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 14),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            formatUsd(round.amountUsd),
                            style: TextStyle(
                                color: Colors.green.shade700,
                                fontWeight: FontWeight.w600,
                                fontSize: 13),
                          ),
                        ],
                      ),
                      Text(round.date,
                          style: const TextStyle(
                              fontSize: 11, color: Colors.grey)),
                      const SizedBox(height: 2),
                      Text(round.investors.join(', '),
                          style: const TextStyle(fontSize: 12)),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }
}

// ─── Equity Tab ────────────────────────────────────────────────────────────────

class _EquityTab extends StatelessWidget {
  final Business business;
  const _EquityTab({required this.business});

  @override
  Widget build(BuildContext context) {
    final shareholders = business.shareholding;
    final totalShares = shareholders.fold<int>(0, (sum, s) => sum + s.shares);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          StatCard(
            label: 'Total Shares Outstanding',
            value: _formatShares(totalShares),
            icon: Icons.pie_chart_outline,
          ),

          _SectionTitle('Cap Table'),
          ...shareholders.map((s) => OwnershipBar(shareholding: s)),

          _SectionTitle('Shareholding Details'),
          _ShareholdingTable(shareholders: shareholders),

          // Legend
          const SizedBox(height: 16),
          Wrap(
            spacing: 12,
            runSpacing: 8,
            children: const [
              _LegendItem(label: 'Ordinary', color: Color(0xFF1565C0)),
              _LegendItem(label: 'Preferred-A', color: Color(0xFF6A1B9A)),
              _LegendItem(label: 'ESOP', color: Color(0xFF546E7A)),
            ],
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  String _formatShares(int shares) {
    if (shares >= 1000000) return '${(shares / 1000000).toStringAsFixed(1)}M';
    if (shares >= 1000) return '${(shares / 1000).toStringAsFixed(0)}K';
    return '$shares';
  }
}

class _ShareholdingTable extends StatelessWidget {
  final List<Shareholding> shareholders;
  const _ShareholdingTable({required this.shareholders});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Table(
        columnWidths: const {
          0: FlexColumnWidth(1.6),
          1: FlexColumnWidth(1.0),
          2: FlexColumnWidth(1.2),
          3: FlexColumnWidth(0.7),
        },
        border: TableBorder(
            horizontalInside: BorderSide(color: Colors.grey.shade100)),
        children: [
          TableRow(
            decoration: BoxDecoration(color: Colors.grey.shade50),
            children: [
              _shCell('Name', header: true),
              _shCell('Shares', header: true),
              _shCell('Class', header: true),
              _shCell('%', header: true),
            ],
          ),
          ...shareholders.map(
            (s) => TableRow(children: [
              _shCell(s.name),
              _shCell('${s.shares ~/ 1000}K'),
              _shCell(s.shareClass),
              _shCell('${s.ownershipPct.toStringAsFixed(0)}%',
                  bold: true),
            ]),
          ),
        ],
      ),
    );
  }

  Widget _shCell(String text, {bool header = false, bool bold = false}) {
    return Padding(
      padding: const EdgeInsets.all(9),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 12,
          fontWeight: (header || bold) ? FontWeight.w600 : FontWeight.normal,
        ),
      ),
    );
  }
}

class _LegendItem extends StatelessWidget {
  final String label;
  final Color color;

  const _LegendItem({required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
            width: 12,
            height: 12,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
        const SizedBox(width: 4),
        Text(label, style: const TextStyle(fontSize: 12, color: Colors.black87)),
      ],
    );
  }
}
