package com.mealchemy.auth;

import com.fasterxml.jackson.databind.ObjectMapper;
import com.mealchemy.auth.dto.LoginRequest;
import com.mealchemy.auth.dto.RegisterRequest;
import com.mealchemy.auth.repository.UserRepository;
import com.mealchemy.auth.repository.UserProfileRepository;
import com.mealchemy.preference.repository.UserPreferencesRepository;
import com.mealchemy.vault.repository.VaultRepository;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.autoconfigure.web.servlet.AutoConfigureMockMvc;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.http.MediaType;
import org.springframework.test.web.servlet.MockMvc;
import org.springframework.test.web.servlet.MvcResult;
import org.springframework.transaction.annotation.Transactional;

import static org.assertj.core.api.Assertions.assertThat;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.post;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.*;

/**
 * Integration tests for AuthController.
 *
 * Requires a running Postgres instance + Docker (as configured in your environment).
 * Each test runs in a transaction that is rolled back after the test so test data
 * never pollutes the database.  The only exception is data that was already there
 * before the test (e.g. the seeded "user" role row).
 */
@SpringBootTest
@AutoConfigureMockMvc
@Transactional   // every test rolls back automatically — no manual cleanup needed
class AuthIntegrationTest {

    @Autowired MockMvc mockMvc;
    @Autowired ObjectMapper objectMapper;

    // Repositories used to verify side-effects directly in the DB
    @Autowired UserRepository userRepository;
    @Autowired UserProfileRepository userProfileRepository;
    @Autowired UserPreferencesRepository userPreferencesRepository;
    @Autowired VaultRepository vaultRepository;

    // A unique email per test run so parallel runs can't collide
    private String testEmail;

    @BeforeEach
    void setUp() {
        testEmail = "test_" + System.nanoTime() + "@mealchemy.com";
    }

    // -------------------------------------------------------------------------
    // REGISTER
    // -------------------------------------------------------------------------

    @Test
    @DisplayName("POST /auth/register → 201 with token, user_id, onboarding_required=true")
    void register_validRequest_returns201WithAuthPayload() throws Exception {

        RegisterRequest body = new RegisterRequest(testEmail, "Password1!", "Chef Mutombo");

        MvcResult result = mockMvc.perform(post("/auth/register")
                .contentType(MediaType.APPLICATION_JSON)
                .content(objectMapper.writeValueAsString(body)))
                .andExpect(status().isCreated())
                .andExpect(jsonPath("$.token").isNotEmpty())
                .andExpect(jsonPath("$.user_id").isNumber())
                .andExpect(jsonPath("$.onboarding_required").value(true))
                .andReturn();

        // Verify the JWT is a three-part string (header.payload.signature)
        String token = objectMapper.readTree(result.getResponse().getContentAsString())
                .get("token").asText();
        assertThat(token.split("\\.")).hasSize(3);
    }

    @Test
    @DisplayName("POST /auth/register → creates user, profile, preferences and vault rows")
    void register_validRequest_createsAllExpectedRows() throws Exception {

        RegisterRequest body = new RegisterRequest(testEmail, "Password1!", "Chef Mutombo");

        MvcResult result = mockMvc.perform(post("/auth/register")
                .contentType(MediaType.APPLICATION_JSON)
                .content(objectMapper.writeValueAsString(body)))
                .andExpect(status().isCreated())
                .andReturn();

        int userId = objectMapper.readTree(result.getResponse().getContentAsString())
                .get("user_id").asInt();

        // User row
        assertThat(userRepository.findById(userId)).isPresent();

        // User profile row
        assertThat(userProfileRepository.findByUserId(userId)).isPresent();

        // User preferences row
        assertThat(userPreferencesRepository.findByUserId(userId)).isPresent();

        // Vault row
        assertThat(vaultRepository.findByOwnerId(userId)).isNotEmpty();
    }

