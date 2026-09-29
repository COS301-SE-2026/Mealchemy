package com.mealchemy.tags.controller;

/* Import libraries */
import java.util.List;
import org.springframework.web.bind.annotation.*;

/* Import classes */
import com.mealchemy.tags.dto.TagDto;
import com.mealchemy.tags.service.TagsService;
import com.mealchemy.shared.dto.ErrorResponse;

/* Swagger */
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.media.ArraySchema;
import io.swagger.v3.oas.annotations.media.Content;
import io.swagger.v3.oas.annotations.media.Schema;
import io.swagger.v3.oas.annotations.responses.ApiResponse;
import io.swagger.v3.oas.annotations.responses.ApiResponses;
import io.swagger.v3.oas.annotations.tags.Tag;

@RestController
@RequestMapping("/api/tags")
@Tag(name = "Tags", description = "Recipe tag lookup for filtering and preference selection")
public class TagsController {
    private final TagsService tagsService;

    public TagsController(TagsService tagsService)
    {
        this.tagsService = tagsService;
    }

    @Operation(summary = "Get active tags", description = "Returns all active tags. When the dietary query parameter is supplied, results are filtered to tags whose dietary flag matches it (e.g. dietary=true returns only active dietary tags). When omitted, all active tags are returned regardless of the dietary flag.")
    @ApiResponses(value = {
        @ApiResponse(responseCode = "200", description = "Tags retrieved successfully", content = @Content(array = @ArraySchema(schema = @Schema(implementation = TagDto.class)))),
        @ApiResponse(responseCode = "400", description = "Invalid value supplied for the dietary parameter", content = @Content(schema = @Schema(implementation = ErrorResponse.class))),
        @ApiResponse(responseCode = "401", description = "No valid JWT present", content = @Content(schema = @Schema(implementation = ErrorResponse.class))),
        @ApiResponse(responseCode = "500", description = "Unexpected server error", content = @Content(schema = @Schema(implementation = ErrorResponse.class)))
    })
    @GetMapping
    public List<TagDto> getTags(@RequestParam(required = false) Boolean dietary)
    {
        return tagsService.getActiveTags(dietary);
    }
}