// unit testing for external links

package com.mealchemy.externallinks;

// import dto
import com.mealchemy.externallinks.dto.ExternalLinkRequest;
import com.mealchemy.externallinks.dto.ExternalLinkResponse;
// import model
import com.mealchemy.externallinks.model.ExternalLink;

// import repository
import com.mealchemy.externallinks.repository.ExternalLinkRepository;

// import service
import com.mealchemy.externallinks.service.ExternalLinkService;


import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.extension.ExtendWith;
import org.mockito.Mock;
import org.mockito.junit.jupiter.MockitoExtension;
import org.springframework.http.HttpStatus;
import org.springframework.web.server.ResponseStatusException;

import java.time.OffsetDateTime;
import java.util.List;
import java.util.Optional;

import static org.junit.jupiter.api.Assertions.*;
import static org.mockito.ArgumentMatchers.any;
import static org.mockito.Mockito.*;
import static org.mockito.ArgumentMatchers.anyInt;


@ExtendWith(MockitoExtension.class) //tells JUnit to use Mockito to create mocks
public class ExternalLinkServiceTest {
    // @Mock - create fake version of dependency
    @Mock private ExternalLinkRepository externalLinkRepository;

    private ExternalLinkService externalLinkService;

    private ExternalLinkRequest createRequest;
    private ExternalLinkRequest updateRequest;

    private ExternalLink existingLink;

    @BeforeEach
    void setUp() {

        externalLinkService = new ExternalLinkService(externalLinkRepository);

        createRequest = new ExternalLinkRequest(
            "Recipe Link",
            "https://www.link.com"
        );

        
        updateRequest = new ExternalLinkRequest(
            "Update Link 1",
            "https://www.updatelink1.com"
        );
        
        existingLink = new ExternalLink(
            3,
            1,
            "Link 1",
            "https://www.link1.com"
        );
        
    }

    // ========== Get External Links Testing ==========

    @Test
    void externalLinks_whenUserHasLink_returnLinks() {
        // Arrange
        ExternalLink link1 = new ExternalLink(
            1,
            1,
            "Link 1",
            "https://www.link1.com"
        );

        ExternalLink link2 = new ExternalLink(
            2,
            1,
            "Link 2",
            "https://www.link2.com"
        );

        when(externalLinkRepository.findByUserId(1)).thenReturn(List.of(link1, link2));

        // Act
        List<ExternalLinkResponse> result = externalLinkService.getExternalLinks(1);

        // Assert
        assertNotNull(result);
        assertEquals(2, result.size());
        assertEquals("Link 1", result.get(0).name());
        assertEquals("https://www.link1.com", result.get(0).url());
        assertEquals("Link 2", result.get(1).name());
        assertEquals("https://www.link2.com", result.get(1).url());
    }

    @Test
    void externalLinks_whenUserHasNoLink_returnsEmptyList() {
        // Arrange
        when(externalLinkRepository.findByUserId(1)).thenReturn(List.of());

        // Act 
        List<ExternalLinkResponse> result = externalLinkService.getExternalLinks(1);

        assertNotNull(result);
        assertTrue(result.isEmpty());
    }

    // ========== POST External Links Testing ==========

    @Test
    void createExternalLinks_createsNewLinkSuccessfully_returnNewLink() {
        // Arrange
        ExternalLink newLink = new ExternalLink(
            1,
            1,
            "Recipe Link",
            "https://www.link.com"
        );

        when(externalLinkRepository.save(any(ExternalLink.class))).thenReturn(newLink);

        // Act 
        ExternalLinkResponse result = externalLinkService.createExternalLink(1, createRequest);

        // Assert
        assertNotNull(result);
        assertEquals("Recipe Link", result.name());
        assertEquals("https://www.link.com", result.url());
        assertEquals(1, result.linkId());
    }


    // ========== PUT External Links Testing ==========

    @Test
    void updateExternalLinks_updateExistingLink_returnUpdatedLink() {
        // Arrange
        when(externalLinkRepository.findByLinkIdAndUserId(3, 1)).thenReturn(Optional.of(existingLink));
        when(externalLinkRepository.save(any(ExternalLink.class))).thenReturn(existingLink);
        
        // Act 
        ExternalLinkResponse result = externalLinkService.updateExternalLink(3, 1, updateRequest);

        // Assert
        assertNotNull(result);
        assertEquals("Update Link 1", result.name());
        assertEquals("https://www.updatelink1.com", result.url());
        assertNotNull(result.updatedAt());
        verify(externalLinkRepository).save(any(ExternalLink.class));
    }


    @Test
    void externalLinks_noLinkMatches_throwsNotFound() {
        // Arrange 
        when(externalLinkRepository.findByLinkIdAndUserId(anyInt(), anyInt())).thenReturn(Optional.empty());

        // Act 
        ResponseStatusException ex = assertThrows(
            ResponseStatusException.class,
            () -> externalLinkService.updateExternalLink(1, 1, updateRequest)
        );

        // Assert
        assertEquals(HttpStatus.NOT_FOUND, ex.getStatusCode());
        verify(externalLinkRepository, never()).save(any());
    }


    // ========== DELETE Testing ==========

    @Test
    void deleteExternalLink_whenNotFound_throwNotFound() {
        // Arrange
        when(externalLinkRepository.findByLinkIdAndUserId(1, 48)).thenReturn(Optional.empty());

        // Act
        ResponseStatusException ex = assertThrows(
            ResponseStatusException.class,
            () -> externalLinkService.deleteExternalLink(1, 48)
        );

        assertEquals(HttpStatus.NOT_FOUND, ex.getStatusCode());
        verify(externalLinkRepository, never()).delete(any());
    }

    @Test 
    void deleteExternalLink_sucessfulDelete() {
        // Arrange
        when(externalLinkRepository.findByLinkIdAndUserId(3, 1)).thenReturn(Optional.of(existingLink));

        // Act 
        externalLinkService.deleteExternalLink(3, 1);

        verify(externalLinkRepository).delete(existingLink);
    }
}