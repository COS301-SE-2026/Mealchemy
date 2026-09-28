class Signal {
  const Signal({
    required this.type,
    required this.percentage,
    required this.message,
  });

  final String type;
  final int percentage;
  final String message;

  factory Signal.fromJson(Map<String, dynamic> json) {
    return Signal(
      type: json['signal'] as String,
      percentage: (json['percentage'] as num).round(),
      message: json['message'] as String,
    );
  }
}