CREATE TEMPORARY TABLE total_cost_of_orders 
    AS (
        select p_order_number ID, SUM(contains.point_of_sale_price) total_price
        from contains
        GROUP BY p_order_number
        ORDER BY SUM(contains.point_of_sale_price)
    ) 
;

DELETE FROM total_cost_of_orders
WHERE total_price =
    (
        SELECT 
            MIN(total_cost_of_orders.total_price)
        FROM
            total_cost_of_orders
    )
;
SELECT package.package_id, total_cost_of_orders.ID, total_cost_of_orders.total_price, product_order.p_order_number
FROM package
INNER JOIN product_order ON product_order.p_order_number = package.p_order_number
FULL OUTER JOIN total_cost_of_orders ON total_cost_of_orders.ID = product_order.p_order_number
WHERE total_cost_of_orders.total_price = 
    (
        SELECT 
            MIN(total_cost_of_orders.total_price)
        FROM
            total_cost_of_orders
    )
AND package.package_id IS NOT NULL
;