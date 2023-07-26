--- I want to analyze the data from a pizza place to make recommendations for future business

--- First I wonder how many customers they have each day
SELECT dateconverted, COUNT(order_id) AS customers_per_day
FROM PortfolioProjects..orders
WHERE dateconverted = dateconverted
GROUP BY dateconverted
ORDER BY dateconverted
--- I found the customers per day, so now we want to find an overall trend in the data. We could do this by finding the median, but since there is no median function in SQL,
--- we will do this manually. 
WITH customers_per_day AS
(
SELECT dateconverted, COUNT(order_id) AS per_day
FROM PortfolioProjects..orders
WHERE dateconverted = dateconverted
GROUP BY dateconverted
)

SELECT *, 
ROW_NUMBER() OVER(
	ORDER BY per_day) AS num
FROM customers_per_day
ORDER BY per_day DESC

--- It looks like the median, which is at number 179, is 59 customers. So, the shop has a median of 59 customers per day. That means that the shop would generally want to 
--- be prepared to serve that many customers or a little more everyday.

--- We could also find the mean, or the average of the data. 
WITH customers_day AS 
(SELECT dateconverted, COUNT(order_id) AS customers_per_day
FROM PortfolioProjects..orders
WHERE dateconverted = dateconverted
GROUP BY dateconverted
---ORDER BY dateconverted
)

SELECT SUM(customers_per_day)/ COUNT(dateconverted)
FROM customers_day
--- Looks like the mean is also 59 customers


--- Now we want to know what their peak hours are, or what hours they get the most business. 
SELECT COUNT(*) AS orders,SUBSTRING(time,1,2) AS hour
FROM PortfolioProjects..orders
GROUP BY SUBSTRING(time,1,2)
ORDER BY hour DESC
---It looks like the most amount of orders occur from 12pm to 1pm, and from 5pm to 7pm. These are their peak hours.  
--- We want to know how many pizzas are typically in an order. Again, we have some outliers here, so we cannnot use mean to summarize this data, we need to use median
SELECT order_id, SUM(quantity) AS pizzas_per_order
FROM PortfolioProjects..order_details
GROUP BY order_id
ORDER BY order_id

WITH pizzas_per_order AS
(
SELECT order_id, SUM(quantity) AS pizzas
FROM PortfolioProjects..order_details
WHERE order_id = order_id
GROUP BY order_id
)

SELECT *, 
ROW_NUMBER() OVER(
	ORDER BY pizzas) AS rownum
FROM pizzas_per_order 
ORDER BY pizzas DESC
--- The median would be between 10675 and 10674, which means the usual amount of pizzas in an order is 5 pizzas. Meaning the company would want to plan to have enough stock to make 
--- this many pizzas per customer.

--- Next we want to find which pizzas are best sellers
SELECT pizza_id, SUM(quantity) AS num_pizzas_ordered
FROM PortfolioProjects..order_details
GROUP BY pizza_id
ORDER BY SUM(quantity) DESC
--- It looks like the best seller is big_meat_s, or a small big meat pizza, with 4,981 orders. The second one is a large thai chicken with 3,689 orders.

--- I want to find out how much money the company made in 2015, which is the year all our data is in
SELECT SUM(CAST((quantity * pricefixed) AS decimal(7,2)))
FROM PortfolioProjects..order_details AS details
JOIN PortfolioProjects..pizzas AS pizzas
	ON details.pizza_id = pizzas.pizza_id

--- In 2015, the company made 2,175,104.70

--- We also want to know when the majority of sales happen. If they happen around a specific season. 
SELECT DATEPART(mm,dateconverted) AS month, SUM(CAST(quantity * pricefixed AS decimal(7,2))) AS monthly_sales
FROM  PortfolioProjects..orders AS orders
JOIN  PortfolioProjects..order_details AS details
	ON  orders.order_id = details.order_id
JOIN PortfolioProjects..pizzas AS pizzas
	ON details.pizza_id = pizzas.pizza_id
GROUP BY DATEPART(mm,dateconverted)
ORDER BY month DESC
--- It looks like the company makes the most money from pizza in July with 190,841.90. The second month they make the most is November with 189,316.45

--- The company wants to know what pizzas could be taken off the menu, or what promotions they could do to get more people to buy these pizzas. 
--- To figure this out we need to know what pizzas get ordered the least.

SELECT pizza_id,SUM(quantity) AS orders_per_pizza
FROM PortfolioProjects..order_details
GROUP BY pizza_id
ORDER BY orders_per_pizza
--- It looks like the greek xxl pizza gets ordered the least amount of times, with 76. The company could either choose to get rid of the pizza all together, or they could run a sale or coupons
--- to encourage people to buy the pizza.
