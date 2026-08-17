package com.mealchemy.preference.repository;

/* Importing classes */

/* Importing libraries */

import com.mealchemy.preference.model.UserCuisineAffinities;
import org.springframework.data.jpa.repository.JpaRepository;
import java.util.*;

public interface UserCuisineAffinitiesRepository extends JpaRepository <UserCuisineAffinites, Integer>
{
    
}
