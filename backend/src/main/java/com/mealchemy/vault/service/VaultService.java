package com.mealchemy.vault.service;

/* Import libraries */
import org.springframework.stereotype.Service;
import java.util.stream.Collectors;
import java.util.List;

/* Import classes */
import com.mealchemy.vault.model.Vault;
import com.mealchemy.vault.dto.VaultResponse;
import com.mealchemy.vault.dto.VaultRequest;
import com.mealchemy.vault.repository.VaultRepository;

@Service
public class VaultService
{   
    private final VaultRepository vaultRepository;

    public VaultService(VaultRepository vaultRepository)
    {
        this.vaultRepository = vaultRepository;
    }

    // Get all vaults that beint to ownerId
    public List<VaultResponse> getVaultsByOwnerId(Integer ownerId)
    {
        return vaultRepository.findByOwnerId(ownerId).stream().map(VaultResponse::from).collect(Collectors.toList());
    }

    // Get a single vault using id
    public VaultResponse getVault(int id)
    {
        Vault vaultForReturn = vaultRepository.findById(id).orElseThrow(() -> new RuntimeException("Vault not found."));
        return VaultResponse.from(vaultForReturn);
    }

    // Post to create a new vault
    public VaultResponse createVault(VaultRequest request, Integer ownerId)
    {
        Vault vaultForReturn = mapRequestToEntity(request, ownerId);
        return VaultResponse.from(vaultRepository.save(vaultForReturn));
    }

    // Put to update an existing vault
    public VaultResponse updateVault(int id, VaultRequest request, Integer ownerId)
    {
        Vault vaultForReturn = vaultRepository.findById(id).orElseThrow(() -> new RuntimeException("Vault not found."));

        vaultForReturn.setOwnerId(ownerId);
        vaultForReturn.setVaultType(request.vaultType());
        vaultForReturn.setName(request.name());

        return VaultResponse.from(vaultRepository.save(vaultForReturn));
    }

    // Delete a specific vault using id
    public void deleteVault(int id)
    {
        vaultRepository.deleteById(id);
    }

    /* Mapping functions */

    private Vault mapRequestToEntity(VaultRequest request, Integer ownerId)
    {
        Vault vault = new Vault();

        vault.setOwnerId(ownerId);
        vault.setVaultType(request.vaultType());
        vault.setName(request.name());

        return vault;
    }
}