package com.mealchemy.vault.controller;

/* Import libraries */

import org.springframework.data.domain.Page;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PatchMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;

/* Import classes */

import com.mealchemy.shared.dto.ErrorResponse;
import com.mealchemy.vault.dto.NotificationResponse;
import com.mealchemy.vault.service.NotificationService;

import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.media.Content;
import io.swagger.v3.oas.annotations.media.Schema;
import io.swagger.v3.oas.annotations.responses.ApiResponse;
import io.swagger.v3.oas.annotations.responses.ApiResponses;
import io.swagger.v3.oas.annotations.tags.Tag;



@RestController
@RequestMapping("/notifications")
@Tag(name = "Notifications", description = "Per-user notification inbox for shared vault activity: list, unread count, mark as read. Live updates pushed separately over WebSocket.")
public class NotificationController {

    private final NotificationService notificationService;

    public NotificationController(NotificationService notificationService)
    {
        this.notificationService = notificationService;
    }

    /* Mapping functions */

    // Get
    @Operation(summary = "Get the caller's notification inbox", description = "Returns the authenticated user's notifications across all vaults, newest first, one page at a time. Read and unread notifications. ")
    @ApiResponses(value = {
        @ApiResponse(responseCode = "200", description = "Page of notifications retrieved successfully (empty page if user has no notifications)"), 
        @ApiResponse(responseCode = "401", description = "No valid JWT present", content = @Content(schema = @Schema(implementation = ErrorResponse.class))),
        @ApiResponse(responseCode = "500", description = "Unexpected server error", content = @Content(schema = @Schema(implementation = ErrorResponse.class)))
    })
    @GetMapping("")
    public ResponseEntity<Page<NotificationResponse>> getInbox(@AuthenticationPrincipal String userId, @RequestParam(defaultValue = "0") int page,  @RequestParam(defaultValue = "20") int size)
    {
        // page can't be negative
        int safePage = Math.max(page, 0);
        int safeSize = Math.min(Math.max(size, 1), 50); 

        return ResponseEntity.ok(notificationService.getInbox(Integer.parseInt(userId), safePage, safeSize));
    }


    // Get
    @Operation(summary = "Get the caller's number of unread notifications", description = "Returns the number of unread notifications for the authenticated user. ")
    @ApiResponses(value = {
        @ApiResponse(responseCode = "200", description = "Unread count retrieved successfully", content = @Content(schema = @Schema(implementation = Long.class))), 
        @ApiResponse(responseCode = "401", description = "No valid JWT present", content = @Content(schema = @Schema(implementation = ErrorResponse.class))),
        @ApiResponse(responseCode = "500", description = "Unexpected server error", content = @Content(schema = @Schema(implementation = ErrorResponse.class)))
    })
    @GetMapping("/unread-count")
    public ResponseEntity<Long> getNumberOfUnreadMessages(@AuthenticationPrincipal String userId)
    {
        return ResponseEntity.ok(notificationService.getNumUnread(Integer.parseInt(userId)));
    }


    // Patch
    @Operation(summary = "Mark one notification as read", description = "Marks a single notification belonging to the authenticated user as read and returns it.")
    @ApiResponses(value = {
        @ApiResponse(responseCode = "200", description = "Notification marked as read", content = @Content(schema = @Schema(implementation = NotificationResponse.class))), 
        @ApiResponse(responseCode = "400", description = "NotificationId is not a valid number", content = @Content(schema = @Schema(implementation = ErrorResponse.class))),
        @ApiResponse(responseCode = "401", description = "No valid JWT present", content = @Content(schema = @Schema(implementation = ErrorResponse.class))),
        @ApiResponse(responseCode = "404", description = "Notification not found, or belongs to another user", content = @Content(schema = @Schema(implementation = ErrorResponse.class))),
        @ApiResponse(responseCode = "500", description = "Unexpected server error", content = @Content(schema = @Schema(implementation = ErrorResponse.class)))
    })
    @PatchMapping("/{notificationId}/read")
    public ResponseEntity<NotificationResponse> markNotificationAsRead(@PathVariable Integer notificationId, @AuthenticationPrincipal String userId)
    {
        return ResponseEntity.ok(notificationService.markAsRead(notificationId, Integer.parseInt(userId)));
    }

    // Patch
    @Operation(summary = "Mark all notifications as read", description = "Mark every unread notification belonging to the authenticated user as read.")
    @ApiResponses(value = {
        @ApiResponse(responseCode = "204", description = "All notifications marked as read"), 
        @ApiResponse(responseCode = "401", description = "No valid JWT present", content = @Content(schema = @Schema(implementation = ErrorResponse.class))),
        @ApiResponse(responseCode = "500", description = "Unexpected server error", content = @Content(schema = @Schema(implementation = ErrorResponse.class)))
    })
    @PatchMapping("/read-all")
    public ResponseEntity<Void> markAllNotificationAsRead(@AuthenticationPrincipal String userId)
    {
        notificationService.markAllAsRead(Integer.parseInt(userId));
        return ResponseEntity.noContent().build();
    }
}


