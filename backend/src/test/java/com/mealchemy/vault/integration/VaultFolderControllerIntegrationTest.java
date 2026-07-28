package com.mealchemy.vault.controller;

import com.mealchemy.auth.model.User;
import com.mealchemy.auth.repository.UserRepository;
import com.mealchemy.vault.model.Vault;
import com.mealchemy.vault.model.VaultFolder;
import com.mealchemy.vault.model.VaultMember;
import com.mealchemy.vault.repository.VaultFolderRepository;
import com.mealchemy.vault.repository.VaultMemberRepository;
import com.mealchemy.vault.repository.VaultRepository;
import com.mealchemy.vault.dto.VaultFolderRequest;
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
public class VaultFolderControllerIntegrationTest {

    @Autowired
    private MockMvc mockMvc;

    @Autowired
    private VaultFolderRepository vaultFolderRepository;

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
    private Vault privateVault;
    private Vault sharedVault;

    @BeforeEach
    void setUp() {
        // clear in FK-safe order: folders/members first, then vaults, then users
        vaultFolderRepository.deleteAll();
        vaultMemberRepository.deleteAll();
        vaultRepository.deleteAll();
        userRepository.deleteAll();

        owner = newUser("owner@gmail.com");
        member = newUser("member@gmail.com");
        outsider = newUser("outsider@gmail.com");

        privateVault = newVault(owner.getUserId(), VaultType.PRIVATE, "Owner's Private Vault");
        sharedVault = newVault(owner.getUserId(), VaultType.SHARED, "Shared Test Vault");

        VaultMember memberRow = new VaultMember();
        memberRow.setVault(sharedVault);
        memberRow.setUser(member);
        vaultMemberRepository.save(memberRow);
    }

    private User newUser(String email) {
        User user = new User();
        user.setEmail(email);
        user.setPasswordHash("hashed-password");
        user.setRoles(List.of("USER"));
        return userRepository.save(user);
    }

    private Vault newVault(Integer ownerId, VaultType type, String name) {
        Vault vault = new Vault();
        vault.setOwnerId(ownerId);
        vault.setVaultType(type);
        vault.setName(name);
        return vaultRepository.save(vault);
    }

    private VaultFolder newFolder(Vault vault, String folderName) {
        VaultFolder folder = new VaultFolder();
        folder.setVault(vault);
        folder.setFolderName(folderName);
        return vaultFolderRepository.save(folder);
    }

    private UsernamePasswordAuthenticationToken authAs(Integer userId) {
        return new UsernamePasswordAuthenticationToken(String.valueOf(userId), null, List.of());
    }

    /* getPrivateVaultFolders */

    @Test
    void getPrivateVaultFolders_returns200_withList() throws Exception {
        newFolder(privateVault, "General");

        mockMvc.perform(get("/folders/vault/private")
                        .with(authentication(authAs(owner.getUserId()))))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$", hasSize(1)))
                .andExpect(jsonPath("$[0].folderName", is("General")))
                .andExpect(jsonPath("$[0].vaultId", is(privateVault.getVaultId())));
    }

    @Test
    void getPrivateVaultFolders_returns404_whenPrivateVaultNotFound() throws Exception {
        // outsider has no private vault created for them
        mockMvc.perform(get("/folders/vault/private")
                        .with(authentication(authAs(outsider.getUserId()))))
                .andExpect(status().isNotFound())
                .andExpect(jsonPath("$.message").value("Private vault not found."));
    }

    /* getVaultFolderByVaultId */

    @Test
    void getVaultFolderByVaultId_returns200_whenOwner() throws Exception {
        newFolder(sharedVault, "General");

        mockMvc.perform(get("/folders/vault/{vaultId}", sharedVault.getVaultId())
                        .with(authentication(authAs(owner.getUserId()))))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$", hasSize(1)))
                .andExpect(jsonPath("$[0].folderName", is("General")));
    }

    @Test
    void getVaultFolderByVaultId_returns200_whenMember() throws Exception {
        newFolder(sharedVault, "General");

        mockMvc.perform(get("/folders/vault/{vaultId}", sharedVault.getVaultId())
                        .with(authentication(authAs(member.getUserId()))))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$", hasSize(1)));
    }

    @Test
    void getVaultFolderByVaultId_returns403_whenNotOwnerOrMember() throws Exception {
        newFolder(sharedVault, "General");

        mockMvc.perform(get("/folders/vault/{vaultId}", sharedVault.getVaultId())
                        .with(authentication(authAs(outsider.getUserId()))))
                .andExpect(status().isForbidden())
                .andExpect(jsonPath("$.message").value("Only a vault member/owner can view the folders."));
    }

