package com.mealchemy.vault.repository;

/* Import libraries */
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import java.util.Optional;
import java.util.List;

/* Import classes */
import com.mealchemy.vault.model.Vault;
import com.mealchemy.shared.enums.VaultType;

@Repository
public interface VaultRepository extends JpaRepository<Vault, Integer>
{
    List<Vault> findByOwnerId(Integer ownerId); 
    Optional<Vault> findByOwnerIdAndVaultType(Integer ownerId, VaultType vaultType);
    List<Vault> findAllByOwnerIdAndVaultType(Integer ownerId, VaultType vaultType);

    // get which vault recipe is in - regardless of membership
    @Query("""
            SELECT DISTINCT folderRecipe.folder.vault
            FROM VaultFolderRecipe folderRecipe
            WHERE folderRecipe.recipe.recipeId = :recipeId
    """)
    Optional<Vault> findVaultByRecipeId(@Param("recipeId") Integer recipeId);
}