-- =============================================================================
-- V21__create_shopping_list_items.sql
-- 
-- Each row is an item in the shopping list
-- Field formats mirror pantry_ingredients so the Complete Shop action can directly insert items from shopping list to pantry and delete it from shopping list
-- =============================================================================

CREATE TABLE shopping_list_items (
    item_id             SERIAL          PRIMARY KEY,
    shopping_list_id    INT             NOT NULL REFERENCES shopping_lists(shopping_list_id) ON DELETE CASCADE,
    ing_id              INT             REFERENCES ingredient_catalogue(ing_id),
    name                VARCHAR(200),   --only used when ing_id is null   
    quantity            DECIMAL(10,3),
    unit                VARCHAR(30),
    purchased           BOOLEAN         NOT NULL DEFAULT FALSE
);

CREATE INDEX idx_shopping_list_items_list_id ON shopping_list_items(shopping_list_id);

COMMENT ON TABLE shopping_list_items            IS 'Items in a shopping list - mirrors pantry ingredients.';
COMMENT ON COLUMN shopping_list_items.ing_id    IS 'Null for manual free text entries. References ingredient_catalogue for catalogue items.';
COMMENT ON COLUMN shopping_list_items.name      IS 'Free text name when ing_id is null.';
COMMENT ON COLUMN shopping_list_items.purchased IS 'To toggle a checkbox in UI.';