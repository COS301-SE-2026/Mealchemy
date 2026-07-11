// talks to ingredient_catalogue db table

import com.mealchemy.preference.model.IngredientCatalogue;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.Optional;
import java.util.List;

public interface IngredientCatalogueRepository extends JpaRepository< {
    List<IngredientCatalogue> findByIngId(Integer ingId);
    
    // when using ingredients catalogue - usually fininding ingredients by name
    List<IngredientCatalogue> findByNameContaining(String name);

}
