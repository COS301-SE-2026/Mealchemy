-- =============================================================================
-- V28__seed_ingredient_categories.sql
--
-- Seeds ingredient categories directly from USDA Foundation Foods category names.
-- Shelf life values are estimates
-- =============================================================================

INSERT INTO ingredient_categories (name, pantry_shelf_life_days, fridge_shelf_life_days)
VALUES
    ('Baked Products', 7, 14),
    ('Beef Products', NULL, 4),
    ('Beverages', 180, 7),
    ('Cereal Grains and Pasta', 365, NULL),
    ('Dairy and Egg Products', NULL, 14),
    ('Fats and Oils', 180, NULL),
    ('Finfish and Shellfish Products', NULL, 2),
    ('Fruits and Fruit Juices', 7, 21),
    ('Lamb, Veal, and Game Products', NULL, 4),
    ('Legumes and Legume Products', 365, NULL),
    ('Nut and Seed Products', 180, NULL),
    ('Pork Products', NULL, 4),
    ('Poultry Products', NULL, 2),
    ('Restaurant Foods', NULL, 2),
    ('Sausages and Luncheon Meats', NULL, 5),
    ('Soups, Sauces, and Gravies', 730, 5),
    ('Spices and Herbs', 365, NULL),
    ('Sweets', 180, NULL),
    ('Vegetables and Vegetable Products', 7, 14)
ON CONFLICT (name) DO NOTHING;