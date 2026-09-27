package com.mealchemy.vault.service;
 
/* Import libraries */
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.extension.ExtendWith;
import org.mockito.ArgumentCaptor;
import org.mockito.Captor;
import org.mockito.Mock;
import org.mockito.junit.jupiter.MockitoExtension;
import org.springframework.test.util.ReflectionTestUtils;
 
import java.util.HashSet;
import java.util.List;
import java.util.Optional;
import java.util.Set;
 
import static org.junit.jupiter.api.Assertions.*;
import static org.mockito.ArgumentMatchers.any;
import static org.mockito.ArgumentMatchers.anyInt;
import static org.mockito.ArgumentMatchers.anyList;
import static org.mockito.ArgumentMatchers.eq;
import static org.mockito.Mockito.*;
 
import org.springframework.context.ApplicationEventPublisher;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.PageImpl;
import org.springframework.data.domain.Pageable;
import org.springframework.http.HttpStatus;
import org.springframework.messaging.MessagingException;
import org.springframework.messaging.simp.SimpMessagingTemplate;
import org.springframework.web.server.ResponseStatusException;
 
/* Import classes */
import com.mealchemy.auth.model.User;
import com.mealchemy.auth.repository.UserRepository;
import com.mealchemy.profile.model.UserProfile;
import com.mealchemy.profile.repository.UserProfileRepository;
import com.mealchemy.shared.enums.NotificationType;
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


@ExtendWith(MockitoExtension.class)
public class NotificationServiceTest {
    // @Mock - create fake version of dependency
    @Mock private ApplicationEventPublisher eventPublisher;
    @Mock private NotificationRepository notificationRepository; 
    @Mock private VaultRepository vaultRepository; 
    @Mock private VaultMemberRepository vaultMemberRepository; 
    @Mock private UserRepository userRepository; 
    @Mock private UserProfileRepository userProfileRepository;
    @Mock private SimpMessagingTemplate messagingTemplate; 

    private static final String NOTIFICATION_DESTINATION = "/queue/notifications";
    private static final String VAULT_EVENT_DESTINATION = "/queue/vault-events";

    private static final Integer RECIPE_ID = 22;
    private static final Integer VAULT_ID = 10;
    private static final Integer OWNER_ID = 1;
    private static final Integer ACTOR_ID = 7;
    private static final Integer USER_A_ID = 5;
    private static final Integer USER_B_ID = 6;

    // for save all
    @Captor private ArgumentCaptor<List<Notification>> notificationsCaptor;

    private NotificationService notificationService; 

    private User actor;
    private User userA;
    private User userB;

    @BeforeEach
    void setUp()
    {
        notificationService = new NotificationService(eventPublisher, notificationRepository, vaultRepository, vaultMemberRepository, userRepository, userProfileRepository, messagingTemplate);
        actor = createUser(ACTOR_ID, "actor@email.com");
        userA = createUser(USER_A_ID, "userA@email.com");
        userB = createUser(USER_B_ID, "userB@email.com");
    }

    // ========== Helpers ==========

    private User createUser(Integer id, String email)
    {
        User user = new User();
        ReflectionTestUtils.setField(user, "userId", id);
        user.setEmail(email);
        return user;
    }

    private Vault createVaultOwnedBy(Integer ownerId)
    {
        Vault vault = new Vault();
        vault.setOwnerId(ownerId);
        return vault;
    }

    private VaultMember createVaultMember(Vault vault, Integer userId)
    {
        VaultMember member = new VaultMember();
        member.setVault(vault);
        member.setUser(createUser(userId, "member" + userId + "email.com"));
        return member;
    }

    private NotificationEvent createEvent(List<Integer> recipients, Integer actorId)
    {
        return new NotificationEvent(
            recipients,
            actorId,
            NotificationType.RECIPE_ADDED,
            "Test user added Penne to Family Dinners",
            VAULT_ID,
            RECIPE_ID,
            null
        );
    }

    private VaultLiveEvent createLiveEvent(List<Integer> recipients)
    {
        return new VaultLiveEvent(recipients, NotificationType.LOCK_ACQUIRED, VAULT_ID, RECIPE_ID, ACTOR_ID);
    }


    private Notification createNotification(Integer id, User recipient, boolean isRead)
    {
        Notification notification = new Notification();
        notification.setNotificationId(id);
        notification.setRecipientUser(recipient);
        notification.setType(NotificationType.RECIPE_ADDED);
        notification.setIsRead(isRead);
        notification.setMessage("message" + id);
        return notification;
    }

    // saveAll
    private void saveAllReturnsInput()
    {
        when(notificationRepository.saveAll(anyList())).thenAnswer(invocation -> invocation.getArgument(0));
    }

