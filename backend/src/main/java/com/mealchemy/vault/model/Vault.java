    package com.mealchemy.vault.model;

    /* Import libraries */

    import jakarta.persistence.*;  
    import java.time.OffsetDateTime;
    import java.util.*;
    import org.hibernate.annotations.JdbcTypeCode;
    import org.hibernate.type.SqlTypes;

    /* Import classes */

    import com.mealchemy.shared.enums.VaultType;

    @Entity
    @Table(name = "vaults")
    public class Vault
    {

        /* Declaring fields */

        @Id
        @GeneratedValue(strategy = GenerationType.IDENTITY)
        @Column(name = "vault_id")
        private Integer vaultId;
        
        @Column(name = "owner_id")
        private Integer ownerId;

        @Enumerated(EnumType.STRING)
        @Column(name = "vault_type", nullable = false, columnDefinition = "vault_type_enum")
        @JdbcTypeCode(SqlTypes.NAMED_ENUM)
        private VaultType vaultType = VaultType.PRIVATE;

        @Column(nullable = false)
        private String name = "My Vault";

        @Column(name = "created_at", nullable = false)
        private OffsetDateTime createdAt = OffsetDateTime.now();

        @OneToMany(mappedBy = "vault", cascade = CascadeType.ALL, orphanRemoval = true)
        private List<VaultFolder> folders = new ArrayList<>();

        /* Getters */

        public Integer getVaultId()
        {
            return vaultId;
        }

        public Integer getOwnerId()
        {
            return ownerId;
        }

        public VaultType getVaultType()
        {
            return vaultType;
        }

        public String getName()
        {
            return name;
        }

        public OffsetDateTime getCreatedAt()
        {
            return createdAt;
        }

        public List<VaultFolder> getFolders()
        {
            return folders;
        }

        /* Setters */

        public void setOwnerId(Integer ownerIdIn)
        {
            ownerId = ownerIdIn;
        }

        public void setVaultType(VaultType vaultTypeIn)
        {
            vaultType = vaultTypeIn;  
        }

        public void setName(String nameIn)
        {
            name = nameIn;
        }

        public void setFolders(List<VaultFolder> foldersIn)
        {
            folders = foldersIn;
        }
    }