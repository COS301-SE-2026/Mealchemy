// talks to external_links db table

package com.mealchemy.externallinks.repository;

import com.mealchemy.externallinks.model.ExternalLink;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.List;
import java.util.Optional;

public interface ExternalLinkRepository extends JpaRepository<ExternalLink, Integer>{ 
    List<ExternalLink> findByUserId(Integer userId); 
    Optional<ExternalLink> findByLinkIdAndUserId(Integer linkId, Integer userId);
}