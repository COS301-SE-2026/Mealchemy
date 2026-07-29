package com.mealchemy.vault.controller;
 
/* Import libraries */
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.extension.ExtendWith;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.autoconfigure.web.servlet.WebMvcTest;
import org.springframework.test.context.bean.override.mockito.MockitoBean;
import org.springframework.http.MediaType;
import org.springframework.test.web.servlet.MockMvc;
import org.springframework.test.context.junit.jupiter.SpringExtension;
import org.springframework.security.test.context.support.WithMockUser;
import static org.springframework.security.test.web.servlet.request.SecurityMockMvcRequestPostProcessors.csrf;
 
import java.time.OffsetDateTime;
import java.util.List;
import com.mealchemy.config.JwtUtil;
 
import static org.mockito.ArgumentMatchers.any;
import static org.mockito.ArgumentMatchers.eq;
import static org.mockito.Mockito.*;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.*;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.*;
 
import com.fasterxml.jackson.databind.ObjectMapper;
import org.springframework.web.server.ResponseStatusException;
import org.springframework.http.HttpStatus;
 
/* Import classes */
import com.mealchemy.vault.dto.VaultRequest;
import com.mealchemy.vault.dto.VaultResponse;
import com.mealchemy.vault.service.VaultService;
import com.mealchemy.shared.enums.VaultType;
import com.mealchemy.config.WithMockJwtUser;
 
@ExtendWith(SpringExtension.class)
@WebMvcTest(VaultController.class)
@WithMockJwtUser(userId = "1")
public class VaultControllerTest {
    @Autowired
    private MockMvc mockMvc;
 
    @MockitoBean 
    private JwtUtil jwtUtil;

    @MockitoBean
    private VaultService vaultService;
 
    @Autowired
    private ObjectMapper objectMapper;
 
    private VaultResponse response;
    private VaultRequest request;
 
    @BeforeEach
    void setUp()
    {
        response = new VaultResponse(1, 1, VaultType.SHARED, "Test Vault", OffsetDateTime.now());
 
        request = new VaultRequest(VaultType.SHARED, "Test Vault");
    }
 
    @Test
    void getVaultsByOwnerId_returns200_withList() throws Exception
    {
        when(vaultService.getVaultsByOwnerId(1)).thenReturn(List.of(response));
 
        mockMvc.perform(get("/vaults/owner/vaults")).andExpect(status().isOk()).andExpect(jsonPath("$[0].name").value("Test Vault"));
    }
 
    @Test
    void getVault_returns200_whenFound() throws Exception
    {
        when(vaultService.getVault(1, 1)).thenReturn(response);
 
        mockMvc.perform(get("/vaults/1")).andExpect(status().isOk()).andExpect(jsonPath("$.name").value("Test Vault"));
    }
 
    @Test
    void getVault_returns404_whenNotFound() throws Exception
    {
        when(vaultService.getVault(99, 1)).thenThrow(new ResponseStatusException(HttpStatus.NOT_FOUND, "Vault not found."));
 
        mockMvc.perform(get("/vaults/99")).andExpect(status().isNotFound()).andExpect(jsonPath("$.message").value("Vault not found."));
    }
 
    @Test
    void getVault_returns403_whenNotOwnerOrMember() throws Exception
    {
        when(vaultService.getVault(1, 1)).thenThrow(new ResponseStatusException(HttpStatus.FORBIDDEN, "Only a vault member/owner can view it."));
 
        mockMvc.perform(get("/vaults/1")).andExpect(status().isForbidden()).andExpect(jsonPath("$.message").value("Only a vault member/owner can view it."));
    }
 
    @Test
    void getAccessibleVaults_returns200_withList() throws Exception
    {
        when(vaultService.getAccessibleVaults(1)).thenReturn(List.of(response));
 
        mockMvc.perform(get("/vaults/accessible")).andExpect(status().isOk()).andExpect(jsonPath("$[0].name").value("Test Vault"));
    }
 
    @Test
    void getAccessibleVaults_returns200_withEmptyList() throws Exception
    {
        when(vaultService.getAccessibleVaults(1)).thenReturn(List.of());
 
        mockMvc.perform(get("/vaults/accessible")).andExpect(status().isOk()).andExpect(jsonPath("$").isEmpty());
    }
 
    @Test
    void createVault_returns200_withCreatedVault() throws Exception
    {
        when(vaultService.createVault(any(VaultRequest.class), eq(1))).thenReturn(response);
 
        mockMvc.perform(post("/vaults")
            .with(csrf())
            .contentType(MediaType.APPLICATION_JSON)
            .content(objectMapper.writeValueAsString(request)))
            .andExpect(status().isOk())
            .andExpect(jsonPath("$.name").value("Test Vault"));
    }
 
    @Test
    void createVault_returns400_whenNameBlank() throws Exception
    {
        VaultRequest invalidRequest = new VaultRequest(VaultType.SHARED, "");
 
        mockMvc.perform(post("/vaults")
            .with(csrf())
            .contentType(MediaType.APPLICATION_JSON)
            .content(objectMapper.writeValueAsString(invalidRequest)))
            .andExpect(status().isBadRequest());
    }
 
    @Test
    void createVault_returns403_whenVaultTypeIsPrivate() throws Exception
    {
        VaultRequest privateRequest = new VaultRequest(VaultType.PRIVATE, "Private Vault");
 
        when(vaultService.createVault(any(VaultRequest.class), eq(1)))
            .thenThrow(new ResponseStatusException(HttpStatus.FORBIDDEN, "Users only get one private vault."));
 
        mockMvc.perform(post("/vaults")
            .with(csrf())
            .contentType(MediaType.APPLICATION_JSON)
            .content(objectMapper.writeValueAsString(privateRequest)))
            .andExpect(status().isForbidden())
            .andExpect(jsonPath("$.message").value("Users only get one private vault."));
    }
 
    @Test
    void updateVault_returns200_withUpdatedVault() throws Exception
    {
        when(vaultService.updateVault(eq(1), any(VaultRequest.class), eq(1))).thenReturn(response);
 
        mockMvc.perform(put("/vaults/1")
            .with(csrf())
            .contentType(MediaType.APPLICATION_JSON)
            .content(objectMapper.writeValueAsString(request)))
            .andExpect(status().isOk())
            .andExpect(jsonPath("$.name").value("Test Vault"));
    }
 
    @Test
    void updateVault_returns404_whenNotFound() throws Exception
    {
        when(vaultService.updateVault(eq(99), any(VaultRequest.class), eq(1)))
            .thenThrow(new ResponseStatusException(HttpStatus.NOT_FOUND, "Vault not found."));
 
        mockMvc.perform(put("/vaults/99")
            .with(csrf())
            .contentType(MediaType.APPLICATION_JSON)
            .content(objectMapper.writeValueAsString(request)))
            .andExpect(status().isNotFound())
            .andExpect(jsonPath("$.message").value("Vault not found."));
    }
 
    @Test
    void deleteVault_returns200() throws Exception
    {
        doNothing().when(vaultService).deleteVault(1, 1);
 
        mockMvc.perform(delete("/vaults/1").with(csrf()))
            .andExpect(status().isOk());
    }
 
    @Test
    void deleteVault_returns403_whenPrivateVault() throws Exception
    {
        doThrow(new ResponseStatusException(HttpStatus.FORBIDDEN, "Private vaults can't be deleted."))
            .when(vaultService).deleteVault(1, 1);
 
        mockMvc.perform(delete("/vaults/1").with(csrf()))
            .andExpect(status().isForbidden())
            .andExpect(jsonPath("$.message").value("Private vaults can't be deleted."));
    }
}