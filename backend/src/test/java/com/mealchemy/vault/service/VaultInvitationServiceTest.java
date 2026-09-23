// unit testing for VaultInvitationService
 
package com.mealchemy.vault;
 
//models
import com.mealchemy.vault.model.Vault;
import com.mealchemy.vault.model.VaultInvitation;
import com.mealchemy.vault.model.VaultMember;
import com.mealchemy.auth.model.User;
 
//dtos
import com.mealchemy.vault.dto.VaultMemberResponse;
import com.mealchemy.vault.dto.VaultInvitationResponse;
import com.mealchemy.vault.dto.VaultInvitationRequest;
 
//repositories
import com.mealchemy.vault.repository.VaultRepository;
import com.mealchemy.vault.repository.VaultMemberRepository;
import com.mealchemy.vault.repository.VaultInvitationRepository;
import com.mealchemy.auth.repository.UserRepository;
 
//enums
import com.mealchemy.shared.enums.VaultType;
import com.mealchemy.shared.enums.InvitationStatus;
import com.mealchemy.shared.enums.VaultMemberRole;
 
//service
import com.mealchemy.vault.service.VaultInvitationService;
 
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.extension.ExtendWith;
import org.mockito.InjectMocks;
import org.mockito.Mock;
import org.mockito.junit.jupiter.MockitoExtension;
import org.springframework.http.HttpStatus;
import org.springframework.web.server.ResponseStatusException;
import org.springframework.test.util.ReflectionTestUtils;
 
import java.util.List;
import java.util.Optional;
import java.time.OffsetDateTime;
 
import static org.junit.jupiter.api.Assertions.*;
import static org.mockito.ArgumentMatchers.any;
import static org.mockito.Mockito.*;


@ExtendWith(MockitoExtension.class)
public class VaultInvitationServiceTest {
    // @Mock - create fake version of dependency
    @Mock private VaultRepository vaultRepository;
    @Mock private VaultMemberRepository vaultMemberRepository;
    @Mock private VaultInvitationRepository vaultInvitationRepository;
    @Mock private UserRepository userRepository;

    @InjectMocks
    private VaultInvitationService vaultInvitationService;

    private User owner;
    private User invitedUser;
    private Vault sharedVault;
    private VaultInvitation existingInvitation ;
    private VaultInvitationRequest invitationRequest; 

    @BeforeEach
    void setUp() {
        // users
        owner = new User();
        owner.setEmail("owner@email.com");
        ReflectionTestUtils.setField(owner, "userId", 1);

        invitedUser = new User();
        invitedUser.setEmail("invitedUser@email.com");
        ReflectionTestUtils.setField(invitedUser, "userId", 2);

        // shared vault
        sharedVault = new Vault();
        sharedVault.setOwnerId(1);
        sharedVault.setVaultType(VaultType.SHARED);
        sharedVault.setName("Dinner Club");
        ReflectionTestUtils.setField(sharedVault, "vaultId", 5);
        ReflectionTestUtils.setField(sharedVault, "createdAt", OffsetDateTime.parse("2026-09-21T10:00:00Z"));

        // existing PENDING invitation
        existingInvitation = new VaultInvitation();
        existingInvitation.setVault(sharedVault);
        existingInvitation.setInvitedUser(invitedUser);
        existingInvitation.setInvitedByUser(owner);
        existingInvitation.setStatus(InvitationStatus.PENDING);
        existingInvitation.setExpiresAt(OffsetDateTime.parse("2026-09-28T10:00:00Z"));
        existingInvitation.setInvitationId(10);
        ReflectionTestUtils.setField(existingInvitation, "createdAt", OffsetDateTime.parse("2026-09-21T10:00:00Z"));

        // request DTOs
        invitationRequest = new VaultInvitationRequest("invitedUser@email.com");
    }

