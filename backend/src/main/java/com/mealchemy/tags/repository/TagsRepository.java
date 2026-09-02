package com.mealchemy.tags.repository;

/* Import classes */
import com.mealchemy.tags.model.Tags;

/* Import libraries */
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

@Repository
public interface TagsRepository extends JpaRepository<Tags, Integer>{
    
}
