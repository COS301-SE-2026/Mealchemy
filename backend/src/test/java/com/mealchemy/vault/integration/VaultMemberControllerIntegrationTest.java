package com.mealchemy.vault.integration;

import com.mealchemy.auth.model.User;
import com.mealchemy.auth.repository.UserRepository;
import com.mealchemy.vault.model.Vault;
import com.mealchemy.vault.model.VaultMember;
import com.mealchemy.vault.repository.VaultMemberRepository;
import com.mealchemy.vault.repository.VaultRepository;
import com.mealchemy.vault.dto.VaultMemberRequest;
import com.mealchemy.shared.enums.VaultType;
import com.fasterxml.jackson.databind.ObjectMapper;

import java.util.List;

import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.autoconfigure.web.servlet.AutoConfigureMockMvc;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.security.authentication.UsernamePasswordAuthenticationToken;
import org.springframework.test.context.ActiveProfiles;
import org.springframework.test.web.servlet.MockMvc;
import org.springframework.http.MediaType;

import static org.hamcrest.Matchers.hasSize;
import static org.hamcrest.Matchers.is;
import static org.hamcrest.Matchers.notNullValue;
import static org.springframework.security.test.web.servlet.request.SecurityMockMvcRequestPostProcessors.authentication;
import static org.springframework.security.test.web.servlet.request.SecurityMockMvcRequestPostProcessors.csrf;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.*;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.jsonPath;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.status;

@SpringBootTest
@AutoConfigureMockMvc
@ActiveProfiles("test")
public class VaultMemberControllerIntegrationTest {

    @Autowired
    private MockMvc mockMvc;

    @Autowired
    private VaultMemberRepository vaultMemberRepository;

    @Autowired
    private VaultRepository vaultRepository;

    @Autowired
    private UserRepository userRepository;

    @Autowired
    private ObjectMapper objectMapper;

    private User owner;
    private User member;
    private User outsider;
    private Vault sharedVault;

    @BeforeEach
    void setUp() {
        vaultMemberRepository.deleteAll();
        vaultRepository.deleteAll();
        userRepository.deleteAll();

        owner = newUser("owner@gmail.com");
        member = newUser("member@gmail.com");
        outsider = newUser("outsider@gmail.com");

        sharedVault = new Vault();
        sharedVault.setOwnerId(owner.getUserId());
        sharedVault.setVaultType(VaultType.SHARED);
        sharedVault.setName("Shared Test Vault");
        sharedVault = vaultRepository.save(sharedVault);
    }

    private User newUser(String email) {
        User user = new User();
        user.setEmail(email);
        user.setPasswordHash("hashed-password");
        user.setRoles(List.of("USER"));
        return userRepository.save(user);
    }

    private VaultMember addMemberRow(Vault vault, User user) {
        VaultMember vaultMember = new VaultMember();
        vaultMember.setVault(vault);
        vaultMember.setUser(user);
        return vaultMemberRepository.save(vaultMember);
    }

    private UsernamePasswordAuthenticationToken authAs(Integer userId) {
        return new UsernamePasswordAuthenticationToken(String.valueOf(userId), null, List.of());
    }

    @Test
    void getVaultMembersByVaultId_returns200_whenOwner() throws Exception {
        addMemberRow(sharedVault, member);

        mockMvc.perform(get("/vault/{vaultId}/members/all", sharedVault.getVaultId())
                .with(authentication(authAs(owner.getUserId()))))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$", hasSize(2)))
            .andExpect(jsonPath("$[0].userId", is(owner.getUserId())))
            .andExpect(jsonPath("$[0].id").doesNotExist())
            .andExpect(jsonPath("$[1].userId", is(member.getUserId())))
            .andExpect(jsonPath("$[1].vaultId", is(sharedVault.getVaultId())))
            .andExpect(jsonPath("$[1].joinedAt", notNullValue()));
    }

    @Test
    void getVaultMembersByVaultId_returns200_whenMember() throws Exception {
        addMemberRow(sharedVault, member);

        mockMvc.perform(get("/vault/{vaultId}/members/all", sharedVault.getVaultId())
                .with(authentication(authAs(member.getUserId()))))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$", hasSize(2)))
                .andExpect(jsonPath("$[0].userId", is(owner.getUserId())))
                .andExpect(jsonPath("$[1].userId", is(member.getUserId())));
    }

    @Test
    void getVaultMembersByVaultId_returns404_whenNotOwnerOrMember() throws Exception {
        addMemberRow(sharedVault, member);

        mockMvc.perform(get("/vault/{vaultId}/members/all", sharedVault.getVaultId())
                .with(authentication(authAs(outsider.getUserId()))))
                .andExpect(status().isNotFound())
                .andExpect(jsonPath("$.message").value("Vault not found."));
    }

    @Test
    void getVaultMembersByVaultId_returns404_whenVaultNotFound() throws Exception {
        mockMvc.perform(get("/vault/{vaultId}/members/all", 999999)
                .with(authentication(authAs(owner.getUserId()))))
                .andExpect(status().isNotFound())
                .andExpect(jsonPath("$.message").value("Vault not found."));
    }

    @Test
    void removeVaultMember_returns204_andDeletesRow() throws Exception {
        addMemberRow(sharedVault, member);

        mockMvc.perform(delete("/vault/{vaultId}/members/{userId}", sharedVault.getVaultId(), member.getUserId())
                        .with(authentication(authAs(owner.getUserId())))
                        .with(csrf()))
                .andExpect(status().isNoContent());

        org.junit.jupiter.api.Assertions.assertTrue(
                vaultMemberRepository.findByVault_VaultIdAndUser_UserId(sharedVault.getVaultId(), member.getUserId()).isEmpty()
        );
    }

    @Test
    void removeVaultMember_returns404_whenNotOwner() throws Exception {
        addMemberRow(sharedVault, member);

        mockMvc.perform(delete("/vault/{vaultId}/members/{userId}", sharedVault.getVaultId(), member.getUserId())
                        .with(authentication(authAs(outsider.getUserId())))
                        .with(csrf()))
                .andExpect(status().isNotFound())
                .andExpect(jsonPath("$.message").value("Vault not found."));
    }

    @Test
    void removeVaultMember_returns404_whenMemberRowNotFound() throws Exception {
        mockMvc.perform(delete("/vault/{vaultId}/members/{userId}", sharedVault.getVaultId(), member.getUserId())
                        .with(authentication(authAs(owner.getUserId())))
                        .with(csrf()))
                .andExpect(status().isNotFound())
                .andExpect(jsonPath("$.message").value("VaultMember row not found."));
    }
}
