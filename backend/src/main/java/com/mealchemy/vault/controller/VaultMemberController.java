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
}
