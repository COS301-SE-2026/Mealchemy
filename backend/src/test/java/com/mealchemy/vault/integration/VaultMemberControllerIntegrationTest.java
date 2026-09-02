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
                .andExpect(jsonPath("$", hasSize(1)))
                .andExpect(jsonPath("$[0].userId", is(member.getUserId())))
                .andExpect(jsonPath("$[0].vaultId", is(sharedVault.getVaultId())))
                .andExpect(jsonPath("$[0].joinedAt", notNullValue()));
    }

    @Test
    void getVaultMembersByVaultId_returns200_whenMember() throws Exception {
        addMemberRow(sharedVault, member);

        mockMvc.perform(get("/vault/{vaultId}/members/all", sharedVault.getVaultId())
                        .with(authentication(authAs(member.getUserId()))))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$", hasSize(1)))
                .andExpect(jsonPath("$[0].userId", is(member.getUserId())));
    }

    @Test
    void getVaultMembersByVaultId_returns403_whenNotOwnerOrMember() throws Exception {
        addMemberRow(sharedVault, member);

        mockMvc.perform(get("/vault/{vaultId}/members/all", sharedVault.getVaultId())
                        .with(authentication(authAs(outsider.getUserId()))))
                .andExpect(status().isForbidden())
                .andExpect(jsonPath("$.message").value("Only a member/owner of the vault can view its members."));
    }

    @Test
    void getVaultMembersByVaultId_returns404_whenVaultNotFound() throws Exception {
        mockMvc.perform(get("/vault/{vaultId}/members/all", 999999)
                        .with(authentication(authAs(owner.getUserId()))))
                .andExpect(status().isNotFound())
                .andExpect(jsonPath("$.message").value("Vault not found."));
    }

    @Test
    void addVaultMember_returns200_withCreatedMember() throws Exception {
        VaultMemberRequest request = new VaultMemberRequest(member.getEmail());

        mockMvc.perform(post("/vault/{vaultId}/members/create", sharedVault.getVaultId())
                        .with(authentication(authAs(owner.getUserId())))
                        .with(csrf())
                        .contentType(MediaType.APPLICATION_JSON)
                        .content(objectMapper.writeValueAsString(request)))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.userId", is(member.getUserId())))
                .andExpect(jsonPath("$.vaultId", is(sharedVault.getVaultId())))
                .andExpect(jsonPath("$.joinedAt", notNullValue()));

        List<VaultMember> savedRows = vaultMemberRepository.findByVault_VaultId(sharedVault.getVaultId());
        org.junit.jupiter.api.Assertions.assertEquals(1, savedRows.size());
        org.junit.jupiter.api.Assertions.assertEquals(member.getUserId(), savedRows.get(0).getUser().getUserId());
    }

    @Test
    void addVaultMember_returns403_whenNotOwner() throws Exception {
        VaultMemberRequest request = new VaultMemberRequest(member.getEmail());

        mockMvc.perform(post("/vault/{vaultId}/members/create", sharedVault.getVaultId())
                        .with(authentication(authAs(outsider.getUserId())))
                        .with(csrf())
                        .contentType(MediaType.APPLICATION_JSON)
                        .content(objectMapper.writeValueAsString(request)))
                .andExpect(status().isForbidden())
                .andExpect(jsonPath("$.message").value("Only the owner of the vault can add a new member."));
    }

    @Test
    void addVaultMember_returns403_whenVaultIsPrivate() throws Exception {
        Vault privateVault = new Vault();
        privateVault.setOwnerId(owner.getUserId());
        privateVault.setVaultType(VaultType.PRIVATE);
        privateVault.setName("Private Test Vault");
        privateVault = vaultRepository.save(privateVault);

        VaultMemberRequest request = new VaultMemberRequest(member.getEmail());

        mockMvc.perform(post("/vault/{vaultId}/members/create", privateVault.getVaultId())
                        .with(authentication(authAs(owner.getUserId())))
                        .with(csrf())
                        .contentType(MediaType.APPLICATION_JSON)
                        .content(objectMapper.writeValueAsString(request)))
                .andExpect(status().isForbidden())
                .andExpect(jsonPath("$.message").value("Members can't be added to a private vault."));
    }

    @Test
    void addVaultMember_returns404_whenUserNotFound() throws Exception {
        VaultMemberRequest request = new VaultMemberRequest("doesnotexist@gmail.com");

        mockMvc.perform(post("/vault/{vaultId}/members/create", sharedVault.getVaultId())
                        .with(authentication(authAs(owner.getUserId())))
                        .with(csrf())
                        .contentType(MediaType.APPLICATION_JSON)
                        .content(objectMapper.writeValueAsString(request)))
                .andExpect(status().isNotFound())
                .andExpect(jsonPath("$.message").value("User not found."));
    }

    @Test
    void addVaultMember_returns400_whenEmailBlank() throws Exception {
        VaultMemberRequest invalidRequest = new VaultMemberRequest("");

        mockMvc.perform(post("/vault/{vaultId}/members/create", sharedVault.getVaultId())
                        .with(authentication(authAs(owner.getUserId())))
                        .with(csrf())
                        .contentType(MediaType.APPLICATION_JSON)
                        .content(objectMapper.writeValueAsString(invalidRequest)))
                .andExpect(status().isBadRequest());
    }

    @Test
    void removeVaultMember_returns204_andDeletesRow() throws Exception {
        addMemberRow(sharedVault, member);

        VaultMemberRequest request = new VaultMemberRequest(member.getEmail());

        mockMvc.perform(delete("/vault/{vaultId}/members/delete", sharedVault.getVaultId())
                        .with(authentication(authAs(owner.getUserId())))
                        .with(csrf())
                        .contentType(MediaType.APPLICATION_JSON)
                        .content(objectMapper.writeValueAsString(request)))
                .andExpect(status().isNoContent());

        org.junit.jupiter.api.Assertions.assertTrue(
                vaultMemberRepository.findByVault_VaultIdAndUser_UserId(sharedVault.getVaultId(), member.getUserId()).isEmpty()
        );
    }

    @Test
    void removeVaultMember_returns403_whenNotOwner() throws Exception {
        addMemberRow(sharedVault, member);

        VaultMemberRequest request = new VaultMemberRequest(member.getEmail());

        mockMvc.perform(delete("/vault/{vaultId}/members/delete", sharedVault.getVaultId())
                        .with(authentication(authAs(outsider.getUserId())))
                        .with(csrf())
                        .contentType(MediaType.APPLICATION_JSON)
                        .content(objectMapper.writeValueAsString(request)))
                .andExpect(status().isForbidden())
                .andExpect(jsonPath("$.message").value("Only the owner of the vault can remove a member."));
    }

    @Test
    void removeVaultMember_returns404_whenUserNotFound() throws Exception {
        VaultMemberRequest request = new VaultMemberRequest("doesnotexist@gmail.com");

        mockMvc.perform(delete("/vault/{vaultId}/members/delete", sharedVault.getVaultId())
                        .with(authentication(authAs(owner.getUserId())))
                        .with(csrf())
                        .contentType(MediaType.APPLICATION_JSON)
                        .content(objectMapper.writeValueAsString(request)))
                .andExpect(status().isNotFound())
                .andExpect(jsonPath("$.message").value("User not found."));
    }

    @Test
    void removeVaultMember_returns404_whenMemberRowNotFound() throws Exception {
        VaultMemberRequest request = new VaultMemberRequest(member.getEmail());

        mockMvc.perform(delete("/vault/{vaultId}/members/delete", sharedVault.getVaultId())
                        .with(authentication(authAs(owner.getUserId())))
                        .with(csrf())
                        .contentType(MediaType.APPLICATION_JSON)
                        .content(objectMapper.writeValueAsString(request)))
                .andExpect(status().isNotFound())
                .andExpect(jsonPath("$.message").value("VaultMember row not found."));
    }
}
