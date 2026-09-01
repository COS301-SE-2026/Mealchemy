package com.mealchemy.swipes.controller;

/* Import libraries */
import org.springframework.web.bind.annotation.*;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import jakarta.validation.Valid;

/* Import classes */
import com.mealchemy.swipes.service.SwipeService;
import com.mealchemy.swipes.dto.SwipeRequest;
import com.mealchemy.swipes.dto.SwipeResponse;

@RestController
@RequestMapping("/discovery")
public class SwipeController {
    private final SwipeService swipeService;

    public SwipeController(SwipeService swipeService)
    {
        this.swipeService = swipeService;
    }

    @PostMapping("/swipes")
    public SwipeResponse recordSwipe(@AuthenticationPrincipal String userId, @Valid @RequestBody SwipeRequest request)
    {
        Swipe saved = swipeService.recordSwipe(
            Integer.parseInt(userId),
            request.recipeId(),
            request.cuisineValue(),
            request.action(),
            request.signalScores()
        );
        return SwipeResponse.from(saved);
    }
}