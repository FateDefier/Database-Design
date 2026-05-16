# 数据表结构说明

本文档详细描述所有数据库表的列、约束和关系。

## 数据库

**数据库名**: `ecommerce`

**字符集**: UTF-8（支持中文）

---

## 数据表

### 1. user（用户表）

存储系统用户信息。

| 列名 | 类型 | 约束 | 说明 |
|------|------|------|------|
| `user_id` | INT | PRIMARY KEY | 用户唯一标识 |
| `name` | VARCHAR | NOT NULL | 用户显示名称 |
| `phone` | VARCHAR | NOT NULL, UNIQUE | 手机号（用于登录） |
| `password` | VARCHAR | NOT NULL | 密码（演示用途，明文存储） |

**索引**: `user_id` 主键索引，`phone` 唯一索引

---

### 2. product（商品表）

存储商品信息。

| 列名 | 类型 | 约束 | 说明 |
|------|------|------|------|
| `product_id` | INT | PRIMARY KEY | 商品唯一标识 |
| `pname` | VARCHAR | NOT NULL | 商品名称 |
| `price` | DECIMAL(10,2) | NOT NULL | 当前售价 |
| `stock` | INT | NOT NULL, DEFAULT 0 | 库存数量 |
| `category_id` | INT | FOREIGN KEY → category(category_id) | 商品分类引用 |

**外键**:
- `category_id` 引用 `category(category_id)`

---

### 3. order（订单表）

存储订单头信息。

| 列名 | 类型 | 约束 | 说明 |
|------|------|------|------|
| `order_id` | INT | PRIMARY KEY | 订单唯一标识 |
| `user_id` | INT | FOREIGN KEY → user(user_id), NOT NULL | 下单用户 |
| `total` | DECIMAL(10,2) | NOT NULL | 订单总金额 |
| `order_time` | DATETIME | DEFAULT CURRENT_TIMESTAMP | 下单时间 |

**外键**:
- `user_id` 引用 `user(user_id)`

---

### 4. order_item（订单项表）

存储订单中的明细项。这是解决订单和商品多对多关系的中间表。

| 列名 | 类型 | 约束 | 说明 |
|------|------|------|------|
| `item_id` | INT | PRIMARY KEY | 订单项唯一标识 |
| `order_id` | INT | FOREIGN KEY → order(order_id), NOT NULL | 所属订单 |
| `product_id` | INT | FOREIGN KEY → product(product_id), NOT NULL | 商品引用 |
| `num` | INT | NOT NULL | 购买数量 |
| `price` | DECIMAL(10,2) | NOT NULL | 下单时价格（快照） |

**外键**:
- `order_id` 引用 `order(order_id)`
- `product_id` 引用 `product(product_id)`

**设计说明**: `price` 列存储下单时的价格，而非当前商品价格。这确保即使商品后续调价，历史订单数据仍然准确。

---

### 5. address（地址表）

存储用户收货地址。

| 列名 | 类型 | 约束 | 说明 |
|------|------|------|------|
| `addr_id` | INT | PRIMARY KEY | 地址唯一标识 |
| `user_id` | INT | FOREIGN KEY → user(user_id), NOT NULL | 所属用户 |
| `receiver` | VARCHAR | NOT NULL | 收件人姓名 |
| `phone` | VARCHAR | NOT NULL | 收件人电话 |
| `detail` | VARCHAR | NOT NULL | 详细地址 |
| `is_default` | TINYINT | DEFAULT 0 | 是否默认地址（1=是，0=否） |

**外键**:
- `user_id` 引用 `user(user_id)`

---

### 6. category（商品分类表）

以层级结构存储商品分类。

| 列名 | 类型 | 约束 | 说明 |
|------|------|------|------|
| `category_id` | INT | PRIMARY KEY | 分类唯一标识 |
| `category_name` | VARCHAR | NOT NULL | 分类名称 |
| `parent_id` | INT | FOREIGN KEY → category(category_id), NULLABLE | 父分类引用（NULL 表示顶级分类） |

**外键**:
- `parent_id` 引用 `category(category_id)`（自引用）

**设计说明**: 自引用的 `parent_id` 形成树形结构。顶级分类的 `parent_id` 为 NULL，支持无限层级嵌套（如：电脑设备 → 电脑配件 → 输入设备）。

---

## 关系汇总

| 关系 | 类型 | 实现方式 |
|------|------|----------|
| user → order | 一对多 | `order.user_id` 引用 `user.user_id` |
| user → address | 一对多 | `address.user_id` 引用 `user.user_id` |
| order → order_item | 一对多 | `order_item.order_id` 引用 `order.order_id` |
| product → order_item | 一对多 | `order_item.product_id` 引用 `product.product_id` |
| category → product | 一对多 | `product.category_id` 引用 `category.category_id` |
| category → category | 自引用 | `category.parent_id` 引用 `category.category_id` |

---

## 数据完整性约束

1. **主键**: 所有表均使用单列主键进行唯一标识。

2. **外键**: 所有关系通过外键约束强制执行，防止孤立记录。

3. **NOT NULL**: 关键字段（名称、价格、数量）标记为 NOT NULL，确保数据完整性。

4. **UNIQUE**: `user.phone` 列具有唯一约束，防止重复注册。

5. **默认值**: `order.order_time` 默认为当前时间戳，`address.is_default` 默认为 0。
