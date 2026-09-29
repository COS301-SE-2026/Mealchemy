package com.mealchemy.vault.controller;

/* Import libraries */
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.extension.ExtendWith;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.autoconfigure.web.servlet.WebMvcTest;
import org.springframework.test.context.bean.override.mockito.MockitoBean;
import org.springframework.http.MediaType;
import org.springframework.http.HttpStatus;
import org.springframework.test.web.servlet.MockMvc;
import org.springframework.test.context.junit.jupiter.SpringExtension;
import static org.springframework.security.test.web.servlet.request.SecurityMockMvcRequestPostProcessors.csrf;

import java.time.OffsetDateTime;
import com.mealchemy.config.JwtUtil;

import static org.mockito.Mockito.*;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.*;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.*;

import org.springframework.web.server.ResponseStatusException;

/* Import classes */
import com.mealchemy.vault.dto.RecipeLockResponse;
import com.mealchemy.vault.service.RecipeEditLockService;
import com.mealchemy.config.WithMockJwtUser;

@ExtendWith(SpringExtension.class)
@WebMvcTest(RecipeEditLockController.class)
@WithMockJwtUser(userId = "1")
public class RecipeEditLockControllerTest 
{
    @Autowired
    private MockMvc mockMvc;

    @MockitoBean
    private JwtUtil jwtUtil;
    
    @MockitoBean
    private RecipeEditLockService recipeEditLockService;
    
    private RecipeLockResponse lockResponse;

    @BeforeEach
    void setUp()
    {
        lockResponse = new RecipeLockResponse(
            8,
            1,
            "owner@email.com",
            OffsetDateTime.parse("2026-09-24T10:00:00Z"),
            OffsetDateTime.parse("2026-09-24T10:01:30Z")
        );
    }


    // ========== Get lock (GET /recipes/{recipeId}/lock) ==========

    @Test
    void getLock_lockExists_returns200() throws Exception 
    {
        // Arrange
        when(recipeEditLockService.getLock(8, 1)).thenReturn(lockResponse);

        // Act and Assert
        mockMvc.perform(get("/recipes/8/lock"))
            .andExpect(status().isOk())
            .andExpect(jsonPath("$.recipeId").value(8))
            .andExpect(jsonPath("$.lockedByUserId").value(1))
            .andExpect(jsonPath("$.lockedByEmail").value("owner@email.com"));

    }

    @Test
    void getLock_noLiveLock_returns204() throws Exception 
    {
        // Arrange
        when(recipeEditLockService.getLock(8, 1)).thenReturn(null);

        // Act and Assert
        mockMvc.perform(get("/recipes/8/lock"))
            .andExpect(status().isNoContent());
    }

    @Test
    void getLock_recipeNotFound_returns404() throws Exception 
    {
        // Arrange
        when(recipeEditLockService.getLock(99, 1)).thenThrow(new ResponseStatusException(HttpStatus.NOT_FOUND, "Recipe not found."));

        // Act and Assert
        mockMvc.perform(get("/recipes/99/lock"))
            .andExpect(status().isNotFound())
            .andExpect(jsonPath("$.message").value("Recipe not found."));    
    }


    // ========== Acquire lock (POST /recipes/{recipeId}/lock) ==========

    @Test
    void acquireLock_success_returns200() throws Exception 
    {
        // Arrange
        when(recipeEditLockService.acquireLock(8, 1)).thenReturn(lockResponse);

        // Act and Assert
        mockMvc.perform(post("/recipes/8/lock")
            .with(csrf()))
            .andExpect(status().isOk())
            .andExpect(jsonPath("$.recipeId").value(8))
            .andExpect(jsonPath("$.lockedByUserId").value(1));
    }

    @Test
    void acquireLock_callerCannotEdit_returns404() throws Exception 
    {
        // Arrange
        when(recipeEditLockService.acquireLock(8, 1)).thenThrow(new ResponseStatusException(HttpStatus.NOT_FOUND, "Recipe not found."));

        // Act and Assert
        mockMvc.perform(post("/recipes/8/lock")
            .with(csrf()))
            .andExpect(status().isNotFound())
            .andExpect(jsonPath("$.message").value("Recipe not found."));  
    }

    @Test
    void acquireLock_lockedByOtherUser_returns409() throws Exception 
    {
        // Arrange
        when(recipeEditLockService.acquireLock(8, 1)).thenThrow(new ResponseStatusException(HttpStatus.CONFLICT, "This recipe is currently being edited by another user."));

        // Act and Assert
        mockMvc.perform(post("/recipes/8/lock")
            .with(csrf()))
            .andExpect(status().isConflict())
            .andExpect(jsonPath("$.message").value("This recipe is currently being edited by another user."));  
    }


    // ========== Release lock (DELETE /recipes/{recipeId}/lock) ==========

    @Test
    void releaseLock_success_returns204() throws Exception 
    {
        // Arrange
        doNothing().when(recipeEditLockService).releaseLock(8, 1);

        // Act and Assert
        mockMvc.perform(delete("/recipes/8/lock")
            .with(csrf()))
            .andExpect(status().isNoContent());
    }

    @Test
    void releaseLock_callerNotHolder_returns403() throws Exception 
    {
        // Arrange
    doThrow(new ResponseStatusException(HttpStatus.FORBIDDEN, "Only the lock holder can release this lock.")).when(recipeEditLockService).releaseLock(8, 1);
        // Act and Assert
        mockMvc.perform(delete("/recipes/8/lock")
            .with(csrf()))
            .andExpect(status().isForbidden())
            .andExpect(jsonPath("$.message").value("Only the lock holder can release this lock."));  
    }

    @Test
    void releaseLock_noLockExists_returns404() throws Exception 
    {
        // Arrange
        doThrow(new ResponseStatusException(HttpStatus.NOT_FOUND, "No active lock on this recipe")).when(recipeEditLockService).releaseLock(8, 1);

        // Act and Assert
        mockMvc.perform(delete("/recipes/8/lock")
            .with(csrf()))
            .andExpect(status().isNotFound())
            .andExpect(jsonPath("$.message").value("No active lock on this recipe"));  
    }
}