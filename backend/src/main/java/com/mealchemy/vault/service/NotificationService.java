package com.mealchemy.vault.service;

/* Import libraries */

import java.util.ArrayList;
import java.util.HashSet;
import java.util.List;
import java.util.Optional;
import java.util.Set;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.context.ApplicationEventPublisher;
import org.springframework.http.HttpStatus;
import org.springframework.messaging.simp.SimpMessagingTemplate;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Propagation;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.transaction.event.TransactionPhase;
import org.springframework.transaction.event.TransactionalEventListener;
import org.springframework.web.server.ResponseStatusException;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.PageRequest;

/* Import classes */

import com.mealchemy.auth.model.User;
import com.mealchemy.auth.repository.UserRepository;
import com.mealchemy.profile.model.UserProfile;
import com.mealchemy.profile.repository.UserProfileRepository;
import com.mealchemy.vault.dto.NotificationResponse;
import com.mealchemy.vault.dto.VaultLiveEventResponse;
import com.mealchemy.vault.event.NotificationEvent;
import com.mealchemy.vault.event.VaultLiveEvent;
import com.mealchemy.vault.model.Notification;
import com.mealchemy.vault.model.Vault;
import com.mealchemy.vault.model.VaultMember;
import com.mealchemy.vault.repository.NotificationRepository;
import com.mealchemy.vault.repository.VaultMemberRepository;
import com.mealchemy.vault.repository.VaultRepository;


@Service
public class NotificationService 
{
    private final ApplicationEventPublisher eventPublisher;
    private final NotificationRepository notificationRepository;
    private final VaultRepository vaultRepository;
    private final VaultMemberRepository vaultMemberRepository;
    private final UserRepository userRepository;
    private final UserProfileRepository userProfileRepository;
    private final SimpMessagingTemplate messagingTemplate;

    private static final String NOTIFICATION_DESTINATION = "/queue/notifications";
    private static final String VAULT_EVENT_DESTINATION = "/queue/vault-events";

    private static final Logger log = LoggerFactory.getLogger(NotificationService.class);

    public NotificationService(ApplicationEventPublisher eventPublisher, NotificationRepository notificationRepository, VaultRepository vaultRepository,
        VaultMemberRepository vaultMemberRepository, UserRepository userRepository, UserProfileRepository userProfileRepository, SimpMessagingTemplate messagingTemplate) 
        {
            this.eventPublisher = eventPublisher; 
            this.notificationRepository = notificationRepository;
            this.vaultRepository = vaultRepository;
            this.vaultMemberRepository = vaultMemberRepository;
            this.userRepository = userRepository;
            this.userProfileRepository = userProfileRepository;
            this.messagingTemplate = messagingTemplate;
        }
    

        public void publish(NotificationEvent event)
        {
            // no recipeints for notification - thereofor no need to publish
            if (event.recipientUserIds() == null || event.recipientUserIds().isEmpty()) 
            {
                return;
            }

            eventPublisher.publishEvent(event);
        }

        public void publishLiveEvent(VaultLiveEvent event)
        {
            // no recipeints for notification - thereofor no need to publish
            if (event.recipientUserIds() == null || event.recipientUserIds().isEmpty()) 
            {
                return;
            }

            eventPublisher.publishEvent(event);
        }


        // get all members of vault - exclude caller (person that triggered notification)
        public List<Integer> getVaultParticipantIds(Integer vaultId, Integer excludeUserId) 
        {
            // get vault to get owner
            Vault vault = vaultRepository.findById(vaultId)
                    .orElseThrow(() -> new ResponseStatusException(HttpStatus.NOT_FOUND, "Vault not found."));

            // create set
            Set<Integer> participantIds = new HashSet<>();
            
            // adding vault owner
            if (!vault.getOwnerId().equals(excludeUserId))
            {
                participantIds.add(vault.getOwnerId());
            }

            // get vault members 
            List<VaultMember> activeVaultMembers = vaultMemberRepository.findByVault_VaultId(vaultId);

            for (VaultMember member : activeVaultMembers)
            {
                if (!member.getUser().getUserId().equals(excludeUserId)) 
                {
                    participantIds.add(member.getUser().getUserId());
                }
            }

            return new ArrayList<>(participantIds);
        }

