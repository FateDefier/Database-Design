# 业务逻辑说明

本文档解释电商数据库系统中实现的业务规则和数据流程。

## 核心业务实体

### 用户生命周期

```
注册 → 认证 → 浏览 → 下单 → 订单处理
```

用户通过手机号和密码注册。每个用户可以拥有多个收货地址，其中一个标记为默认地址以便快速结算。

### 商品管理

商品存在于分类层级中。每个商品跟踪：
- 当前价格
- 可用库存
- 分类归属

商品可以通过修改 `category_id` 重新分类。

### 订单处理

订单遵循以下流程：

1. **创建订单**：用户创建订单并计算总金额
2. **添加商品**：商品作为订单项添加，记录数量和价格快照
3. **更新库存**：商品库存按购买数量减少
4. **完成订单**：订单最终确认并记录时间戳

### 地址管理

用户可以存储多个地址。`is_default` 标志允许在结算时快速获取首选收货地址。

---

## 核心业务规则

### 规则一：价格快照保存

创建订单项时，当前商品价格被复制到 `order_item.price`。这确保：
- 即使商品后续调价，历史订单仍然准确
- 可以从明细项重新计算订单总金额
- 可以对比购买价格与当前价格进行分析

### 规则二：库存管理

以下情况需要更新商品库存：
- 下单时（库存减少）
- 取消订单时（库存增加）

SQL 实现使用 UPDATE JOIN：

```sql
UPDATE ecommerce.product
INNER JOIN ecommerce.order_item ON product.product_id = order_item.product_id
SET product.stock = product.stock - order_item.num
WHERE order_item.order_id = ?;
```

### 规则三：删除时的参照完整性

由于外键约束，删除订单必须遵循特定顺序：

1. 先删除订单项（子记录）
2. 再删除订单（父记录）

如果不先删除订单项就直接删除订单，会触发外键约束错误。

### 规则四：分类层级

分类通过自引用的 `parent_id` 形成树形结构：
- 顶级分类的 `parent_id` 为 NULL
- 子分类引用其父分类
- 支持灵活的分类方式（如：电子产品 → 电脑 → 笔记本）

### 规则五：默认地址

每个用户可以有一个默认地址（`is_default = 1`）。系统应确保每个用户只有一个地址被标记为默认。

---

## 数据流程图

### 下单流程

```
[用户] → 创建订单 → [订单表]
  ↓
  选择商品 → [订单项表]
  ↓
  系统更新库存 → [商品表]
```

### 取消订单流程

```
[用户] → 取消订单
  ↓
  系统删除订单项 → [订单项表]
  ↓
  系统删除订单 → [订单表]
  ↓
  （可选）系统恢复库存 → [商品表]
```

### 分类查询流程

```
[用户] → 选择分类
  ↓
  系统查询分类树 → [分类表]
  ↓
  系统获取商品 → [商品表]
  ↓
  返回筛选结果
```

---

## 常见查询模式

### 模式一：用户订单历史

获取指定用户的所有订单及订单详情：

```sql
SELECT o.order_id, o.order_time, o.total,
       p.pname, oi.num, oi.price
FROM `order` o
JOIN order_item oi ON o.order_id = oi.order_id
JOIN product p ON oi.product_id = p.product_id
WHERE o.user_id = ?
ORDER BY o.order_time DESC;
```

### 模式二：商品销售统计

计算每个商品的总销量和总收入：

```sql
SELECT p.product_id, p.pname,
       SUM(oi.num) AS total_sold,
       SUM(oi.num * oi.price) AS total_revenue
FROM product p
LEFT JOIN order_item oi ON p.product_id = oi.product_id
GROUP BY p.product_id, p.pname;
```

### 模式三：分类商品列表

列出某个分类及其子分类下的所有商品：

```sql
SELECT p.pname, p.price, c.category_name
FROM product p
JOIN category c ON p.category_id = c.category_id
WHERE c.category_name = ? OR c.parent_id = (
    SELECT category_id FROM category WHERE category_name = ?
);
```

### 模式四：用户默认地址

快速获取用户的默认收货地址：

```sql
SELECT receiver, phone, detail
FROM address
WHERE user_id = ? AND is_default = 1;
```

---

## 业务场景

### 场景一：新用户注册

1. 用户提供姓名、手机号、密码
2. 系统插入 `user` 表
3. 手机号唯一性由 UNIQUE 约束保证

### 场景二：商品购买

1. 用户浏览商品（查询 `product` 表）
2. 用户选择商品和数量
3. 系统在 `order` 表创建订单记录
4. 系统在 `order_item` 表创建订单项
5. 系统更新 `product` 表中的商品库存

### 场景三：取消订单

1. 用户申请取消订单
2. 系统删除订单项（遵循外键约束）
3. 系统删除订单记录
4. 可选：系统恢复商品库存

### 场景四：地址管理

1. 用户添加新地址（插入 `address` 表）
2. 如果标记为默认地址，系统应取消该用户的其他默认地址
3. 用户可以更新或删除地址

---

## 数据一致性考虑

### 事务边界

对于修改多个表的操作（如创建订单），应使用事务确保原子性：

```sql
START TRANSACTION;
-- 插入订单
-- 插入订单项
-- 更新商品库存
COMMIT;
```

### 并发访问

在生产系统中，库存更新需要加锁机制以防止超卖：

```sql
SELECT stock FROM product WHERE product_id = ? FOR UPDATE;
-- 检查库存是否充足
UPDATE product SET stock = stock - ? WHERE product_id = ?;
```

### 数据验证

应用层验证应检查：
- 下单前检查库存是否充足
- 订单项与商品的价格一致性
- 修改地址前验证用户所有权
