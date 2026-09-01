package com.mealchemy.externallinks.service;
//models
import com.mealchemy.externallinks.model.ExternalLink;
//repositories
import com.mealchemy.externallinks.repository.ExternalLinkRepository;

import org.springframework.transaction.annotation.Transactional; //need to annotate any function that makes an update to the database

//dtos
import com.mealchemy.externallinks.dto.ExternalLinkResponse;
import com.mealchemy.externallinks.dto.ExternalLinkRequest;

import java.util.List;
import java.util.ArrayList;
import java.time.OffsetDateTime;

import org.springframework.http.HttpStatus;
import org.springframework.stereotype.Service;
import org.springframework.web.server.ResponseStatusException;

@Service
public class ExternalLinkService {

    private final ExternalLinkRepository externalLinkRepository;

    public ExternalLinkService(ExternalLinkRepository externalLinkRepository) {
        this.externalLinkRepository = externalLinkRepository;
    }

    // GET request - gets all the logged in user's external links
    public List<ExternalLinkResponse> getExternalLinks(Integer userId) {
        
        List<ExternalLink> linksList = externalLinkRepository.findByUserId(userId);

        List<ExternalLinkResponse> responseList = new ArrayList<>();
        for(ExternalLink link : linksList) {
            ExternalLinkResponse response = new ExternalLinkResponse(
                link.getLinkId(),
                link.getName(),
                link.getUrl(),
                link.getCreatedAt(),
                link.getUpdatedAt()
            );

            responseList.add(response);
        }

        return responseList;
    }

    // POST request - create new external link
    @Transactional
    public ExternalLinkResponse createExternalLink(Integer userId, ExternalLinkRequest request) {
        
        ExternalLink newLink = new ExternalLink();
        newLink.setUserId(userId);
        newLink.setName(request.name());
        newLink.setUrl(request.url());
        
        ExternalLink savedLink = externalLinkRepository.save(newLink);
        
        return new ExternalLinkResponse(
                savedLink.getLinkId(),
                savedLink.getName(),
                savedLink.getUrl(),
                savedLink.getCreatedAt(),
                savedLink.getUpdatedAt()
        );
    }

    // PUT request - update links
    @Transactional
    public ExternalLinkResponse updateExternalLink(Integer linkId, Integer userId, ExternalLinkRequest request) {
        ExternalLink linkToUpdate = externalLinkRepository.findByLinkIdAndUserId(linkId, userId)
                                                                  .orElseThrow(() -> new ResponseStatusException(HttpStatus.NOT_FOUND, "User or link not found"));

        linkToUpdate.setName(request.name());
        linkToUpdate.setUrl(request.url());
        linkToUpdate.setUpdatedAt(OffsetDateTime.now());
        
        ExternalLink savedLink = externalLinkRepository.save(linkToUpdate);
        
        return new ExternalLinkResponse(
                savedLink.getLinkId(),
                savedLink.getName(),
                savedLink.getUrl(),
                savedLink.getCreatedAt(),
                savedLink.getUpdatedAt()
        );
    }

    // DELETE request - deletes the selected external link
    @Transactional
    public void deleteExternalLink(Integer linkId, Integer userId) {
        ExternalLink linkToDelete = externalLinkRepository.findByLinkIdAndUserId(linkId, userId)
                                                          .orElseThrow(() -> new ResponseStatusException(HttpStatus.NOT_FOUND, "User or link not found"));

        externalLinkRepository.delete(linkToDelete);
    }
}