    // ========= Tests ==========

    // publish event
    @Test 
    void publishLiveEvent_withRecipients_publishesEvent()
    {
        // Arrange
        NotificationEvent event = createEvent(List.of(USER_A_ID), ACTOR_ID);

        // Act 
        notificationService.publish(event);

        // Assert
        verify(eventPublisher).publishEvent(event);
    }

    @Test 
    void publishLiveEvent_emptyRecipients_doesNothing()
    {
        // Arrange
        NotificationEvent event = createEvent(null, ACTOR_ID);

        // Act 
        notificationService.publish(event);

        // Assert
        verifyNoInteractions(eventPublisher);
    }

    // publish live event
    @Test 
    void publish_withRecipients_publishes()
    {
        // Arrange
        VaultLiveEvent event = new VaultLiveEvent(
            List.of(USER_A_ID),
            NotificationType.LOCK_ACQUIRED,
            VAULT_ID,
            22,
            ACTOR_ID
        );

        // Act 
        notificationService.publishLiveEvent(event);

        // Assert
        verify(eventPublisher).publishEvent(event);
    }

    @Test 
    void publish_noRecipients_doesNothing()
    {
        // Arrange
        VaultLiveEvent event = new VaultLiveEvent(
            List.of(),
            NotificationType.LOCK_ACQUIRED,
            VAULT_ID,
            22,
            ACTOR_ID
        );

        // Act 
        notificationService.publishLiveEvent(event);

        // Assert
        verifyNoInteractions(eventPublisher);
    }


    // get vault members
    @Test
    void getVaultParticipantIds_includeOwnerAndMembers_excludeActor()
    {
        // Arrange
        Vault vault = createVaultOwnedBy(OWNER_ID);
        when(vaultRepository.findById(VAULT_ID)).thenReturn(Optional.of(vault));
        when(vaultMemberRepository.findByVault_VaultId(VAULT_ID)).thenReturn(List.of(createVaultMember(vault, 2), createVaultMember(vault, 3)));

        // Act
        List<Integer> result = notificationService.getVaultParticipantIds(VAULT_ID, 2);

        // Assert
        assertEquals(Set.of(OWNER_ID, 3), new HashSet<>(result));
    }

    @Test
    void getVaultParticipantIds_actorIsOwner_excludeActor()
    {
        // Arrange
        Vault vault = createVaultOwnedBy(OWNER_ID);
        when(vaultRepository.findById(VAULT_ID)).thenReturn(Optional.of(vault));
        when(vaultMemberRepository.findByVault_VaultId(VAULT_ID)).thenReturn(List.of(createVaultMember(vault, 2), createVaultMember(vault, 3)));

        // Act
        List<Integer> result = notificationService.getVaultParticipantIds(VAULT_ID, OWNER_ID);

        // Assert
        assertEquals(Set.of(2, 3), new HashSet<>(result));
    }

    @Test 
    void getVaultParticipantIds_noMembers_ownerOnly()
    {
        // Arrange 
        when(vaultRepository.findById(VAULT_ID)).thenReturn(Optional.of(createVaultOwnedBy(OWNER_ID)));
        when(vaultMemberRepository.findByVault_VaultId(VAULT_ID)).thenReturn(List.of());
 
        // Act
        List<Integer> result = notificationService.getVaultParticipantIds(VAULT_ID, ACTOR_ID);

        // Assert
        assertEquals(Set.of(OWNER_ID), new HashSet<>(result));
    }

    @Test 
    void getVaultParticipantIds_vaultNotFound_throwNotFound()
    {
        // Arrange
        when(vaultRepository.findById(99)).thenReturn(Optional.empty());

        // Act
        ResponseStatusException ex = assertThrows(
            ResponseStatusException.class,
            () -> notificationService.getVaultParticipantIds(99, OWNER_ID)
        );

        // Assert
        assertEquals(HttpStatus.NOT_FOUND, ex.getStatusCode());
    }


    // get display name
    @Test
    void getDisplayName_profileWithName_returnName()
    {
        // Arrange
        UserProfile profile = new UserProfile();
        profile.setDisplayName("Test user");

        when(userProfileRepository.findByUserId(ACTOR_ID)).thenReturn(Optional.of(profile));

        // Act
        String displayName = notificationService.getDisplayName(ACTOR_ID);

        // Assert
        assertEquals("Test user", displayName);
        verifyNoInteractions(userRepository);
    }

