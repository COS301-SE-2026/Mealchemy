package com.mealchemy.tags.controller;

/* Import libraries */
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.extension.ExtendWith;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.autoconfigure.web.servlet.WebMvcTest;
import org.springframework.test.context.bean.override.mockito.MockitoBean;
import org.springframework.test.web.servlet.MockMvc;
import org.springframework.test.context.junit.jupiter.SpringExtension;

import java.util.List;
import com.mealchemy.config.JwtUtil;

import static org.mockito.Mockito.*;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.*;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.*;

/* Import classes */
import com.mealchemy.tags.dto.TagsResponse;
import com.mealchemy.tags.service.TagsService;
import com.mealchemy.config.WithMockJwtUser;


@ExtendWith(SpringExtension.class)
@WebMvcTest(TagsController.class)
@WithMockJwtUser(userId = "1")
public class TagsControllerTest {
    @Autowired
    private MockMvc mockMvc;

    @MockitoBean
    private JwtUtil jwtUtil;

    @MockitoBean
    private TagsService tagsService;

    private TagsResponse dietaryTag;
    private TagsResponse nonDietaryTag;

    @BeforeEach
    void setUp()
    {
        dietaryTag = new TagsResponse(1, "Vegetarian", true);
        nonDietaryTag = new TagsResponse(2, "Quick Meal", false);
    }

    @Test
    void getTags_returns200_withDietaryTags_whenDietaryTrue() throws Exception
    {
        when(tagsService.getActiveTags(true)).thenReturn(List.of(dietaryTag));

        mockMvc.perform(get("/api/tags").param("dietary", "true"))
            .andExpect(status().isOk())
            .andExpect(jsonPath("$.length()").value(1))
            .andExpect(jsonPath("$[0].tagId").value(1))
            .andExpect(jsonPath("$[0].tagName").value("Vegetarian"))
            .andExpect(jsonPath("$[0].isDietary").value(true));
    }

    @Test
    void getTags_returns200_withAllTags_whenDietaryOmitted() throws Exception
    {
        when(tagsService.getActiveTags(null)).thenReturn(List.of(dietaryTag, nonDietaryTag));

        mockMvc.perform(get("/api/tags"))
            .andExpect(status().isOk())
            .andExpect(jsonPath("$.length()").value(2))
            .andExpect(jsonPath("$[1].tagName").value("Quick Meal"))
            .andExpect(jsonPath("$[1].isDietary").value(false));
    }

    @Test
    void getTags_returns200_withEmptyList() throws Exception
    {
        when(tagsService.getActiveTags(true)).thenReturn(List.of());

        mockMvc.perform(get("/api/tags").param("dietary", "true"))
            .andExpect(status().isOk())
            .andExpect(jsonPath("$").isEmpty());
    }

    @Test
    void getTags_returns400_whenDietaryNotBoolean() throws Exception
    {
        mockMvc.perform(get("/api/tags").param("dietary", "banana"))
            .andExpect(status().isBadRequest());

        verifyNoInteractions(tagsService);
    }
}