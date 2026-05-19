// talks to user_preferences db table

package com.mealchemy.preference.repository;

import com.mealchemy.preference.model.UserPreferences;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.Optional;
import java.util.List;


public interface UserPreferencesRepository extends JpaRepository<UserPreferences, Long>{ // UserPreferences object, primary key is Long (preference_id)
    Optional<UserPreferences> findByUserId(Long userId); 
}