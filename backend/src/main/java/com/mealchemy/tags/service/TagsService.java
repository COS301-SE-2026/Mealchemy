package com.mealchemy.tags.service;

/* Import classes */
import com.mealchemy.tags.dto.TagsResponse;
import com.mealchemy.tags.model.Tags;
import com.mealchemy.tags.repository.TagsRepository;

/* Import libraries */
import java.util.List;
import org.springframework.stereotype.Service;

@Service
public class TagsService {

    private final TagsRepository tagsRepository;

    public TagsService(TagsRepository tagsRepository)
    {
        this.tagsRepository = tagsRepository;
    }

    public List<TagsResponse> getActiveTags(Boolean dietary)
    {
        List<Tags> tags = (dietary == null)
                ? tagsRepository.findByIsActiveTrue()
                : tagsRepository.findByIsActiveTrueAndIsDietary(dietary);

        return tags.stream()
                .map(tag -> new TagsResponse(tag.getTagId(), tag.getTagName(), tag.getIsDietary()))
                .toList();
    }
}