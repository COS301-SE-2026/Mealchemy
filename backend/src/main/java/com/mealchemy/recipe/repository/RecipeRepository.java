package com.mealchemy.recipe.repository;

/* Import libraries */

import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;
// import java.util.*;

/* Import classes */

import com.mealchemy.recipe.model.Recipe;

@Repository
public interface RecipeRepository extends JpaRepository<Recipe, Integer>
{
    List<Recipe> findByIsCommunityPublishedTrue();
}