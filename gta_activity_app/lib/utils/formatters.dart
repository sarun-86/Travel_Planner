String formatDateRange(DateTime start, DateTime end) {
  final startStr = _shortDate(start);
  final endStr = _shortDate(end);
  return startStr == endStr ? startStr : '$startStr – $endStr';
}

String _shortDate(DateTime d) {
  const months = [
    '', 'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
    'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
  ];
  return '${months[d.month]} ${d.day}';
}

String regionLabel(String region) {
  const labels = {
    'downtown_toronto': 'Downtown TO',
    'west_gta': 'West GTA',
    'east_gta': 'East GTA',
    'north_gta': 'North GTA',
    'niagara': 'Niagara',
  };
  return labels[region] ?? region;
}

String costLabel(String tier) {
  const labels = {
    'free': 'Free',
    'paid_low': '\$',
    'paid_mid': '\$\$',
    'paid_high': '\$\$\$',
  };
  return labels[tier] ?? tier;
}

String audienceLabel(String tag) {
  const labels = {
    'family': 'Family',
    'kids': 'Kids',
    'couples': 'Couples',
    'friends': 'Friends',
  };
  return labels[tag] ?? tag;
}
