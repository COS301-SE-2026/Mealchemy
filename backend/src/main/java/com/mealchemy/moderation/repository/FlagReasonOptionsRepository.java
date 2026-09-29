// talks to flag_reason_options db table

package com.mealchemy.moderation.repository;

import com.mealchemy.moderation.model.FlagReasonOptions;

import java.util.List;
import java.util.Optional;
import org.springframework.data.jpa.repository.JpaRepository;


public interface FlagReasonOptionsRepository extends JpaRepository<FlagReasonOptions, Integer> {
    
    // for validation
    boolean existsByValue(String value);

    Optional<FlagReasonOptions> findByValue(String value);

    List<FlagReasonOptions> findAllByOrderBySortOrderAsc();
}
