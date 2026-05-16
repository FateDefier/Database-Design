-- 插入7-8条虚拟数据
-- 1.用户表
INSERT INTO ecommerce.`user` (user_id, `name`, phone, `password`)
VALUES
(1, '张三', '13800138000', 'zhangsan123'),
(2, '李四', '13900139000', 'lisi456'),
(3, '王五', '13700137000', 'wangwu789'),
(4, '赵六', '13600136000', 'zhaoliu321'),
(5, '孙七', '13500135000', 'sunqi654'),
(6, '周八', '13400134000', 'zhouba987'),
(7, '吴九', '13300133000', 'wujiu765'),
(8, '郑十', '13200132000', 'zhengshi432');

-- 2.商品表
INSERT INTO ecommerce.product (product_id, pname, price, stock) 
VALUES 
(101, '笔记本电脑', 4999.99, 50),
(102, '无线鼠标', 99.99, 200),
(103, '机械键盘', 199.99, 100),
(104, '蓝牙耳机', 299.99, 150),
(105, '移动硬盘', 599.99, 80),
(106, '显示器', 1299.99, 40),
(107, '充电宝', 129.99, 300),
(108, 'U盘', 69.99, 500);

-- 3.订单表
INSERT INTO ecommerce.`order` (order_id, user_id, total) 
VALUES 
(1001, 1, 5199.98),   -- 张三：笔记本+键盘
(1002, 2, 99.99),     -- 李四：无线鼠标
(1003, 3, 1899.98),   -- 王五：显示器+U盘
(1004, 4, 299.99),    -- 赵六：蓝牙耳机
(1005, 5, 739.98),    -- 孙七：移动硬盘+U盘
(1006, 6, 129.99),    -- 周八：充电宝
(1007, 7, 6499.98);   -- 吴九：笔记本+显示器

-- 4.订单项表
INSERT INTO ecommerce.order_item (item_id, order_id, product_id, num, price) 
VALUES 
(1, 1001, 101, 1, 4999.99),  -- 订单1001：笔记本
(2, 1001, 103, 1, 199.99),  -- 订单1001：键盘
(3, 1002, 102, 1, 99.99),   -- 订单1002：鼠标
(4, 1003, 106, 1, 1299.99), -- 订单1003：显示器
(5, 1003, 108, 1, 69.99),   -- 订单1003：U盘
(6, 1004, 104, 1, 299.99),  -- 订单1004：耳机
(7, 1005, 105, 1, 599.99),  -- 订单1005：移动硬盘
(8, 1005, 108, 2, 69.99);   -- 订单1005：2个U盘

-- 5.地址表
INSERT INTO ecommerce.address (addr_id, user_id, receiver, phone, detail, is_default)
VALUES
(1, 1, '张三', '13800138000', '北京市海淀区XX街道1号', 1),
(2, 2, '李四', '13900139000', '上海市浦东新区XX路2号', 1),
(3, 3, '王五', '13700137000', '广州市天河区XX巷3号', 0),
(4, 4, '赵六', '13600136000', '深圳市南山区XX街4号', 1),
(5, 5, '孙七', '13500135000', '杭州市西湖区XX路5号', 0),
(6, 6, '周八', '13400134000', '成都市武侯区XX巷6号', 1),
(7, 7, '吴九', '13300133000', '武汉市洪山区XX街7号', 0),
(8, 8, '郑十', '13200132000', '西安市雁塔区XX路8号', 1);

-- 6.商品分类表
INSERT INTO ecommerce.category (category_id, category_name, parent_id)
VALUES
(1, '电脑设备', NULL),          -- 顶级分类
(2, '电脑配件', 1),             -- 子分类（属于"电脑设备"）
(3, '移动设备', NULL),          -- 顶级分类
(4, '存储设备', NULL),          -- 顶级分类
(5, '输入设备', 2),             -- 子分类（属于"电脑配件"）
(6, '音频设备', 3);             -- 子分类（属于"移动设备"）

-- 同步修改商品表，增加分类关联字段
ALTER TABLE ecommerce.product 
ADD COLUMN category_id INT,
ADD FOREIGN KEY (category_id) REFERENCES ecommerce.category(category_id);

-- 为现有商品补充分类
UPDATE ecommerce.product SET category_id = 1 WHERE product_id = 101;  -- 笔记本电脑→电脑设备
UPDATE ecommerce.product SET category_id = 5 WHERE product_id = 102;  -- 无线鼠标→输入设备
UPDATE ecommerce.product SET category_id = 5 WHERE product_id = 103;  -- 机械键盘→输入设备
UPDATE ecommerce.product SET category_id = 6 WHERE product_id = 104;  -- 蓝牙耳机→音频设备
UPDATE ecommerce.product SET category_id = 4 WHERE product_id = 105;  -- 移动硬盘→存储设备
UPDATE ecommerce.product SET category_id = 2 WHERE product_id = 106;  -- 显示器→电脑配件
UPDATE ecommerce.product SET category_id = 3 WHERE product_id = 107;  -- 充电宝→移动设备
UPDATE ecommerce.product SET category_id = 4 WHERE product_id = 108;  -- U盘→存储设备
UPDATE ecommerce.product SET category_id = 6 WHERE product_id = 109;  -- 有线耳机→音频设备
