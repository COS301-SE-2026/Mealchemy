package com.mealchemy.moderation.service;

//models
import com.mealchemy.auth.model.User;
import com.mealchemy.profile.model.UserProfile;

//repositories
import com.mealchemy.auth.repository.UserRepository;
import com.mealchemy.profile.repository.UserProfileRepository;

//dtos
import com.mealchemy.moderation.dto.UserSummaryResponse;

import org.springframework.transaction.annotation.Transactional; //need to annotate any function that makes an update to the database

import java.util.List;
import java.util.ArrayList;

import org.springframework.http.HttpStatus;
import org.springframework.stereotype.Service;
import org.springframework.web.server.ResponseStatusException;


@Service
public class AdminService {

    private final UserRepository userRepository;
    private final UserProfileRepository userProfileRepository;

    public AdminService(UserRepository userRepository, UserProfileRepository userProfileRepository) {
        this.userRepository = userRepository;
        this.userProfileRepository = userProfileRepository;
    }


    // ========== Helper function - call before any admin action is done ==========

    public void requireAdmin(Integer userId) { //guard for any action that requires an admin

        User userToCheck = userRepository.findById(userId)
                    .orElseThrow(() -> new ResponseStatusException(HttpStatus.NOT_FOUND, "User not found."));

        if (!userToCheck.getRoles().contains("ADMIN")) {
            throw new ResponseStatusException(HttpStatus.FORBIDDEN, "User is not an Admin.");
        }
    }

    private UserSummaryResponse toResponse(User user) {
        // find user profile first
        UserProfile profile = userProfileRepository.findByUserId(user.getUserId())
                        .orElseThrow(() -> new ResponseStatusException(HttpStatus.NOT_FOUND, "User profile not found."));

        return new  UserSummaryResponse(
            user.getUserId(),
            profile.getDisplayName(),
            user.getEmail(),
            user.getRoles()
        );

    }

    
    // GET - find user by email
    public UserSummaryResponse findUserByEmail(String email, Integer adminUser) {
        // performing admin task
        requireAdmin(adminUser);

        User userSearchedFor = userRepository.findByEmail(email)
                        .orElseThrow(() -> new ResponseStatusException(HttpStatus.NOT_FOUND, "User not found."));

        return toResponse(userSearchedFor);
    }


    // PUT - make user an admin
    @Transactional
    public UserSummaryResponse promoteToAdmin(Integer userToPromoteId, Integer adminUser) {
        // performing admin task
        requireAdmin(adminUser);

        User userToPromote = userRepository.findById(userToPromoteId)
                        .orElseThrow(() -> new ResponseStatusException(HttpStatus.NOT_FOUND, "User not found."));

        List<String> updatedRoles = new ArrayList<>(userToPromote.getRoles());

        // if user is already an admin
        if (updatedRoles.contains("ADMIN")) {
            throw new ResponseStatusException(HttpStatus.CONFLICT, "User is already an Admin.");
        }
        updatedRoles.add("ADMIN");
        userToPromote.setRoles(updatedRoles);
        userRepository.save(userToPromote);

       return toResponse(userToPromote);
    }
}