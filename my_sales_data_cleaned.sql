SELECT * 
FROM PortfolioProjects..my_sales_data_operations_dirty$
--- The first thing I notice is that the capitalization in the store column is not consistent 
SELECT *,
CASE
	WHEN store = 'west' Then 'West'
	WHEN store = 'east' THEN 'East'
	WHEN store = 'south' THEN 'South'
	WHEN store = 'north' THEN 'North'
	ELSE store
END
FROM PortfolioProjects..my_sales_data_operations_dirty$

UPDATE PortfolioProjects..my_sales_data_operations_dirty$
SET store = 
CASE
	WHEN store = 'west' Then 'West'
	WHEN store = 'east' THEN 'East'
	WHEN store = 'south' THEN 'South'
	WHEN store = 'north' THEN 'North'
	ELSE store
END

--- I can also see that there a NULL values in the quantity column
SELECT a.product_id, a.quantity,a.revenue, b.product_id,b.quantity, b.revenue, ISNULL(a.quantity, b.quantity)
FROM PortfolioProjects..my_sales_data_operations_dirty$ AS a
JOIN PortfolioProjects..my_sales_data_operations_dirty$ AS b
	ON a.product_id = b.product_id
	AND a.revenue = b.revenue
WHERE a.quantity IS NULL

UPDATE a
SET quantity = ISNULL(a.quantity, b.quantity)
	FROM PortfolioProjects..my_sales_data_operations_dirty$ AS a
	JOIN PortfolioProjects..my_sales_data_operations_dirty$ AS b
		ON a.product_id = b.product_id
		AND a.revenue = b.revenue
	WHERE a.quantity IS NULL 

--- There are less NULL values, but there are still some
SELECT a.product_id, a.quantity,a.revenue, b.product_id,b.quantity, b.revenue, ISNULL(a.quantity,(a.revenue/(b.revenue/b.quantity)))
FROM PortfolioProjects..my_sales_data_operations_dirty$ AS a
 JOIN PortfolioProjects..my_sales_data_operations_dirty$ AS b
	ON a.product_id = b.product_id
WHERE a.quantity IS NULL

UPDATE a
SET quantity = ISNULL(a.quantity,(a.revenue/(b.revenue/b.quantity)))
	FROM PortfolioProjects..my_sales_data_operations_dirty$ AS a
	JOIN PortfolioProjects..my_sales_data_operations_dirty$ AS b
		ON a.product_id = b.product_id
	WHERE a.quantity IS NULL

--- After doing this I noticed that there were still NULL values.
--- I realized after messing around with my query, it was because I should have only been looking where the quantity in b was not NULL as well as where the quantity a was NULL

SELECT a.product_id, a.quantity,a.revenue, b.product_id,b.quantity, b.revenue, ISNULL(a.quantity,(a.revenue/(b.revenue/b.quantity)))
FROM PortfolioProjects..my_sales_data_operations_dirty$ AS a
 JOIN PortfolioProjects..my_sales_data_operations_dirty$ AS b
	ON a.product_id = b.product_id
WHERE a.quantity IS NULL AND b.quantity IS NOT NULL

UPDATE a
SET quantity = ISNULL(a.quantity,(a.revenue/(b.revenue/b.quantity)))
	FROM PortfolioProjects..my_sales_data_operations_dirty$ AS a
	JOIN PortfolioProjects..my_sales_data_operations_dirty$ AS b
		ON a.product_id = b.product_id
	WHERE a.quantity IS NULL AND b.quantity IS NOT NULL

---Now let's see if there are duplicates in this data set
WITH RowNumCTE AS(
SELECT *,
	ROW_NUMBER() OVER( 
	PARTITION BY date,
				 product_id,
				 store,
				 quantity,
				 revenue
				 ORDER BY 
				 order_id
				 )
				 AS row_num
FROM PortfolioProjects..my_sales_data_operations_dirty$
---ORDER BY order_id
)

SELECT * 
FROM RowNumCTE
WHERE row_num > 1

--- There are no duplicates in the data