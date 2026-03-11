import 'package:flutter/material.dart';
import 'package:avalokan/models/business_data.dart';
import 'package:avalokan/utils/format.dart';

class FinancialTable extends StatelessWidget {
  final List<ProfitAndLoss> pnlList;

  const FinancialTable({super.key, required this.pnlList});

  @override
  Widget build(BuildContext context) {
    if (pnlList.isEmpty) return const SizedBox();

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Table(
        columnWidths: const {0: FlexColumnWidth(1.8)},
        border: TableBorder(
          horizontalInside: BorderSide(color: Colors.grey.shade100),
        ),
        children: [
          _headerRow(pnlList),
          _dataRow('Revenue', pnlList.map((p) => p.revenueNpr).toList(), alwaysPositive: true),
          _dataRow('Gross Profit', pnlList.map((p) => p.grossProfitNpr).toList()),
          _dataRow('EBITDA', pnlList.map((p) => p.ebitdaNpr).toList()),
          _dataRow('Net Profit', pnlList.map((p) => p.netProfitNpr).toList()),
        ],
      ),
    );
  }

  TableRow _headerRow(List<ProfitAndLoss> pnlList) {
    return TableRow(
      decoration: BoxDecoration(color: Colors.grey.shade50),
      children: [
        _cell('Metric', isHeader: true),
        ...pnlList.map((p) => _cell(p.fiscalYear, isHeader: true)),
      ],
    );
  }

  TableRow _dataRow(String label, List<double> values, {bool alwaysPositive = false}) {
    return TableRow(
      children: [
        _cell(label),
        ...values.map((v) {
          final color = alwaysPositive
              ? Colors.black87
              : (v >= 0 ? Colors.green.shade700 : Colors.red.shade700);
          return _cell(formatNprShort(v), color: color, bold: true);
        }),
      ],
    );
  }

  Widget _cell(String text, {bool isHeader = false, Color? color, bool bold = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 9),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 12,
          fontWeight: (isHeader || bold) ? FontWeight.w600 : FontWeight.normal,
          color: color ?? (isHeader ? Colors.black87 : Colors.black87),
        ),
      ),
    );
  }
}
