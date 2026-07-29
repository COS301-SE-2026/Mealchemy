package com.mealchemy.vault.repository;

/* Import libraries */
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;
import java.util.Optional;
import java.util.List;

/* Import classes */
import com.mealchemy.vault.model.VaultFolder;

@Repository
public interface VaultFolderRepository extends JpaRepository<VaultFolder, Integer> {
    List<VaultFolder> findByVault_VaultId(int vaultId);
    Optional<VaultFolder> findByFolderName(String folderName);
}
