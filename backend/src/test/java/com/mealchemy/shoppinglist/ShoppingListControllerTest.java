// unit testing for shopping list

package com.mealchemy.shoppinglist;

//dtos
import com.mealchemy.shoppinglist.dto.CreateShoppingListItemRequest;
import com.mealchemy.shoppinglist.dto.CreateShoppingListRequest;
import com.mealchemy.shoppinglist.dto.PantryRecipeComparisonRequest;
import com.mealchemy.shoppinglist.dto.PurchasedUpdateRequest;
import com.mealchemy.shoppinglist.dto.ShoppingListResponse;
import com.mealchemy.shoppinglist.dto.ShoppingListItemResponse;
import com.mealchemy.shoppinglist.dto.ShoppingListWithItemsResponse;
import com.mealchemy.shoppinglist.dto.UpdateShoppingListItemRequest;
import com.mealchemy.shoppinglist.dto.UpdateShoppingListRequest;
import com.mealchemy.shoppinglist.dto.DeleteBatchItemsRequest;
import com.mealchemy.shoppinglist.dto.CompleteShopResponse;
import com.mealchemy.shoppinglist.dto.AddRecipeToShoppingListRequest;

// controller
import com.mealchemy.shoppinglist.controller.ShoppingListController;

// enum
import com.mealchemy.shared.enums.ShoppingListStatus;

// import service
import com.mealchemy.shoppinglist.service.ShoppingListService;

import com.fasterxml.jackson.databind.ObjectMapper;
import com.mealchemy.config.JwtUtil;

import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.autoconfigure.web.servlet.WebMvcTest;
import org.springframework.boot.test.context.TestConfiguration;
import org.springframework.context.annotation.Bean;
import org.springframework.http.HttpStatus;
import org.springframework.http.MediaType;
import org.springframework.security.authentication.UsernamePasswordAuthenticationToken;
import org.springframework.security.config.annotation.web.builders.HttpSecurity;
import org.springframework.security.config.annotation.web.configurers.AbstractHttpConfigurer;
import org.springframework.security.web.SecurityFilterChain;
import org.springframework.test.context.bean.override.mockito.MockitoBean;
import org.springframework.test.web.servlet.MockMvc;
import org.springframework.web.server.ResponseStatusException;

import java.util.List;
import java.util.Optional;
import java.math.BigDecimal;
import java.time.OffsetDateTime;

import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.patch;
import static org.springframework.security.test.web.servlet.request.SecurityMockMvcRequestPostProcessors.authentication;

import static org.mockito.ArgumentMatchers.any;
import static org.mockito.ArgumentMatchers.anyInt;
import static org.mockito.ArgumentMatchers.eq;
import static org.mockito.Mockito.when;
import static org.mockito.Mockito.doThrow;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.get;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.post;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.put;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.delete;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.*;


@WebMvcTest(ShoppingListController.class)
public class ShoppingListControllerTest {

    // setup
    @TestConfiguration
    static class TestSecurityConfig {
        @Bean
        public SecurityFilterChain filterChain(HttpSecurity http) throws Exception {
            http
                .csrf(AbstractHttpConfigurer::disable)
                .authorizeHttpRequests(auth -> auth.anyRequest().permitAll());
            return http.build();
        }
    }

    @Autowired
    private MockMvc mockMvc;

    @Autowired
    private ObjectMapper objectMapper;

    @MockitoBean
    private ShoppingListService shoppingListService;

    @MockitoBean
    private JwtUtil jwtUtil;

    // ========== GET Testing (GET /api/shopping-lists) ==========

    @Test
    void getShoppingLists_validToken_return200() throws Exception {
    // Arrange - mock response
        ShoppingListResponse mockResponse = new ShoppingListResponse(
            1,
            1,
            "Weekly Groceries",
            3,
            ShoppingListStatus.ACTIVE,
            OffsetDateTime.parse("2026-07-23T23:00:00Z")
        );

        when(shoppingListService.getUsersShoppingLists(anyInt())).thenReturn(List.of(mockResponse));

        // Act and assert
        mockMvc.perform(get("/api/shopping-lists").with(authentication(new UsernamePasswordAuthenticationToken("1", null, List.of()))))
                .andExpect(status().isOk())
                // fields in response object
                .andExpect(jsonPath("$[0].shopping_list_id").value(1))
                .andExpect(jsonPath("$[0].user_id").value(1))
                .andExpect(jsonPath("$[0].name").value("Weekly Groceries"))
                .andExpect(jsonPath("$[0].num_items").value(3))
                .andExpect(jsonPath("$[0].status").value("ACTIVE"));
    }

    @Test
    void getShoppingLists_validToken_return200EmptyList() throws Exception {
        // Arrange
        when(shoppingListService.getUsersShoppingLists(anyInt())).thenReturn(List.of());

        // Act and assert
        mockMvc.perform(get("/api/shopping-lists").with(authentication(new UsernamePasswordAuthenticationToken("1", null, List.of()))))
                .andExpect(status().isOk())
                // check response is array 
                .andExpect(jsonPath("$").isArray())
                .andExpect(jsonPath("$").isEmpty());
    }

