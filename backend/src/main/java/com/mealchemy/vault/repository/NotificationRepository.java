package com.mealchemy.vault.repository;
 
/* Import libraries */
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;
import java.util.Optional;
import java.util.List;
 
/* Import classes */
import com.mealchemy.vault.model.Notification;

@Repository
public interface NotificationRepository extends JpaRepository<Notification, Integer>
{
    // get users inbox notifications one page at a time -newest first
    Page<Notification> findByRecipientUser_UserIdOrderByCreatedAtDesc(Integer userId, Pageable pageable);

    // num unread notifications
    long countByRecipientUser_UserIdAndIsReadFalse(Integer userId);

    // get speciic notification
    Optional<Notification> findByNotificationIdAndRecipientUser_UserId(Integer notificationId, Integer userId);

    // all unread 
    List<Notification> findByRecipientUser_UserIdAndIsReadFalse(Integer userId);
}
