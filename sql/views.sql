-- 视图操作
-----------------------------------------------------------------------------------
-- 1.创建用户订单概览视图
USE ecommerce;

CREATE VIEW user_order AS
SELECT `user`.user_id, `user`.`name`, `user`.`phone`, `order`.order_id, `order`.order_time, `order`.total
FROM ecommerce.`user`
LEFT JOIN ecommerce.`order` ON `user`.user_id = `order`.user_id;
-----------------------------------------------------------------------------------
-- 2.商品销售统计试图
USE ecommerce;

CREATE VIEW product_order_item AS
SELECT product.product_id, product.pname, product.price AS price1, product.stock, order_item.num, order_item.price AS price2
FROM product
JOIN order_item ON product.product_id = order_item.product_id;
-----------------------------------------------------------------------------------
-- 3.订单商品明细视图
USE ecommerce;

CREATE VIEW product_details AS
SELECT `order`.order_id, `order`.order_time, product.price AS price1, product.pname, order_item.num, order_item.price AS price2
FROM `order`
JOIN order_item ON `order`.order_id = order_item.order_id
JOIN product ON order_item.product_id = product.product_id;
-----------------------------------------------------------------------------------
-- 4.用户地址关联视图
USE ecommerce;

CREATE VIEW user_addr AS
SELECT `user`.user_id, `user`.`name`, address.receiver, address.phone AS receiver_address, address.detail AS detail_address
FROM ecommerce.`user`
LEFT JOIN ecommerce.address ON `user`.user_id = address.user_id AND address.is_default=1; -- 仅关联默认地址
-----------------------------------------------------------------------------------
-- 5.商品分类关联视图
USE ecommerce;

CREATE VIEW product_category AS
SELECT product.product_id, product.pname, product.price, category.category_name, category.parent_id
FROM ecommerce.product
LEFT JOIN ecommerce.category ON product.category_id = category.category_id;