    // ========== Create vault invitation ==========
    @Test
    void createInvitation_valid_returns200() {
        // Arrange
        when(vaultRepository.findById(5)).thenReturn(Optional.of(sharedVault));
        when(userRepository.findByEmail("invitedUser@email.com")).thenReturn(Optional.of(invitedUser));
        when(vaultMemberRepository.existsByVault_VaultIdAndUser_UserId(5, 2)).thenReturn(false);
        when(vaultInvitationRepository.existsByVault_VaultIdAndInvitedUser_UserIdAndStatus(5, 2, InvitationStatus.PENDING)).thenReturn(false);
        when(userRepository.findById(1)).thenReturn(Optional.of(owner));
        // return what gets passed to saved
        when(vaultInvitationRepository.save(any(VaultInvitation.class))).thenAnswer(invocation -> invocation.getArgument(0));

        // Act
        VaultInvitationResponse response = vaultInvitationService.createInvitation(5, invitationRequest, 1);

        // Assert
        verify(vaultInvitationRepository).save(any(VaultInvitation.class));

        assertEquals(InvitationStatus.PENDING, response.status());
        assertEquals(5, response.vaultId());
        assertEquals("Dinner Club", response.vaultName());
        assertEquals("invitedUser@email.com", response.invitedEmail());
        assertEquals("owner@email.com", response.invitedByEmail());
    } 


    @Test
    void createInvitation_whenNoVaultFound_throwsNotFound() {
        // Arrange
        when(vaultRepository.findById(5)).thenReturn(Optional.empty());

        // Act 
        ResponseStatusException ex = assertThrows(
            ResponseStatusException.class,
            () -> vaultInvitationService.createInvitation(5, invitationRequest, 1)
        );

        // Assert
        assertEquals(HttpStatus.NOT_FOUND, ex.getStatusCode());
        verifyNoInteractions(userRepository, vaultMemberRepository, vaultInvitationRepository);
    }

    @Test
    void createInvitation_whenNotOwner_throwsForbidden() {
        // Arrange
        when(vaultRepository.findById(5)).thenReturn(Optional.of(sharedVault));

        // Act 
        ResponseStatusException ex = assertThrows(
            ResponseStatusException.class,
            () -> vaultInvitationService.createInvitation(5, invitationRequest, 4)
        );

        // Assert
        assertEquals(HttpStatus.FORBIDDEN, ex.getStatusCode());
        verifyNoInteractions(userRepository, vaultMemberRepository, vaultInvitationRepository);
    }

    @Test
    void createInvitation_whenInvitingSelf_throwsBadRequest() {
        // Arrange
        VaultInvitationRequest selfInvite = new VaultInvitationRequest("owner@email.com");
        when(vaultRepository.findById(5)).thenReturn(Optional.of(sharedVault));
        when(userRepository.findByEmail("owner@email.com")).thenReturn(Optional.of(owner));

        // Act 
        ResponseStatusException ex = assertThrows(
            ResponseStatusException.class,
            () -> vaultInvitationService.createInvitation(5, selfInvite, 1)
        );

        // Assert
        assertEquals(HttpStatus.BAD_REQUEST, ex.getStatusCode());
        verifyNoInteractions(vaultInvitationRepository);
    }

    @Test 
    void createInvitation_whenUserAlreadyMember_throwsConflict() {
        // Arrange
        when(vaultRepository.findById(5)).thenReturn(Optional.of(sharedVault));
        when(userRepository.findByEmail("invitedUser@email.com")).thenReturn(Optional.of(invitedUser));
        when(vaultMemberRepository.existsByVault_VaultIdAndUser_UserId(5, 2)).thenReturn(true);

        // Act 
        ResponseStatusException ex = assertThrows(
            ResponseStatusException.class,
            () -> vaultInvitationService.createInvitation(5, invitationRequest, 1)
        );

        // Assert
        assertEquals(HttpStatus.CONFLICT, ex.getStatusCode());
        verifyNoInteractions(vaultInvitationRepository);
    }


    // ========== Get vault invitations ==========

