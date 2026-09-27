package com.mealchemy.vault.controller;
 
/* Import libraries */
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.extension.ExtendWith;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.autoconfigure.web.servlet.WebMvcTest;
import org.springframework.test.context.bean.override.mockito.MockitoBean;
import org.springframework.http.HttpStatus;
import org.springframework.test.web.servlet.MockMvc;
import org.springframework.test.context.junit.jupiter.SpringExtension;
import static org.springframework.security.test.web.servlet.request.SecurityMockMvcRequestPostProcessors.csrf;
 
import java.time.OffsetDateTime;
import java.util.List;
 
import org.springframework.data.domain.PageImpl;
import org.springframework.data.domain.PageRequest;
import com.mealchemy.config.JwtUtil;
 
import static org.mockito.Mockito.*;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.*;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.*;
 
import org.springframework.web.server.ResponseStatusException;
 
/* Import classes */
import com.mealchemy.vault.dto.NotificationResponse;
import com.mealchemy.vault.service.NotificationService;
import com.mealchemy.shared.enums.NotificationType;
import com.mealchemy.config.WithMockJwtUser;
 
@ExtendWith(SpringExtension.class)
@WebMvcTest(NotificationController.class)
@WithMockJwtUser(userId = "1")
public class NotificationControllerTest 
{
    @Autowired
    private MockMvc mockMvc;

    @MockitoBean
    private JwtUtil jwtUtil;
    
    @MockitoBean
    private NotificationService notificationService;
    
    private NotificationResponse unreadNotification;
    private NotificationResponse readNotification;

    @BeforeEach
    void setUp()
    {
        unreadNotification = new NotificationResponse(
            32,
            NotificationType.RECIPE_ADDED,
            "Test user added Penne to Family Dinners",
            false,
            7,
            10,
            22,
            null,
            OffsetDateTime.parse("2026-09-24T10:01:30Z")
        );

        readNotification = new NotificationResponse(
            31,
            NotificationType.VAULT_INVITE,
            "Owner invited you to join Family Dinners",
            true,
            7,
            10,
            null,
            3,
            OffsetDateTime.parse("2026-09-24T10:01:30Z")
        );
    }

    // ========== Helpers ==========

    // Page requet
    private PageImpl<NotificationResponse> pageOf(List<NotificationResponse> items, int page, int size)
    {
        return new PageImpl<>(items, PageRequest.of(page, size), items.size());
    }


    // ========== Get inbox (GET /notifications) ==========

    @Test 
    void getInbox_withNotifications_returns200() throws Exception
    {
        // Arrange
        when(notificationService.getInbox(1, 0, 20)).thenReturn(pageOf(List.of(unreadNotification, readNotification), 0, 20));

        // Act
        mockMvc.perform(get("/notifications"))
            .andExpect(status().isOk())
            .andExpect(jsonPath("$.content.length()").value(2))
            .andExpect(jsonPath("$.content[0].notificationId").value(32))
            .andExpect(jsonPath("$.content[0].type").value("RECIPE_ADDED"))
            .andExpect(jsonPath("$.content[0].message").value("Test user added Penne to Family Dinners"))
            .andExpect(jsonPath("$.content[0].isRead").value(false))
            .andExpect(jsonPath("$.content[0].refVaultId").value(10))
            .andExpect(jsonPath("$.content[0].refRecipeId").value(22))
            .andExpect(jsonPath("$.content[1].notificationId").value(31))
            .andExpect(jsonPath("$.content[1].isRead").value(true))
            .andExpect(jsonPath("$.content[1].refInvitationId").value(3));            
    }

    @Test
    void getInbox_noNotifications_returns200withEmptyContent() throws Exception
    {
        // Arrange
        when(notificationService.getInbox(1, 0, 20)).thenReturn(pageOf(List.of(), 0, 20));

        // Act
        mockMvc.perform(get("/notifications"))
            .andExpect(status().isOk())
            .andExpect(jsonPath("$.content.length()").value(0));
    }

    @Test 
    void getInbox_customPageAndSize_returns200() throws Exception
    {
        // Arrange
        when(notificationService.getInbox(1, 2, 10)).thenReturn(pageOf(List.of(), 2, 10));

        // Act
        mockMvc.perform(get("/notifications").param("page", "2").param("size", "10"))
            .andExpect(status().isOk());    
            
        // Assert
        verify(notificationService).getInbox(1, 2, 10);
    }