    // ========== POST Testing (POST /api/shopping-lists) ==========

    @Test
    void createShoppingList_validRequest_return200() throws Exception {
    // Arrange - mock response
        CreateShoppingListRequest mockRequest = new CreateShoppingListRequest(
            "New List",
            ShoppingListStatus.ACTIVE
        );

        ShoppingListResponse mockResponse = new ShoppingListResponse(
            1,
            1,
            "New List",
            0,
            ShoppingListStatus.ACTIVE,
            OffsetDateTime.parse("2026-07-23T23:00:00Z")
        );

        when(shoppingListService.createNewShoppingList(anyInt(), any(CreateShoppingListRequest.class))).thenReturn(mockResponse);

        // Act and assert
        mockMvc.perform(post("/api/shopping-lists").with(authentication(new UsernamePasswordAuthenticationToken("1", null, List.of())))
                .contentType(MediaType.APPLICATION_JSON)
                .content(objectMapper.writeValueAsString(mockRequest)))
                .andExpect(status().isOk())
                // fields in response object
                .andExpect(jsonPath("$.shopping_list_id").value(1))
                .andExpect(jsonPath("$.user_id").value(1))
                .andExpect(jsonPath("$.name").value("New List"))
                .andExpect(jsonPath("$.num_items").value(0))
                .andExpect(jsonPath("$.status").value("ACTIVE"));
    }

    @Test
    void createShoppingList_badRequestBody_returns400() throws Exception {
        // Arrange - mock response
        // Bad request
       String badRequest = """
                    {
                        ShoppingListStatus.ACTIVE
                    }
                """;

        // Act and Assert
        mockMvc.perform(post("/api/shopping-lists").with(authentication(new UsernamePasswordAuthenticationToken("1", null, List.of())))
                .contentType(MediaType.APPLICATION_JSON)
                .content(badRequest))
                .andExpect(status().isBadRequest());
    }
    
    // ========== PUT Testing (PUT /api/shopping-lists/{id}) ==========

    @Test
    void updateShoppingList_validRequest_return200() throws Exception {
        UpdateShoppingListRequest mockRequest = new UpdateShoppingListRequest(
            "Updated List",
            ShoppingListStatus.COMPLETED
        );

        ShoppingListResponse mockResponse = new ShoppingListResponse(
            1,
            1,
            "Updated List",
            3,
            ShoppingListStatus.COMPLETED,
            OffsetDateTime.parse("2026-07-23T23:00:00Z")
        );

        when(shoppingListService.updateShoppingList(anyInt(), eq(1), any(UpdateShoppingListRequest.class))).thenReturn(mockResponse);

        // Act and assert
        mockMvc.perform(put("/api/shopping-lists/{id}", 1).with(authentication(new UsernamePasswordAuthenticationToken("1", null, List.of())))
                // fields in response object
                .contentType(MediaType.APPLICATION_JSON)
                .content(objectMapper.writeValueAsString(mockRequest)))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.shopping_list_id").value(1))
                .andExpect(jsonPath("$.user_id").value(1))
                .andExpect(jsonPath("$.name").value("Updated List"))
                .andExpect(jsonPath("$.num_items").value(3))
                .andExpect(jsonPath("$.status").value("COMPLETED"));
    }

    @Test
    void updateShoppingList_notFound_return404() throws Exception {
        UpdateShoppingListRequest mockRequest = new UpdateShoppingListRequest(
            "Updated List",
            ShoppingListStatus.COMPLETED
        );

        when(shoppingListService.updateShoppingList(anyInt(), eq(1), any(UpdateShoppingListRequest.class))).thenThrow(new ResponseStatusException(HttpStatus.NOT_FOUND, "Shopping list not found"));

        // Act and assert
        mockMvc.perform(put("/api/shopping-lists/{id}", 1).with(authentication(new UsernamePasswordAuthenticationToken("1", null, List.of())))
                // fields in response object
                .contentType(MediaType.APPLICATION_JSON)
                .content(objectMapper.writeValueAsString(mockRequest)))
                .andExpect(status().isNotFound())
                .andExpect(jsonPath("$.message").value("Shopping list not found"));
    }
    
    @Test
    void updateShoppingList_notOwned_return401() throws Exception {
        UpdateShoppingListRequest mockRequest = new UpdateShoppingListRequest(
            "Updated List",
            ShoppingListStatus.COMPLETED
        );

        when(shoppingListService.updateShoppingList(anyInt(), eq(1), any(UpdateShoppingListRequest.class))).thenThrow(new ResponseStatusException(HttpStatus.UNAUTHORIZED, "You do not own this shopping list"));

        // Act and assert
        mockMvc.perform(put("/api/shopping-lists/{id}", 1).with(authentication(new UsernamePasswordAuthenticationToken("1", null, List.of())))
                // fields in response object
                .contentType(MediaType.APPLICATION_JSON)
                .content(objectMapper.writeValueAsString(mockRequest)))
                .andExpect(status().isUnauthorized())
                .andExpect(jsonPath("$.message").value("You do not own this shopping list"));
    }

