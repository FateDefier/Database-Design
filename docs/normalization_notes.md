# Normalization Notes

This document analyzes the database design from a normalization perspective, explaining how the schema adheres to normal forms and the trade-offs involved.

## Normal Forms Overview

| Normal Form | Requirement | Status |
|-------------|-------------|--------|
| 1NF | Atomic values, no repeating groups | ✓ Achieved |
| 2NF | 1NF + no partial dependencies | ✓ Achieved |
| 3NF | 2NF + no transitive dependencies | ✓ Achieved |

---

## First Normal Form (1NF)

**Rule**: Each column must contain atomic (indivisible) values, and each row must be unique.

### Analysis

All tables in this design satisfy 1NF:

- **user**: Each column contains single values (name, phone, password)
- **product**: Each column contains single values (pname, price, stock)
- **order**: Each column contains single values (user_id, total, order_time)
- **order_item**: Each column contains single values (order_id, product_id, num, price)
- **address**: Each column contains single values (receiver, phone, detail)
- **category**: Each column contains single values (category_name, parent_id)

### Example

The `address` table stores addresses in a single `detail` column rather than splitting into street, city, state, zip. This is acceptable for this project's scope, though a production system might benefit from structured address fields.

---

## Second Normal Form (2NF)

**Rule**: Must be in 1NF, and all non-key attributes must be fully dependent on the entire primary key.

### Analysis

All tables use single-column primary keys, so partial dependencies are not possible:

- **user**: `user_id` is the sole primary key; all other columns depend on it
- **product**: `product_id` is the sole primary key; all other columns depend on it
- **order**: `order_id` is the sole primary key; all other columns depend on it
- **order_item**: `item_id` is the sole primary key; all other columns depend on it
- **address**: `addr_id` is the sole primary key; all other columns depend on it
- **category**: `category_id` is the sole primary key; all other columns depend on it

### Note on order_item

If `order_item` used a composite primary key `(order_id, product_id)`, we would need to verify that `num` and `price` depend on both columns. Since `item_id` is used as the primary key instead, this concern is avoided.

---

## Third Normal Form (3NF)

**Rule**: Must be in 2NF, and no non-key attribute should depend on another non-key attribute (no transitive dependencies).

### Analysis

#### user table
- `user_id` → `name`, `phone`, `password`
- No transitive dependencies exist

#### product table
- `product_id` → `pname`, `price`, `stock`, `category_id`
- `category_id` → `category_name` (but this is a foreign key, not a transitive dependency)
- The category name is stored in the `category` table, not in `product`

#### order table
- `order_id` → `user_id`, `total`, `order_time`
- `user_id` → `name` (but this is stored in the `user` table, not in `order`)
- No transitive dependencies exist

#### order_item table
- `item_id` → `order_id`, `product_id`, `num`, `price`
- No transitive dependencies exist

#### address table
- `addr_id` → `user_id`, `receiver`, `phone`, `detail`, `is_default`
- No transitive dependencies exist

#### category table
- `category_id` → `category_name`, `parent_id`
- `parent_id` → `parent_category_name` (but this is stored via self-reference, not duplicated)
- No transitive dependencies exist

---

## Design Decisions and Trade-offs

### Decision 1: Price Snapshot in order_item

**Choice**: Store `price` in `order_item` even though it's also in `product`.

**Justification**: This is a deliberate denormalization for business reasons:
- Historical orders must reflect the price at time of purchase
- Product prices may change after orders are placed
- Order totals can be recalculated from line items

**Impact**: Slight redundancy, but ensures data accuracy for historical records.

### Decision 2: Order Total in order table

**Choice**: Store `total` in `order` even though it can be calculated from `order_item`.

**Justification**: This is another deliberate denormalization:
- Avoids recalculating totals for every order query
- Provides a quick reference for order value
- Can be used for validation (compare stored total vs. calculated total)

**Impact**: Potential inconsistency if order items are modified without updating total.

### Decision 3: Category Hierarchy via Self-Reference

**Choice**: Use `parent_id` self-referencing instead of separate parent/child tables.

**Justification**:
- Simple implementation for tree structures
- Allows unlimited nesting depth
- Easy to query direct children or parents

**Trade-offs**:
- Querying all descendants requires recursive queries or multiple joins
- No built-in constraint to prevent circular references

### Decision 4: Single Address Table

**Choice**: Store all addresses in one table with `user_id` foreign key.

**Justification**:
- Simple one-to-many relationship
- Easy to query all user addresses
- `is_default` flag allows quick default address retrieval

**Alternative Considered**: Separate tables for billing and shipping addresses. Rejected as unnecessary complexity for this project scope.

---

## Potential Normalization Issues

### Issue 1: Password Storage

**Current**: Passwords stored in plaintext in `user` table.

**Problem**: Security vulnerability. Passwords should be hashed.

**Recommendation**: In a production system, store password hashes instead of plaintext passwords.

### Issue 2: Address Structure

**Current**: Address stored as single `detail` string.

**Problem**: Difficult to query by city, state, or zip code.

**Recommendation**: For a production system, consider splitting into structured fields (street, city, state, zip_code, country).

### Issue 3: Category Hierarchy Depth

**Current**: Self-referencing allows unlimited depth.

**Problem**: Deep hierarchies require complex recursive queries.

**Recommendation**: Consider limiting depth or using a materialized path pattern for frequently queried hierarchies.

---

## Normalization Benefits in This Design

### Data Consistency

- User information is stored once in the `user` table
- Product information is stored once in the `product` table
- Category information is stored once in the `category` table
- No redundant storage of user names, product names, or category names

### Update Anomalies

- Changing a user's name requires updating only one row in the `user` table
- Changing a product's price requires updating only one row in the `product` table
- No risk of inconsistent data due to multiple copies

### Insert Anomalies

- New products can be added without creating orders
- New users can be registered without placing orders
- New categories can be created without assigning products

### Delete Anomalies

- Deleting an order doesn't affect the product catalog
- Deleting a product doesn't affect historical orders (due to price snapshot)
- Deleting a user doesn't affect product or category data

---

## Conclusion

The database design successfully achieves Third Normal Form (3NF) while making deliberate denormalization choices where business requirements justify them. The price snapshot in `order_item` and the total in `order` are conscious decisions to prioritize data accuracy and query performance over strict normalization.

The self-referencing category hierarchy is a standard pattern for tree structures in relational databases, trading query complexity for implementation simplicity.
