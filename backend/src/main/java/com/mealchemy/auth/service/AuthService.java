package com.mealchemy.auth.service;
//models
import com.mealchemy.auth.model.User;
import com.mealchemy.auth.model.UserProfile;
import com.mealchemy.preference.model.UserPreferences;
import com.mealchemy.vault.model.Vault;
//repositories
import com.mealchemy.auth.repository.UserRepository;
import com.mealchemy.auth.repository.UserProfileRepository;
import com.mealchemy.preference.repository.UserPreferencesRepository;
import com.mealchemy.vault.repository.VaultRepository;
//dtos
import com.mealchemy.auth.dto.AuthResponse;
import com.mealchemy.auth.dto.LoginRequest;
import com.mealchemy.auth.dto.RegisterRequest;
//shared enums
import com.mealchemy.shared.enums.VaultType;
//config and security
import com.mealchemy.config.JwtUtil;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Service;

import org.springframework.http.HttpStatus;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.web.server.ResponseStatusException;

import java.util.List;

@Service
public class AuthService {

    private final UserRepository userRepository; //in order to read from/modify database
    private final UserProfileRepository userProfileRepository;
    private final UserPreferencesRepository userPreferencesRepository;
    private final VaultRepository vaultRepository;
    private final PasswordEncoder passwordEncoder; //hash passwords
    private final JwtUtil jwtUtil; //token authentication

    // Constructor injection - Spring automatically wires
    public AuthService(UserRepository userRepository,
                    UserProfileRepository userProfileRepository,
                    UserPreferencesRepository userPreferencesRepository,
                    VaultRepository vaultRepository,
                    PasswordEncoder passwordEncoder,
                    JwtUtil jwtUtil) {
        this.userRepository = userRepository;
        this.userProfileRepository = userProfileRepository;
        this.userPreferencesRepository = userPreferencesRepository;
        this.vaultRepository = vaultRepository;
        this.passwordEncoder = passwordEncoder;
        this.jwtUtil = jwtUtil;
    }

    // Logic to register new user
    @Transactional
    public AuthResponse register(RegisterRequest request) { //return auth response dto to send to frontend. Take in a register request dto
        // 1. check if user already exists or email is already in use
        if(userRepository.existsByEmail(request.email())) {
            throw new ResponseStatusException(HttpStatus.CONFLICT, "Email already registered");
        }
        
        // 2. create new user
        User user = new User();
        
        //postgres assigns id
        user.setEmail(request.email());
        user.setPasswordHash(passwordEncoder.encode(request.password()));
        user.setRoles(List.of("USER"));
        userRepository.save(user); //inserts into db

        // 3. create user_profile
        UserProfile userProfile = new UserProfile();
        //postgres assigns id
        userProfile.setUserId(user.getUserId());
        userProfile.setDisplayName(request.displayName());
        userProfileRepository.save(userProfile);

        // 4. create user_prefernce row - will be updated in user preference service
        UserPreferences userPreferences = new UserPreferences();
        //postgres assigns preference id
        userPreferences.setUserId(user.getUserId());
        userPreferencesRepository.save(userPreferences);

        // 5. create vaults row 
        Vault vault = new Vault();
        //postgres assigns id
        vault.setOwnerId(user.getUserId());
        vault.setVaultType(VaultType.PRIVATE);
        vault.setName("My Vault");
        vaultRepository.save(vault);

        // 6. generate token and return response to flutter
        String token = jwtUtil.generateToken(user);
        
        return new AuthResponse(user.getUserId(), token, true);

    }


    public AuthResponse login(LoginRequest request) {
        // 1. find user - if email not found must register
        User user = userRepository.findByEmail(request.email())
                    .orElseThrow(() -> 
                        new ResponseStatusException(HttpStatus.UNAUTHORIZED, "Invalid credentials"));

        // 2. check account is not soft deleted
        if (user.getDeletedAt() != null) {
            throw new ResponseStatusException(HttpStatus.UNAUTHORIZED, "Invalid credentials");
        }

        // 3. check password matches stored hash
        if (!passwordEncoder.matches(request.password(), user.getPasswordHash())) {
            throw new ResponseStatusException(HttpStatus.UNAUTHORIZED, "Invalid credentials");
        }

        // 4. generate token and return response to flutter
        String token = jwtUtil.generateToken(user);

        return new AuthResponse(user.getUserId(), token, false);
    }
}