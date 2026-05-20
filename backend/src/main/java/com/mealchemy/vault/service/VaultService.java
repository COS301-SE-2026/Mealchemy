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
    public List<VaultResponse> getVaultsByOwnerId(int ownerId)
    {
        return vaultRepository.findByOwnerId(ownerId).stream().map(this::mapToResponseDto).collect(Collectors.toList());
    }

    // Get a single vault using id
    public VaultResponse getVault(int id)
    {
        Vault vaultForReturn = vaultRepository.findById(id).orElseThrow(() -> new RuntimeException("Vault not found."));
        return mapToResponseDto(vaultForReturn);
    }

    // Post to create a new vault
    public VaultResponse createVault(VaultRequest request)
    {
        Vault vaultForReturn = mapRequestToEntity(request);
        return mapToResponseDto(vaultRepository.save(vaultForReturn));
    }

    // Put to update an existing vault
    public VaultResponse updateVault(int id, VaultRequest request)
    {
        Vault vaultForReturn = vaultRepository.findById(id).orElseThrow(() -> new RuntimeException("Vault not found."));

        vaultForReturn.setOwnerId(request.getOwnerId());
        vaultForReturn.setVaultType(request.getVaultType());
        vaultForReturn.setName(request.getName());

        return mapToResponseDto(vaultRepository.save(vaultForReturn));
    }

    // Delete a specific vault using id
    public void deleteVault(int id)
    {
        vaultRepository.deleteById(id);
    }

    /* Mapping functions */

    private VaultResponse mapToResponseDto(Vault vaultIn)
    {
        VaultResponse response = new VaultResponse();

        response.setVaultId(vaultIn.getVaultId());
        response.setOwnerId(vaultIn.getOwnerId());
        response.setVaultType(vaultIn.getVaultType());
        response.setName(vaultIn.getName());
        response.setCreatedAt(vaultIn.getCreatedAt());

        return response;
    }

    private VaultFolder mapRequestToEntity(VaultRequest request)
    {
        Vault vault = new Vault();

        vault.setOwnerId(request.getOwnerId());
        vault.setVaultType(request.getVaultType());
        vault.setName(request.getName());

        return vault;
    }
}