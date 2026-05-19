// talks to role db table - needs to read from role table at runtime

package com.mealchemy.auth.repository;

import com.mealchemy.auth.model.Role;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.Optional;

public interface RoleRepository extends JpaRepository<Role, Long> { //Role object and role_id
    Optional<Role> findByRoleName(String roleName);
}