    @Test 
    void getInbox_negativePage_clampToZero() throws Exception
    {
        // Arrange
        when(notificationService.getInbox(1, 0, 20)).thenReturn(pageOf(List.of(), 0, 20));

        // Act
        mockMvc.perform(get("/notifications").param("page", "-2"))
            .andExpect(status().isOk());    
            
        // Assert
        verify(notificationService).getInbox(1, 0, 20);
    }

    @Test 
    void getInbox_sizeZero_clampToOne() throws Exception
    {
        // Arrange
        when(notificationService.getInbox(1, 0, 1)).thenReturn(pageOf(List.of(), 0, 1));

        // Act
        mockMvc.perform(get("/notifications").param("size", "0"))
            .andExpect(status().isOk());    
            
        // Assert
        verify(notificationService).getInbox(1, 0, 1);
    }

    @Test 
    void getInbox_sizeGreaterThanMax_clampToFifty() throws Exception
    {
        // Arrange
        when(notificationService.getInbox(1, 0, 50)).thenReturn(pageOf(List.of(), 0, 50));

        // Act
        mockMvc.perform(get("/notifications").param("size", "100"))
            .andExpect(status().isOk());    
            
        // Assert
        verify(notificationService).getInbox(1, 0, 50);
    }

    @Test 
    void getInbox_pageNumberNotANumber_returns400() throws Exception
    {
        // Act
        mockMvc.perform(get("/notifications").param("page", "non-number"))
            .andExpect(status().isBadRequest());
            
        // Assert
        verifyNoInteractions(notificationService);
    }


    // ========== Get unread count (GET /notifications/unread-count) ==========

    @Test
    void getNumberOfUnreadMessages_returns200() throws Exception
    {
        // Arrange
        when(notificationService.getNumUnread(1)).thenReturn(4L);

        // Act and Assert
        mockMvc.perform(get("/notifications/unread-count"))
            .andExpect(status().isOk())
            .andExpect(content().string("4"));
    }

    @Test
    void getNumberOfUnreadMessages_nonUnread_returns200WithZero() throws Exception
    {
        // Arrange
        when(notificationService.getNumUnread(1)).thenReturn(0L);

        // Act and Assert
        mockMvc.perform(get("/notifications/unread-count"))
            .andExpect(status().isOk())
            .andExpect(content().string("0"));
    }


    // ========== Mark one as read (PATCH /notifications/{notificationId}/read) ==========

    @Test
    void markNotificationAsRead_ownNotification_returns200() throws Exception
    {
        // Arrange 
        NotificationResponse marked = new NotificationResponse(
            32,
            NotificationType.RECIPE_ADDED,
            "Test user added Penne to Family Dinners",
            true,
            7,
            10,
            22,
            null,
            OffsetDateTime.parse("2026-09-24T10:01:30Z")
        );

        when(notificationService.markAsRead(32, 1)).thenReturn(marked);

        // Act and Assert
        mockMvc.perform(patch("/notifications/32/read")
            .with(csrf()))
            .andExpect(status().isOk())
            .andExpect(jsonPath("$.notificationId").value(32))
            .andExpect(jsonPath("$.isRead").value(true));
    }

    @Test
    void markNotificationAsRead_notFoundOrOtherUser_returns404() throws Exception 
    {
        // Arrange
        when(notificationService.markAsRead(99, 1)).thenThrow(new ResponseStatusException(HttpStatus.NOT_FOUND, "Notification not found."));

        // Act and Assert
        mockMvc.perform(patch("/notifications/99/read")
            .with(csrf()))
            .andExpect(status().isNotFound())
            .andExpect(jsonPath("$.message").value("Notification not found."));    
    }

    @Test
    void markNotificationAsRead_nonNumericId_returns400() throws Exception
    {
        // Act and Assert
        mockMvc.perform(patch("/notifications/non-number/read")
            .with(csrf()))
            .andExpect(status().isBadRequest());
 
        verifyNoInteractions(notificationService);
    }

    // ========== Mark all as read (PATCH /notifications/read-all) ==========
 
    @Test
    void markAllNotificationAsRead_returns204() throws Exception
    {
        // Arrange
        doNothing().when(notificationService).markAllAsRead(1);
 
        // Act and Assert
        mockMvc.perform(patch("/notifications/read-all")
            .with(csrf()))
            .andExpect(status().isNoContent());
 
        verify(notificationService).markAllAsRead(1);
    }
}