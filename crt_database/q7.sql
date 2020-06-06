SELECT recipient.recipient_id, recipient.fname, recipient.lname
FROM contains
INNER JOIN flower_product ON flower_product.product_id = contains.product_id
INNER JOIN product_order ON contains.p_order_number = product_order.p_order_number
INNER JOIN package ON product_order.p_order_number = package.p_order_number
INNER JOIN recipient ON package.package_id = recipient.package_id
WHERE 
product_order.p_order_number = package.p_order_number
EXCEPT
SELECT recipient.recipient_id, recipient.fname, recipient.lname
FROM contains
INNER JOIN flower_product ON flower_product.product_id = contains.product_id
INNER JOIN product_order ON contains.p_order_number = product_order.p_order_number
INNER JOIN package ON product_order.p_order_number = package.p_order_number
INNER JOIN recipient ON package.package_id = recipient.package_id
WHERE 
product_order.p_order_number = package.p_order_number
and flower_product.product_name = 'Rose'
ORDER BY recipient_id
;