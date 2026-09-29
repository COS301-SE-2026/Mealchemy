package com.mealchemy.tags.service;

/* Import libraries */
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.extension.ExtendWith;
import org.mockito.InjectMocks;
import org.mockito.Mock;
import org.mockito.junit.jupiter.MockitoExtension;
import org.springframework.test.util.ReflectionTestUtils;

import java.util.List;

import static org.junit.jupiter.api.Assertions.*;
import static org.mockito.Mockito.*;

/* Import classes */
import com.mealchemy.tags.dto.TagDto;
import com.mealchemy.tags.model.Tags;
import com.mealchemy.tags.repository.TagsRepository;

@ExtendWith(MockitoExtension.class)
public class TagsServiceTest {
    @Mock
    private TagsRepository tagsRepository;

    @InjectMocks
    private TagsService tagsService;

    private Tags dietaryTag;
    private Tags nonDietaryTag;

    @BeforeEach
    void setUp()
    {
        dietaryTag = new Tags();
        ReflectionTestUtils.setField(dietaryTag, "tagId", 1);
        dietaryTag.setTagName("Vegetarian");
        dietaryTag.setIsActive(true);
        dietaryTag.setIsDietary(true);

        nonDietaryTag = new Tags();
        ReflectionTestUtils.setField(nonDietaryTag, "tagId", 2);
        nonDietaryTag.setTagName("Quick Meal");
        nonDietaryTag.setIsActive(true);
        nonDietaryTag.setIsDietary(false);
    }

    @Test
    void getActiveTags_returnsAllActiveTags_whenDietaryIsNull()
    {
        when(tagsRepository.findByIsActiveTrue()).thenReturn(List.of(dietaryTag, nonDietaryTag));

        List<TagDto> result = tagsService.getActiveTags(null);

        assertEquals(2, result.size());
        assertEquals("Vegetarian", result.get(0).tagName());
        assertEquals("Quick Meal", result.get(1).tagName());
        verify(tagsRepository, times(1)).findByIsActiveTrue();
        verify(tagsRepository, never()).findByIsActiveTrueAndIsDietary(any());
    }

    @Test
    void getActiveTags_returnsDietaryTags_whenDietaryIsTrue()
    {
        when(tagsRepository.findByIsActiveTrueAndIsDietary(true)).thenReturn(List.of(dietaryTag));

        List<TagDto> result = tagsService.getActiveTags(true);

        assertEquals(1, result.size());
        assertEquals(1, result.get(0).tagId());
        assertEquals("Vegetarian", result.get(0).tagName());
        assertTrue(result.get(0).isDietary());
        verify(tagsRepository, never()).findByIsActiveTrue();
    }

    @Test
    void getActiveTags_returnsNonDietaryTags_whenDietaryIsFalse()
    {
        when(tagsRepository.findByIsActiveTrueAndIsDietary(false)).thenReturn(List.of(nonDietaryTag));

        List<TagDto> result = tagsService.getActiveTags(false);

        assertEquals(1, result.size());
        assertEquals(2, result.get(0).tagId());
        assertEquals("Quick Meal", result.get(0).tagName());
        assertFalse(result.get(0).isDietary());
        verify(tagsRepository, never()).findByIsActiveTrue();
    }

    @Test
    void getActiveTags_returnsEmptyList_whenNoneFound()
    {
        when(tagsRepository.findByIsActiveTrueAndIsDietary(true)).thenReturn(List.of());

        List<TagDto> result = tagsService.getActiveTags(true);

        assertTrue(result.isEmpty());
    }
}