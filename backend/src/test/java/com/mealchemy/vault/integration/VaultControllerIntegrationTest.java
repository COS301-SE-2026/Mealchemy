package com.mealchemy.vault.integration;

import com.mealchemy.auth.model.User;
import com.mealchemy.auth.repository.UserRepository;
import com.mealchemy.vault.dto.VaultRequest;
import com.mealchemy.vault.model.Vault;
import com.mealchemy.vault.model.VaultMember;
import com.mealchemy.vault.repository.VaultMemberRepository;
import com.mealchemy.vault.repository.VaultRepository;
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

import static org.hamcrest.Matchers.greaterThan;
import static org.hamcrest.Matchers.hasSize;
import static org.hamcrest.Matchers.is;
import static org.hamcrest.Matchers.notNullValue;
import static org.springframework.security.test.web.servlet.request.SecurityMockMvcRequestPostProcessors.authentication;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.*;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.jsonPath;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.status;
import static org.springframework.security.test.web.servlet.request.SecurityMockMvcRequestPostProcessors.csrf;
import org.springframework.http.MediaType;

@SpringBootTest
@AutoConfigureMockMvc
@ActiveProfiles("test")
public class VaultControllerIntegrationTest {

    @Autowired
    private MockMvc mockMvc;

    @Autowired
    private VaultRepository vaultRepository;

    @Autowired
    private VaultMemberRepository vaultMemberRepository;

    @Autowired
    private UserRepository userRepository;

    @Autowired
    private ObjectMapper objectMapper;

    private User owner;
    private User otherUser;

    private Vault ownedVault;
    private Vault memberVault;

    @BeforeEach
    void setUp() {
        vaultMemberRepository.deleteAll();
        vaultRepository.deleteAll();
        userRepository.deleteAll();

        owner = new User();
        owner.setEmail("owner@mealchemy.com");
        owner.setPasswordHash("hashed-password");
        owner.setRoles(List.of("USER"));
        owner = userRepository.save(owner);

        otherUser = new User();
        otherUser.setEmail("other@mealchemy.com");
        otherUser.setPasswordHash("hashed-password");
        otherUser.setRoles(List.of("USER"));
        otherUser = userRepository.save(otherUser);

        ownedVault = new Vault();
        ownedVault.setOwnerId(owner.getUserId());
        ownedVault.setVaultType(VaultType.SHARED);
        ownedVault.setName("Owner's Vault");
        ownedVault = vaultRepository.save(ownedVault);

        memberVault = new Vault();
        memberVault.setOwnerId(otherUser.getUserId());
        memberVault.setVaultType(VaultType.SHARED);
        memberVault.setName("Shared Vault");
        memberVault = vaultRepository.save(memberVault);

        VaultMember membership = new VaultMember();
        membership.setVault(memberVault);
        membership.setUser(owner);
        vaultMemberRepository.save(membership);
    }

    private UsernamePasswordAuthenticationToken authAs(User user) {
        return new UsernamePasswordAuthenticationToken(
                String.valueOf(user.getUserId()),
                null,
                List.of()
        );
    }

    /* getVaultsByOwnerId */

    @Test
    void getVaultsByOwnerId_returnsVaultsOwnedByAuthenticatedUser() throws Exception {
        mockMvc.perform(get("/vaults/owner/vaults")
                        .with(authentication(authAs(owner))))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$", hasSize(1)))
                .andExpect(jsonPath("$[0].vaultId", is(ownedVault.getVaultId())))
                .andExpect(jsonPath("$[0].ownerId", is(owner.getUserId())))
                .andExpect(jsonPath("$[0].name", is("Owner's Vault")))
                .andExpect(jsonPath("$[0].vaultType", is("SHARED")))
                .andExpect(jsonPath("$[0].createdAt", notNullValue()));
    }

    /* getVault */

    @Test
    void getVault_returnsVault_whenAuthenticatedUserIsOwner() throws Exception {
        mockMvc.perform(get("/vaults/{id}", ownedVault.getVaultId())
                        .with(authentication(authAs(owner))))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.vaultId", is(ownedVault.getVaultId())))
                .andExpect(jsonPath("$.name", is("Owner's Vault")));
    }

