
-- CASE 2: Customer Analysis

--Q2: Identify for each customer what their favorite cities and states are in terms of where they have placed the most orders from up to date.

--Tip: For example, Nancy has thus far placed orders from 3 different cities: 3 orders from Santo Andre, 8 orders from Vitoria and 10 orders from Sao Paulo. 
--Nancy's favorite city is the city where she has placed the most orders from. 

--Consequently, in the output of our SQL query, her favorite city shall appear as "Sao Paulo", and her total number of orders shall appear as "21" (3+8+10).


WITH CUSTOMERS_ORDERS_CARTESIAN_PRODUCT AS

	(WITH CUSTOMERS_TOTAL_ORDERS AS
	 
			(SELECT UNIQUE_ID,
					COUNT(DISTINCT ORDER_ID) AS TOTAL_ORDER_COUNT
			 
				FROM CUSTOMERS
				LEFT JOIN ORDERS USING (CUSTOMER_ID)
				GROUP BY 1
			),
	
	 CUSTOMER_FAVORITE_CITY AS(
		 
	 		SELECT UNIQUE_ID,
					CITY,
					STATE,
		 			ZIP_CODE,
		 			COUNT(DISTINCT ORDER_ID) AS ORDER_COUNT_PER_CUST_CITY_STATE_ZIP_CODE,
			 		MIN(AGE('2018-09-03 17:40:06'::timestamp, APPROVED_TIME)) AS MOST_RECENT_ORDER
			 		--Most_Recent_Order criterion comes into play activated only if the total number of orders placed by a customer from multiple cities is equal to each other.
			 
			FROM CUSTOMERS
			LEFT JOIN ORDERS USING (CUSTOMER_ID)
			GROUP BY 1, 2, 3, 4
	)
	 
	 --In the SELECT statement below, due to the information requested, I felt compelled to do a Cartesian product operation of the two tables above
	 --so that I could combine the total orders placed by each customer with the customers' favorite cities, states and zip codes.
	 
	SELECT UNIQUE_ID, 
	 		CITY,
	 		STATE, 
	 		ZIP_CODE,
	 		TOTAL_ORDER_COUNT,
	 		DENSE_RANK() OVER(PARTITION BY UNIQUE_ID ORDER BY ORDER_COUNT_PER_CUST_CITY_STATE_ZIP_CODE DESC, MOST_RECENT_ORDER ASC) AS INTEGRATED_CRITERIA  
	 		--As mentioned above, Most_Recent_Order is our 2nd-level filter in case the first order count-related criteria does not suffice to finalise an outcome.
	 		
	 		--For example, a customer with UNIQUE_ID 'd44ccec15f5f86d14d6a2cfa67da1975' has only 1 order placed from 3 different cities. In this case, the 2nd criterion comes into play.
	 		--So when we apply the 2nd filter, the query detects the city where the customer last ordered and only brings it as a result.
	 
	FROM CUSTOMERS_TOTAL_ORDERS
	INNER JOIN CUSTOMER_FAVORITE_CITY USING(UNIQUE_ID)

)

SELECT UNIQUE_ID,
	CITY AS FAVORITE_CITY,
	STATE AS FAVORITE_STATE,
	ZIP_CODE AS FAVORITE_ZIP_CODE,
	TOTAL_ORDER_COUNT

FROM CUSTOMERS_ORDERS_CARTESIAN_PRODUCT
WHERE INTEGRATED_CRITERIA = 1 --Here I get a single record for each customer that only matches my criteria.
ORDER BY 5 DESC