    @Test
    void updateShoppingList_idNotInt_returns400() throws Exception {
        UpdateShoppingListRequest mockRequest = new UpdateShoppingListRequest(
            "Updated List",
            ShoppingListStatus.COMPLETED
        );

        // Act and assert
        mockMvc.perform(put("/api/shopping-lists/{id}", "non-int").with(authentication(new UsernamePasswordAuthenticationToken("1", null, List.of())))
                .contentType(MediaType.APPLICATION_JSON)
                .content(objectMapper.writeValueAsString(mockRequest))) 
                .andExpect(status().isBadRequest());
    }

    // ========== DELETE Testing (DELETE /api/shopping-lists/{id}) ==========
    
    @Test
    void deleteShoppingList_validDelete_returns204() throws Exception {
        // Act and assert
        mockMvc.perform(delete("/api/shopping-lists/{id}", 3).with(authentication(new UsernamePasswordAuthenticationToken("1", null, List.of())))) //check {id}    
                .andExpect(status().isNoContent())
                .andExpect(content().string(""));
    }

    @Test
    void deleteShoppingList_notFound_returns404() throws Exception {

        doThrow(new ResponseStatusException(HttpStatus.NOT_FOUND, "Shopping list not found")).when(shoppingListService).deleteShoppingList(anyInt(), eq(3));

        // Act and Assert
        mockMvc.perform(delete("/api/shopping-lists/{id}", 3).with(authentication(new UsernamePasswordAuthenticationToken("1", null, List.of()))))  
                .andExpect(status().isNotFound())
                .andExpect(jsonPath("$.message").value("Shopping list not found"));
    }

    @Test
    void deleteShoppingList_notOwned_returns401() throws Exception {

        doThrow(new ResponseStatusException(HttpStatus.UNAUTHORIZED, "You do not own this shopping list")).when(shoppingListService).deleteShoppingList(anyInt(), eq(3));

        // Act and Assert
        mockMvc.perform(delete("/api/shopping-lists/{id}", 3).with(authentication(new UsernamePasswordAuthenticationToken("1", null, List.of()))))  
                .andExpect(status().isUnauthorized())
                .andExpect(jsonPath("$.message").value("You do not own this shopping list"));
    }


    // ========== GET Testing (GET /api/shopping-lists/{id}) - list with itemns ==========

    @Test
    void getListWithItems_validToken_returns200ListWithItems() throws Exception {
        // Arrange - mock response
        ShoppingListItemResponse itemResponse = new ShoppingListItemResponse(
            1,
            1,
            2,
            "Hummus",
            "Legumes and Legume Products",
            new BigDecimal("100"),
            "g",
            false
        );

        ShoppingListWithItemsResponse mockResponse = new ShoppingListWithItemsResponse(
            1,
            1,
            "Weekly Groceries",
            ShoppingListStatus.ACTIVE,
            OffsetDateTime.parse("2026-07-23T23:00:00Z"),
            1,
            List.of(itemResponse)
        );

        when(shoppingListService.getSpecificListItems(anyInt(), eq(1))).thenReturn(mockResponse);

        // Act and assert
        mockMvc.perform(get("/api/shopping-lists/{id}", 1).with(authentication(new UsernamePasswordAuthenticationToken("1", null, List.of()))))
                .andExpect(status().isOk())
                // fields in response object
                .andExpect(jsonPath("$.shopping_list_id").value(1))
                .andExpect(jsonPath("$.user_id").value(1))
                .andExpect(jsonPath("$.name").value("Weekly Groceries"))
                .andExpect(jsonPath("$.num_items").value(1))
                .andExpect(jsonPath("$.status").value("ACTIVE"))
                .andExpect(jsonPath("$.items[0].item_id").value(1))
                .andExpect(jsonPath("$.items[0].shopping_list_id").value(1))
                .andExpect(jsonPath("$.items[0].ing_id").value(2))
                .andExpect(jsonPath("$.items[0].name").value("Hummus"))
                .andExpect(jsonPath("$.items[0].category").value("Legumes and Legume Products"))
                .andExpect(jsonPath("$.items[0].quantity").value(100))
                .andExpect(jsonPath("$.items[0].unit").value("g"))
                .andExpect(jsonPath("$.items[0].purchased").value(false));
    }

    @Test
    void getListWithItems_notFound_returns404() throws Exception {

        when(shoppingListService.getSpecificListItems(anyInt(), eq(3))).thenThrow(new ResponseStatusException(HttpStatus.NOT_FOUND, "Shopping list not found"));

        // Act and assert
        mockMvc.perform(get("/api/shopping-lists/{id}", 3).with(authentication(new UsernamePasswordAuthenticationToken("1", null, List.of())))
                .contentType(MediaType.APPLICATION_JSON))
                .andExpect(status().isNotFound())
                .andExpect(jsonPath("$.message").value("Shopping list not found"));
    }
    
