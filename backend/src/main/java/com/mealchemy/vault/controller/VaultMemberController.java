package com.mealchemy.vault.controller;

/* Import libraries */
import org.springframework.web.bind.annotation.*;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import java.util.*;
import java.validation.Valid;

/* Import classes */
import com.mealchemy.vault.dto.VaultMemberResponse;
import com.mealchemy.vault.dto.VaultMemberRequest;
import com.mealchemy.vault.service.VaultMemberService;

@RestController
@RequestMapping("/vaultmember")
public class VaultMemberController {
    private final VaultMemberService vaultMemberService;

    public VaultMemberController(VaultMemberService vaultMemberService)
    {
        this.vaultMemberService = vaultMemberService;
    }

    /* Mapping functions */

    // Get
    @GetMapping("/vault/{vaultId}/all")
    public List<VaultMemberResponse> getVaultMembersByVaultId(@PathVariable Integer vaultId, @AuthenticationPrincipal Integer userId)
    {
        return vaultMemberService.getVaultMembersByVaultId(vaultId, userId);
    }

    // Post
    @PostMapping("/vault/{vaultId}/create")
    public VaultMemberResponse addVaultMember(@PathVariable Integer vaultId, @Valid @RequestBody VaultMemberRequest request, @AuthenticationPrincipal Integer ownerId)
    {
        return vaultMemberService.addVaultMember(vaultId, request, ownerId);
    }

    // Delete
    @DeleteMapping("/vault/{vaultId}/delete")
    public void removeVaultMember(@PathVariable Integer vaultId, @Valid, @RequestBody VaultMemberRequest request, @AuthenticationPrincipal Integer ownerId)
    {
        vaultMemberService.removeVaultMember(vaultId, request, ownerId);
    }
}
