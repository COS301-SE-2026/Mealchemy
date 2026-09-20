package com.mealchemy.vault.service;

/* Import libraries */
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import java.util.List;
import java.util.stream.Collectors;
import java.time.OffsetDateTime;
import org.springframework.web.server.*;
import org.springframework.http.*;

/* Import classes */

// models
import com.mealchemy.vault.model.Vault;
import com.mealchemy.auth.model.User;
import com.mealchemy.vault.model.VaultMember;
import com.mealchemy.vault.model.VaultInvitation;

// dtos
import com.mealchemy.vault.dto.VaultInvitationRequest;
import com.mealchemy.vault.dto.VaultInvitationResponse;
import com.mealchemy.vault.dto.VaultMemberResponse;

// repositories
import com.mealchemy.vault.repository.VaultRepository;
import com.mealchemy.vault.repository.VaultMemberRepository;
import com.mealchemy.vault.repository.VaultInvitationRepository;
import com.mealchemy.auth.repository.UserRepository;

// enums
import com.mealchemy.shared.enums.VaultType;
import com.mealchemy.shared.enums.InvitationStatus;
import com.mealchemy.shared.enums.VaultMemberRole;

@Service
public class VaultInvitationService
{   
    private final VaultRepository vaultRepository;
    private final VaultMemberRepository vaultMemberRepository;
    private final VaultInvitationRepository vaultInvitationRepository;
    private final UserRepository userRepository;

    public VaultInvitationService(VaultRepository vaultRepository, VaultMemberRepository vaultMemberRepository, VaultInvitationRepository vaultInvitationRepository, UserRepository userRepository)
    {
        this.vaultRepository = vaultRepository;
        this.vaultMemberRepository = vaultMemberRepository;
        this.vaultInvitationRepository = vaultInvitationRepository;
        this.userRepository = userRepository;
    }

    // POST - create invitation (owner of a vault invites a user to the vault)
    public VaultInvitationResponse createInvitation(Integer vaultId, VaultInvitationRequest request, Integer ownerId) 
    {
        // check vault exists
        Vault selectedVault = vaultRepository.findById(vaultId)
                        .orElseThrow(() -> new ResponseStatusException(HttpStatus.NOT_FOUND, "Vault not found."));

        if (!selectedVault.getOwnerId().equals(ownerId)) 
        {
            throw new ResponseStatusException(HttpStatus.FORBIDDEN, "You are not the Vault owner.");
        }

        // check vault is shared 
        if (!selectedVault.getVaultType().equals(VaultType.SHARED)) 
        {
            throw new ResponseStatusException(HttpStatus.FORBIDDEN, "Vault is not a shared vault.");
        }

        // find user to invite
        User invitedUser = userRepository.findByEmail(request.email())
                    .orElseThrow(() -> new ResponseStatusException(HttpStatus.NOT_FOUND, "Email not found."));

        // can't invite yourself
        if (invitedUser.getUserId().equals(ownerId)) {
            throw new ResponseStatusException(HttpStatus.BAD_REQUEST, "You cannot invite yourself.");
        }

        // user already in vault
        if (vaultMemberRepository.existsByVault_VaultIdAndUser_UserId(vaultId, invitedUser.getUserId())) {
            throw new ResponseStatusException(HttpStatus.CONFLICT, "User already a member of this vault.");
        }

        // if a pending invitation already exists for this user for this vault
        if (vaultInvitationRepository.existsByVault_VaultIdAndInvitedUser_UserIdAndStatus(vaultId, invitedUser.getUserId(), InvitationStatus.PENDING)) {
            throw new ResponseStatusException(HttpStatus.CONFLICT, "User already has a pending invitation for vault.");
        }

        // find owner user
        User owner = userRepository.findById(ownerId)
                    .orElseThrow(() -> new ResponseStatusException(HttpStatus.NOT_FOUND, "User not found."));

        // building invitation
        VaultInvitation newInvitation = new VaultInvitation();
        newInvitation.setVault(selectedVault);
        newInvitation.setInvitedUser(invitedUser);
        newInvitation.setInvitedByUser(owner);
        newInvitation.setStatus(InvitationStatus.PENDING);
        newInvitation.setExpiresAt(OffsetDateTime.now().plusDays(7)); // invitation expires after 7 days

        VaultInvitation saved = vaultInvitationRepository.save(newInvitation);

        // TODO: Vault invitation notification 

        return VaultInvitationResponse.from(saved);
    }