    @Test
    void getListWithItems_notOwned_returns401() throws Exception {
        
        when(shoppingListService.getSpecificListItems(anyInt(), eq(1))).thenThrow(new ResponseStatusException(HttpStatus.UNAUTHORIZED, "You do not own this shopping list"));

        // Act and assert
        mockMvc.perform(get("/api/shopping-lists/{id}", 1).with(authentication(new UsernamePasswordAuthenticationToken("1", null, List.of())))
                // fields in response object
                .contentType(MediaType.APPLICATION_JSON))
                .andExpect(status().isUnauthorized())
                .andExpect(jsonPath("$.message").value("You do not own this shopping list"));
    }

    // ========== POST Testing (POST /api/shopping-lists/{id}/items) - add item to a specified shopping list ==========

    @Test
    void addItem_validRequest_returns200() throws Exception {
        CreateShoppingListItemRequest mockRequest = new CreateShoppingListItemRequest(
            2,
            null,
            new BigDecimal("100"),
            "g"
        );

        ShoppingListItemResponse mockResponse = new ShoppingListItemResponse(
            1,
            1,
            2,
            "Hummus",
            "Legumes and Legume Products",
            new BigDecimal("100"),
            "g",
            false
        );

        when(shoppingListService.addNewShoppingListItem(anyInt(), eq(1), any(CreateShoppingListItemRequest.class))).thenReturn(mockResponse);

        // Act and assert
        mockMvc.perform(post("/api/shopping-lists/{id}/items", 1).with(authentication(new UsernamePasswordAuthenticationToken("1", null, List.of())))
                .contentType(MediaType.APPLICATION_JSON)
                .content(objectMapper.writeValueAsString(mockRequest)))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.item_id").value(1))
                .andExpect(jsonPath("$.shopping_list_id").value(1))
                .andExpect(jsonPath("$.ing_id").value(2))
                .andExpect(jsonPath("$.name").value("Hummus"))
                .andExpect(jsonPath("$.category").value("Legumes and Legume Products"))
                .andExpect(jsonPath("$.quantity").value(100))
                .andExpect(jsonPath("$.unit").value("g"))
                .andExpect(jsonPath("$.purchased").value(false));
    }

    @Test
    void addItem_bad_request_returns400() throws Exception {
        // Bad request
       String badRequest = """
                            {
                                "ing_id": "non-number",
                                "quantity": "wrong"
                            }
                         """;

        // Act and Assert
        mockMvc.perform(post("/api/shopping-lists/{id}/items", 1).with(authentication(new UsernamePasswordAuthenticationToken("1", null, List.of())))
                .contentType(MediaType.APPLICATION_JSON)
                .content(badRequest))
                .andExpect(status().isBadRequest());
    }

    @Test 
    void addItem_listNotFound_returns404() throws Exception{
         CreateShoppingListItemRequest mockRequest = new CreateShoppingListItemRequest(
            2,
            null,
            new BigDecimal("100"),
            "g"
        );

        when(shoppingListService.addNewShoppingListItem(anyInt(), eq(1), any(CreateShoppingListItemRequest.class))).thenThrow(new ResponseStatusException(HttpStatus.NOT_FOUND, "Shopping list not found"));

        // Act and assert
        mockMvc.perform(post("/api/shopping-lists/{id}/items", 1).with(authentication(new UsernamePasswordAuthenticationToken("1", null, List.of())))
                // fields in response object
                .contentType(MediaType.APPLICATION_JSON)
                .content(objectMapper.writeValueAsString(mockRequest)))
                .andExpect(status().isNotFound())
                .andExpect(jsonPath("$.message").value("Shopping list not found"));
    }


    // ========== PUT Testing (PUT /api/shopping-lists/{id}/items/{itemId}) - add item to a specified shopping list ==========

    @Test
    void updateItem_validRequest_returns200() throws Exception {
        UpdateShoppingListItemRequest mockRequest = new UpdateShoppingListItemRequest(
            2,
            null,
            new BigDecimal("200"),
            "g",
            true
        );

        ShoppingListItemResponse mockResponse = new ShoppingListItemResponse(
            1,
            1,
            2,
            "Hummus",
            "Legumes and Legume Products",
            new BigDecimal("200"),
            "g",
            true
        );

        when(shoppingListService.updateShoppingListItem(anyInt(), eq(1), eq(1), any(UpdateShoppingListItemRequest.class))).thenReturn(mockResponse);

        // Act and assert
        mockMvc.perform(put("/api/shopping-lists/{id}/items/{itemId}", 1, 1).with(authentication(new UsernamePasswordAuthenticationToken("1", null, List.of())))
                .contentType(MediaType.APPLICATION_JSON)
                .content(objectMapper.writeValueAsString(mockRequest)))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.item_id").value(1))
                .andExpect(jsonPath("$.shopping_list_id").value(1))
                .andExpect(jsonPath("$.ing_id").value(2))
                .andExpect(jsonPath("$.name").value("Hummus"))
                .andExpect(jsonPath("$.category").value("Legumes and Legume Products"))
                .andExpect(jsonPath("$.quantity").value(200))
                .andExpect(jsonPath("$.unit").value("g"))
                .andExpect(jsonPath("$.purchased").value(true));
    }

