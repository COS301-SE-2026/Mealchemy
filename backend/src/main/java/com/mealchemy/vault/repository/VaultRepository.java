// talks to vaults table

package com.mealchemy.vault.repository;

import com.mealchemy.vault.model.Vault;
import org.springframework.data.jpa.repository.JpaRepository;
import java.util.Optional;
import java.util.List;


public interface VaultRepository extends JpaRepository<Vault, Integer> { // Vault object, primary key is Integer (vault_id)
    Optional<VaultRepository> findByOwnerId(Integer ownerId); // finds owner of Vault when user opens their vault
}