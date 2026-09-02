package com.mealchemy.swipes.repository;

/* Import classes */
import com.mealchemy.swipes.model.Swipe;
import com.mealchemy.shared.enums.SwipeAction;

/* Import libraries */
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;
import java.util.*;

@Repository
public interface SwipeRepository extends JpaRepository<Swipe, Integer> {
    List<Swipe> findByUserId(Integer UserId);
    List<Swipe> findByUserIdAndFlushedFalse(Integer userId);
    long countByUserIdAndFlushedFalse(Integer userId);
    List<Swipe> findByUserIdAndAction(Integer userId, SwipeAction action);
}