    @Test 
    void updateItem_itemNotFound_returns404() throws Exception {
         UpdateShoppingListItemRequest mockRequest = new UpdateShoppingListItemRequest(
            2,
            null,
            new BigDecimal("100"),
            "g",
            true
        );

        when(shoppingListService.updateShoppingListItem(anyInt(), eq(1), eq(1), any(UpdateShoppingListItemRequest.class))).thenThrow(new ResponseStatusException(HttpStatus.NOT_FOUND, "Item not found"));

        // Act and assert
        mockMvc.perform(put("/api/shopping-lists/{id}/items/{itemId}", 1, 1).with(authentication(new UsernamePasswordAuthenticationToken("1", null, List.of())))
                // fields in response object
                .contentType(MediaType.APPLICATION_JSON)
                .content(objectMapper.writeValueAsString(mockRequest)))
                .andExpect(status().isNotFound())
                .andExpect(jsonPath("$.message").value("Item not found"));
    }

    @Test
    void updateItem_itemBelongsToDifferentList_returns404() throws Exception {

        UpdateShoppingListItemRequest mockRequest = new UpdateShoppingListItemRequest(
                2, 
                null, 
                new BigDecimal("100"), 
                "g", 
                true
        );

        when(shoppingListService.updateShoppingListItem(anyInt(), eq(1), eq(99), any(UpdateShoppingListItemRequest.class))).thenThrow(new ResponseStatusException(HttpStatus.NOT_FOUND, "The selected item is not in the shopping list"));

        mockMvc.perform(put("/api/shopping-lists/{id}/items/{itemId}", 1, 99).with(authentication(new UsernamePasswordAuthenticationToken("1", null, List.of())))
                .contentType(MediaType.APPLICATION_JSON)
                .content(objectMapper.writeValueAsString(mockRequest)))
                .andExpect(status().isNotFound())
                .andExpect(jsonPath("$.message").value("The selected item is not in the shopping list"));
    }

    // ========== PATCH Testing (PATCH /api/shopping-lists/{id}/items/{itemId}/purchased) - update purchased flag ==========
    
    @Test
    void updatePurchased_validRequest_returns200() throws Exception {
        PurchasedUpdateRequest mockRequest = new PurchasedUpdateRequest(
            true
        );

        ShoppingListItemResponse mockResponse = new ShoppingListItemResponse(
            1,
            1,
            2,
            "Hummus",
            "Legumes and Legume Products",
            new BigDecimal("200"),
            "g",
            true
        );

        when(shoppingListService.updatePurchasedFlag(anyInt(), eq(1), eq(1), any(PurchasedUpdateRequest.class))).thenReturn(mockResponse);

        // Act and assert
        mockMvc.perform(patch("/api/shopping-lists/{id}/items/{itemId}/purchased", 1, 1).with(authentication(new UsernamePasswordAuthenticationToken("1", null, List.of())))
                .contentType(MediaType.APPLICATION_JSON)
                .content(objectMapper.writeValueAsString(mockRequest)))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.item_id").value(1))
                .andExpect(jsonPath("$.shopping_list_id").value(1))
                .andExpect(jsonPath("$.ing_id").value(2))
                .andExpect(jsonPath("$.name").value("Hummus"))
                .andExpect(jsonPath("$.category").value("Legumes and Legume Products"))
                .andExpect(jsonPath("$.quantity").value(200))
                .andExpect(jsonPath("$.unit").value("g"))
                .andExpect(jsonPath("$.purchased").value(true));
    }

    @Test 
    void updatePurchased_itemNotFound_returns404() throws Exception {
        PurchasedUpdateRequest mockRequest = new PurchasedUpdateRequest(
            true
        );

        when(shoppingListService.updatePurchasedFlag(anyInt(), eq(1), eq(1), any(PurchasedUpdateRequest.class))).thenThrow(new ResponseStatusException(HttpStatus.NOT_FOUND, "Item not found"));

        // Act and assert
        mockMvc.perform(patch("/api/shopping-lists/{id}/items/{itemId}/purchased", 1, 1).with(authentication(new UsernamePasswordAuthenticationToken("1", null, List.of())))
                // fields in response object
                .contentType(MediaType.APPLICATION_JSON)
                .content(objectMapper.writeValueAsString(mockRequest)))
                .andExpect(status().isNotFound())
                .andExpect(jsonPath("$.message").value("Item not found"));
    }

