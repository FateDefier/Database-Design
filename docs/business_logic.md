# Business Logic

This document explains the business rules and data flows implemented in the e-commerce database system.

## Core Business Entities

### User Lifecycle

```
Registration → Authentication → Browse → Order → Post-Order
```

Users register with a phone number and password. They can have multiple shipping addresses, with one marked as default for quick checkout.

### Product Management

Products exist within a category hierarchy. Each product tracks:
- Current price
- Available stock
- Category classification

Products can be reclassified by changing their `category_id`.

### Order Processing

Orders follow this flow:

1. **Order Creation**: A user creates an order with a calculated total
2. **Item Addition**: Products are added as order items with quantity and price snapshot
3. **Inventory Update**: Product stock decreases by ordered quantity
4. **Order Completion**: Order is finalized with timestamp

### Address Management

Users can store multiple addresses. The `is_default` flag allows quick retrieval of the primary shipping address during checkout.

---

## Key Business Rules

### Rule 1: Price Snapshot Preservation

When an order item is created, the current product price is copied into `order_item.price`. This ensures that:
- Historical orders remain accurate even if product prices change
- Order totals can be recalculated from line items
- Price analysis can compare purchase price vs. current price

### Rule 2: Inventory Management

Product stock must be updated when:
- An order is placed (stock decreases)
- An order is cancelled (stock increases)

The SQL implementation uses UPDATE with JOIN:

```sql
UPDATE ecommerce.product
INNER JOIN ecommerce.order_item ON product.product_id = order_item.product_id
SET product.stock = product.stock - order_item.num
WHERE order_item.order_id = ?;
```

### Rule 3: Referential Integrity in Deletion

Order deletion must follow a specific sequence due to foreign key constraints:

1. Delete order items first (child records)
2. Then delete the order (parent record)

Attempting to delete an order without removing its items first will result in a foreign key violation error.

### Rule 4: Category Hierarchy

Categories form a tree structure through self-referencing `parent_id`:
- Top-level categories have `parent_id = NULL`
- Subcategories reference their parent category
- This allows flexible classification (e.g., Electronics → Computers → Laptops)

### Rule 5: Default Address

Each user can have one default address (where `is_default = 1`). The system should ensure only one address per user is marked as default.

---

## Data Flow Diagrams

### Order Creation Flow

```
[User] → Creates Order → [Order Table]
  ↓
  Selects Products → [Order Item Table]
  ↓
  System Updates Stock → [Product Table]
```

### Order Cancellation Flow

```
[User] → Cancels Order
  ↓
  System Deletes Order Items → [Order Item Table]
  ↓
  System Deletes Order → [Order Table]
  ↓
  (Optional) System Restores Stock → [Product Table]
```

### Category Query Flow

```
[User] → Selects Category
  ↓
  System Queries Category Tree → [Category Table]
  ↓
  System Retrieves Products → [Product Table]
  ↓
  Returns Filtered Results
```

---

## Common Query Patterns

### Pattern 1: User Order History

Retrieve all orders for a specific user with order details:

```sql
SELECT o.order_id, o.order_time, o.total,
       p.pname, oi.num, oi.price
FROM `order` o
JOIN order_item oi ON o.order_id = oi.order_id
JOIN product p ON oi.product_id = p.product_id
WHERE o.user_id = ?
ORDER BY o.order_time DESC;
```

### Pattern 2: Product Sales Statistics

Calculate total sales quantity and revenue per product:

```sql
SELECT p.product_id, p.pname,
       SUM(oi.num) AS total_sold,
       SUM(oi.num * oi.price) AS total_revenue
FROM product p
LEFT JOIN order_item oi ON p.product_id = oi.product_id
GROUP BY p.product_id, p.pname;
```

### Pattern 3: Category Product Listing

List all products under a category and its subcategories:

```sql
SELECT p.pname, p.price, c.category_name
FROM product p
JOIN category c ON p.category_id = c.category_id
WHERE c.category_name = ? OR c.parent_id = (
    SELECT category_id FROM category WHERE category_name = ?
);
```

### Pattern 4: User Default Address

Quickly retrieve a user's default shipping address:

```sql
SELECT receiver, phone, detail
FROM address
WHERE user_id = ? AND is_default = 1;
```

---

## Business Scenarios

### Scenario 1: New User Registration

1. User provides name, phone, password
2. System inserts into `user` table
3. Phone number uniqueness is enforced by UNIQUE constraint

### Scenario 2: Product Purchase

1. User browses products (query `product` table)
2. User selects products and quantities
3. System creates order record in `order` table
4. System creates order items in `order_item` table
5. System updates product stock in `product` table

### Scenario 3: Order Cancellation

1. User requests order cancellation
2. System deletes order items (respecting foreign key constraints)
3. System deletes order record
4. Optionally, system restores product stock

### Scenario 4: Address Management

1. User adds new address (insert into `address` table)
2. If marked as default, system should unset other defaults for that user
3. User can update or delete addresses

---

## Data Consistency Considerations

### Transaction Boundaries

For operations that modify multiple tables (like order creation), transactions should be used to ensure atomicity:

```sql
START TRANSACTION;
-- Insert order
-- Insert order items
-- Update product stock
COMMIT;
```

### Concurrent Access

In a production system, inventory updates would need locking mechanisms to prevent overselling:

```sql
SELECT stock FROM product WHERE product_id = ? FOR UPDATE;
-- Check if stock is sufficient
UPDATE product SET stock = stock - ? WHERE product_id = ?;
```

### Data Validation

Application-level validation should check:
- Stock availability before order creation
- Price consistency between order item and product
- User ownership of addresses before modification
