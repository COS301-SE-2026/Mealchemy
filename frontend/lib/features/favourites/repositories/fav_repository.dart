import '../models/favourite.dart';

abstract class FavRepository {
  
  Future<List<Favourite>> getFavs();
  Future<void> removeFav(int recipeId);
}