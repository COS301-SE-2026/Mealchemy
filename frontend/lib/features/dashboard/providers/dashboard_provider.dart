import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mealchemy/features/auth/models/user.dart';


//State
class DashboardState{
  final bool isLoading;
  final String? errorMessage;
  final User? currentUser;
  final int smartSuggestionItemsAway;
  final int smartSuggestionRecipeCount;

  const DashboardState({
    this.isLoading = false,
    this.errorMessage,
    this.currentUser,
    this.smartSuggestionItemsAway = 0,
    this.smartSuggestionRecipeCount = 0,
  });

  DashboardState copyWith({
    bool? isLoading,
    String? errorMessage,
    User? currentUser,
    int? smartSuggestionItemsAway,
    int? smartSuggestionRecipeCount,
  }) {
    return DashboardState(
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage,
      currentUser: currentUser ?? this.currentUser,
      smartSuggestionItemsAway: smartSuggestionItemsAway ?? this.smartSuggestionItemsAway,
      smartSuggestionRecipeCount: smartSuggestionRecipeCount ?? this.smartSuggestionRecipeCount,
    );
  }
}

//Notifier 
class DashboardNotifier extends StateNotifier<DashboardState> {
  DashboardNotifier() : super(const DashboardState());
 
  Future<void> loadDashboard() async {
    state =  state.copyWith(isLoading: true, errorMessage: null);
 
    //Replace with real API call later 
    await Future.delayed(const Duration(milliseconds: 600));
 
     state = state.copyWith(
      isLoading: false,
      currentUser: const User(
        userId: 1,
        email: 'mutombo@mealchemy.com',
        displayName: 'Mutombo',
        role: 'user',
      ),
      //smart suggestion data will come from the reicipe suggestion
      //repository once that feature is built
      smartSuggestionItemsAway: 3,
      smartSuggestionRecipeCount: 10,
    );
  }
}


//Provider
final dashboardProvider = StateNotifierProvider<DashboardNotifier, DashboardState>((ref) {
  return DashboardNotifier();
});