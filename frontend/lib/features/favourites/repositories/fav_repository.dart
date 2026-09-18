import '../models/favourite.dart';

abstract class FavRepository {
  
  Future<List<Favourite>> getFavs();
  Future<Favourite> addFav({required int recipeId});
  Future<void> removeFav(int recipeId);
}