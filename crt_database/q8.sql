SELECT supplier.vendor_name, supplier.supply_id, COUNT(*) as num_products_filled
FROM supply_purchase_order
INNER JOIN supplier ON supply_purchase_order.supply_id = supplier.supply_id
INNER JOIN refills ON refills.supply_purchase_id = supply_purchase_order.supply_purchase_id
GROUP BY supplier.vendor_name, supplier.supply_id
HAVING  COUNT(*) <= 1
ORDER BY supplier.supply_id
;