    // ========== DELETE Testing (DELETE /api/shopping-lists/{id}/items/{itemId}) - delete single item ==========

    @Test
    void deleteItem_validDelete_returns204() throws Exception {
        mockMvc.perform(delete("/api/shopping-lists/{id}/items/{itemId}", 1, 1).with(authentication(new UsernamePasswordAuthenticationToken("1", null, List.of()))))
                .andExpect(status().isNoContent())
                .andExpect(content().string(""));
    }

    @Test
    void deleteItem_notFound_returns404() throws Exception {
        doThrow(new ResponseStatusException(HttpStatus.NOT_FOUND, "Item not found"))
            .when(shoppingListService).deleteShoppingListItem(anyInt(), eq(1), eq(1));

        mockMvc.perform(delete("/api/shopping-lists/{id}/items/{itemId}", 1, 1).with(authentication(new UsernamePasswordAuthenticationToken("1", null, List.of()))))
                .andExpect(status().isNotFound())
                .andExpect(jsonPath("$.message").value("Item not found"));
    }


    // ========== POST Testing (POST /api/shopping-lists/{id}/items/batch-delete) ==========

    @Test
    void batchDelete_validRequest_returns204() throws Exception {
        DeleteBatchItemsRequest mockRequest = new DeleteBatchItemsRequest(List.of(1, 2, 3));

        mockMvc.perform(post("/api/shopping-lists/{id}/items/batch-delete", 1).with(authentication(new UsernamePasswordAuthenticationToken("1", null, List.of())))
                .contentType(MediaType.APPLICATION_JSON)
                .content(objectMapper.writeValueAsString(mockRequest)))
                .andExpect(status().isNoContent())
                .andExpect(content().string(""));
    }

    @Test
    void batchDelete_oneItemInvalid_returns404() throws Exception {
        DeleteBatchItemsRequest mockRequest = new DeleteBatchItemsRequest(List.of(1, 2, 999));

        doThrow(new ResponseStatusException(HttpStatus.NOT_FOUND, "Item not found")).when(shoppingListService).deleteSelectedItems(anyInt(), eq(1), any(DeleteBatchItemsRequest.class));

        mockMvc.perform(post("/api/shopping-lists/{id}/items/batch-delete", 1).with(authentication(new UsernamePasswordAuthenticationToken("1", null, List.of())))
                .contentType(MediaType.APPLICATION_JSON)
                .content(objectMapper.writeValueAsString(mockRequest)))
                .andExpect(status().isNotFound())
                .andExpect(jsonPath("$.message").value("Item not found"));
    }


    // ========== PUT Testing (PUT /api/shopping-lists/{id}/items/select-all) ==========

    @Test
    void selectAllItems_validRequest_returns200WithAllPurchasedTrue() throws Exception {
        ShoppingListItemResponse itemResponse = new ShoppingListItemResponse(
            1, 
            1,
            2,
            "Hummus", 
            "Legumes and Legume Products",
            new BigDecimal("100"), 
            "g", 
            true
        );

        ShoppingListWithItemsResponse mockResponse = new ShoppingListWithItemsResponse(
            1, 
            1, 
            "Weekly Groceries", 
            ShoppingListStatus.ACTIVE,
            OffsetDateTime.parse("2026-07-23T23:00:00Z"),
            1,
            List.of(itemResponse)
        );

        when(shoppingListService.selectAllItemsAsPurchased(anyInt(), eq(1))).thenReturn(mockResponse);

        mockMvc.perform(put("/api/shopping-lists/{id}/items/select-all", 1).with(authentication(new UsernamePasswordAuthenticationToken("1", null, List.of()))))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.shopping_list_id").value(1))
                .andExpect(jsonPath("$.num_items").value(1)) 
                .andExpect(jsonPath("$.items[0].purchased").value(true));
    }

    @Test
    void selectAllItems_listNotFound_returns404() throws Exception {
        when(shoppingListService.selectAllItemsAsPurchased(anyInt(), eq(1))).thenThrow(new ResponseStatusException(HttpStatus.NOT_FOUND, "Shopping list not found"));

        mockMvc.perform(put("/api/shopping-lists/{id}/items/select-all", 1).with(authentication(new UsernamePasswordAuthenticationToken("1", null, List.of()))))
                .andExpect(status().isNotFound())
                .andExpect(jsonPath("$.message").value("Shopping list not found"));
    }


    // ========== PUT Testing (PUT /api/shopping-lists/{id}/items/deselect-all) ==========

