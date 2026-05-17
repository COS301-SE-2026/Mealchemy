-- =============================================================================
-- V22__seed_recipe_steps.sql
--
-- Seeds all steps for all 5 recipes in the correct numbered order
-- The UNIQUE constraint on (recipe_id, step_nr) prevents duplicate step numbers
-- =============================================================================

-- Recipe 1: Honey Sriracha Chicken and Broccoli

WITH recipe_1 AS (SELECT recipe_id FROM recipes WHERE title = 'Honey Sriracha Chicken and Broccoli')
INSERT INTO recipe_steps (recipe_id, step_nr, content)
SELECT recipe_id, 1, 'Preheat oven to 220°C. Coat the diced chicken in the beaten egg whites, then toss in the corn starch and 3.5g of salt until evenly coated.' FROM recipe_1 UNION ALL
SELECT recipe_id, 2, 'Spray a large nonstick sheet pan with olive oil spray. Arrange the coated chicken in a single layer and bake for 10 minutes.' FROM recipe_1 UNION ALL
SELECT recipe_id, 3, 'Flip the chicken pieces and add the broccoli florets to the pan. Drizzle the broccoli with 10ml sesame oil, 2.5g salt, and a pinch of pepper. Bake for a further 10 minutes until the chicken is cooked through.' FROM recipe_1 UNION ALL
SELECT recipe_id, 4, 'Whisk together the honey, sriracha sauce, seasoned rice vinegar, and remaining sesame oil in a bowl. Toss the baked chicken in the sauce until fully coated.' FROM recipe_1 UNION ALL
SELECT recipe_id, 5, 'Divide the cooked brown rice between 8 meal prep bowls. Top with the sauced chicken and roasted broccoli. Garnish with sliced scallions and black and white sesame seeds.' FROM recipe_1;

-- Recipe 2: Caprese Pasta Salad 

WITH recipe_2 AS (SELECT recipe_id FROM recipes WHERE title = 'Caprese Pasta Salad')
INSERT INTO recipe_steps (recipe_id, step_nr, content)
SELECT recipe_id, 1, 'Bring a large pot of well-salted water to a boil. Cook the cavatappi pasta according to package instructions, slightly past al dente. Drain, toss with a drizzle of olive oil, and spread on a plate or tray to cool to room temperature.' FROM recipe_2 UNION ALL
SELECT recipe_id, 2, 'In a large bowl, whisk together the 80ml extra-virgin olive oil, lemon juice, balsamic vinegar, grated pecorino, garlic, salt, and a generous grind of black pepper until combined.' FROM recipe_2 UNION ALL
SELECT recipe_id, 3, 'Add the cooled pasta to the bowl and toss to coat in the dressing. Add the halved cherry tomatoes, mozzarella balls, red onion, and torn basil. Toss again. Gently fold in the shaved pecorino to finish.' FROM recipe_2 UNION ALL
SELECT recipe_id, 4, 'Taste and season with additional salt and pepper as needed. Garnish with extra torn basil leaves and serve immediately, or refrigerate for up to two days.' FROM recipe_2;

-- Recipe 3: Penne Alla Vodka

WITH recipe_3 AS (SELECT recipe_id FROM recipes WHERE title = 'Penne Alla Vodka')
INSERT INTO recipe_steps (recipe_id, step_nr, content)
SELECT recipe_id, 1, 'Heat the olive oil in a large deep skillet over medium heat. Add the chopped onion, sliced garlic, salt, and red pepper flakes. Sauté for 5 to 8 minutes, stirring occasionally, until the onion is soft and translucent.' FROM recipe_3 UNION ALL
SELECT recipe_id, 2, 'Add the tomato paste and cook for 3 minutes, stirring frequently, until it darkens to a deep red. Stir in the vodka and cook for 1 minute to cook off the alcohol.' FROM recipe_3 UNION ALL
SELECT recipe_id, 3, 'Add the crushed whole peeled tomatoes and stir to combine. Reduce heat to low and simmer for 10 minutes.' FROM recipe_3 UNION ALL
SELECT recipe_id, 4, 'Remove the sauce from the heat and allow to cool slightly. Transfer to a blender and blend until completely smooth. Set aside.' FROM recipe_3 UNION ALL
SELECT recipe_id, 5, 'Bring a large pot of well-salted water to a boil. Cook the penne until al dente according to package instructions. Before draining, reserve 240ml of pasta water. Drain the pasta.' FROM recipe_3 UNION ALL
SELECT recipe_id, 6, 'Return the blended sauce to the skillet over low heat. Stir in the heavy cream and 120ml of the reserved pasta water. Add the drained pasta and toss well, adding more pasta water a little at a time if needed to achieve a glossy, silky coating.' FROM recipe_3 UNION ALL
SELECT recipe_id, 7, 'Serve immediately, topped with chopped fresh parsley or basil and a generous grating of Parmesan cheese.' FROM recipe_3;

-- Recipe 4: Lemon Herb Salmon with Roasted Vegetables

WITH recipe_4 AS (SELECT recipe_id FROM recipes WHERE title = 'Lemon Herb Salmon with Roasted Vegetables')
INSERT INTO recipe_steps (recipe_id, step_nr, content)
SELECT recipe_id, 1, 'Preheat oven to 200°C. Line a large baking sheet with parchment paper.' FROM recipe_4 UNION ALL
SELECT recipe_id, 2, 'Arrange the sliced zucchini, red and yellow bell peppers, and cherry tomatoes on the baking sheet. Drizzle with 30ml of the olive oil, season with salt and pepper, and toss to coat. Spread into an even single layer.' FROM recipe_4 UNION ALL
SELECT recipe_id, 3, 'Place the salmon fillets on top of the vegetables. In a small bowl, mix the remaining 30ml olive oil with the lemon juice, minced garlic, dried oregano, and dried thyme. Spoon the herb mixture evenly over each fillet and season with the remaining salt and pepper.' FROM recipe_4 UNION ALL
SELECT recipe_id, 4, 'Roast for 18 to 20 minutes until the salmon flakes easily with a fork and the vegetables are tender and lightly caramelised at the edges.' FROM recipe_4 UNION ALL
SELECT recipe_id, 5, 'Remove from the oven, garnish with fresh parsley, and serve immediately directly from the pan.' FROM recipe_4;

-- Recipe 5: Black Bean and Corn Burrito Bowls

WITH recipe_5 AS (SELECT recipe_id FROM recipes WHERE title = 'Black Bean and Corn Burrito Bowls')
INSERT INTO recipe_steps (recipe_id, step_nr, content)
SELECT recipe_id, 1, 'Heat the olive oil in a large skillet over medium heat. Add the diced red onion and red bell pepper and cook for 5 minutes, stirring occasionally, until softened.' FROM recipe_5 UNION ALL
SELECT recipe_id, 2, 'Add the drained black beans and thawed corn to the skillet. Season with ground cumin, smoked paprika, garlic powder, and sea salt. Stir to combine and cook for 5 minutes until everything is heated through.' FROM recipe_5 UNION ALL
SELECT recipe_id, 3, 'Squeeze the fresh lime juice over the mixture, stir well, and remove from heat.' FROM recipe_5 UNION ALL
SELECT recipe_id, 4, 'Divide the cooked brown rice evenly between 4 serving bowls. Spoon the black bean and corn mixture generously over the rice.' FROM recipe_5 UNION ALL
SELECT recipe_id, 5, 'Top each bowl with sliced avocado and fresh coriander leaves. Add a dollop of sour cream and serve immediately.' FROM recipe_5;