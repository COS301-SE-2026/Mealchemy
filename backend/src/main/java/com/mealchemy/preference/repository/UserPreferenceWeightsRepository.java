package com.mealchemy.preference.repository;

/* Import classes */

/* Import libraries */

import com.mealchemy.preference.model.UserPreferenceWeights;
import org.springframework.data.jpa.repository.JpaRepository;
import java.util.*;

public interface UserPreferenceWeightsRepository extends JpaRepository<UserPreferenceWeights, Integer>
{
    
}
