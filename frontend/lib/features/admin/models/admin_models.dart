import '../../recipe/models/recipe.dart';

enum FlagStatus {
  pending('PENDING'),
  reviewed('REVIEWED'),
  removed('REMOVED');

  const FlagStatus(this.apiValue);

  final String apiValue;

  static FlagStatus fromJson(String value) {
    return FlagStatus.values.firstWhere(
      (status) => status.apiValue == value,
      orElse: () => throw FormatException('Unknown flag status: $value'),
    );
  }
}

class FlaggedRecipe {
  const FlaggedRecipe({
    required this.flaggedId,
    required this.recipeId,
    required this.recipeTitle,
    required this.flaggedByUserId,
    required this.reasonValue,
    required this.reasonLabel,
    required this.status,
    required this.flaggedAt,
    this.recipePhotoUrl,
  });

  final int flaggedId;
  final int recipeId;
  final String recipeTitle;
  final String? recipePhotoUrl;
  final int flaggedByUserId;
  final String reasonValue;
  final String reasonLabel;
  final FlagStatus status;
  final DateTime flaggedAt;

  factory FlaggedRecipe.fromJson(Map<String, dynamic> json) {
    return FlaggedRecipe(
      flaggedId: json['flagged_id'] as int,
      recipeId: json['recipe_id'] as int,
      recipeTitle: json['recipe_title'] as String,
      recipePhotoUrl: json['recipe_photo_url'] as String?,
      flaggedByUserId: json['flagged_by_user_id'] as int,
      reasonValue: json['reason_value'] as String,
      reasonLabel: json['reason_label'] as String,
      status: FlagStatus.fromJson(json['status'] as String),
      flaggedAt: DateTime.parse(json['flagged_at'] as String),
    );
  }
}

class FlaggedRecipeDetail {
  const FlaggedRecipeDetail({
    required this.flag,
    required this.recipe,
  });

  final FlaggedRecipe flag;

  //admin endpoint embeds recipe metadata only
  //ingredients and steps are fetched separately by review feature
  final Recipe recipe;

  factory FlaggedRecipeDetail.fromJson(Map<String, dynamic> json) {
    return FlaggedRecipeDetail(
      flag: FlaggedRecipe.fromJson(json),
      recipe: Recipe.fromJson(
        Map<String, dynamic>.from(json['recipeResponse'] as Map),
      ),
    );
  }
}

class AdminUserSummary {
  AdminUserSummary({
    required this.userId,
    required this.displayName,
    required this.email,
    required List<String> roles,
  }) : roles = List.unmodifiable(roles);

  final int userId;
  final String displayName;
  final String email;
  final List<String> roles;

  //describes the user returned by lookup/promotion
  //not the current session's access check
  bool get isAdmin => roles.contains('ADMIN');

  factory AdminUserSummary.fromJson(Map<String, dynamic> json) {
    return AdminUserSummary(
      userId: json['user_id'] as int,
      displayName: json['display_name'] as String,
      email: json['email'] as String,
      roles: List<String>.from(json['roles'] as List),
    );
  }
}
