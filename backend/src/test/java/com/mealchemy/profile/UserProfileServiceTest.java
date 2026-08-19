// unit testing for user profile

package com.mealchemy.profile;
// dtos
import com.mealchemy.profile.dto.UserProfileResponse;
import com.mealchemy.profile.dto.UserProfileUpdateRequest;
// model
import com.mealchemy.profile.model.UserProfile;
// repositories
import com.mealchemy.profile.repository.UserProfileRepository;
// services
import com.mealchemy.profile.service.UserProfileService;
import com.mealchemy.equipment.service.EquipmentService;

import com.mealchemy.shared.enums.PreferredUnit;

import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.extension.ExtendWith;
import org.mockito.InjectMocks;
import org.mockito.Mock;
import org.mockito.junit.jupiter.MockitoExtension;
import org.springframework.http.HttpStatus;
import org.springframework.web.server.ResponseStatusException;

import java.util.List;
import java.util.Optional;

import static org.junit.jupiter.api.Assertions.*;
import static org.mockito.ArgumentMatchers.any;
import static org.mockito.Mockito.*;


@ExtendWith(MockitoExtension.class) // tells JUnit to use Mockito to create mocks
public class UserProfileServiceTest {
    // @Mock - create fake version of dependency
    @Mock private UserProfileRepository userProfileRepository;
    @Mock private EquipmentService equipmentService;

    // @InjectMocks creates the real UserProfileService and injects the mocks above into it - actually testing PreferenceSer
    @InjectMocks
    private UserProfileService userProfileService;

    private UserProfile userProfile;
    private UserProfileUpdateRequest updateRequest;

    @BeforeEach
    void setUp() {
        // simulates what db returns for existing user
        userProfile = new UserProfile();
        userProfile.setUserId(1);
        userProfile.setDisplayName("test");
        userProfile.setAvatarUrl("www");
        userProfile.setPreferredUnit(PreferredUnit.METRIC);
        userProfile.setEquipment(List.of("Microwave", "Oven"));

        // simulates what flutter puts in PUT req
        updateRequest = new UserProfileUpdateRequest(
            "test-2",
            "url",
            PreferredUnit.IMPERIAL,
            List.of("Blender")
        );
    }

    // ========== Get User Profile Testing ==========

    @Test
    void userProfile_whenUserNotFound_throwsNotFound() {
        // Arrange
        when(userProfileRepository.findByUserId(1)).thenReturn(Optional.empty());

        // Act
        ResponseStatusException ex = assertThrows(
            ResponseStatusException.class,
            () -> userProfileService.getUserProfile(1)
        );

        // Assert
        assertEquals(HttpStatus.NOT_FOUND, ex.getStatusCode());
    }

    @Test
    void userProfile_whenUserExists_returnsUserProfile() {
        // Arrange
        when(userProfileRepository.findByUserId(1)).thenReturn(Optional.of(userProfile));

        // Act
        UserProfileResponse response = userProfileService.getUserProfile(1);

        // Assert
        assertNotNull(response);
        assertEquals("test", response.displayName());
        assertEquals("www", response.avatarUrl());
        assertEquals(PreferredUnit.METRIC, response.preferredUnit());
        assertEquals(List.of("Microwave", "Oven"), response.equipment());
    }

    // ========== Update User Profile Testing ==========

    @Test
    void updateUserProfile_withValidRequest_updatesAndReturnsUserProfile() {
        // Arrange
        when(userProfileRepository.findByUserId(1)).thenReturn(Optional.of(userProfile));
        when(userProfileRepository.save(any(UserProfile.class))).thenReturn(userProfile);
        when(equipmentService.getValidEquipmentValues()).thenReturn(List.of("Blender"));
        // Act
        UserProfileResponse response = userProfileService.updateUserProfile(1, updateRequest);

        // Assert - show updated values
        assertNotNull(response);
        assertEquals("test-2", response.displayName());
        assertEquals("url", response.avatarUrl());
        assertEquals(PreferredUnit.IMPERIAL, response.preferredUnit());
        assertEquals(List.of("Blender"), response.equipment());

        // Verify save was called once
        verify(userProfileRepository).save(any(UserProfile.class));
    }

    @Test
    void updateUserProfile_whenUserNotFound_throwsNotFound() {
       // Arrange - no profle exist for this user
        when(userProfileRepository.findByUserId(1)).thenReturn(Optional.empty());

        // Act
        ResponseStatusException ex = assertThrows(
            ResponseStatusException.class,
            () -> userProfileService.updateUserProfile(1, updateRequest)
        );

        // Assert
        assertEquals(HttpStatus.NOT_FOUND, ex.getStatusCode());

        // Verify save was never called
        verify(userProfileRepository, never()).save(any());
    }

    @Test
    void updateUserProfile_whenBadRequest_throwsBadRequest() {
       // Arrange - no profle exist for this user
        when(userProfileRepository.findByUserId(1)).thenReturn(Optional.of(userProfile));

        UserProfileUpdateRequest request = new UserProfileUpdateRequest(
            "",
            "url",
            PreferredUnit.IMPERIAL,
            List.of("Blender")
        );

        // Act
        ResponseStatusException ex = assertThrows(
            ResponseStatusException.class,
            () -> userProfileService.updateUserProfile(1, request)
        );

        // Assert
        assertEquals(HttpStatus.BAD_REQUEST, ex.getStatusCode());

        // Verify save was never called
        verify(userProfileRepository, never()).save(any());
    }
    
    @Test
    void updateUserProfile_withEmptyEquipment_updatesAndReturnsUserProfile() {
        // Arrange
        when(userProfileRepository.findByUserId(1)).thenReturn(Optional.of(userProfile));
        when(userProfileRepository.save(any(UserProfile.class))).thenReturn(userProfile);

        UserProfileUpdateRequest request = new UserProfileUpdateRequest(
            "test",
            "url",
            PreferredUnit.IMPERIAL,
            List.of()
        );

        // Act
        UserProfileResponse response = userProfileService.updateUserProfile(1, request);

        // Assert - show updated values
        assertNotNull(response);
        assertEquals("test", response.displayName());
        assertEquals("url", response.avatarUrl());
        assertEquals(PreferredUnit.IMPERIAL, response.preferredUnit());
        assertEquals(List.of(""), response.equipment());

        // Verify save was called once
        verify(userProfileRepository).save(any(UserProfile.class));
    }
}