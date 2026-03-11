import 'package:flutter/material.dart';

class AppData {
  final List<AppUser> users;
  final List<Business> businesses;
  final List<Portfolio> portfolios;

  AppData({required this.users, required this.businesses, required this.portfolios});

  factory AppData.fromJson(Map<String, dynamic> json) {
    return AppData(
      users: (json['users'] as List).map((e) => AppUser.fromJson(e as Map<String, dynamic>)).toList(),
      businesses: (json['businesses'] as List).map((e) => Business.fromJson(e as Map<String, dynamic>)).toList(),
      portfolios: (json['portfolios'] as List).map((e) => Portfolio.fromJson(e as Map<String, dynamic>)).toList(),
    );
  }
}

class AppUser {
  final String id;
  final String email;
  final String displayName;
  final String? avatarUrl;
  final String phone;
  final List<String> portfolios;

  AppUser({
    required this.id,
    required this.email,
    required this.displayName,
    this.avatarUrl,
    required this.phone,
    required this.portfolios,
  });

  factory AppUser.fromJson(Map<String, dynamic> json) {
    return AppUser(
      id: json['id'] as String,
      email: json['email'] as String,
      displayName: json['display_name'] as String,
      avatarUrl: json['avatar_url'] as String?,
      phone: (json['phone'] as String?) ?? '',
      portfolios: (json['portfolios'] as List).map((e) => e.toString()).toList(),
    );
  }
}

class Portfolio {
  final String id;
  final String ownerId;
  final String name;
  final String description;
  final List<String> businessIds;

  Portfolio({
    required this.id,
    required this.ownerId,
    required this.name,
    required this.description,
    required this.businessIds,
  });

  factory Portfolio.fromJson(Map<String, dynamic> json) {
    return Portfolio(
      id: json['id'] as String,
      ownerId: json['owner_id'] as String,
      name: json['name'] as String,
      description: (json['description'] as String?) ?? '',
      businessIds: (json['business_ids'] as List).map((e) => e.toString()).toList(),
    );
  }
}

class Business {
  final String id;
  final String portfolioId;
  final CoreIdentity coreIdentity;
  final MarketDynamics marketDynamics;
  final Operations operations;
  final Financials financials;
  final List<Shareholding> shareholding;

  Business({
    required this.id,
    required this.portfolioId,
    required this.coreIdentity,
    required this.marketDynamics,
    required this.operations,
    required this.financials,
    required this.shareholding,
  });

