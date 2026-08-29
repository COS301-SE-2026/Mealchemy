// talks to user_profile db table

package com.mealchemy.profile.repository;

import com.mealchemy.profile.model.UserProfile;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.Optional;
import java.util.List;

public interface UserProfileRepository extends JpaRepository<UserProfile, Integer>{ 
    Optional<UserProfile> findByUserId(Integer userId); 
}