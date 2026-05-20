package com.mealchemy.vault.repository;

/* Import libraries */
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;
import java.utils.Optional;
import java.utils.List;

/* Import classes */
import com.mealchemy.vault.model.Vault;

@Repository
public interface VaultRepository extends JpaRepository<Vault, Long>
{
    List<Vault> findByOwnerId(Long ownerId); 
}