    // GET - Get all the invitations for a specific vault (owners view)
    public List<VaultInvitationResponse> getVaultInvitations(Integer vaultId, Integer ownerId) {
        // check vault exists
        Vault selectedVault = vaultRepository.findById(vaultId)
                        .orElseThrow(() -> new ResponseStatusException(HttpStatus.NOT_FOUND, "Vault not found."));

        // check owner of vault
        if (!selectedVault.getOwnerId().equals(ownerId)) 
        {
            throw new ResponseStatusException(HttpStatus.FORBIDDEN, "You are not the Vault owner.");
        }

        List<VaultInvitation> selectedVaultInvitations = vaultInvitationRepository.findByVault_VaultId(vaultId);

        return selectedVaultInvitations.stream()
            .map(VaultInvitationResponse::from)
            .collect(Collectors.toList());
    }


    // GET - Get all of the pending invitations for the passed in user
    public List<VaultInvitationResponse> getMyPendingInvitations(Integer userId) 
    {
        List<VaultInvitation> usersVaultInvitations = vaultInvitationRepository.findByInvitedUser_UserIdAndStatus(userId, InvitationStatus.PENDING);

        return usersVaultInvitations.stream()
            .map(VaultInvitationResponse::from)
            .collect(Collectors.toList());
    }

    // POST - User accepts a PENDING invitation
    @Transactional
    public VaultMemberResponse acceptInvitation(Integer invitationId, Integer userId) 
    {
        VaultInvitation invite = vaultInvitationRepository.findById(invitationId)
                            .orElseThrow(() -> new ResponseStatusException(HttpStatus.NOT_FOUND, "Vault invitation not found."));

        // check user is the invitee
        if (!invite.getInvitedUser().getUserId().equals(userId)) {
            throw new ResponseStatusException(HttpStatus.FORBIDDEN, "User not the intended recipient.");
        }

        if (!invite.getStatus().equals(InvitationStatus.PENDING)) {
            throw new ResponseStatusException(HttpStatus.CONFLICT, "Invitation has the wrong status.");
        }

        // creating new Vault member
        VaultMember newMember = new VaultMember();
        newMember.setUser(invite.getInvitedUser());
        newMember.setVault(invite.getVault());
        newMember.setRole(VaultMemberRole.VIEWER);

        VaultMember savedMember = vaultMemberRepository.save(newMember);

        // update invitation status
        invite.setStatus(InvitationStatus.ACCEPTED);
        invite.setRespondedAt(OffsetDateTime.now());
        vaultInvitationRepository.save(invite);

        // TODO: Notification - invitation accepted

        return VaultMemberResponse.from(savedMember);
    }

    // PUT - User declines a PENDING invitation
    @Transactional
    public VaultInvitationResponse declineInvitation(Integer invitationId, Integer userId) 
    {
        VaultInvitation invite = vaultInvitationRepository.findById(invitationId)
                            .orElseThrow(() -> new ResponseStatusException(HttpStatus.NOT_FOUND, "Vault invitation not found."));

        // check user is the invitee
        if (!invite.getInvitedUser().getUserId().equals(userId)) {
            throw new ResponseStatusException(HttpStatus.FORBIDDEN, "User not the intended recipient.");
        }

        if (!invite.getStatus().equals(InvitationStatus.PENDING)) {
            throw new ResponseStatusException(HttpStatus.CONFLICT, "Invitation has the wrong status.");
        }

        // update invitation status
        invite.setStatus(InvitationStatus.DECLINED);
        invite.setRespondedAt(OffsetDateTime.now());
        
        VaultInvitation saved = vaultInvitationRepository.save(invite);

        // TODO: Notification - invitation declined

        return VaultInvitationResponse.from(saved);

    }


    // PUT - Vault owner cancels pending invitation
    @Transactional
    public void cancelInvitation(Integer invitationId, Integer ownerId) 
    {
        VaultInvitation invite = vaultInvitationRepository.findById(invitationId)
                            .orElseThrow(() -> new ResponseStatusException(HttpStatus.NOT_FOUND, "Vault invitation not found."));

        // check owner of vault
        if (!invite.getVault().getOwnerId().equals(ownerId)) 
        {
            throw new ResponseStatusException(HttpStatus.FORBIDDEN, "You are not the Vault owner.");
        }

        if (!invite.getStatus().equals(InvitationStatus.PENDING)) {
            throw new ResponseStatusException(HttpStatus.CONFLICT, "Invitation has the wrong status.");
        }

        // update invitation status
        invite.setStatus(InvitationStatus.CANCELLED);
        invite.setRespondedAt(OffsetDateTime.now());

        // TODO: Notification - invitation accepted
        
        vaultInvitationRepository.save(invite);
    }
}