-- SELECT priceeach, quantityordered, productcode, ordernumber FROM orderdetails WHERE ordernumber = 10011;
SELECT * FROM orders WHERE ordernumber = 10011;
-- SELECT * FROM customers WHERE customernumber = 103;

-- INSERT INTO payments VALUES (103, 'HQ336542', '2020-10-11', 2000);
-- SELECT * FROM payments LIMIT 1;

-- SELECT orders.customernumber, orders.status, orders.ordernumber FROM customers JOIN orders ON customers.customernumber = orders.customernumber WHERE customers.customernumber = 103 AND UPPER(orders.status) NOT LIKE 'SHIPPED' AND UPPER(orders.status) NOT LIKE 'CANCELLED';
-- UPDATE orders SET status = 'ON HOLD' where orders.ordernumber = 10011;