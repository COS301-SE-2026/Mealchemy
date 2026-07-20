package com.mealchemy.vault.repository;

/* Import libraries */

import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;
import java.util.*;

/* Import classes */

import com.mealchemy.vault.model.VaultMember;
import com.mealchemy.auth.model.User;

@Repository
public interface VaultMemberRepository extends JpaRepository<VaultMember, Integer>
{
    List<VaultMember> findByVault_VaultId(Integer vaultId);
    boolean existsByVault_VaultIdAndUser_UserId(Integer vaultId, Integer userId);
    List<VaultMember> findByVault_VaultIdAndUser_UserId(Integer vaultId, Integer userId);
}