    @Test
    void getDisplayName_noName_fallBackOnEmail()
    {
        // Arrange
        UserProfile profile = new UserProfile();
        profile.setDisplayName("");

        when(userProfileRepository.findByUserId(ACTOR_ID)).thenReturn(Optional.of(profile));
        when(userRepository.findById(ACTOR_ID)).thenReturn(Optional.of(actor));

        // Act
        String email = notificationService.getDisplayName(ACTOR_ID);

        // Assert
        assertEquals("actor@email.com", email);
    }

    
    // handle notification event
    @Test
    void handleNotificationEvent_savesOneRowPerRecipient()
    {
        // Arrange 
        when(userRepository.getReferenceById(ACTOR_ID)).thenReturn(actor);
        when(userRepository.getReferenceById(USER_A_ID)).thenReturn(userA);
        when(userRepository.getReferenceById(USER_B_ID)).thenReturn(userB);
        saveAllReturnsInput();

        // Act
        notificationService.handleNotificationEvent(createEvent(List.of(USER_A_ID, USER_B_ID), ACTOR_ID));

        // Assert
        verify(notificationRepository).saveAll(notificationsCaptor.capture());
        List<Notification> saved = notificationsCaptor.getValue();

        assertEquals(2, saved.size());
        assertEquals(userA, saved.get(0).getRecipientUser());
        assertEquals(userB, saved.get(1).getRecipientUser());

        for (Notification notification : saved)
        {
            assertSame(actor, notification.getActor());
            assertEquals(NotificationType.RECIPE_ADDED, notification.getType());
            assertEquals("Test user added Penne to Family Dinners", notification.getMessage());
            assertEquals(VAULT_ID, notification.getRefVaultId());
            assertEquals(RECIPE_ID, notification.getRefRecipeId());
            assertNull(notification.getRefInvitationId());
        }
    }

    @Test
    void handleNotificationEvent_pushesToEachRecipient()
    {
        // Arrange 
        when(userRepository.getReferenceById(ACTOR_ID)).thenReturn(actor);
        when(userRepository.getReferenceById(USER_A_ID)).thenReturn(userA);
        when(userRepository.getReferenceById(USER_B_ID)).thenReturn(userB);
        saveAllReturnsInput();

        // Act
        notificationService.handleNotificationEvent(createEvent(List.of(USER_A_ID, USER_B_ID), ACTOR_ID));

        // Assert - userId sent as a String (WebSocket principal name)
        verify(messagingTemplate).convertAndSendToUser(eq("5"), eq(NOTIFICATION_DESTINATION), any(NotificationResponse.class));
        verify(messagingTemplate).convertAndSendToUser(eq("6"), eq(NOTIFICATION_DESTINATION), any(NotificationResponse.class));
    }

    @Test
    void handleNotificationEvent_withNullActor_savesWithNullActor()
    {
        when(userRepository.getReferenceById(USER_A_ID)).thenReturn(userA);
        saveAllReturnsInput();

        // Act 
        notificationService.handleNotificationEvent(createEvent(List.of(USER_A_ID), null));
        
        // Assert
        verify(notificationRepository).saveAll(notificationsCaptor.capture());
        assertNull(notificationsCaptor.getValue().get(0).getActor());

        verify(userRepository, times(1)).getReferenceById(anyInt());
    }

    @Test
    void handleNotificationEvent_saveFails_nothingPushed()
    {
        // Arrange
        when(userRepository.getReferenceById(ACTOR_ID)).thenReturn(actor);
        when(userRepository.getReferenceById(USER_A_ID)).thenReturn(userA);
        when(notificationRepository.saveAll(anyList())).thenThrow(new RuntimeException("db down"));
 
        // Act
        assertThrows(
            RuntimeException.class,
            () -> notificationService.handleNotificationEvent(createEvent(List.of(USER_A_ID), ACTOR_ID))
        );
 
        // Assert - save happens before push, so a failed save means no push
        verifyNoInteractions(messagingTemplate);
    }


    // handle live event
    @Test
    void handleLiveEvent_pushesToRecipient()
    {
        // Arrange
        ArgumentCaptor<VaultLiveEventResponse> payloadCaptor = ArgumentCaptor.forClass(VaultLiveEventResponse.class);

        // Act
        notificationService.handleLiveEvent(createLiveEvent(List.of(USER_A_ID, USER_B_ID)));

        // Assert
        verify(messagingTemplate).convertAndSendToUser(eq("5"), eq(VAULT_EVENT_DESTINATION), payloadCaptor.capture());
        verify(messagingTemplate).convertAndSendToUser(eq("6"), eq(VAULT_EVENT_DESTINATION), any(VaultLiveEventResponse.class));
 
        VaultLiveEventResponse payload = payloadCaptor.getValue();
        assertEquals(NotificationType.LOCK_ACQUIRED, payload.type());
        assertEquals(VAULT_ID, payload.vaultId());
        assertEquals(RECIPE_ID, payload.recipeId());
        assertEquals(ACTOR_ID, payload.actorUserId());
    }