    @Test
    @DisplayName("POST /auth/register → password is stored as a bcrypt hash, never plaintext")
    void register_passwordIsHashedInDatabase() throws Exception {

        RegisterRequest body = new RegisterRequest(testEmail, "Password1!", "Chef Mutombo");

        MvcResult result = mockMvc.perform(post("/auth/register")
                .contentType(MediaType.APPLICATION_JSON)
                .content(objectMapper.writeValueAsString(body)))
                .andExpect(status().isCreated())
                .andReturn();

        int userId = objectMapper.readTree(result.getResponse().getContentAsString())
                .get("user_id").asInt();

        String storedHash = userRepository.findById(userId)
                .orElseThrow()
                .getPasswordHash();

        assertThat(storedHash).startsWith("$2a$");          // bcrypt prefix
        assertThat(storedHash).doesNotContain("Password1!");  // never plaintext
    }

    @Test
    @DisplayName("POST /auth/register → 409 when email is already registered")
    void register_duplicateEmail_returns409() throws Exception {

        RegisterRequest body = new RegisterRequest(testEmail, "Password1!", "Chef Mutombo");

        // First registration — should succeed
        mockMvc.perform(post("/auth/register")
                .contentType(MediaType.APPLICATION_JSON)
                .content(objectMapper.writeValueAsString(body)))
                .andExpect(status().isCreated());

        // Second registration with the same email — should conflict
        mockMvc.perform(post("/auth/register")
                .contentType(MediaType.APPLICATION_JSON)
                .content(objectMapper.writeValueAsString(body)))
                .andExpect(status().isConflict());
    }

    @Test
    @DisplayName("POST /auth/register → 400 for invalid email format")
    void register_invalidEmail_returns400() throws Exception {

        RegisterRequest body = new RegisterRequest("not-an-email", "Password1!", "Chef Mutombo");

        mockMvc.perform(post("/auth/register")
                .contentType(MediaType.APPLICATION_JSON)
                .content(objectMapper.writeValueAsString(body)))
                .andExpect(status().isBadRequest());
    }

    @Test
    @DisplayName("POST /auth/register → 400 when password is shorter than 8 characters")
    void register_shortPassword_returns400() throws Exception {

        RegisterRequest body = new RegisterRequest(testEmail, "short", "Chef Mutombo");

        mockMvc.perform(post("/auth/register")
                .contentType(MediaType.APPLICATION_JSON)
                .content(objectMapper.writeValueAsString(body)))
                .andExpect(status().isBadRequest());
    }

    @Test
    @DisplayName("POST /auth/register → 400 when displayName is blank")
    void register_blankDisplayName_returns400() throws Exception {

        RegisterRequest body = new RegisterRequest(testEmail, "Password1!", "");

        mockMvc.perform(post("/auth/register")
                .contentType(MediaType.APPLICATION_JSON)
                .content(objectMapper.writeValueAsString(body)))
                .andExpect(status().isBadRequest());
    }

    @Test
    @DisplayName("POST /auth/register → 400 when request body is missing entirely")
    void register_emptyBody_returns400() throws Exception {

        mockMvc.perform(post("/auth/register")
                .contentType(MediaType.APPLICATION_JSON)
                .content("{}"))
                .andExpect(status().isBadRequest());
    }

    // -------------------------------------------------------------------------
    // LOGIN
    // -------------------------------------------------------------------------

    @Test
    @DisplayName("POST /auth/login → 200 with token, user_id, onboarding_required=false")
    void login_validCredentials_returns200WithAuthPayload() throws Exception {

        // Arrange — register first
        RegisterRequest reg = new RegisterRequest(testEmail, "Password1!", "Chef Mutombo");
        mockMvc.perform(post("/auth/register")
                .contentType(MediaType.APPLICATION_JSON)
                .content(objectMapper.writeValueAsString(reg)))
                .andExpect(status().isCreated());

        // Act — login
        LoginRequest login = new LoginRequest(testEmail, "Password1!");

        MvcResult result = mockMvc.perform(post("/auth/login")
                .contentType(MediaType.APPLICATION_JSON)
                .content(objectMapper.writeValueAsString(login)))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.token").isNotEmpty())
                .andExpect(jsonPath("$.user_id").isNumber())
                .andExpect(jsonPath("$.onboarding_required").value(false))
                .andReturn();

        // The login token should also be a valid three-part JWT
        String token = objectMapper.readTree(result.getResponse().getContentAsString())
                .get("token").asText();
        assertThat(token.split("\\.")).hasSize(3);
    }

