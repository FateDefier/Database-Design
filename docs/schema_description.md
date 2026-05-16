# Schema Description

This document provides a detailed description of all database tables, their columns, constraints, and relationships.

## Database

**Database Name**: `ecommerce`

**Character Set**: UTF-8 (for Chinese character support)

---

## Tables

### 1. user

Stores system user information.

| Column | Type | Constraints | Description |
|--------|------|-------------|-------------|
| `user_id` | INT | PRIMARY KEY | Unique user identifier |
| `name` | VARCHAR | NOT NULL | User's display name |
| `phone` | VARCHAR | NOT NULL, UNIQUE | Phone number (used for login) |
| `password` | VARCHAR | NOT NULL | Password (stored in plaintext for demo purposes) |

**Indexes**: Primary key on `user_id`, unique index on `phone`

---

### 2. product

Stores product information.

| Column | Type | Constraints | Description |
|--------|------|-------------|-------------|
| `product_id` | INT | PRIMARY KEY | Unique product identifier |
| `pname` | VARCHAR | NOT NULL | Product name |
| `price` | DECIMAL(10,2) | NOT NULL | Current selling price |
| `stock` | INT | NOT NULL, DEFAULT 0 | Available inventory quantity |
| `category_id` | INT | FOREIGN KEY → category(category_id) | Product category reference |

**Foreign Keys**:
- `category_id` references `category(category_id)`

---

### 3. order

Stores order header information.

| Column | Type | Constraints | Description |
|--------|------|-------------|-------------|
| `order_id` | INT | PRIMARY KEY | Unique order identifier |
| `user_id` | INT | FOREIGN KEY → user(user_id), NOT NULL | Order owner |
| `total` | DECIMAL(10,2) | NOT NULL | Order total amount |
| `order_time` | DATETIME | DEFAULT CURRENT_TIMESTAMP | Order creation time |

**Foreign Keys**:
- `user_id` references `user(user_id)`

---

### 4. order_item

Stores individual line items within an order. This is the junction table resolving the many-to-many relationship between orders and products.

| Column | Type | Constraints | Description |
|--------|------|-------------|-------------|
| `item_id` | INT | PRIMARY KEY | Unique line item identifier |
| `order_id` | INT | FOREIGN KEY → order(order_id), NOT NULL | Parent order reference |
| `product_id` | INT | FOREIGN KEY → product(product_id), NOT NULL | Product reference |
| `num` | INT | NOT NULL | Quantity ordered |
| `price` | DECIMAL(10,2) | NOT NULL | Price at time of purchase (snapshot) |

**Foreign Keys**:
- `order_id` references `order(order_id)`
- `product_id` references `product(product_id)`

**Design Note**: The `price` column stores the price at the time of purchase, not the current product price. This ensures historical orders remain accurate even if product prices change.

---

### 5. address

Stores user shipping addresses.

| Column | Type | Constraints | Description |
|--------|------|-------------|-------------|
| `addr_id` | INT | PRIMARY KEY | Unique address identifier |
| `user_id` | INT | FOREIGN KEY → user(user_id), NOT NULL | Address owner |
| `receiver` | VARCHAR | NOT NULL | Receiver's name |
| `phone` | VARCHAR | NOT NULL | Receiver's phone number |
| `detail` | VARCHAR | NOT NULL | Full address details |
| `is_default` | TINYINT | DEFAULT 0 | Whether this is the default address (1=yes, 0=no) |

**Foreign Keys**:
- `user_id` references `user(user_id)`

---

### 6. category

Stores product categories in a hierarchical structure.

| Column | Type | Constraints | Description |
|--------|------|-------------|-------------|
| `category_id` | INT | PRIMARY KEY | Unique category identifier |
| `category_name` | VARCHAR | NOT NULL | Category display name |
| `parent_id` | INT | FOREIGN KEY → category(category_id), NULLABLE | Parent category reference (NULL for top-level) |

**Foreign Keys**:
- `parent_id` references `category(category_id)` (self-referencing)

**Design Note**: The self-referencing `parent_id` creates a tree structure for categories. Top-level categories have `parent_id = NULL`. This allows unlimited nesting depth (e.g., Electronics → Computers → Laptops).

---

## Relationship Summary

| Relationship | Type | Implementation |
|--------------|------|----------------|
| user → order | One-to-Many | `order.user_id` references `user.user_id` |
| user → address | One-to-Many | `address.user_id` references `user.user_id` |
| order → order_item | One-to-Many | `order_item.order_id` references `order.order_id` |
| product → order_item | One-to-Many | `order_item.product_id` references `product.product_id` |
| category → product | One-to-Many | `product.category_id` references `category.category_id` |
| category → category | Self-referencing | `category.parent_id` references `category.category_id` |

---

## Data Integrity Constraints

1. **Primary Keys**: All tables have single-column primary keys for unique identification.

2. **Foreign Keys**: All relationships are enforced through foreign key constraints, preventing orphaned records.

3. **NOT NULL**: Critical fields (names, prices, quantities) are marked as NOT NULL to ensure data completeness.

4. **UNIQUE**: The `user.phone` column has a unique constraint to prevent duplicate registrations.

5. **DEFAULT Values**: `order.order_time` defaults to current timestamp, `address.is_default` defaults to 0.
