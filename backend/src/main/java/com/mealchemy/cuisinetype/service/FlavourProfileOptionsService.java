package com.mealchemy.cuisinetype.service;

/* Import libraries */

import org.springframework.stereotype.Service;
import java.util.*;
import java.util.stream.*;

/* Import classes */

import com.mealchemy.cuisinetype.model.FlavourProfileOptions;
import com.mealchemy.cuisinetype.dto.FlavourProfileOptionsResponse;
import com.mealchemy.cuisinetype.repository.FlavourProfileOptionsRepository;

@Service
public class FlavourProfileOptionsService {
    
    private final FlavourProfileOptionsRepository flavourProfileOptionsRepository;

    public FlavourProfileOptionsService(FlavourProfileOptionsRepository flavourProfileOptionsRepository)
    {
        this.flavourProfileOptionsRepository = flavourProfileOptionsRepository;
    }

    // Get all cuisine types
    public List<FlavourProfileOptionsResponse> getAllCuisineTypes()
    {
        return flavourProfileOptionsRepository.findAll().stream().map(FlavourProfileOptionsResponse::from).collect(Collectors.toList());
    }
}
