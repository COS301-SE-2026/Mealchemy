package com.mealchemy.vault.service;

/* Import libraries */
import org.springframework.stereotype.Service;

/* Import classes */
import com.mealchemy.vault.model.Vault;
import com.mealchemy.vault.dto.VaultResponse;
import com.mealchemy.vault.repository.VaultRepository;

@Service
public class VaultService
{   
    private final VaultRepository vaultRepository;

    public VaultService(VaultRepository vaultRepository)
    {
        this.vaultRepository = vaultRepository;
    }

    /* Mapping functions */

    private VaultResponse mapToResponseDto(Vault vaultIn)
    {
        VaultResponse response = new VaultResponse();

        response.setVaultId(vaultIn.getVaultId())
        response.setOwnerId(vaultIn.getOwnerId);
        response.setVaultType(vaultIn.getVaultType());
        response.setName(vaultIn.getName());
        response.setCreatedAt(vaultIn.getCreatedAt());

        return response;
    }
}