    @Test
    void getVaultFolderByVaultId_returns404_whenVaultNotFound() throws Exception {
        mockMvc.perform(get("/folders/vault/{vaultId}", 999999)
                        .with(authentication(authAs(owner.getUserId()))))
                .andExpect(status().isNotFound())
                .andExpect(jsonPath("$.message").value("Vault not found."));
    }

    /* getVaultFolderByName */

    @Test
    void getVaultFolderByName_returns200_whenFound() throws Exception {
        newFolder(sharedVault, "General");

        mockMvc.perform(get("/folders/{vaultId}/folder/name/{name}", sharedVault.getVaultId(), "General")
                        .with(authentication(authAs(owner.getUserId()))))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.folderName", is("General")));
    }

    @Test
    void getVaultFolderByName_returns404_whenNotFound() throws Exception {
        mockMvc.perform(get("/folders/{vaultId}/folder/name/{name}", sharedVault.getVaultId(), "Missing")
                        .with(authentication(authAs(owner.getUserId()))))
                .andExpect(status().isNotFound())
                .andExpect(jsonPath("$.message").value("Folder not found."));
    }

    /* getVaultFolderById */

    @Test
    void getVaultFolderById_returns200_whenFound() throws Exception {
        VaultFolder folder = newFolder(sharedVault, "General");

        mockMvc.perform(get("/folders/{vaultId}/folder/{id}", sharedVault.getVaultId(), folder.getFolderId())
                        .with(authentication(authAs(owner.getUserId()))))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.folderName", is("General")));
    }

    @Test
    void getVaultFolderById_returns404_whenNotFound() throws Exception {
        mockMvc.perform(get("/folders/{vaultId}/folder/{id}", sharedVault.getVaultId(), 999999)
                        .with(authentication(authAs(owner.getUserId()))))
                .andExpect(status().isNotFound())
                .andExpect(jsonPath("$.message").value("Folder not found."));
    }

    /* createVaultFolder */

    @Test
    void createVaultFolder_returns200_withCreatedFolder() throws Exception {
        VaultFolderRequest request = new VaultFolderRequest(sharedVault.getVaultId(), "NewFolder");

        mockMvc.perform(post("/folders")
                        .with(authentication(authAs(owner.getUserId())))
                        .with(csrf())
                        .contentType(MediaType.APPLICATION_JSON)
                        .content(objectMapper.writeValueAsString(request)))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.folderName", is("NewFolder")))
                .andExpect(jsonPath("$.vaultId", is(sharedVault.getVaultId())))
                .andExpect(jsonPath("$.createdAt", notNullValue()));

        List<VaultFolder> savedRows = vaultFolderRepository.findByVault_VaultId(sharedVault.getVaultId());
        org.junit.jupiter.api.Assertions.assertEquals(1, savedRows.size());
        org.junit.jupiter.api.Assertions.assertEquals("NewFolder", savedRows.get(0).getFolderName());
    }

    @Test
    void createVaultFolder_returns400_whenFolderNameBlank() throws Exception {
        VaultFolderRequest invalidRequest = new VaultFolderRequest(sharedVault.getVaultId(), "");

        mockMvc.perform(post("/folders")
                        .with(authentication(authAs(owner.getUserId())))
                        .with(csrf())
                        .contentType(MediaType.APPLICATION_JSON)
                        .content(objectMapper.writeValueAsString(invalidRequest)))
                .andExpect(status().isBadRequest());
    }

    @Test
    void createVaultFolder_returns403_whenNotOwner() throws Exception {
        VaultFolderRequest request = new VaultFolderRequest(sharedVault.getVaultId(), "NewFolder");

        mockMvc.perform(post("/folders")
                        .with(authentication(authAs(outsider.getUserId())))
                        .with(csrf())
                        .contentType(MediaType.APPLICATION_JSON)
                        .content(objectMapper.writeValueAsString(request)))
                .andExpect(status().isForbidden())
                .andExpect(jsonPath("$.message").value("Only a vault owner can modify folders."));
    }

    @Test
    void createVaultFolder_returns404_whenVaultNotFound() throws Exception {
        VaultFolderRequest request = new VaultFolderRequest(999999, "NewFolder");

        mockMvc.perform(post("/folders")
                        .with(authentication(authAs(owner.getUserId())))
                        .with(csrf())
                        .contentType(MediaType.APPLICATION_JSON)
                        .content(objectMapper.writeValueAsString(request)))
                .andExpect(status().isNotFound())
                .andExpect(jsonPath("$.message").value("Vault not found."));
    }

