package com.mealchemy.vault.controller;

/* Import libraries */
import org.springframework.web.bind.annotation.*;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import java.util.*;
import jakarta.validation.Valid;

/* Import classes */
import com.mealchemy.vault.dto.VaultMemberResponse;
import com.mealchemy.vault.dto.VaultMemberRequest;
import com.mealchemy.vault.service.VaultMemberService;

@RestController
@RequestMapping("/vault")
public class VaultMemberController {
    private final VaultMemberService vaultMemberService;

    public VaultMemberController(VaultMemberService vaultMemberService)
    {
        this.vaultMemberService = vaultMemberService;
    }

    /* Mapping functions */

    // Get
    @GetMapping("/{vaultId}/members/all")
    public List<VaultMemberResponse> getVaultMembersByVaultId(@PathVariable Integer vaultId, @AuthenticationPrincipal String userId)
    {
        return vaultMemberService.getVaultMembersByVaultId(vaultId, Integer.parseInt(userId));
    }

    // Post
    @PostMapping("/{vaultId}/members/create")
    public VaultMemberResponse addVaultMember(@PathVariable Integer vaultId, @Valid @RequestBody VaultMemberRequest request,
        @AuthenticationPrincipal String ownerId)
    {
        return vaultMemberService.addVaultMember(vaultId, request, Integer.parseInt(ownerId));
    }

    // Delete
    @DeleteMapping("/{vaultId}/members/delete")
    public void removeVaultMember(@PathVariable Integer vaultId, @Valid @RequestBody VaultMemberRequest request, @AuthenticationPrincipal String ownerId)
    {
        vaultMemberService.removeVaultMember(vaultId, request, Integer.parseInt(ownerId));
    }
}