    @Test
    void getVault_returnsVault_whenAuthenticatedUserIsMember() throws Exception {
        mockMvc.perform(get("/vaults/{id}", memberVault.getVaultId())
                        .with(authentication(authAs(owner))))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.vaultId", is(memberVault.getVaultId())))
                .andExpect(jsonPath("$.name", is("Shared Vault")));
    }

    @Test
    void getVault_returns404_whenVaultDoesNotExist() throws Exception {
        mockMvc.perform(get("/vaults/{id}", 999999)
                        .with(authentication(authAs(owner))))
                .andExpect(status().isNotFound())
                .andExpect(jsonPath("$.message", is("Vault not found.")));
    }

    @Test
    void getVault_returns403_whenNotOwnerOrMember() throws Exception {
        mockMvc.perform(get("/vaults/{id}", ownedVault.getVaultId())
                        .with(authentication(authAs(otherUser))))
                .andExpect(status().isForbidden())
                .andExpect(jsonPath("$.message", is("Only a vault member/owner can view it.")));
    }

    /* getAccessibleVaults */

    @Test
    void getAccessibleVaults_returnsOwnedAndMemberVaults() throws Exception {
        mockMvc.perform(get("/vaults/accessible")
                        .with(authentication(authAs(owner))))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$", hasSize(2)));
    }

    @Test
    void getAccessibleVaults_returnsEmptyList_whenUserHasNoVaults() throws Exception {
        User isolatedUser = new User();
        isolatedUser.setEmail("isolated@mealchemy.com");
        isolatedUser.setPasswordHash("hashed-password");
        isolatedUser.setRoles(List.of("USER"));
        isolatedUser = userRepository.save(isolatedUser);

        mockMvc.perform(get("/vaults/accessible")
                        .with(authentication(authAs(isolatedUser))))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$").isEmpty());
    }

    /* createVault */

    @Test
    void createVault_createsVaultForAuthenticatedUser() throws Exception {
        VaultRequest request = new VaultRequest(VaultType.SHARED, "New Vault");

        mockMvc.perform(post("/vaults")
                        .with(authentication(authAs(owner)))
                        .with(csrf())
                        .contentType(MediaType.APPLICATION_JSON)
                        .content(objectMapper.writeValueAsString(request)))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.vaultId", notNullValue()))
                .andExpect(jsonPath("$.ownerId", is(owner.getUserId())))
                .andExpect(jsonPath("$.name", is("New Vault")))
                .andExpect(jsonPath("$.vaultType", is("SHARED")))
                .andExpect(jsonPath("$.createdAt", notNullValue()));

        List<Vault> ownersVaults = vaultRepository.findByOwnerId(owner.getUserId());
        org.junit.jupiter.api.Assertions.assertEquals(2, ownersVaults.size());
    }

    @Test
    void createVault_returns400_whenNameBlank() throws Exception {
        VaultRequest request = new VaultRequest(VaultType.SHARED, "");

        mockMvc.perform(post("/vaults")
                        .with(authentication(authAs(owner)))
                        .with(csrf())
                        .contentType(MediaType.APPLICATION_JSON)
                        .content(objectMapper.writeValueAsString(request)))
                .andExpect(status().isBadRequest())
                .andExpect(jsonPath("$.message", is("name: must not be blank")));
    }

    @Test
    void createVault_returns403_whenVaultTypeIsPrivate() throws Exception {
        VaultRequest request = new VaultRequest(VaultType.PRIVATE, "Private Vault");

        mockMvc.perform(post("/vaults")
                        .with(authentication(authAs(owner)))
                        .with(csrf())
                        .contentType(MediaType.APPLICATION_JSON)
                        .content(objectMapper.writeValueAsString(request)))
                .andExpect(status().isForbidden())
                .andExpect(jsonPath("$.message", is("Users only get one private vault.")));
    }

    /* updateVault */

