// unit testing for adminService

package com.mealchemy.moderation;

//dtos
import com.mealchemy.moderation.dto.UserSummaryResponse;

//models
import com.mealchemy.auth.model.User;
import com.mealchemy.profile.model.UserProfile;

//repositories
import com.mealchemy.auth.repository.UserRepository;
import com.mealchemy.profile.repository.UserProfileRepository;

//service
import com.mealchemy.moderation.service.AdminService;

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
import java.util.ArrayList;

import static org.junit.jupiter.api.Assertions.*;
import static org.mockito.ArgumentMatchers.any;
import static org.mockito.ArgumentMatchers.anyInt;
import static org.mockito.Mockito.*;

@ExtendWith(MockitoExtension.class)
public class AdminServiceTest {
    // @Mock - create fake version of dependency
    @Mock private UserRepository userRepository;
    @Mock private UserProfileRepository userProfileRepository;

    // @InjectMocks creates the real PantryService and injects the mocks above into it - actually testing ShoppingListService
    @InjectMocks
    private AdminService adminService;

    private User adminUser;
    private User regularUser;
    private UserProfile regularUserProfile;

     @BeforeEach
    void setUp() {

        adminUser = new User();
        adminUser.setEmail("admin@mealchemy.com");
        adminUser.setPasswordHash("hashed");
        adminUser.setRoles(List.of("ADMIN"));
        ReflectionTestUtils.setField(adminUser, "userId", 1);

        regularUser = new User();
        regularUser.setEmail("regularUser@email.com");
        regularUser.setPasswordHash("hashed");
        regularUser.setRoles(List.of("USER"));
        ReflectionTestUtils.setField(regularUser, "userId", 4);

        regularUserProfile = new UserProfile();
        regularUserProfile.setDisplayName("Regular User");
        ReflectionTestUtils.setField(regularUserProfile, "userId", 4);
    }

    // ========== requireAdmin ==========

    @Test
    void requireAdmin_whenUserNotFound_throwsNotFound() {
        // Arrange
        when(userRepository.findById(99)).thenReturn(Optional.empty());

        // Act
        ResponseStatusException ex = assertThrows(
            ResponseStatusException.class,
            () -> adminService.requireAdmin(99)
        );

        // Assert
        assertEquals(HttpStatus.NOT_FOUND, ex.getStatusCode());
    }

    @Test
    void requireAdmin_whenUserIsNotAdmin_throwsForbidden() {
        // Arrange
        when(userRepository.findById(4)).thenReturn(Optional.of(regularUser));

        // Act
        ResponseStatusException ex = assertThrows(
            ResponseStatusException.class,
            () -> adminService.requireAdmin(4)
        );

        // Assert
        assertEquals(HttpStatus.NOT_FOUND, ex.getStatusCode());
    }


    // ========== Find user by email ==========

    @Test
    void findUserByEmail_valid_returnsUserSummary() {
        // Arrange
        when(userRepository.findById(1)).thenReturn(Optional.of(adminUser));
        when(userRepository.findByEmail("regularUser@email.com")).thenReturn(Optional.of(regularUser));
        when(userProfileRepository.findByUserId(4)).thenReturn(Optional.of(regularUserProfile));

        // Act
        UserSummaryResponse response = adminService.findByEmail("regularUser@email.com", 1);

        // Assert
        assertEquals(4, response.userId());
        assertEquals("Regular User", response.displayName());
        assertEquals("regularUser@email.com", response.email());
        assertEquals(List.of("USER"), response.roles());
    }

    @Test
    void findUserByEmail_notAdmin_throwsForbidden() {
        // Arrange
        when(userRepository.findById(4)).thenReturn(Optional.of(regularUser));

        // Act
        ResponseStatusException ex = assertThrows(
            ResponseStatusException.class,
            () -> adminService.findUserByEmail("regularUser@email.com", 4)
        );

        // Assert
        assertEquals(HttpStatus.FORBIDDEN, ex.getStatusCode());
    }

    @Test
    void findUserByEmail_emailNotFound_throwsNotFound() {
        // Arrange
        when(userRepository.findById(1)).thenReturn(Optional.of(adminUser));
        when(userRepository.findByEmail("nobody@email.com")).thenReturn(Optional.empty());

        // Act
        ResponseStatusException ex = assertThrows(
            ResponseStatusException.class,
            () -> adminService.findUserByEmail("nobody@email.com", 1)
        );

        // Assert
        assertEquals(HttpStatus.NOT_FOUND, ex.getStatusCode());
    }


    // ========== promoteToAdmin ==========

    @Test
    void promoteToAdmin_valid_addsAdminRoleAndSaves() {
        // Arrange
        when(userRepository.findById(1)).thenReturn(Optional.of(adminUser));
        when(userRepository.findById(4)).thenReturn(Optional.of(regularUser));
        when(userProfileRepository.findByUserId(4)).thenReturn(Optional.of(regularUserProfile));

        // Act
        UserSummaryResponse response = adminService.promoteToAdmin(4, 1);

        // Assert
        assertTrue(regularUser.getRoles().contains("ADMIN"));
        assertTrue(regularUser.getRoles().contains("USER"));
        assertEquals(4, response.userId());
        assertTrue(response.roles().contains("ADMIN"));
        verify(userRepository).save(regularUser);
    }
    
    @Test
    void promoteToAdmin_notAdmin_throwsForbidden() {
        // Arrange
        when(userRepository.findById(4)).thenReturn(Optional.of(regularUser));

        // Act
        ResponseStatusException ex = assertThrows(
            ResponseStatusException.class,
            () -> adminService.promoteToAdmin(4, 4)
        );

        // Assert
        assertEquals(HttpStatus.FORBIDDEN, ex.getStatusCode());
        verify(userRepository, never()).save(any());
    }

    @Test
    void promoteToAdmin_targetUserNotFound_throwsNotFound() {
        // Arrange
        when(userRepository.findById(1)).thenReturn(Optional.of(adminUser));
        when(userRepository.findById(99)).thenReturn(Optional.empty());

        // Act
        ResponseStatusException ex = assertThrows(
            ResponseStatusException.class,
            () -> adminService.promoteToAdmin(99, 1)
        );

        // Assert
        assertEquals(HttpStatus.NOT_FOUND, ex.getStatusCode());
    }


    @Test
    void promoteToAdmin_targetUserAlreadyAdmin_throwsConflict() {
        // Arrange
        User alreadyAdmin = new User();
        alreadyAdmin.setEmail("admin@mealchemy.com");
        alreadyAdmin.setPasswordHash("hashed");
        alreadyAdmin.setRoles(List.of("USER", "ADMIN"));
        ReflectionTestUtils.setField(alreadyAdmin, "userId", 7);

        when(userRepository.findById(1)).thenReturn(Optional.of(adminUser));
        when(userRepository.findById(7)).thenReturn(Optional.of(alreadyAdmin));

        // Act
        ResponseStatusException ex = assertThrows(
            ResponseStatusException.class,
            () -> adminService.promoteToAdmin(7, 1)
        );

        // Assert
        assertEquals(HttpStatus.CONFLICT, ex.getStatusCode());
        verify(userRepository, never()).save(any());

    }
}