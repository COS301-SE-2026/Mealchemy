// talks to vaults table

package com.mealchemy.vault.repository;

import com.mealchemy.vault.model.Vault;
import org.springframework.data.jpa.repository.JpaRepository;
import java.util.Optional;
import java.util.List;


public interface VaultRepository extends JpaRepository<Vault, Long> { // Vault object, primary key is Long (vault_id)
    Optional<VaultRepository> findByOwnerId(Long ownerId); // finds owner of Vault when user opens their vault
}