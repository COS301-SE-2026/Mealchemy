// unit testing for FlagReasonOptions

package com.mealchemy.moderation;

//dtos
import com.mealchemy.moderation.dto.FlagReasonOptionsResponse;

//models
import com.mealchemy.moderation.model.FlagReasonOptions;

//repositories
import com.mealchemy.moderation.repository.FlagReasonOptionsRepository;

//enums
import com.mealchemy.shared.enums.FlagStatus;

//service
import com.mealchemy.moderation.service.FlagReasonOptionsService;

import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.extension.ExtendWith;
import org.mockito.InjectMocks;
import org.mockito.Mock;
import org.mockito.ArgumentCaptor;
import org.mockito.junit.jupiter.MockitoExtension;
import org.springframework.http.HttpStatus;
import org.springframework.web.server.ResponseStatusException;
import org.springframework.test.util.ReflectionTestUtils;

import java.util.List;
import java.util.Optional;
import java.time.OffsetDateTime;

import static org.junit.jupiter.api.Assertions.*;
import static org.mockito.ArgumentMatchers.any;
import static org.mockito.ArgumentMatchers.anyInt;
import static org.mockito.Mockito.*;

@ExtendWith(MockitoExtension.class)
public class FlagReasonOptionsServiceTest {
    // @Mock - create fake version of dependency
    @Mock private FlagReasonOptionsRepository flagReasonOptionsRepository;

    // @InjectMocks creates the real PantryService and injects the mocks above into it - actually testing ShoppingListService
    @InjectMocks
    private FlagReasonOptionsService flagReasonOptionsService;

    
    // Get all flag reason options
    @Test
    void getAllFlagReasonOptons_valid_returnsMappedList() {
        // Arrange
        FlagReasonOptions inappropriateLanguage = new FlagReasonOptions();
        inappropriateLanguage.setValue("INAPPROPRIATE_LANGUAGE");
        inappropriateLanguage.setLabel("Inappropriate language");

        FlagReasonOptions spamMisleading = new FlagReasonOptions();
        spamMisleading.setValue("SPAM_MISLEADING");
        spamMisleading.setLabel("Spam / misleading");

        when(flagReasonOptionsRepository.findAllByOrderBySortOrderAsc()).thenReturn(List.of(inappropriateLanguage, spamMisleading));

        // Act
        List<FlagReasonOptionsResponse> responses = flagReasonOptionsService.getAllFlagReasonOptions();

        // Assert
        assertEquals(2, responses.size());
        assertEquals("INAPPROPRIATE_LANGUAGE", responses.get(0).value());
        assertEquals("Inappropriate language", responses.get(0).label());
        assertEquals("SPAM_MISLEADING", responses.get(1).value());
        assertEquals("Spam / misleading", responses.get(1).label());
    }

    @Test 
    void getAllFlagReasonOptons_none_returnsEmptyList() {
        // Arange
        when(flagReasonOptionsRepository.findAllByOrderBySortOrderAsc()).thenReturn(List.of());
    
        // Act 
        List<FlagReasonOptionsResponse> responses = flagReasonOptionsService.getAllFlagReasonOptions();

        // Assert
        assertNotNull(responses);
        assertTrue(responses.isEmpty());
    }
    
}