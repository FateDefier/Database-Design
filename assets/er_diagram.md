# ER Diagram - E-Commerce Database System

```mermaid
erDiagram
    USER {
        int user_id PK
        varchar name
        varchar phone
        varchar password
    }

    PRODUCT {
        int product_id PK
        varchar pname
        decimal price
        int stock
        int category_id FK
    }

    ORDER {
        int order_id PK
        int user_id FK
        decimal total
        datetime order_time
    }

    ORDER_ITEM {
        int item_id PK
        int order_id FK
        int product_id FK
        int num
        decimal price
    }

    ADDRESS {
        int addr_id PK
        int user_id FK
        varchar receiver
        varchar phone
        varchar detail
        boolean is_default
    }

    CATEGORY {
        int category_id PK
        varchar category_name
        int parent_id FK
    }

    USER ||--o{ ORDER : "places"
    USER ||--o{ ADDRESS : "has"
    ORDER ||--o{ ORDER_ITEM : "contains"
    PRODUCT ||--o{ ORDER_ITEM : "appears in"
    CATEGORY ||--o{ PRODUCT : "belongs to"
    CATEGORY ||--o{ CATEGORY : "parent-child"
```

## Relationship Summary

| Relationship | Type | Description |
|--------------|------|-------------|
| USER → ORDER | One-to-Many | A user can place multiple orders |
| USER → ADDRESS | One-to-Many | A user can have multiple addresses |
| ORDER → ORDER_ITEM | One-to-Many | An order can contain multiple items |
| PRODUCT → ORDER_ITEM | One-to-Many | A product can appear in multiple order items |
| CATEGORY → PRODUCT | One-to-Many | A category can contain multiple products |
| CATEGORY → CATEGORY | Self-referencing | Categories can have parent categories (hierarchy) |
