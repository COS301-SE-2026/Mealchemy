package com.mealchemy.moderation.service;

// import classes
import com.mealchemy.moderation.model.FlagReasonOptions;
import com.mealchemy.moderation.dto.FlagReasonOptionsResponse;
import com.mealchemy.moderation.repository.FlagReasonOptionsRepository;

// import libraries
import org.springframework.stereotype.Service;
import java.util.*;

@Service
public class FlagReasonOptionsService {
    
    private final FlagReasonOptionsRepository flagReasonOptionsRepository;

    public FlagReasonOptionsService(FlagReasonOptionsRepository flagReasonOptionsRepository) {
        this.flagReasonOptionsRepository = flagReasonOptionsRepository;
    }

    // GET - all flag reason options available
    public List<FlagReasonOptionsResponse> getAllFlagReasonOptions() {
        List<FlagReasonOptions> responses = flagReasonOptionsRepository.findAllByOrderBySortOrderAsc();

        List<FlagReasonOptionsResponse> result = new ArrayList<>();

        for (FlagReasonOptions response : responses) {
            FlagReasonOptionsResponse option = new FlagReasonOptionsResponse(
                response.getValue(),
                response.getLabel()
            );
            result.add(option);
        }

        return result;
    }

}
