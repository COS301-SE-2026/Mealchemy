package com.mealchemy.profile.service;
//models
import com.mealchemy.profile.model.UserProfile;
//repositories
import com.mealchemy.profile.repository.UserProfileRepository;
// services
import com.mealchemy.equipment.service.EquipmentService;

import org.springframework.transaction.annotation.Transactional; //need to annotate any function that makes an update to the database

//dtos
import com.mealchemy.profile.dto.UserProfileUpdateRequest;
import com.mealchemy.profile.dto.UserProfileResponse;

import java.util.List;
import java.time.OffsetDateTime;

import org.springframework.http.HttpStatus;
import org.springframework.stereotype.Service;
import org.springframework.web.server.ResponseStatusException;

@Service
public class UserProfileService {

    private final UserProfileRepository userProfileRepository;
    private final EquipmentService equipmentService;

    public UserProfileService(UserProfileRepository userProfileRepository, EquipmentService equipmentService) {
        this.userProfileRepository = userProfileRepository;
        this.equipmentService = equipmentService;
    }

    // GET request - Logic to get user profile
    public UserProfileResponse getUserProfile(Integer userId) { //return logged in user's profile info
        UserProfile userProfile = userProfileRepository.findByUserId(userId)
                                        .orElseThrow(() -> new ResponseStatusException(HttpStatus.NOT_FOUND, "User profile not found")); //need to send correct error code

        return new UserProfileResponse(
                            userProfile.getDisplayName(),
                            userProfile.getAvatarUrl(),
                            userProfile.getPreferredUnit(),
                            userProfile.getEquipment(),
                            userProfile.getUpdatedAt()
                    );
    }

    @Transactional
    public UserProfileResponse updateUserProfile(Integer userId, UserProfileUpdateRequest request) {
        UserProfile userProfile = userProfileRepository.findByUserId(userId)
                                        .orElseThrow(() -> new ResponseStatusException(HttpStatus.NOT_FOUND, "User profile not found"));

        // send through every field on every request
        if (request.displayName() == null || request.preferredUnit() == null || request.equipment() == null) {
            throw new ResponseStatusException(HttpStatus.BAD_REQUEST, "All profile fields are required");
        }

        if (request.displayName().isBlank() || request.displayName().length() > 80) {
            throw new ResponseStatusException(HttpStatus.BAD_REQUEST, "Display name must be between 1-80 characters");
        }

        // check equipment against valid options
        List<String> equipmentOptions = equipmentService.getValidEquipmentValues();
        List<String> invalidEquipment = request.equipment().stream()
                                                           .filter(equip -> !equipmentOptions.contains(equip)) // if current equipment item being streamed in is'nt a valid option, add it to invalid list
                                                           .toList();

        if (!invalidEquipment.isEmpty()) { //some invalid equipment was passed in
            throw new ResponseStatusException(HttpStatus.BAD_REQUEST, "Invalid equipment item");
        }
        

        userProfile.setDisplayName(request.displayName());
        userProfile.setAvatarUrl(request.avatarUrl());
        userProfile.setPreferredUnit(request.preferredUnit());
        userProfile.setEquipment(request.equipment());
        userProfile.setUpdatedAt(OffsetDateTime.now());

        userProfileRepository.save(userProfile);

        return new UserProfileResponse(
                            userProfile.getDisplayName(),
                            userProfile.getAvatarUrl(),
                            userProfile.getPreferredUnit(),
                            userProfile.getEquipment(),
                            userProfile.getUpdatedAt()
                    );
    }

}