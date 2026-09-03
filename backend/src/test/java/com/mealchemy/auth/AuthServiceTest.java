// unit testing for registration and login

package com.mealchemy.auth;

import com.mealchemy.auth.dto.AuthResponse;
import com.mealchemy.auth.dto.LoginRequest;
import com.mealchemy.auth.dto.RegisterRequest;
import com.mealchemy.auth.model.User;
import com.mealchemy.profile.model.UserProfile;
import com.mealchemy.profile.repository.UserProfileRepository;
import com.mealchemy.auth.repository.UserRepository;
import com.mealchemy.auth.service.AuthService;
import com.mealchemy.config.JwtUtil;
import com.mealchemy.preference.model.UserPreferences;
import com.mealchemy.preference.repository.UserPreferencesRepository;
import com.mealchemy.vault.model.Vault;
import com.mealchemy.vault.repository.VaultRepository;
import com.mealchemy.preference.repository.UserCuisineAffinitiesRepository;
import com.mealchemy.preference.repository.UserPreferenceWeightsRepository;
import com.mealchemy.cuisinetype.service.FlavourProfileOptionsService;
import com.mealchemy.preference.model.UserPreferenceWeights;

import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.extension.ExtendWith;
import org.mockito.InjectMocks;
import org.mockito.Mock;
import org.mockito.junit.jupiter.MockitoExtension;
import org.springframework.http.HttpStatus;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.web.server.ResponseStatusException;

import java.util.Optional;
import java.util.List;

import static org.junit.jupiter.api.Assertions.*;
import static org.mockito.ArgumentMatchers.any;
import static org.mockito.ArgumentMatchers.anyString;
import static org.mockito.Mockito.*;
import static org.mockito.ArgumentMatchers.anyList;

@ExtendWith(MockitoExtension.class) //tells JUnit to use Mockito to create mocks
public class AuthServiceTest {

    // @Mock - create fake version of dependency
    @Mock private UserRepository userRepository;
    @Mock private UserProfileRepository userProfileRepository;
    @Mock private UserPreferencesRepository userPreferencesRepository;
    @Mock private UserCuisineAffinitiesRepository userCuisineAffinitiesRepository;
    @Mock private UserPreferenceWeightsRepository userPreferenceWeightsRepository;
    @Mock private FlavourProfileOptionsService flavourProfileOptionsService;
    @Mock private VaultRepository vaultRepository;
    @Mock private PasswordEncoder passwordEncoder;
    @Mock private JwtUtil jwtUtil;

    // @InjectMocks creates the real AuthService and injects the mocks above into it - actually testing AuthService
    @InjectMocks
    private AuthService authService;

    // reusable test data
    private RegisterRequest validRegisterRequest;
    private LoginRequest validLoginRequest;
    private User savedUser;

    @BeforeEach //runs before every test method
    void setUp() {
        validRegisterRequest = new RegisterRequest(
            "test@test.com",
            "password123!",
            "Test User"
        );

        validLoginRequest = new LoginRequest(
            "test@test.com",
            "password123!"
        );

        savedUser = new User();
        savedUser.setEmail("test@test.com");
        savedUser.setPasswordHash("$2a$12$hashedpassword");
        savedUser.setRoles(List.of("USER"));
    }

    // ========== Registration Testing ==========

    // Negative paths
    @Test
    void register_whenEmailAlreadyExists_throwsConflict() {
        // Arrange - testing when email already exists
        when(userRepository.existsByEmail("test@test.com")).thenReturn(true);

        // Act and assert - call register and expect an error
        ResponseStatusException ex = assertThrows(
            ResponseStatusException.class,
            () -> authService.register(validRegisterRequest)
        );

        // Check the status code is 409 CONFLICT
        assertEquals(HttpStatus.CONFLICT, ex.getStatusCode());

        // Verify user was never saved
        verify(userRepository, never()).save(any());
    }