    @Test
    void getVaultInvitations_valid_returnsList() {
        // Arrange
        when(vaultRepository.findById(5)).thenReturn(Optional.of(sharedVault));
        when(vaultInvitationRepository.findByVault_VaultId(5)).thenReturn(List.of(existingInvitation));

        // Act
        List<VaultInvitationResponse> responses = vaultInvitationService.getVaultInvitations(5, 1);

        // Assert
        assertEquals(5, responses.get(0).vaultId());
        assertEquals("Dinner Club", responses.get(0).vaultName());
        assertEquals("invitedUser@email.com", responses.get(0).invitedEmail());
        assertEquals("owner@email.com", responses.get(0).invitedByEmail());
        assertEquals(InvitationStatus.PENDING, responses.get(0).status());
    }

    @Test
    void getVaultInvitations_noInvitations_returnsEmptyList() {
        // Arrange
        when(vaultRepository.findById(5)).thenReturn(Optional.of(sharedVault));
        when(vaultInvitationRepository.findByVault_VaultId(5)).thenReturn(List.of());

        // Act
        List<VaultInvitationResponse> responses = vaultInvitationService.getVaultInvitations(5, 1);

        // Assert
        assertTrue(responses.isEmpty());
    }

    @Test
    void getVaultInvitations_vaultNotFound_throwsNotFound() {
        // Arrange
        when(vaultRepository.findById(5)).thenReturn(Optional.empty());

        // Act 
        ResponseStatusException ex = assertThrows(
            ResponseStatusException.class,
            () -> vaultInvitationService.getVaultInvitations(5, 1)
        );

        // Assert
        assertEquals(HttpStatus.NOT_FOUND, ex.getStatusCode());
        verifyNoInteractions(vaultInvitationRepository);
    }

    @Test
    void getVaultInvitations_whenNotOwner_throwsForbidden() {
        // Arrange
        when(vaultRepository.findById(5)).thenReturn(Optional.of(sharedVault));

        // Act 
        ResponseStatusException ex = assertThrows(
            ResponseStatusException.class,
            () -> vaultInvitationService.getVaultInvitations(5, 4)
        );

        // Assert
        assertEquals(HttpStatus.FORBIDDEN, ex.getStatusCode());
        verifyNoInteractions(vaultInvitationRepository);
    }
  

    // ========== Get user's (my) pending invitations ==========

    @Test
    void getMyPendingInvitations_valid_returnsList() {
        // Arrange
        when(vaultInvitationRepository.findByInvitedUser_UserIdAndStatus(2, InvitationStatus.PENDING)).thenReturn(List.of(existingInvitation));

        // Act
        List<VaultInvitationResponse> responses = vaultInvitationService.getMyPendingInvitations(2);

        // Assert
        assertEquals(5, responses.get(0).vaultId());
        assertEquals("Dinner Club", responses.get(0).vaultName());
        assertEquals("invitedUser@email.com", responses.get(0).invitedEmail());
        assertEquals("owner@email.com", responses.get(0).invitedByEmail());
        assertEquals(InvitationStatus.PENDING, responses.get(0).status());
    }

    @Test
    void getMyPendingInvitations_noInvitations_returnsEmptyList() {
        // Arrange
        when(vaultInvitationRepository.findByInvitedUser_UserIdAndStatus(2, InvitationStatus.PENDING)).thenReturn(List.of());
        
        // Act
        List<VaultInvitationResponse> responses = vaultInvitationService.getMyPendingInvitations(2);

        // Assert
        assertTrue(responses.isEmpty());
    }


    // ========== Accept pending invitation ==========

