class MealPlan {
  final int planId;
  final int vaultId;

  const MealPlan({required this.planId, required this.vaultId});

  factory MealPlan.fromJson(Map<String, dynamic> json) {
    return MealPlan(
      planId: json['planId'] as int,
      vaultId: json['vaultId'] as int,
    );
  }
}
