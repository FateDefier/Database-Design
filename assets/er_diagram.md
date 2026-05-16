# ER 图 — 电商数据库系统

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

    USER ||--o{ ORDER : "下单"
    USER ||--o{ ADDRESS : "拥有"
    ORDER ||--o{ ORDER_ITEM : "包含"
    PRODUCT ||--o{ ORDER_ITEM : "出现在"
    CATEGORY ||--o{ PRODUCT : "属于"
    CATEGORY ||--o{ CATEGORY : "父子关系"
```

## 关系汇总

| 关系 | 类型 | 说明 |
|------|------|------|
| USER → ORDER | 一对多 | 一个用户可以有多个订单 |
| USER → ADDRESS | 一对多 | 一个用户可以有多个地址 |
| ORDER → ORDER_ITEM | 一对多 | 一个订单可以有多个订单项 |
| PRODUCT → ORDER_ITEM | 一对多 | 一个商品可以出现在多个订单项中 |
| CATEGORY → PRODUCT | 一对多 | 一个分类可以包含多个商品 |
| CATEGORY → CATEGORY | 自引用 | 分类可以有父分类（层级结构） |