    @Test
    void acceptInvitation_valid_createsMemberWithInvitedUser() {
        // Arrange
        when(vaultInvitationRepository.findById(10)).thenReturn(Optional.of(existingInvitation));
        when(vaultMemberRepository.save(any(VaultMember.class))).thenAnswer(invocation -> {
            VaultMember saved = invocation.getArgument(0);
            ReflectionTestUtils.setField(saved, "id", 15);
            return saved;
        });

        // Act
        VaultMemberResponse response = vaultInvitationService.acceptInvitation(10, invitedUser.getUserId());

        // Assert
        assertEquals(invitedUser.getUserId(), response.userId());
        assertEquals(sharedVault.getVaultId(), response.vaultId());
        assertEquals(VaultMemberRole.VIEWER, response.role());

        verify(vaultMemberRepository).save(any(VaultMember.class));
    }

    @Test 
    void acceptInvitation_valid_updatesInvitationToAccepted() {
        // Arrange
        when(vaultInvitationRepository.findById(10)).thenReturn(Optional.of(existingInvitation));
        when(vaultMemberRepository.save(any(VaultMember.class))).thenAnswer(invocation -> invocation.getArgument(0));

        // Act
        vaultInvitationService.acceptInvitation(10, invitedUser.getUserId());

        // Assert
        assertEquals(InvitationStatus.ACCEPTED, existingInvitation.getStatus());
        assertNotNull(existingInvitation.getRespondedAt());

        verify(vaultInvitationRepository).save(existingInvitation);
    }

    @Test
    void acceptInvitation_invitationNotFound_throwsNotFound() {
        // Arrange
        when(vaultInvitationRepository.findById(10)).thenReturn(Optional.empty());

        // Act 
        ResponseStatusException ex = assertThrows(
            ResponseStatusException.class,
            () -> vaultInvitationService.acceptInvitation(10, 2)
        );

        // Assert
        assertEquals(HttpStatus.NOT_FOUND, ex.getStatusCode());
        verifyNoInteractions(vaultMemberRepository);
    }

    @Test
    void acceptInvitation_callerNotInvitee_throwsForbidden() {
        // Arrange - existing userId = 2
        when(vaultInvitationRepository.findById(10)).thenReturn(Optional.of(existingInvitation));

        // Act 
        ResponseStatusException ex = assertThrows(
            ResponseStatusException.class,
            () -> vaultInvitationService.acceptInvitation(10, 3)
        );

        // Assert
        assertEquals(HttpStatus.FORBIDDEN, ex.getStatusCode());
        verifyNoInteractions(vaultMemberRepository);
    }

    @Test
    void acceptInvitation_notPending_throwsConflict() {
        // Arrange - right invitee but invite no longer PENDING
        existingInvitation.setStatus(InvitationStatus.ACCEPTED);
        when(vaultInvitationRepository.findById(10)).thenReturn(Optional.of(existingInvitation));

        // Act 
        ResponseStatusException ex = assertThrows(
            ResponseStatusException.class,
            () -> vaultInvitationService.acceptInvitation(10, 2)
        );

        // Assert
        assertEquals(HttpStatus.CONFLICT, ex.getStatusCode());
        verifyNoInteractions(vaultMemberRepository);
    }


    // ========== Decline pending invitation ==========

    @Test
    void declineInvitation_valid_setsDeclinedStatusAndRespondedAt() {
        // Arrange
        when(vaultInvitationRepository.findById(10)).thenReturn(Optional.of(existingInvitation));
        when(vaultInvitationRepository.save(any(VaultInvitation.class))).thenAnswer(invocation -> invocation.getArgument(0));

        // Act
        VaultInvitationResponse response = vaultInvitationService.declineInvitation(10, invitedUser.getUserId());

        // Assert
        assertEquals(InvitationStatus.DECLINED, response.status());
        assertNotNull(response.respondedAt());    

        verify(vaultInvitationRepository).save(existingInvitation);
        verifyNoInteractions(vaultMemberRepository);
    }

    @Test
    void declineInvitation_invitationNotFound_throwsNotFound() {
        // Arrange
        when(vaultInvitationRepository.findById(10)).thenReturn(Optional.empty());

        // Act 
        ResponseStatusException ex = assertThrows(
            ResponseStatusException.class,
            () -> vaultInvitationService.declineInvitation(10, 2)
        );

        // Assert
        assertEquals(HttpStatus.NOT_FOUND, ex.getStatusCode());
        verifyNoInteractions(vaultMemberRepository);
    }