  factory Business.fromJson(Map<String, dynamic> json) {
    return Business(
      id: json['id'] as String,
      portfolioId: json['portfolio_id'] as String,
      coreIdentity: CoreIdentity.fromJson(json['core_identity'] as Map<String, dynamic>),
      marketDynamics: MarketDynamics.fromJson(json['market_dynamics'] as Map<String, dynamic>),
      operations: Operations.fromJson(json['operations'] as Map<String, dynamic>),
      financials: Financials.fromJson(json['financials'] as Map<String, dynamic>),
      shareholding: (json['shareholding'] as List)
          .map((e) => Shareholding.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }

  double ownershipFor(String userId) {
    final matches = shareholding.where((s) => s.shareholderId == userId);
    return matches.isEmpty ? 0.0 : matches.first.ownershipPct;
  }

  ProfitAndLoss? get latestPnL {
    if (financials.profitAndLoss.isEmpty) return null;
    return financials.profitAndLoss.last;
  }
}

class CoreIdentity {
  final String legalName;
  final String tradeName;
  final String legalStructure;
  final String industry;
  final String stage;
  final String mission;
  final String vision;
  final String problemSolved;
  final String? website;
  final Map<String, String> socialMedia;
  final Color primaryColor;
  final String? tagline;

  CoreIdentity({
    required this.legalName,
    required this.tradeName,
    required this.legalStructure,
    required this.industry,
    required this.stage,
    required this.mission,
    required this.vision,
    required this.problemSolved,
    this.website,
    required this.socialMedia,
    required this.primaryColor,
    this.tagline,
  });

  factory CoreIdentity.fromJson(Map<String, dynamic> json) {
    Color color = const Color(0xFFAB4545);
    String? tagline;
    if (json['brand_guidelines'] != null) {
      final bg = json['brand_guidelines'] as Map<String, dynamic>;
      final hex = bg['primary_color'] as String?;
      if (hex != null) color = _hexToColor(hex);
      tagline = bg['tagline'] as String?;
    }
    final socialMedia = <String, String>{};
    if (json['social_media'] != null) {
      (json['social_media'] as Map<String, dynamic>).forEach((k, v) {
        socialMedia[k] = v.toString();
      });
    }
    return CoreIdentity(
      legalName: (json['legal_name'] as String?) ?? '',
      tradeName: (json['trade_name'] as String?) ?? '',
      legalStructure: (json['legal_structure'] as String?) ?? '',
      industry: (json['industry'] as String?) ?? '',
      stage: (json['stage'] as String?) ?? '',
      mission: (json['mission'] as String?) ?? '',
      vision: (json['vision'] as String?) ?? '',
      problemSolved: (json['problem_solved'] as String?) ?? '',
      website: json['website'] as String?,
      socialMedia: socialMedia,
      primaryColor: color,
      tagline: tagline,
    );
  }

  static Color _hexToColor(String hex) {
    final h = hex.replaceAll('#', '');
    return Color(int.parse('FF$h', radix: 16));
  }
}

class MarketDynamics {
  final TargetDemographics targetDemographics;
  final CompetitiveLandscape competitiveLandscape;
  final MarketSize marketSize;

  MarketDynamics({
    required this.targetDemographics,
    required this.competitiveLandscape,
    required this.marketSize,
  });

  factory MarketDynamics.fromJson(Map<String, dynamic> json) {
    return MarketDynamics(
      targetDemographics: TargetDemographics.fromJson(json['target_demographics'] as Map<String, dynamic>),
      competitiveLandscape: CompetitiveLandscape.fromJson(json['competitive_landscape'] as Map<String, dynamic>),
      marketSize: MarketSize.fromJson(json['market_size'] as Map<String, dynamic>),
    );
  }
}

class TargetDemographics {
  final String primaryCustomer;
  final String secondaryCustomer;
  final List<String> customerPainPoints;
  final List<String> buyingTriggers;

  TargetDemographics({
    required this.primaryCustomer,
    required this.secondaryCustomer,
    required this.customerPainPoints,
    required this.buyingTriggers,
  });

  factory TargetDemographics.fromJson(Map<String, dynamic> json) {
    return TargetDemographics(
      primaryCustomer: (json['primary_customer'] as String?) ?? '',
      secondaryCustomer: (json['secondary_customer'] as String?) ?? '',
      customerPainPoints: (json['customer_pain_points'] as List? ?? []).map((e) => e.toString()).toList(),
      buyingTriggers: (json['buying_triggers'] as List? ?? []).map((e) => e.toString()).toList(),
    );
  }
}

class CompetitiveLandscape {
  final List<Competitor> topCompetitors;
  final String unfairAdvantage;

  CompetitiveLandscape({required this.topCompetitors, required this.unfairAdvantage});

  factory CompetitiveLandscape.fromJson(Map<String, dynamic> json) {
    return CompetitiveLandscape(
      topCompetitors: (json['top_competitors'] as List? ?? [])
          .map((e) => Competitor.fromJson(e as Map<String, dynamic>))
          .toList(),
      unfairAdvantage: (json['unfair_advantage'] as String?) ?? '',
    );
  }
}

class Competitor {
  final String name;
  final String strength;
  final String weakness;

  Competitor({required this.name, required this.strength, required this.weakness});

  factory Competitor.fromJson(Map<String, dynamic> json) {
    return Competitor(
      name: (json['name'] as String?) ?? '',
      strength: (json['strength'] as String?) ?? '',
      weakness: (json['weakness'] as String?) ?? '',
    );
  }
}

class MarketSize {
  final double tamUsd;
  final double samUsd;
  final double somUsd;
  final double currentMarketSharePct;
  final double growthRateYoyPct;

  MarketSize({
    required this.tamUsd,
    required this.samUsd,
    required this.somUsd,
    required this.currentMarketSharePct,
    required this.growthRateYoyPct,
  });

  factory MarketSize.fromJson(Map<String, dynamic> json) {
    return MarketSize(
      tamUsd: (json['tam_usd'] as num).toDouble(),
      samUsd: (json['sam_usd'] as num).toDouble(),
      somUsd: (json['som_usd'] as num).toDouble(),
      currentMarketSharePct: (json['current_market_share_pct'] as num).toDouble(),
      growthRateYoyPct: (json['growth_rate_yoy_pct'] as num).toDouble(),
    );
  }
}

class Operations {
  final List<TechStackItem> techStack;
  final OrgChart orgChart;
  final List<KeyPartnership> keyPartnerships;
  final List<BusinessDocument> documents;

  Operations({
    required this.techStack,
    required this.orgChart,
    required this.keyPartnerships,
    required this.documents,
  });

  factory Operations.fromJson(Map<String, dynamic> json) {
    return Operations(
      techStack: (json['tech_stack'] as List? ?? [])
          .map((e) => TechStackItem.fromJson(e as Map<String, dynamic>))
          .toList(),
      orgChart: OrgChart.fromJson(json['org_chart'] as Map<String, dynamic>),
      keyPartnerships: (json['key_partnerships'] as List? ?? [])
          .map((e) => KeyPartnership.fromJson(e as Map<String, dynamic>))
          .toList(),
      documents: (json['documents'] as List? ?? [])
          .map((e) => BusinessDocument.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }
}

class TechStackItem {
  final String category;
  final String tool;

  TechStackItem({required this.category, required this.tool});

  factory TechStackItem.fromJson(Map<String, dynamic> json) {
    return TechStackItem(
      category: (json['category'] as String?) ?? '',
      tool: (json['tool'] as String?) ?? '',
    );
  }
}

class OrgChart {
  final CeoInfo ceo;
  final List<Department> departments;
  final int totalHeadcount;

  OrgChart({required this.ceo, required this.departments, required this.totalHeadcount});

  factory OrgChart.fromJson(Map<String, dynamic> json) {
    return OrgChart(
      ceo: CeoInfo.fromJson(json['ceo'] as Map<String, dynamic>),
      departments: (json['departments'] as List? ?? [])
          .map((e) => Department.fromJson(e as Map<String, dynamic>))
          .toList(),
      totalHeadcount: (json['total_headcount'] as int?) ?? 0,
    );
  }
}

class CeoInfo {
  final String name;
  final List<String> directReports;

  CeoInfo({required this.name, required this.directReports});

  factory CeoInfo.fromJson(Map<String, dynamic> json) {
    return CeoInfo(
      name: (json['name'] as String?) ?? '',
      directReports: (json['direct_reports'] as List? ?? []).map((e) => e.toString()).toList(),
    );
  }
}

class Department {
  final String name;
  final String head;
  final int headcount;

  Department({required this.name, required this.head, required this.headcount});

  factory Department.fromJson(Map<String, dynamic> json) {
    return Department(
      name: (json['name'] as String?) ?? '',
      head: (json['head'] as String?) ?? '',
      headcount: (json['headcount'] as int?) ?? 0,
    );
  }
}

class KeyPartnership {
  final String partner;
  final String type;
  final int since;

  KeyPartnership({required this.partner, required this.type, required this.since});

  factory KeyPartnership.fromJson(Map<String, dynamic> json) {
    return KeyPartnership(
      partner: (json['partner'] as String?) ?? '',
      type: (json['type'] as String?) ?? '',
      since: (json['since'] as int?) ?? 0,
    );
  }
}

class BusinessDocument {
  final String type;
  final String? withParty;
  final String signedDate;
  final String? expiryDate;

  BusinessDocument({
    required this.type,
    this.withParty,
    required this.signedDate,
    this.expiryDate,
  });

  bool get isExpiringSoon {
    if (expiryDate == null) return false;
    final expiry = DateTime.tryParse(expiryDate!);
    if (expiry == null) return false;
    return expiry.difference(DateTime.now()).inDays <= 90;
  }

  bool get isExpired {
    if (expiryDate == null) return false;
    final expiry = DateTime.tryParse(expiryDate!);
    if (expiry == null) return false;
    return expiry.isBefore(DateTime.now());
  }

  factory BusinessDocument.fromJson(Map<String, dynamic> json) {
    return BusinessDocument(
      type: (json['type'] as String?) ?? '',
      withParty: json['with'] as String?,
      signedDate: (json['signed_date'] as String?) ?? '',
      expiryDate: json['expiry_date'] as String?,
    );
  }
}

class Financials {
  final List<RevenueStream> revenueStreams;
  final List<ProfitAndLoss> profitAndLoss;
  final BalanceSheet balanceSheet;
  final List<CashFlow> cashFlows;
  final List<FundingRound> fundingHistory;

  Financials({
    required this.revenueStreams,
    required this.profitAndLoss,
    required this.balanceSheet,
    required this.cashFlows,
    required this.fundingHistory,
  });

  factory Financials.fromJson(Map<String, dynamic> json) {
    return Financials(
      revenueStreams: (json['revenue_streams'] as List? ?? [])
          .map((e) => RevenueStream.fromJson(e as Map<String, dynamic>))
          .toList(),
      profitAndLoss: (json['profit_and_loss'] as List? ?? [])
          .map((e) => ProfitAndLoss.fromJson(e as Map<String, dynamic>))
          .toList(),
      balanceSheet: BalanceSheet.fromJson(json['balance_sheet_latest'] as Map<String, dynamic>),
      cashFlows: (json['cash_flow_summary'] as List? ?? [])
          .map((e) => CashFlow.fromJson(e as Map<String, dynamic>))
          .toList(),
      fundingHistory: (json['funding_history'] as List? ?? [])
          .map((e) => FundingRound.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }
}

class RevenueStream {
  final String stream;
  final String model;
  final int pctOfRevenue;

  RevenueStream({required this.stream, required this.model, required this.pctOfRevenue});

  factory RevenueStream.fromJson(Map<String, dynamic> json) {
    return RevenueStream(
      stream: (json['stream'] as String?) ?? '',
      model: (json['model'] as String?) ?? '',
      pctOfRevenue: (json['pct_of_revenue'] as int?) ?? 0,
    );
  }
}

class ProfitAndLoss {
  final String fiscalYear;
  final double revenueNpr;
  final double cogsNpr;
  final double grossProfitNpr;
  final double opexNpr;
  final double ebitdaNpr;
  final double netProfitNpr;

  ProfitAndLoss({
    required this.fiscalYear,
    required this.revenueNpr,
    required this.cogsNpr,
    required this.grossProfitNpr,
    required this.opexNpr,
    required this.ebitdaNpr,
    required this.netProfitNpr,
  });

  factory ProfitAndLoss.fromJson(Map<String, dynamic> json) {
    return ProfitAndLoss(
      fiscalYear: (json['fiscal_year'] as String?) ?? '',
      revenueNpr: (json['revenue_npr'] as num).toDouble(),
      cogsNpr: (json['cogs_npr'] as num).toDouble(),
      grossProfitNpr: (json['gross_profit_npr'] as num).toDouble(),
      opexNpr: (json['operating_expenses_npr'] as num).toDouble(),
      ebitdaNpr: (json['ebitda_npr'] as num).toDouble(),
      netProfitNpr: (json['net_profit_npr'] as num).toDouble(),
    );
  }
}

class BalanceSheet {
  final String asOf;
  final double totalAssetsNpr;
  final double totalLiabilitiesNpr;
  final double equityNpr;
  final double cashNpr;
  final double debtNpr;

  BalanceSheet({
    required this.asOf,
    required this.totalAssetsNpr,
    required this.totalLiabilitiesNpr,
    required this.equityNpr,
    required this.cashNpr,
    required this.debtNpr,
  });

  factory BalanceSheet.fromJson(Map<String, dynamic> json) {
    return BalanceSheet(
      asOf: (json['as_of'] as String?) ?? '',
      totalAssetsNpr: (json['total_assets_npr'] as num).toDouble(),
      totalLiabilitiesNpr: (json['total_liabilities_npr'] as num).toDouble(),
      equityNpr: (json['shareholders_equity_npr'] as num).toDouble(),
      cashNpr: (json['cash_and_equivalents_npr'] as num).toDouble(),
      debtNpr: (json['total_debt_npr'] as num).toDouble(),
    );
  }
}

class CashFlow {
  final String fiscalYear;
  final double operatingNpr;
  final double investingNpr;
  final double financingNpr;

  CashFlow({
    required this.fiscalYear,
    required this.operatingNpr,
    required this.investingNpr,
    required this.financingNpr,
  });

  factory CashFlow.fromJson(Map<String, dynamic> json) {
    return CashFlow(
      fiscalYear: (json['fiscal_year'] as String?) ?? '',
      operatingNpr: (json['operating_npr'] as num).toDouble(),
      investingNpr: (json['investing_npr'] as num).toDouble(),
      financingNpr: (json['financing_npr'] as num).toDouble(),
    );
  }
}

class FundingRound {
  final String round;
  final double amountUsd;
  final String date;
  final List<String> investors;

  FundingRound({
    required this.round,
    required this.amountUsd,
    required this.date,
    required this.investors,
  });

  factory FundingRound.fromJson(Map<String, dynamic> json) {
    return FundingRound(
      round: (json['round'] as String?) ?? '',
      amountUsd: (json['amount_usd'] as num).toDouble(),
      date: (json['date'] as String?) ?? '',
      investors: (json['investors'] as List? ?? []).map((e) => e.toString()).toList(),
    );
  }
}

class Shareholding {
  final String shareholderId;
  final String name;
  final int shares;
  final String shareClass;
  final double ownershipPct;
  final String? acquisitionDate;

  Shareholding({
    required this.shareholderId,
    required this.name,
    required this.shares,
    required this.shareClass,
    required this.ownershipPct,
    this.acquisitionDate,
  });

  factory Shareholding.fromJson(Map<String, dynamic> json) {
    return Shareholding(
      shareholderId: (json['shareholder_id'] as String?) ?? '',
      name: (json['name'] as String?) ?? '',
      shares: (json['shares'] as int?) ?? 0,
      shareClass: (json['share_class'] as String?) ?? '',
      ownershipPct: (json['ownership_pct'] as num).toDouble(),
      acquisitionDate: json['acquisition_date'] as String?,
    );
  }
}