    @Test
    void updateVault_updatesNameAndType_whenAuthenticatedUserIsOwner() throws Exception {
        VaultRequest request = new VaultRequest(VaultType.SHARED, "Renamed Vault");

        mockMvc.perform(put("/vaults/{id}", ownedVault.getVaultId())
                        .with(authentication(authAs(owner)))
                        .with(csrf())
                        .contentType(MediaType.APPLICATION_JSON)
                        .content(objectMapper.writeValueAsString(request)))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.vaultId", is(ownedVault.getVaultId())))
                .andExpect(jsonPath("$.name", is("Renamed Vault")));

        Vault updatedVault = vaultRepository.findById(ownedVault.getVaultId())
                .orElseThrow(() -> new IllegalStateException("Updated vault was not found"));
        org.junit.jupiter.api.Assertions.assertEquals("Renamed Vault", updatedVault.getName());
    }

    @Test
    void updateVault_returns404_whenVaultDoesNotExist() throws Exception {
        VaultRequest request = new VaultRequest(VaultType.SHARED, "Renamed Vault");

        mockMvc.perform(put("/vaults/{id}", 999999)
                        .with(authentication(authAs(owner)))
                        .with(csrf())
                        .contentType(MediaType.APPLICATION_JSON)
                        .content(objectMapper.writeValueAsString(request)))
                .andExpect(status().isNotFound())
                .andExpect(jsonPath("$.message", is("Vault not found.")));
    }

    @Test
    void updateVault_returns403_whenAuthenticatedUserIsNotOwner() throws Exception {
        VaultRequest request = new VaultRequest(VaultType.SHARED, "Renamed Vault");

        mockMvc.perform(put("/vaults/{id}", ownedVault.getVaultId())
                        .with(authentication(authAs(otherUser)))
                        .with(csrf())
                        .contentType(MediaType.APPLICATION_JSON)
                        .content(objectMapper.writeValueAsString(request)))
                .andExpect(status().isForbidden())
                .andExpect(jsonPath("$.message", is("Vault can only be edited by the owner.")));
    }

    @Test
    void updateVault_returns403_whenVaultTypeIsPrivate() throws Exception {
        VaultRequest request = new VaultRequest(VaultType.PRIVATE, "Renamed Vault");

        mockMvc.perform(put("/vaults/{id}", ownedVault.getVaultId())
                        .with(authentication(authAs(owner)))
                        .with(csrf())
                        .contentType(MediaType.APPLICATION_JSON)
                        .content(objectMapper.writeValueAsString(request)))
                .andExpect(status().isForbidden())
                .andExpect(jsonPath("$.message", is("Users only get one private vault.")));
    }

    /* deleteVault */

    @Test
    void deleteVault_deletesVault_whenAuthenticatedUserIsOwner() throws Exception {
        mockMvc.perform(delete("/vaults/{id}", ownedVault.getVaultId())
                        .with(authentication(authAs(owner)))
                        .with(csrf()))
                .andExpect(status().isNoContent());

        org.junit.jupiter.api.Assertions.assertFalse(
                vaultRepository.findById(ownedVault.getVaultId()).isPresent()
        );
    }

    @Test
    void deleteVault_returns403_whenAuthenticatedUserIsNotOwner() throws Exception {
        mockMvc.perform(delete("/vaults/{id}", ownedVault.getVaultId())
                        .with(authentication(authAs(otherUser)))
                        .with(csrf()))
                .andExpect(status().isForbidden())
                .andExpect(jsonPath("$.message", is("Vaults can only be deleted be the owner.")));

        org.junit.jupiter.api.Assertions.assertTrue(
                vaultRepository.findById(ownedVault.getVaultId()).isPresent()
        );
    }

    @Test
    void deleteVault_returns403_whenVaultTypeIsPrivate() throws Exception {
        ownedVault.setVaultType(VaultType.PRIVATE);
        vaultRepository.save(ownedVault);

        mockMvc.perform(delete("/vaults/{id}", ownedVault.getVaultId())
                        .with(authentication(authAs(owner)))
                        .with(csrf()))
                .andExpect(status().isForbidden())
                .andExpect(jsonPath("$.message", is("Private vaults can't be deleted.")));

        org.junit.jupiter.api.Assertions.assertTrue(
                vaultRepository.findById(ownedVault.getVaultId()).isPresent()
        );
    }
}