    /* updateVaultFolder */

    @Test
    void updateVaultFolder_returns200_withUpdatedFolder() throws Exception {
        VaultFolder folder = newFolder(sharedVault, "General");
        VaultFolderRequest request = new VaultFolderRequest(sharedVault.getVaultId(), "Renamed");

        mockMvc.perform(put("/folders/{id}", folder.getFolderId())
                        .with(authentication(authAs(owner.getUserId())))
                        .with(csrf())
                        .contentType(MediaType.APPLICATION_JSON)
                        .content(objectMapper.writeValueAsString(request)))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.folderName", is("Renamed")));

        VaultFolder updated = vaultFolderRepository.findById(folder.getFolderId())
                .orElseThrow(() -> new IllegalStateException("Folder disappeared"));
        org.junit.jupiter.api.Assertions.assertEquals("Renamed", updated.getFolderName());
    }

    @Test
    void updateVaultFolder_returns403_whenNotOwner() throws Exception {
        VaultFolder folder = newFolder(sharedVault, "General");
        VaultFolderRequest request = new VaultFolderRequest(sharedVault.getVaultId(), "Renamed");

        mockMvc.perform(put("/folders/{id}", folder.getFolderId())
                        .with(authentication(authAs(outsider.getUserId())))
                        .with(csrf())
                        .contentType(MediaType.APPLICATION_JSON)
                        .content(objectMapper.writeValueAsString(request)))
                .andExpect(status().isForbidden())
                .andExpect(jsonPath("$.message").value("Only a vault owner can modify folders."));
    }

    @Test
    void updateVaultFolder_returns404_whenFolderNotFound() throws Exception {
        VaultFolderRequest request = new VaultFolderRequest(sharedVault.getVaultId(), "Renamed");

        mockMvc.perform(put("/folders/{id}", 999999)
                        .with(authentication(authAs(owner.getUserId())))
                        .with(csrf())
                        .contentType(MediaType.APPLICATION_JSON)
                        .content(objectMapper.writeValueAsString(request)))
                .andExpect(status().isNotFound())
                .andExpect(jsonPath("$.message").value("Folder not found."));
    }

    @Test
    void updateVaultFolder_returns404_whenVaultNotFound() throws Exception {
        VaultFolder folder = newFolder(sharedVault, "General");
        VaultFolderRequest request = new VaultFolderRequest(999999, "Renamed");

        mockMvc.perform(put("/folders/{id}", folder.getFolderId())
                        .with(authentication(authAs(owner.getUserId())))
                        .with(csrf())
                        .contentType(MediaType.APPLICATION_JSON)
                        .content(objectMapper.writeValueAsString(request)))
                .andExpect(status().isNotFound())
                .andExpect(jsonPath("$.message").value("Vault not found."));
    }

    /* deleteVaultFolder */

    @Test
    void deleteVaultFolder_returns200_andDeletesRow() throws Exception {
        VaultFolder folder = newFolder(sharedVault, "General");

        mockMvc.perform(delete("/folders/vault/{vaultId}/folder/{id}", sharedVault.getVaultId(), folder.getFolderId())
                        .with(authentication(authAs(owner.getUserId())))
                        .with(csrf()))
                .andExpect(status().isOk());

        org.junit.jupiter.api.Assertions.assertTrue(vaultFolderRepository.findById(folder.getFolderId()).isEmpty());
    }

    @Test
    void deleteVaultFolder_returns403_whenNotOwner() throws Exception {
        VaultFolder folder = newFolder(sharedVault, "General");

        mockMvc.perform(delete("/folders/vault/{vaultId}/folder/{id}", sharedVault.getVaultId(), folder.getFolderId())
                        .with(authentication(authAs(outsider.getUserId())))
                        .with(csrf()))
                .andExpect(status().isForbidden())
                .andExpect(jsonPath("$.message").value("Only a vault owner can modify folders."));

        org.junit.jupiter.api.Assertions.assertTrue(vaultFolderRepository.findById(folder.getFolderId()).isPresent());
    }

    @Test
    void deleteVaultFolder_returns404_whenVaultNotFound() throws Exception {
        mockMvc.perform(delete("/folders/vault/{vaultId}/folder/{id}", 999999, 1)
                        .with(authentication(authAs(owner.getUserId())))
                        .with(csrf()))
                .andExpect(status().isNotFound())
                .andExpect(jsonPath("$.message").value("Vault not found."));
    }
}