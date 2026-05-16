-- 数据操作
-----------------------------------------------------------------------------------
-- 插入新商品
INSERT INTO ecommerce.product(product_id, pname, price, stock)
VALUES
(109, "有线耳机", 80.50, 250);
-----------------------------------------------------------------------------------
-- 更新商品价格
UPDATE ecommerce.product
SET price = 4799.99
WHERE product_id = 101;
-----------------------------------------------------------------------------------
-- 下单后减少商品库存
UPDATE ecommerce.product
INNER JOIN ecommerce.order_item ON product.product_id = order_item.product_id
SET product.stock = product.stock - order_item.num  -- 用订单项中的实际购买数量减少库存
WHERE order_item.order_id = 1005;
-----------------------------------------------------------------------------------
-- 取消订单同时删除订单项
-- 必须先删除订单对应的订单项（外键依赖），否则报错
DELETE 
FROM ecommerce.order_item
WHERE order_id = 1003;

DELETE
FROM ecommerce.`order`
WHERE order_id = 1003;
