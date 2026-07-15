package com.mealchemy.cuisinetype.controller;

/* Import libraries */

import org.springframework.web.bind.annotation.*;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import java.util.*;

/* Import classes */

import com.mealchemy.cuisinetype.dto.FlavourProfileOptionsResponse;
import com.mealchemy.cuisinetype.service.FlavourProfileOptionsService;


@RestController
@RequestMapping("/flavourprofileoptions")
public class FlavourProfileOptionsController {
    
    private final FlavourProfileOptionsService flavourProfileOptionsService;

    public FlavourProfileOptionsController(FlavourProfileOptionsService flavourProfileOptionsService)
    {
        this.flavourProfileOptionsService = flavourProfileOptionsService;
    }

    // Get
    @GetMapping("/all")
    public FlavourProfileOptionsResponse getAllCuisineTypes()
    {
        return flavourProfileOptionsService.getAllCuisineTypes();
    }
}
