// unit testing for registration and login

package com.mealchemy.auth;

import com.mealchemy.auth.dto.AuthResponse;
import com.mealchemy.auth.dto.LoginRequest;
import com.mealchemy.auth.dto.RegisterRequest;
import com.mealchemy.auth.model.Role;
import com.mealchemy.auth.model.User;
import com.mealchemy.auth.model.UserProfile;
import com.mealchemy.auth.repository.RoleRepository;
import com.mealchemy.auth.repository.UserProfileRepository;
import com.mealchemy.auth.repository.UserRepository;
import com.mealchemy.auth.service.AuthService;
import com.mealchemy.config.JwtUtil;
import com.mealchemy.preference.model.UserPreferences;
import com.mealchemy.preference.repository.UserPreferencesRepository;
import com.mealchemy.vault.model.Vault;
import com.mealchemy.vault.repository.VaultRepository;

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

import static org.junit.jupiter.api.Assertions.*;
import static org.mockito.ArgumentMatchers.any;
import static org.mockito.ArgumentMatchers.anyString;
import static org.mockito.Mockito.*;

@ExtendWith(MockitoExtension.class) //tells JUnit to use Mockito to create mocks
public class AuthServiceTest {

    // @Mock - create fake version of dependency
    @Mock private UserRepository userRepository;
    @Mock private RoleRepository roleRepository;
    @Mock private UserProfileRepository userProfileRepository;
    @Mock private UserPreferencesRepository userPreferencesRepository;
    @Mock private VaultRepository vaultRepository;
    @Mock private PasswordEncoder passwordEncoder;
    @Mock private JwtUtil jwtUtil;

    // @InjectMocks creates the real AuthService and injects the mocks above into it - actually testing AuthService
    @InjectMocks
    private AuthService authService;

    // reusable test data
    private RegisterRequest validRegisterRequest;
    private LoginRequest validLoginRequest;
    private Role userRole;
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

        userRole = new Role();
        userRole.setRoleName("user");

        savedUser = new User();
        savedUser.setEmail("test@test.com");
        savedUser.setPasswordHash("$2a$12$hashedpassword");
        savedUser.setRoleId(1);
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

    @Test
    void register_whenRoleNotFound_throwsIllegalStateException() {
        // Arrange
        when(userRepository.existsByEmail(anyString())).thenReturn(false);
        when(roleRepository.findByRoleName("user")).thenReturn(Optional.empty()); //no role found

        // Act and Assert
        assertThrows(
            IllegalStateException.class,
            () -> authService.register(validRegisterRequest)
        );
    }

    // Happy path
    @Test
    void register_withValidRequest_returnsAuthResponseWithToken() {
        // Arrange
        when(userRepository.existsByEmail(anyString())).thenReturn(false);
        when(roleRepository.findByRoleName("user")).thenReturn(Optional.of(userRole));
        when(passwordEncoder.encode(anyString())).thenReturn("$2a$12$hashedpassword");
        when(userRepository.save(any(User.class))).thenReturn(savedUser);
        when(userProfileRepository.save(any(UserProfile.class))).thenReturn(new UserProfile());
        when(userPreferencesRepository.save(any(UserPreferences.class))).thenReturn(new UserPreferences());
        when(vaultRepository.save(any(Vault.class))).thenReturn(new Vault());
        when(jwtUtil.generateToken(any(User.class))).thenReturn("mock.jwt.token");

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