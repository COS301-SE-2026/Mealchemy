package com.mealchemy.recipe.controller;

/* Import libraries */
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.autoconfigure.web.servlet.WebMvcTest;
import org.springframework.test.context.bean.override.mockito.MockitoBean;
import org.springframework.http.MediaType;
import org.springframework.test.web.servlet.MockMvc;

import java.time.OffsetDateTime;
import java.util.Map;
import java.util.List;
import java.math.BigDecimal;

import static org.mockito.ArgumentMatchers.any;
import static org.mockito.ArgumentMatchers.eq;
import static org.mockito.Mockito.*;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.*;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.*;
import static org.junit.jupiter.api.Assertions.assertTrue;
import jakarta.servlet.ServletException;
import com.mealchemy.config.JwtUtil;
import static org.springframework.security.test.web.servlet.request.SecurityMockMvcRequestPostProcessors.csrf;
import org.springframework.security.test.context.support.WithMockUser;
import com.fasterxml.jackson.databind.ObjectMapper;
import org.springframework.web.server.ResponseStatusException;
import org.springframework.http.HttpStatus;
import org.springframework.test.context.junit.jupiter.SpringExtension;
import org.junit.jupiter.api.extension.ExtendWith;

/* Import classes */
import com.mealchemy.recipe.dto.RecipeRequest;
import com.mealchemy.recipe.dto.RecipeFullRequest;
import com.mealchemy.recipe.dto.RecipeIngredientRequest;
import com.mealchemy.recipe.dto.RecipePhotoUploadRequest;
import com.mealchemy.recipe.dto.RecipePhotoUploadResponse;
import com.mealchemy.recipe.dto.RecipeStepRequest;
import com.mealchemy.recipe.dto.RecipeResponse;
import com.mealchemy.recipe.service.RecipePhotoService;
import com.mealchemy.recipe.service.RecipeService;
import com.mealchemy.config.WithMockJwtUser;

@ExtendWith(SpringExtension.class)
@WebMvcTest(RecipeController.class)
@WithMockJwtUser(userId = "1")
public class RecipeControllerTest {
    @Autowired
    private MockMvc mockMvc;

    @MockitoBean 
    private JwtUtil jwtUtil;

    @MockitoBean
    private RecipeService recipeService;

    @MockitoBean
    private RecipePhotoService recipePhotoService;

    @Autowired
    private ObjectMapper objectMapper;

    private RecipeResponse response;
    private RecipeFullRequest fullRequest;
    private RecipeRequest request;

    @BeforeEach
    void setUp()
    {
        response = new RecipeResponse(
            1, 1, "Recipe 1", "Description", "Japanese", 10, 15, 2, null, null, null, false, OffsetDateTime.now(), OffsetDateTime.now(), null
        );

        List<RecipeIngredientRequest> ingredients = List.of(
            new RecipeIngredientRequest(1, BigDecimal.valueOf(2.0), "cup", 1)
        );

        List<RecipeStepRequest> steps = List.of(
            new RecipeStepRequest(1, "Mix everything together.")
        );

        fullRequest = new RecipeFullRequest(
            "Req Title", "Description", "Chinese", 10, 15, 2, null, null, null, false, ingredients, steps, 1
        );

        request = new RecipeRequest(
            "Req Title", "Description", "Chinese", 10, 15, 2, null, null, null, false, 1
        );
    }

    @Test
    void getAllRecipes_returns200_withList() throws Exception
    {
        when(recipeService.getAllRecipes(1)).thenReturn(List.of(response));
        
        mockMvc.perform(get("/recipes/all")).andExpect(status().isOk()).andExpect(jsonPath("$[0].title").value("Recipe 1"));
    }

    @Test
    void getAllCommunityPublishedRecipes_returns200_withList() throws Exception
    {
        when(recipeService.getAllCommunityPublishedRecipes()).thenReturn(List.of(response));
 
        mockMvc.perform(get("/recipes/community")).andExpect(status().isOk()).andExpect(jsonPath("$[0].title").value("Recipe 1"));
    }

