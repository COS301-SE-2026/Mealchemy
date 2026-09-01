package com.mealchemy.swipes.service;

/* Import libraries */
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

/* Import classes */
import com.mealchemy.swipes.model.Swipe;
import com.mealchemy.swipes.repository.SwipeRepository;
import com.mealchemy.shared.enums.SwipeAction;
import com.mealchemy.engine.dto.SignalScoresResponse;

@Service
public class SwipeService {
    private final SwipeRepository swipeRepository;
    private final LearningUpdateService learningUpdateService;
    private static final Logger log = LoggerFactory.getLogger(SwipeService.class);
    private static final int BATCH_SIZE = 10;
    
    public SwipeService(SwipeRepository swipeRepository, LearningUpdateService learningUpdateService)
    {
        this.swipeRepository = swipeRepository;
        this.learningUpdateService = learningUpdateService;
    }

    @Transactional
    public Swipe recordSwipe(Integer userId, Integer recipeId, String cuisineValue, SwipeAction action, SignalScoresResponse signalScores)
    {
        Swipe swipe = new Swipe();
        swipe.setUserId(userId);
        swipe.setRecipeId(recipeId);
        swipe.setCuisineValue(cuisineValue);
        swipe.setAction(action);
        swipe.setWeightsSnapshot(signalScores);
        swipe.setFlushed(false);
        Swipe saved = swipeRepository.save(swipe);

        if (swipeRepository.countByUserIdAndFlushedFalse(userId) >= BATCH_SIZE) {
            try {
                learningUpdateService.flushSwipes(userId);
            } catch (Exception ex) {
                log.warn("Learning update flush failed for user {}, will retry on next batch trigger", userId, ex);
            }
        }

        return saved;
    }
}