package com.mealchemy.tags.repository;

/* Import classes */
import com.mealchemy.tags.model.RecipeTags;

/* Import libraries */
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;
import java.util.*;

@Repository
public interface RecipeTagsRepository extends JpaRepository<RecipeTags, Integer> {
    List<RecipeTags> findByRecipeRecipeId(Integer recipeId);
}
