package com.mealchemy.auth.repository;

import com.mealchemy.auth.model.UserProfile;
import org.springframework.data.jpa.repository.JpaRepository;
import java.util.Optional;
import java.util.List;


public interface UserProfileRepository extends JpaRepository<UserProfile, Long>{ //UserProfile object and Long is profileId
    Optional<UserProfile> findByUserId(Long userId); //want to fetch user by their id not profile id
}