    @Test
    void getRecipeById_returns200_whenFound() throws Exception
    {
        when(recipeService.getRecipeById(1, 1)).thenReturn(response);

        mockMvc.perform(get("/recipes/single/1")).andExpect(status().isOk()).andExpect(jsonPath("$.title").value("Recipe 1"));
    }

    @Test
    void getRecipeById_returns404_whenNotFound() throws Exception
    {
        when(recipeService.getRecipeById(99, 1)).thenThrow(new ResponseStatusException(HttpStatus.NOT_FOUND, "Recipe not found."));

        mockMvc.perform(get("/recipes/single/99")).andExpect(status().isNotFound()).andExpect(jsonPath("$.message").value("Recipe not found."));
    }

    @Test
    void getRecipeById_returns403_whenNotAccessible() throws Exception
    {
        when(recipeService.getRecipeById(1, 1)).thenThrow(new ResponseStatusException(HttpStatus.FORBIDDEN, "You do not have permission to view this recipe."));

        mockMvc.perform(get("/recipes/single/1"))
            .andExpect(status().isForbidden())
            .andExpect(jsonPath("$.message").value("You do not have permission to view this recipe."));
    }

    @Test
    void createRecipe_returns200_withCreatedRecipe() throws Exception
    {
        when(recipeService.createRecipe(any(RecipeRequest.class), eq(1))).thenReturn(response);

        mockMvc.perform(post("/recipes/create")
            .with(csrf())
            .contentType(MediaType.APPLICATION_JSON)
            .content(objectMapper.writeValueAsString(request)))
            .andExpect(status().isOk())
            .andExpect(jsonPath("$.title").value("Recipe 1"));
    }

    @Test
    void createRecipe_returns400_whenTitleBlank() throws Exception
    {
        RecipeRequest invalidRequest = new RecipeRequest("", "Description", "Chinese", 10, 15, 2, null, null, null, false, 1);

        mockMvc.perform(post("/recipes/create")
            .with(csrf())
            .contentType(MediaType.APPLICATION_JSON)
            .content(objectMapper.writeValueAsString(invalidRequest)))
            .andExpect(status().isBadRequest());
    }

    @Test
    void createRecipe_returns400_whenServiceRejectsNullFolderId() throws Exception
    {
        RecipeRequest noFolderRequest = new RecipeRequest("Req Title", "Description", "Chinese", 10, 15, 2, null, null, null, false, null);
 
        when(recipeService.createRecipe(any(RecipeRequest.class), eq(1)))
            .thenThrow(new ResponseStatusException(HttpStatus.BAD_REQUEST, "A folder must be specified when creating a recipe."));
 
        mockMvc.perform(post("/recipes/create")
            .with(csrf())
            .contentType(MediaType.APPLICATION_JSON)
            .content(objectMapper.writeValueAsString(noFolderRequest)))
            .andExpect(status().isBadRequest())
            .andExpect(jsonPath("$.message").value("A folder must be specified when creating a recipe."));
    }

    @Test
    void createFromFullRecipe_returns200_withCreatedRecipe() throws Exception
    {
        when(recipeService.createFromFullRecipe(any(RecipeFullRequest.class), eq(1), eq(1))).thenReturn(response);

        mockMvc.perform(post("/recipes/1/copy")
            .with(csrf())
            .contentType(MediaType.APPLICATION_JSON)
            .content(objectMapper.writeValueAsString(fullRequest)))
            .andExpect(status().isOk())
            .andExpect(jsonPath("$.title").value("Recipe 1"));
    }

    @Test
    void createFromFullRecipe_returns400_whenFolderIdNull() throws Exception
    {
        RecipeFullRequest invalidFullRequest = new RecipeFullRequest(
            "Req Title", "Description", "Chinese", 10, 15, 2, null, null, null, false,
            List.of(new RecipeIngredientRequest(1, BigDecimal.valueOf(2.0), "cup", 1)),
            List.of(new RecipeStepRequest(1, "Mix everything together.")),
            null
        );
 
        mockMvc.perform(post("/recipes/1/copy")
            .with(csrf())
            .contentType(MediaType.APPLICATION_JSON)
            .content(objectMapper.writeValueAsString(invalidFullRequest)))
            .andExpect(status().isBadRequest());
    }

