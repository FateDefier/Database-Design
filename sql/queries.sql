-- 查询操作
----------------------------------------------------------------------------------
-- 查询所有商品的信息
SELECT * FROM ecommerce.product;
----------------------------------------------------------------------------------
-- 查询价格低于200元的商品名称和价格，按价格降序排列
SELECT pname, price
FROM ecommerce.product
WHERE price < 200
ORDER BY price DESC;
----------------------------------------------------------------------------------
-- 查询每个商品的库存总量
SELECT product_id, pname, SUM(stock)
FROM ecommerce.product
GROUP BY product_id, pname;
----------------------------------------------------------------------------------
SELECT `order`.user_id, `order`.order_time, `order`.total, `user`.`name`
FROM ecommerce.`user`, ecommerce.`order`
WHERE `user`.user_id = `order`.user_id;
-----------------------------------------------------------------------------------
-- 查询所有订单及其订单项（左外连接）
SELECT `order`.user_id, order_item.product_id, order_item.num, order_item.price
FROM ecommerce.`order`
LEFT JOIN ecommerce.order_item ON `order`.order_id = order_item.order_id;
-----------------------------------------------------------------------------------
-- 查询“电脑配件”分类下的所有商品
SELECT p.pname, p.price 
FROM ecommerce.product
JOIN ecommerce.category ON product.category_id = category.category_id 
WHERE category.category_name = '电脑配件';
-----------------------------------------------------------------------------------
-- 查询购买过"蓝牙耳机"的用户名
SELECT `name`
FROM ecommerce.`user`
WHERE user_id IN 
(
    SELECT user_id
    FROM ecommerce.`order`
    WHERE order_id IN 
    (
        SELECT order_id
        FROM ecommerce.order_item
        WHERE product_id = 
        (
            SELECT product_id
            FROM ecommerce.product
            WHERE pname = "蓝牙耳机"
        )
    )
);