    @Test
    void handleLiveEvent_neverSaves()
    {
        // Act
        notificationService.handleLiveEvent(createLiveEvent(List.of(USER_A_ID, USER_B_ID)));

        // Assert
        verifyNoInteractions(notificationRepository);
    }


    // get inbox
    @Test
    void getInbox_mapsPageToResponse()
    {
        // Arrange
        Page<Notification> page = new PageImpl<>(List.of(createNotification(1, userA, false), createNotification(2, userA, true)));

        when(notificationRepository.findByRecipientUser_UserIdOrderByCreatedAtDesc(eq(USER_A_ID), any(Pageable.class))).thenReturn(page);

        // Act
        Page<NotificationResponse> result = notificationService.getInbox(USER_A_ID, 0, 20);

        // Assert
        assertEquals(2, result.getContent().size());
        assertEquals(1, result.getContent().get(0).notificationId());
        assertFalse(result.getContent().get(0).isRead());
        assertEquals(2, result.getContent().get(1).notificationId());
        assertTrue(result.getContent().get(1).isRead());
    }

    @Test
    void getInbox_passPageAndSize()
    {
        // Arrange
        when(notificationRepository.findByRecipientUser_UserIdOrderByCreatedAtDesc(eq(USER_A_ID), any(Pageable.class))).thenReturn(Page.empty());
        ArgumentCaptor<Pageable> pageableCaptor = ArgumentCaptor.forClass(Pageable.class);
        
        // Act
        notificationService.getInbox(USER_A_ID, 2, 15);

        // Assert
        verify(notificationRepository).findByRecipientUser_UserIdOrderByCreatedAtDesc(eq(USER_A_ID), pageableCaptor.capture());
        assertEquals(2, pageableCaptor.getValue().getPageNumber());
        assertEquals(15, pageableCaptor.getValue().getPageSize());
    }


    // get number of unread notifications
    @Test
    void getNumUnread_returnsCount()
    {
        // Arrange
        when(notificationRepository.countByRecipientUser_UserIdAndIsReadFalse(USER_A_ID)).thenReturn(4L);

        // Act 
        long count = notificationService.getNumUnread(USER_A_ID);
       
        // Assert
        assertEquals(4L, count);
    }


    // mark as read
    @Test
    void markAsRead_ownNotification_setReadTrue()
    {
        // Arrange
        Notification notification = createNotification(1, userA, false);
        when(notificationRepository.findByNotificationIdAndRecipientUser_UserId(1, USER_A_ID)).thenReturn(Optional.of(notification));
        when(notificationRepository.save(notification)).thenReturn(notification);

        // Act
        NotificationResponse response = notificationService.markAsRead(1, USER_A_ID);

        // Assert
        assertTrue(notification.getIsRead());
        assertEquals(1, response.notificationId());
        assertTrue(response.isRead());
    }
    

    @Test
    void markAsRead_notificationNotFound_throwsNotFound()
    {
        // Arrange
        when(notificationRepository.findByNotificationIdAndRecipientUser_UserId(1, USER_B_ID)).thenReturn(Optional.empty());

        // Act 
        ResponseStatusException ex = assertThrows(
            ResponseStatusException.class,
            () -> notificationService.markAsRead(1, USER_B_ID)
        );

        // Assert
        assertEquals(HttpStatus.NOT_FOUND, ex.getStatusCode());
        verify(notificationRepository, never()).save(any(Notification.class));
    }


    // mark all as read
    @Test
    void markAllAsRead_setsAllUnreadToRead()
    {
        // Arrange
        Notification first = createNotification(1, userA, false);
        Notification second = createNotification(2, userA, false);

        when(notificationRepository.findByRecipientUser_UserIdAndIsReadFalse(USER_A_ID)).thenReturn(List.of(first, second));

        // Act 
        notificationService.markAllAsRead(USER_A_ID);

        // Assert
        assertTrue(first.getIsRead());
        assertTrue(second.getIsRead());
    }

    @Test
    void markAllAsRead_nonUnread_doNothing()
    {
        // Arrange
        when(notificationRepository.findByRecipientUser_UserIdAndIsReadFalse(USER_A_ID)).thenReturn(List.of());

        // Act and Assert
        assertDoesNotThrow(() -> notificationService.markAllAsRead(USER_A_ID));
        verify(notificationRepository, never()).save(any(Notification.class));
    }
}
