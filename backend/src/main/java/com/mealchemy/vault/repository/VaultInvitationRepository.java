package com.mealchemy.vault.repository;

/* Import libraries */
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;
import java.util.Optional;
import java.util.List;

/* Import classes */
import com.mealchemy.vault.model.VaultInvitation;
import com.mealchemy.shared.enums.InvitationStatus;

@Repository
public interface VaultInvitationRepository extends JpaRepository<VaultInvitation, Integer>
{
    // find all pending inviutations for logged in user
    List<VaultInvitation> findByInvitedUser_UserIdAndStatus(Integer userId, InvitationStatus status) ; 

    // find all invitations for a specific vault - owner's view of invitations sent
    List<VaultInvitation> findByVault_VaultId(Integer vaultId);


    Boolean existsByVault_VaultIdAndInvitedUser_UserIdAndStatus(Integer vaultId, Integer invitedUserId,  InvitationStatus status);
}