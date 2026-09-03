// Countng based units stay whole when scaled
const _countUnits = {
  'ct',
  'piece',
  'pieces',
  'clove',
  'cloves',
  'slice',
  'slices',
  'can',
  'cans',
  'packet',
  'packets',
  'bunch',
  'bunches',
  'stick',
  'sticks',
};

// Scales a base quantity by factor and formats it for display keeping the unit unchanged.
String formatScaledQuantity({
  required double quantity,
  String? unit,
  required double factor,
}) {
  final scaled = quantity * factor;
  final isCount = unit != null && _countUnits.contains(unit.toLowerCase());

  final String value;
  if (isCount) {
    value = scaled.round().toString();
  } else {
    final rounded = (scaled * 2).round() / 2; // nearest 0.5
    value = rounded == rounded.truncateToDouble()
        ? rounded.toInt().toString()
        : rounded.toString();
  }

  return unit != null ? '$value $unit' : value;
}