    @Test
    void declineInvitation_callerNotInvitee_throwsForbidden() {
        // Arrange - existing userId = 2
        when(vaultInvitationRepository.findById(10)).thenReturn(Optional.of(existingInvitation));

        // Act 
        ResponseStatusException ex = assertThrows(
            ResponseStatusException.class,
            () -> vaultInvitationService.declineInvitation(10, 3)
        );

        // Assert
        assertEquals(HttpStatus.FORBIDDEN, ex.getStatusCode());
        verifyNoInteractions(vaultMemberRepository);
    }

    @Test
    void declineInvitation_notPending_throwsConflict() {
        // Arrange - right invitee but invite no longer PENDING
        existingInvitation.setStatus(InvitationStatus.ACCEPTED);
        when(vaultInvitationRepository.findById(10)).thenReturn(Optional.of(existingInvitation));

        // Act 
        ResponseStatusException ex = assertThrows(
            ResponseStatusException.class,
            () -> vaultInvitationService.declineInvitation(10, 2)
        );

        // Assert
        assertEquals(HttpStatus.CONFLICT, ex.getStatusCode());
        verifyNoInteractions(vaultMemberRepository);
    }


    // ========== Cancel pending invitation ==========

    @Test
    void cancelInvitation_valid_setsCancelledStatusAndRespondedAt() {
        // Arrange
        when(vaultInvitationRepository.findById(10)).thenReturn(Optional.of(existingInvitation));
        when(vaultInvitationRepository.save(any(VaultInvitation.class))).thenAnswer(invocation -> invocation.getArgument(0));

        // Act
        assertDoesNotThrow(() -> vaultInvitationService.cancelInvitation(10, owner.getUserId()));

        // Assert
        assertEquals(InvitationStatus.CANCELLED, existingInvitation.getStatus());
        assertNotNull(existingInvitation.getRespondedAt());

        // regression check
        verify(vaultInvitationRepository).save(existingInvitation);
        verifyNoInteractions(vaultMemberRepository);
    }


    @Test
    void cancelInvitation_invitationNotFound_throwsNotFound() {
        // Arrange
        when(vaultInvitationRepository.findById(10)).thenReturn(Optional.empty());

        // Act 
        ResponseStatusException ex = assertThrows(
            ResponseStatusException.class,
            () -> vaultInvitationService.cancelInvitation(10, owner.getUserId())
        );

        // Assert
        assertEquals(HttpStatus.NOT_FOUND, ex.getStatusCode());
        verifyNoInteractions(vaultMemberRepository);
    }

    @Test
    void cancelInvitation_callerNotOwner_throwsForbidden() {
        // Arrange - existing userId = 2
        when(vaultInvitationRepository.findById(10)).thenReturn(Optional.of(existingInvitation));

        // Act 
        ResponseStatusException ex = assertThrows(
            ResponseStatusException.class,
            () -> vaultInvitationService.cancelInvitation(10, 4)
        );

        // Assert
        assertEquals(HttpStatus.FORBIDDEN, ex.getStatusCode());
        verifyNoInteractions(vaultMemberRepository);
    }

    @Test
    void cancelInvitation_notPending_throwsConflict() {
        // Arrange - correct owner, but invite no longer PENDING
        existingInvitation.setStatus(InvitationStatus.ACCEPTED);
        when(vaultInvitationRepository.findById(10)).thenReturn(Optional.of(existingInvitation));

        ResponseStatusException ex = assertThrows(
            ResponseStatusException.class,
            () -> vaultInvitationService.cancelInvitation(10, owner.getUserId())
        );

        assertEquals(HttpStatus.CONFLICT, ex.getStatusCode());
        verifyNoInteractions(vaultMemberRepository);
    }
}