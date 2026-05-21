    package com.mealchemy.vault.model;

    /* Import libraries */

    import jakarta.persistence.*;
    import java.time.OffsetDateTime;
    import java.util.Arrays;
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
        private int vaultId;
        
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

        /* Getters */

        public int getVaultId()
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
    }