    @Test
    @DisplayName("POST /auth/login → 401 when email does not exist")
    void login_unknownEmail_returns401() throws Exception {

        LoginRequest login = new LoginRequest("ghost@mealchemy.com", "Password1!");

        mockMvc.perform(post("/auth/login")
                .contentType(MediaType.APPLICATION_JSON)
                .content(objectMapper.writeValueAsString(login)))
                .andExpect(status().isUnauthorized());
    }

    @Test
    @DisplayName("POST /auth/login → 401 when password is wrong")
    void login_wrongPassword_returns401() throws Exception {

        // Register a real user first
        RegisterRequest reg = new RegisterRequest(testEmail, "Password1!", "Chef Mutombo");
        mockMvc.perform(post("/auth/register")
                .contentType(MediaType.APPLICATION_JSON)
                .content(objectMapper.writeValueAsString(reg)))
                .andExpect(status().isCreated());

        // Try logging in with the wrong password
        LoginRequest login = new LoginRequest(testEmail, "WrongPass99!");

        mockMvc.perform(post("/auth/login")
                .contentType(MediaType.APPLICATION_JSON)
                .content(objectMapper.writeValueAsString(login)))
                .andExpect(status().isUnauthorized());
    }

    @Test
    @DisplayName("POST /auth/login → 401 for a soft-deleted account")
    void login_softDeletedUser_returns401() throws Exception {

        // Register user
        RegisterRequest reg = new RegisterRequest(testEmail, "Password1!", "Chef Mutombo");
        MvcResult regResult = mockMvc.perform(post("/auth/register")
                .contentType(MediaType.APPLICATION_JSON)
                .content(objectMapper.writeValueAsString(reg)))
                .andExpect(status().isCreated())
                .andReturn();

        int userId = objectMapper.readTree(regResult.getResponse().getContentAsString())
                .get("user_id").asInt();

        // Soft-delete the user directly via the repository
        var user = userRepository.findById(userId).orElseThrow();
        user.setDeletedAt(java.time.OffsetDateTime.now());
        userRepository.save(user);

        // Attempt login — should be rejected
        LoginRequest login = new LoginRequest(testEmail, "Password1!");

        mockMvc.perform(post("/auth/login")
                .contentType(MediaType.APPLICATION_JSON)
                .content(objectMapper.writeValueAsString(login)))
                .andExpect(status().isUnauthorized());
    }

    @Test
    @DisplayName("POST /auth/login → 400 for invalid email format")
    void login_invalidEmailFormat_returns400() throws Exception {

        LoginRequest login = new LoginRequest("not-valid", "Password1!");

        mockMvc.perform(post("/auth/login")
                .contentType(MediaType.APPLICATION_JSON)
                .content(objectMapper.writeValueAsString(login)))
                .andExpect(status().isBadRequest());
    }

    @Test
    @DisplayName("POST /auth/login → 400 when password field is blank")
    void login_blankPassword_returns400() throws Exception {

        LoginRequest login = new LoginRequest(testEmail, "");

        mockMvc.perform(post("/auth/login")
                .contentType(MediaType.APPLICATION_JSON)
                .content(objectMapper.writeValueAsString(login)))
                .andExpect(status().isBadRequest());
    }

    // -------------------------------------------------------------------------
    // LOGOUT
    // -------------------------------------------------------------------------

    @Test
    @DisplayName("POST /auth/logout → 204 No Content")
    void logout_returns204() throws Exception {
        mockMvc.perform(post("/auth/logout"))
                .andExpect(status().isNoContent());
    }
}