        // get display names - see who is doing what
        public String getDisplayName(Integer userId)
        {
            // display name in user profile
            Optional<UserProfile> profile = userProfileRepository.findByUserId(userId); // inside their transaction

            if (profile.isPresent() && profile.get().getDisplayName() != null && !profile.get().getDisplayName().isBlank())
            {
                return profile.get().getDisplayName();
            }

            return userRepository.findById(userId).map(User::getEmail)
                                                  .orElse("Someone");
        }


        // ========== Listeners ==========

        // run after transaction actually commits
        @TransactionalEventListener(phase = TransactionPhase.AFTER_COMMIT, fallbackExecution = true) // run immediately
        @Transactional(propagation = Propagation.REQUIRES_NEW)
        public void handleNotificationEvent(NotificationEvent event)
        {
            // finding actor of event
            User actor = (event.actorUserId() == null) ? null : userRepository.getReferenceById(event.actorUserId());

            // Notification list for each recipient
            List<Notification> recipients = new ArrayList<>();

            for (Integer recipientId : event.recipientUserIds())
            {
                Notification newNotification = new Notification();                
                newNotification.setRecipientUser(userRepository.getReferenceById(recipientId));
                newNotification.setActor(actor);
                newNotification.setType(event.type());
                newNotification.setMessage(event.message());
                newNotification.setRefVaultId(event.refVaultId());
                newNotification.setRefRecipeId(event.refRecipeId());
                newNotification.setRefInvitationId(event.refInvitationId());

                recipients.add(newNotification);
            }

            List<Notification> saved = notificationRepository.saveAll(recipients);

            for (Notification notification : saved)
            {
                try
                {
                    messagingTemplate.convertAndSendToUser(String.valueOf(notification.getRecipientUser().getUserId()), NOTIFICATION_DESTINATION, NotificationResponse.from(notification));
                }
                catch (Exception e)
                {
                    log.warn("Failed to push notification {} to user {}", notification.getNotificationId(), notification.getRecipientUser().getUserId(), e);
                }
            }
        }

        @TransactionalEventListener(phase = TransactionPhase.AFTER_COMMIT, fallbackExecution = true)
        public void handleLiveEvent(VaultLiveEvent event)
        {
            // building payload
            VaultLiveEventResponse payload = VaultLiveEventResponse.from(event);

            for (Integer recipientId : event.recipientUserIds())
            {
                try
                {
                    messagingTemplate.convertAndSendToUser(String.valueOf(recipientId), VAULT_EVENT_DESTINATION, payload);
                }
                catch (Exception e)
                {
                    log.warn("Failed to push {} event to user {}", event.type(),recipientId, e);
                }
                    
            }
        }

        // ========== Inbox methods ==========

        public Page<NotificationResponse> getInbox(Integer userId, int page, int size)
        {
            Page<Notification> notifications = notificationRepository.findByRecipientUser_UserIdOrderByCreatedAtDesc(userId, PageRequest.of(page, size));

            return notifications.map(NotificationResponse::from);
        }

        public long getNumUnread(Integer userId)
        {
            return notificationRepository.countByRecipientUser_UserIdAndIsReadFalse(userId);
        }

        @Transactional
        public NotificationResponse markAsRead(Integer notificationId, Integer userId)
        {
            Notification notificationToRead = notificationRepository.findByNotificationIdAndRecipientUser_UserId(notificationId, userId)
                                        .orElseThrow(() -> new ResponseStatusException(HttpStatus.NOT_FOUND, "Notification not found."));

            notificationToRead.setIsRead(true);

            Notification saved = notificationRepository.save(notificationToRead);

            return NotificationResponse.from(saved);
        }

        @Transactional
        public void markAllAsRead(Integer userId)
        {
            List<Notification> unreadNotifications = notificationRepository.findByRecipientUser_UserIdAndIsReadFalse(userId);

            for (Notification notification : unreadNotifications)
            {
                notification.setIsRead(true);
                notificationRepository.save(notification);
            }
        }


}