    @Test
    void deselectAllItems_validRequest_returns200WithAllPurchasedFalse() throws Exception {
        ShoppingListItemResponse itemResponse = new ShoppingListItemResponse(
            1, 
            1, 
            2, 
            "Hummus", 
            "Legumes and Legume Products",
            new BigDecimal("100"), 
            "g", 
            false
        );

        ShoppingListWithItemsResponse mockResponse = new ShoppingListWithItemsResponse(
            1, 
            1, 
            "Weekly Groceries", 
            ShoppingListStatus.ACTIVE,
            OffsetDateTime.parse("2026-07-23T23:00:00Z"),
            1,
            List.of(itemResponse)
        );

        when(shoppingListService.deselectAllItemsAsPurchased(anyInt(), eq(1))).thenReturn(mockResponse);

        mockMvc.perform(put("/api/shopping-lists/{id}/items/deselect-all", 1).with(authentication(new UsernamePasswordAuthenticationToken("1", null, List.of()))))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.shopping_list_id").value(1))
                .andExpect(jsonPath("$.num_items").value(1)) 
                .andExpect(jsonPath("$.items[0].purchased").value(false));
    }

    @Test
    void deselectAllItems_listNotFound_returns404() throws Exception {
        when(shoppingListService.deselectAllItemsAsPurchased(anyInt(), eq(1))).thenThrow(new ResponseStatusException(HttpStatus.NOT_FOUND, "Shopping list not found"));

        mockMvc.perform(put("/api/shopping-lists/{id}/items/deselect-all", 1).with(authentication(new UsernamePasswordAuthenticationToken("1", null, List.of()))))
                .andExpect(status().isNotFound())
                .andExpect(jsonPath("$.message").value("Shopping list not found"));
    }


    // ========== PUT Testing (PUT /api/shopping-lists/{id}/complete-shop) ==========

    @Test
    void completeShop_validRequest_returns200WithSummary() throws Exception {
        CompleteShopResponse mockResponse = new CompleteShopResponse(
            2,
            List.of("Fresh basil bunch"),
            false
        );

        when(shoppingListService.autoAddToPantryRemoveFromList(anyInt(), eq(1))).thenReturn(mockResponse);

        mockMvc.perform(put("/api/shopping-lists/{id}/complete-shop", 1).with(authentication(new UsernamePasswordAuthenticationToken("1", null, List.of()))))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.added_to_pantry_count").value(2))
                .andExpect(jsonPath("$.skipped_manual_items[0]").value("Fresh basil bunch"))
                .andExpect(jsonPath("$.can_delete_shopping_list").value(false));
    }

    @Test
    void completeShop_listNotFound_returns404() throws Exception {
        when(shoppingListService.autoAddToPantryRemoveFromList(anyInt(), eq(1))).thenThrow(new ResponseStatusException(HttpStatus.NOT_FOUND, "Shopping list not found"));

        mockMvc.perform(put("/api/shopping-lists/{id}/complete-shop", 1).with(authentication(new UsernamePasswordAuthenticationToken("1", null, List.of()))))
                .andExpect(status().isNotFound())
                .andExpect(jsonPath("$.message").value("Shopping list not found"));
    }


    // ========== Generating Shopping List Items (Compares recipe to current pantry ingredients and inserts the rest into shopping list) Testing ==========

    @Test
    void generateShoppingListFromRecipe_validRequest_return200() throws Exception {
        // Arrange - mock response
        PantryRecipeComparisonRequest mockRequest = new PantryRecipeComparisonRequest(
            "Generate Shopping List With All Items",
            false
        );

        ShoppingListResponse mockResponse = new ShoppingListResponse(
            1,
            1,
            "Generate Shopping List With All Items",
            2,
            ShoppingListStatus.ACTIVE,
            OffsetDateTime.parse("2026-07-23T23:00:00Z")
        );

        when(shoppingListService.generateShoppingListFromRecipe(anyInt(), eq(1), any(PantryRecipeComparisonRequest.class))).thenReturn(mockResponse);

        // Act and assert
        mockMvc.perform(post("/api/shopping-lists/from-recipe/{recipeId}", 1).with(authentication(new UsernamePasswordAuthenticationToken("1", null, List.of())))
                .contentType(MediaType.APPLICATION_JSON)
                .content(objectMapper.writeValueAsString(mockRequest)))
                .andExpect(status().isOk())
                // fields in response object
                .andExpect(jsonPath("$.shopping_list_id").value(1))
                .andExpect(jsonPath("$.user_id").value(1))
                .andExpect(jsonPath("$.name").value("Generate Shopping List With All Items"))
                .andExpect(jsonPath("$.num_items").value(2)) 
                .andExpect(jsonPath("$.status").value("ACTIVE"));
    }

    @Test
    void generateShoppingListFromRecipe_bad_request_returns400() throws Exception {
        // Bad request
       String badRequest = """
                            {
                                "name": "name",
                                "include_available_pantry_items": "wrong"
                            }
                         """;

        // Act and Assert
        mockMvc.perform(post("/api/shopping-lists/from-recipe/{recipeId}", 1).with(authentication(new UsernamePasswordAuthenticationToken("1", null, List.of())))
                .contentType(MediaType.APPLICATION_JSON)
                .content(badRequest))
                .andExpect(status().isBadRequest());
    }