    @Test
    void createPhotoUploadUrl_returns200_withUploadDetails() throws Exception
    {
        RecipePhotoUploadRequest photoRequest = new RecipePhotoUploadRequest(
            "image/jpeg",
            2048L
        );
        RecipePhotoUploadResponse photoResponse = new RecipePhotoUploadResponse(
            "https://storage.googleapis.com/signed-upload",
            "https://storage.googleapis.com/bucket/recipes/1/photo.jpg",
            Map.of("Content-Type", "image/jpeg", "Content-Length", "2048"),
            OffsetDateTime.now().plusMinutes(10)
        );
        when(recipePhotoService.createPhotoUploadUrl(
            eq(1),
            any(RecipePhotoUploadRequest.class),
            eq(1)
        )).thenReturn(photoResponse);

        mockMvc.perform(post("/recipes/1/photo-upload-url")
            .with(csrf())
            .contentType(MediaType.APPLICATION_JSON)
            .content(objectMapper.writeValueAsString(photoRequest)))
            .andExpect(status().isOk())
            .andExpect(jsonPath("$.uploadUrl").value(photoResponse.uploadUrl()))
            .andExpect(jsonPath("$.photoUrl").value(photoResponse.photoUrl()))
            .andExpect(jsonPath("$.requiredHeaders.Content-Type").value("image/jpeg"))
            .andExpect(jsonPath("$.requiredHeaders.Content-Length").value("2048"));
    }

    @Test
    void createPhotoUploadUrl_returns400_whenRequestIsInvalid() throws Exception
    {
        RecipePhotoUploadRequest photoRequest = new RecipePhotoUploadRequest("", 0L);

        mockMvc.perform(post("/recipes/1/photo-upload-url")
            .with(csrf())
            .contentType(MediaType.APPLICATION_JSON)
            .content(objectMapper.writeValueAsString(photoRequest)))
            .andExpect(status().isBadRequest());
    }

    @Test
    void createPhotoUploadUrl_returns403_whenUserDoesNotOwnRecipe() throws Exception
    {
        RecipePhotoUploadRequest photoRequest = new RecipePhotoUploadRequest(
            "image/jpeg",
            2048L
        );
        when(recipePhotoService.createPhotoUploadUrl(
            eq(1),
            any(RecipePhotoUploadRequest.class),
            eq(1)
        )).thenThrow(new ResponseStatusException(
            HttpStatus.FORBIDDEN,
            "Only the owner of this recipe can upload a photo."
        ));

        mockMvc.perform(post("/recipes/1/photo-upload-url")
            .with(csrf())
            .contentType(MediaType.APPLICATION_JSON)
            .content(objectMapper.writeValueAsString(photoRequest)))
            .andExpect(status().isForbidden())
            .andExpect(jsonPath("$.message").value(
                "Only the owner of this recipe can upload a photo."
            ));
    }

    @Test
    void updateRecipe_returns200_withUpdatedRecipe() throws Exception
    {
        when(recipeService.updateRecipe(eq(1), any(RecipeRequest.class), eq(1))).thenReturn(response);

        mockMvc.perform(put("/recipes/edit/1")
            .with(csrf())
            .contentType(MediaType.APPLICATION_JSON)
            .content(objectMapper.writeValueAsString(request)))
            .andExpect(status().isOk())
            .andExpect(jsonPath("$.title").value("Recipe 1"));
    }

    @Test
    void deleteRecipe_returns200() throws Exception
    {
        doNothing().when(recipeService).deleteRecipe(1, 1);

        mockMvc.perform(delete("/recipes/delete/1").with(csrf()))
            .andExpect(status().isOk());
    }
    
}
