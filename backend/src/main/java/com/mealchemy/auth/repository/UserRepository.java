// talks to users db table

package com.mealchemy.auth.repository;

import com.mealchemy.auth.model.User;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.Optional;

public interface UserRepository extends JpaRepository<User, Integer> { //interface never gets implemented - params = this repository manages User objects and their primary key type is a Integer
    // custom methods
    Optional<User> findByEmail(String email);
    boolean existsByEmail(String email);
}