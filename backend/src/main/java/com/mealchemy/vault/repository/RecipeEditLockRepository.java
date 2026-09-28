package com.mealchemy.vault.repository;

/* Import libraries */

import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;
import java.util.*;

/* Import classes */

import com.mealchemy.vault.model.RecipeEditLock;

@Repository
public interface RecipeEditLockRepository extends JpaRepository<RecipeEditLock, Integer>
{

}
