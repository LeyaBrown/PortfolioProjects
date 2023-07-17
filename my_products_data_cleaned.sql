SELECT * 
FROM PortfolioProjects..my_products_operations_dirty$
ORDER BY product_id

--- The first thing I notice is that the product_id isn't unique, they all have #NK in front of them. We want our primary key to be a unique value.
--- That means we need to get rid of the #NK

UPDATE PortfolioProjects..my_products_operations_dirty$
SET product_id = REPLACE(product_id, '#NK','')

--- I also notice now that the product_id 7 has a dash after it, so we will fix any product_id's that might have this dash

SELECT *
FROM PortfolioProjects..my_products_operations_dirty$
WHERE product_id LIKE '%-'

UPDATE PortfolioProjects..my_products_operations_dirty$
SET product_id = REPLACE(product_id, '-','')

SELECT category, COUNT(category)
FROM PortfolioProjects..my_products_operations_dirty$
GROUP BY category
ORDER BY category
--- After using this select statement, I can see that some categories contain an 's' at the end and others don't. EX: Some are 'Electronic' and others are 'Electronics'
--- We want to fix this

SELECT category
FROM PortfolioProjects..my_products_operations_dirty$
WHERE category LIKE '%s'

UPDATE PortfolioProjects..my_products_operations_dirty$
SET category = REPLACE(category, '%s', '')
--- This didn't work, so I am thinking maybe the % might affect the REPLACE statement, but I can't just put 's' because then the first 's' in Sport will be replaced too

SELECT category,
CASE
	WHEN category = 'Electronics' THEN 'Electronic'
	WHEN category = 'Sports' THEN 'Sport'
	WHEN category = 'Toys' THEN 'Toy'
	ELSE category
END
FROM PortfolioProjects..my_products_operations_dirty$

UPDATE PortfolioProjects..my_products_operations_dirty$
SET category = 
CASE
	WHEN category = 'Electronics' THEN 'Electronic'
	WHEN category = 'Sports' THEN 'Sport'
	WHEN category = 'Toys' THEN 'Toy'
	ELSE category
END

SELECT subcategory, COUNT(subcategory)
FROM PortfolioProjects..my_products_operations_dirty$
GROUP BY subcategory
ORDER BY subcategory

--- There is a dash infront of 'Accessories', so we need to fix that
UPDATE PortfolioProjects..my_products_operations_dirty$
SET subcategory = REPLACE(subcategory,'-','')


--- Now we need to make sure there is no missing data
SELECT *
FROM PortfolioProjects..my_products_operations_dirty$
WHERE price IS NULL
--- There are no NULL values

--- We also want to check for duplicates
WITH RowNumCTE AS(
SELECT *,
	ROW_NUMBER() OVER (
	PARTITION BY name,
				 category, 
				 subcategory, 
				 price,
				 product_id
				 ORDER BY product_id) AS row_num
FROM PortfolioProjects..my_products_operations_dirty$
---ORDER BY product_id
)

SELECT *
FROM RowNumCTE 
WHERE row_num > 1
---There are no duplicates

SELECT * 
FROM PortfolioProjects..my_products_operations_dirty$
ORDER BY product_id

--- The ORDER BY clause is not working like it should for integers (instead of the order being 1,2,... the order is 1,10,100...)
--- This means that the product_id is not set to the correct data type, instead of an integer it's a string, we need to fix this

SELECT *
FROM PortfolioProjects..my_products_operations_dirty$
ORDER BY CAST(product_id AS int)

ALTER TABLE PortfolioProjects..my_products_operations_dirty$
ALTER COLUMN product_id int

--- Since product_id was of the wrong data type, it's possible that the other columns might be as well. I will check those
SELECT * 
FROM PortfolioProjects..my_products_operations_dirty$
ORDER BY price

--- The other columns seem to be the correct data type