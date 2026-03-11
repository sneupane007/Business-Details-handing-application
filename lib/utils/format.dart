String formatNpr(double amount) {
  final isNeg = amount < 0;
  final abs = amount.abs();
  String formatted;
  if (abs >= 10000000) {
    formatted = 'NPR ${(abs / 10000000).toStringAsFixed(2)} Cr';
  } else if (abs >= 100000) {
    formatted = 'NPR ${(abs / 100000).toStringAsFixed(2)} L';
  } else {
    formatted = 'NPR ${abs.toStringAsFixed(0)}';
  }
  return isNeg ? '-$formatted' : formatted;
}

String formatNprShort(double amount) {
  final isNeg = amount < 0;
  final abs = amount.abs();
  String formatted;
  if (abs >= 10000000) {
    formatted = '${(abs / 10000000).toStringAsFixed(2)} Cr';
  } else if (abs >= 100000) {
    formatted = '${(abs / 100000).toStringAsFixed(2)} L';
  } else {
    formatted = abs.toStringAsFixed(0);
  }
  return isNeg ? '-$formatted' : formatted;
}

String formatUsd(double amount) {
  if (amount >= 1000000) return '\$${(amount / 1000000).toStringAsFixed(1)}M';
  if (amount >= 1000) return '\$${(amount / 1000).toStringAsFixed(0)}K';
  return '\$${amount.toStringAsFixed(0)}';
}