    // Happy path
    @Test
    void register_withValidRequest_returnsAuthResponseWithToken() {
        // Arrange
        when(userRepository.existsByEmail(anyString())).thenReturn(false);
        when(passwordEncoder.encode(anyString())).thenReturn("$2a$12$hashedpassword");
        when(userRepository.save(any(User.class))).thenReturn(savedUser);
        when(userProfileRepository.save(any(UserProfile.class))).thenReturn(new UserProfile());
        when(userPreferencesRepository.save(any(UserPreferences.class))).thenReturn(new UserPreferences());
        when(vaultRepository.save(any(Vault.class))).thenReturn(new Vault());
        when(jwtUtil.generateToken(any(User.class))).thenReturn("mock.jwt.token");
        when(userPreferenceWeightsRepository.save(any(UserPreferenceWeights.class))).thenReturn(new UserPreferenceWeights());
        when(flavourProfileOptionsService.getValidCuisineTypes()).thenReturn(List.of("ITALIAN", "MEXICAN")); 
        when(userCuisineAffinitiesRepository.saveAll(anyList())).thenReturn(List.of());

        // Act
        AuthResponse response = authService.register(validRegisterRequest);

        // Assert
        assertNotNull(response);
        assertEquals("mock.jwt.token", response.accessToken());
        assertTrue(response.onboardingRequired()); // always true for new users

        // Verify all four rows were saved
        verify(userRepository).save(any(User.class));
        verify(userProfileRepository).save(any(UserProfile.class));
        verify(userPreferencesRepository).save(any(UserPreferences.class));
        verify(vaultRepository).save(any(Vault.class));
    }

    // ========== Login Testing ==========

    // Negative path
    @Test
    void login_whenEmailNotFound_throwsUnauthorized() {
        // Arrange - email doesn't exist
        when(userRepository.findByEmail(anyString())).thenReturn(Optional.empty());

        // Act and Assert
        ResponseStatusException ex = assertThrows(
            ResponseStatusException.class,
            () -> authService.login(validLoginRequest)
        );

        assertEquals(HttpStatus.UNAUTHORIZED, ex.getStatusCode());
    }

    @Test
    void login_whenAccountSoftDeleted_throwsUnauthorized() {
        // Arrange - user account has been soft deleted
        savedUser.setDeletedAt(java.time.OffsetDateTime.now());
        when(userRepository.findByEmail(anyString())).thenReturn(Optional.of(savedUser));

        // Act and Assert
        ResponseStatusException ex = assertThrows(
            ResponseStatusException.class,
            () -> authService.login(validLoginRequest)
        );

        assertEquals(HttpStatus.UNAUTHORIZED, ex.getStatusCode());
    }

    @Test
    void login_whenPasswordIncorrect_throwsUnauthorized() {
        // Arrange - user exists but input incorrect password
        when(userRepository.findByEmail(anyString())).thenReturn(Optional.of(savedUser));
        when(passwordEncoder.matches(anyString(), anyString())).thenReturn(false); // wrong password

        // Act and Assert
        ResponseStatusException ex = assertThrows(
            ResponseStatusException.class,
            () -> authService.login(validLoginRequest)
        );

        assertEquals(HttpStatus.UNAUTHORIZED, ex.getStatusCode());
    }
    
    // Happy path
    @Test
    void login_withValidCredentials_returnsAuthResponseWithToken() {
        // Arrange
        when(userRepository.findByEmail(anyString())).thenReturn(Optional.of(savedUser));
        when(passwordEncoder.matches(anyString(), anyString())).thenReturn(true);
        when(jwtUtil.generateToken(any(User.class))).thenReturn("mock.jwt.token");

        // Act
        AuthResponse response = authService.login(validLoginRequest);

        // Assert
        assertNotNull(response);
        assertEquals("mock.jwt.token", response.accessToken());
        assertFalse(response.onboardingRequired()); // always false for existing users
    }
}