    @Test 
    void generateShoppingListFromRecipe_recipeNotFound_returns404() throws Exception{
        PantryRecipeComparisonRequest mockRequest = new PantryRecipeComparisonRequest(
            "Generate Shopping List With All Items",
            false
        );
        when(shoppingListService.generateShoppingListFromRecipe(anyInt(), eq(1), any(PantryRecipeComparisonRequest.class))).thenThrow(new ResponseStatusException(HttpStatus.NOT_FOUND, "Recipe not found"));

        // Act and assert
        mockMvc.perform(post("/api/shopping-lists/from-recipe/{recipeId}", 1).with(authentication(new UsernamePasswordAuthenticationToken("1", null, List.of())))
                // fields in response object
                .contentType(MediaType.APPLICATION_JSON)
                .content(objectMapper.writeValueAsString(mockRequest)))
                .andExpect(status().isNotFound())
                .andExpect(jsonPath("$.message").value("Recipe not found"));
    }

    // Compares recipe to current pantry ingredients and inserts the rest into shopping list specified by the user
    @Test
    void addRecipeIngredientsToShoppingList_validRequest_return200() throws Exception {
        // Arrange - mock response
        AddRecipeToShoppingListRequest mockRequest = new AddRecipeToShoppingListRequest(
            false
        );

        ShoppingListItemResponse itemResponse = new ShoppingListItemResponse(
            1,
            5,
            2,
            "Hummus",
            "Legumes and Legume Products",
            new BigDecimal("100"),
            "g",
            false
        );

        ShoppingListWithItemsResponse mockResponse = new ShoppingListWithItemsResponse(
            5,
            1,
            "Weekly Groceries",
            ShoppingListStatus.ACTIVE,
            OffsetDateTime.parse("2026-07-23T23:00:00Z"),
            1,
            List.of(itemResponse)
        );

       when(shoppingListService.addRecipeIngredientsToShoppingList(anyInt(), eq(5), eq(9), any(AddRecipeToShoppingListRequest.class))).thenReturn(mockResponse);

        // Act and assert
        mockMvc.perform(post("/api/shopping-lists/add-from-recipe/{shoppingListId}/{recipeId}", 5, 9).with(authentication(new UsernamePasswordAuthenticationToken("1", null, List.of())))
                .contentType(MediaType.APPLICATION_JSON)
                .content(objectMapper.writeValueAsString(mockRequest)))        
                .andExpect(status().isOk())
                // fields in response object
                .andExpect(jsonPath("$.shopping_list_id").value(5))
                .andExpect(jsonPath("$.user_id").value(1))
                .andExpect(jsonPath("$.name").value("Weekly Groceries"))
                .andExpect(jsonPath("$.num_items").value(1))
                .andExpect(jsonPath("$.status").value("ACTIVE"))
                .andExpect(jsonPath("$.items[0].item_id").value(1))
                .andExpect(jsonPath("$.items[0].shopping_list_id").value(5))
                .andExpect(jsonPath("$.items[0].ing_id").value(2))
                .andExpect(jsonPath("$.items[0].name").value("Hummus"))
                .andExpect(jsonPath("$.items[0].category").value("Legumes and Legume Products"))
                .andExpect(jsonPath("$.items[0].quantity").value(100))
                .andExpect(jsonPath("$.items[0].unit").value("g"))
                .andExpect(jsonPath("$.items[0].purchased").value(false));
    }

    @Test
    void addRecipeIngredientsToShoppingList_bad_request_returns400() throws Exception {
        // Bad request
       String badRequest = """
                            {
                                "include_available_pantry_items": "wrong"
                            }
                         """;

        // Act and Assert
        mockMvc.perform(post("/api/shopping-lists/add-from-recipe/{shoppingListId}/{recipeId}", 2, 1).with(authentication(new UsernamePasswordAuthenticationToken("1", null, List.of())))
                .contentType(MediaType.APPLICATION_JSON)
                .content(badRequest))
                .andExpect(status().isBadRequest());
    }

    @Test 
    void addRecipeIngredientsToShoppingList_recipeNotFound_returns404() throws Exception{

        AddRecipeToShoppingListRequest mockRequest = new AddRecipeToShoppingListRequest(
            false
        );

        when(shoppingListService.addRecipeIngredientsToShoppingList(anyInt(), eq(2), eq(1), any(AddRecipeToShoppingListRequest.class))).thenThrow(new ResponseStatusException(HttpStatus.NOT_FOUND, "Recipe not found"));

        // Act and assert
        mockMvc.perform(post("/api/shopping-lists/add-from-recipe/{shoppingListId}/{recipeId}", 2, 1).with(authentication(new UsernamePasswordAuthenticationToken("1", null, List.of())))
                // fields in response object
                .contentType(MediaType.APPLICATION_JSON)
                .content(objectMapper.writeValueAsString(mockRequest)))
                .andExpect(status().isNotFound())
                .andExpect(jsonPath("$.message").value("Recipe not found"));
    }

}
