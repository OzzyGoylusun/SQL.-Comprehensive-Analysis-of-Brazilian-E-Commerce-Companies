
-- CASE 3: Sellers-Vendors Analysis

--Q3.1: Who are the top 5 sellers who deliver orders to customers the fastest? 
--Bear in mind that selected vendors need to have processed a considerable number of orders.
--Analyze and comment on the number of orders of these sellers and the reviews and ratings of their products.



--Before examining the query, please review the criteria in my adopted approach:

--1) After my initial calculations, I realized that all 5 of the fastest suppliers have delivered only 1 order,
--As such, I am filtering the data only to include the sellers who have thus far arranged a considerable number of orders.

--Because there is no homogeneous distribution in the total number of orders processed by the sellers in the dataset,
--I resort to the MEDIAN value of 7 instead of the MEAN value of ~33 so that I can base all my calculations on a whole lot more vendors.


--2) After bringing in the top 5 suppliers according to their average delivery speed, 
--if the delivery speed of the suppliers in days and hours turn out to be the same, I disregard the remaining the minutes and seconds data
--and instead consider the number of orders they have thus far processed as the 2nd criterion. 
--That is if the number of orders for a supplier is higher, then that particular supplier ranks higher.


--3) Finally, when calculating order delivery speed for each vendor, I use PURCHASE_TIME instead of APPROVED_TIME, 
--because negative values otherwise occur when there is an order whose payment is confirmed after the actual delivery of that order.



WITH FOR_ORDER_ID_ONLY AS 
--In order to bring in associated vendor reviews, this table is required to be joined with our main FROM statement at the end.
	
	(SELECT DISTINCT ORDER_ID,
				SELLER_ID
	
 		FROM ORDER_ITEMS
	)
 
SELECT DISTINCT SELLER_ID,
	SELLER_CITY,
	SELLER_STATE,
	SELLER_ZIP_CODE_PREFIX AS SELLER_ZIP_CODE,
	SPLIT_PART(TO_CHAR(JUSTIFY_INTERVAL(AVERAGE_DELIVERY_SPEED), 'DD HH24'), ' ', 1) || ' days ' || 
	SPLIT_PART(TO_CHAR(JUSTIFY_INTERVAL(AVERAGE_DELIVERY_SPEED), 'DD HH24'), ' ', 2) || ' hours'
	AS AVERAGE_DELIVERY_SPEED, 
	--JUSTIFY_INTERVAL, to set a 24 hour time interval that has gone out of bounds on the clock without counting over to the next day 
	--A function I use to fix broken time intervals (e.g., "1 day 30:54:56.5")
	
	--Besides, the result returned by JUSTIFY_INTERVAL can be used as a time criterion as I explained above. 
	--I only take into account Day and Time. If there were also Month and Year, they would also fall within the criteria range.
	
	TOTAL_ORDER_COUNT,
	
	--The last 3 variables at the bottom are completely related to the customers' evaluation of vendors located in the Reviews table.
	SCORE,
	COMMENT_TITLE AS TITLE_IN_PORTUGUESE,
	COMMENT_MESSAGE AS COMMENT_IN_PORTUGUESE


FROM  --That's where the magic begins
(WITH TOP_SELLERS_PERFORMANCE_ON_ORDERS AS
	
 	(WITH SELLERS_PERFORMANCE_ON_ORDERS AS
	 
			(WITH SUCC_ORDERS_DELIVERY_SPEED AS
			 
					(SELECT ORDER_ID,
							AGE(DELIVERED_CUSTOMER, PURCHASE_TIME) AS DELIVERY_SPEED
							--It is because of a large number of orders whose payments are confirmed long after orders are delivered.
					 		--Accordingly, I performed my operations based on the Purchase_Time parameter instead of Approved_Time.
					 
						FROM ORDERS
						WHERE (PURCHASE_TIME IS NOT NULL 
							   AND DELIVERED_CUSTOMER IS NOT NULL)
								AND (ORDER_STATUS = 'delivered') 
					 	--I am also filtering the data according to the ORDER_STATUS criterion as it shall only take into account the successful orders.
					),
			 
					UNIQUE_SELLERS_INFO AS(
						
						SELECT DISTINCT ORDER_ID, 
						--The reason we resort to DISTINCT is that when we combine these two tables, for example, there are multiple item IDs associated with a product ID 
						--that causes duplication of data in an undesired fashion
						--and also in order to bring the vendors' information into this table only once.
 										SELLER_ID,
										SELLER_CITY,
										SELLER_STATE,
										SELLER_ZIP_CODE_PREFIX
					 
						FROM ORDER_ITEMS
						LEFT JOIN SELLERS_DATASET USING (SELLER_ID)
			 		)

			 	SELECT *
			 	FROM SUCC_ORDERS_DELIVERY_SPEED
				LEFT JOIN UNIQUE_SELLERS_INFO USING(ORDER_ID)
			 
				--Since, in a given order, there are products belonging to various different vendors and we should not forfeit this data for obvious reasons, 
			 	--I bring the supplier information to our main order table by LEFT JOIN in order to maintain the integrity of the order data. 
			 	--Example: ORDER_ID = 'cf5c8d9f52807cb2d2f0a0ff54c478da'
			 
			 	--Of course, the opposite is also true, that is if there is more than one order processed from a seller having multiple products in his/her arsenal, 
			    --this data is equally valuable to us.
			 	--Example: SELLER_ID = 'b39d7fe263ef469605dbb32608aee0af'
	
			) 
	 
	 	SELECT SELLER_ID,
				SELLER_CITY,
				SELLER_STATE,
	 			SELLER_ZIP_CODE_PREFIX,
	 			AVG(DELIVERY_SPEED) AS AVERAGE_DELIVERY_SPEED,
				COUNT(DISTINCT ORDER_ID) AS TOTAL_ORDER_COUNT
	 				 
		FROM SELLERS_PERFORMANCE_ON_ORDERS
		GROUP BY 1, 2, 3, 4

	) 
 	--The last statement in SELECT informs us that the MEDIAN value is 7 when we run the query with the WITH/AS structure at the beginning instead of the whole query.
 	SELECT *, (SELECT PERCENTILE_CONT(0.5) WITHIN GROUP (ORDER BY TOTAL_ORDER_COUNT) 
			   FROM TOP_SELLERS_PERFORMANCE_ON_ORDERS) AS MEDIAN_VALUE
 
 	FROM TOP_SELLERS_PERFORMANCE_ON_ORDERS
 	WHERE TOTAL_ORDER_COUNT >= 7 --This filter is paramount. We only include suppliers that sell 7 or more products in our dataset.
 	ORDER BY AVERAGE_DELIVERY_SPEED ASC 
 	LIMIT 5 --After filtering according to the fastest vendors, we fetch the information of only the first 5 suppliers with LIMIT.
 	 	 
 ) AS TOP_FIVE_SELLERS_PER_DELIVERY_SPEED
	

LEFT JOIN FOR_ORDER_ID_ONLY USING (SELLER_ID)
LEFT JOIN REVIEWS USING (ORDER_ID)

--In the bottom/WHERE filter, if there is no record of any vendor in terms of relevant data availability, we exclude such evaluations made by customers in our query.
WHERE (SCORE IS NOT NULL) OR  
	(COMMENT_TITLE IS NOT NULL) OR 
	(COMMENT_MESSAGE IS NOT NULL)

ORDER BY AVERAGE_DELIVERY_SPEED ASC, TOTAL_ORDER_COUNT DESC 
--As I mentioned above, if the values in terms of the delivery speed in Days and Hours are equal for suppliers being compared, 
--the supplier with a higher total number of orders ranks higher.





--Q3.2: Which vendors sell products from more categories? Do vendors with more categories also have more orders?

WITH CATEGORY_DIVERSITY_OF_SELLERS AS

	(SELECT SELLER_ID, 
	 	--There are 3095 different vendors/sellers in total, but categorical information of 60 vendors of which are unknown/missing in the sense of what they are selling.
			SELLER_CITY,
			SELLER_STATE,
	 		SELLER_ZIP_CODE_PREFIX,
			COUNT(DISTINCT CATEGORY_NAME) AS NUM_OF_CATEGORY_OFFERED
	 	
	 FROM ORDER_ITEMS
	 INNER JOIN SELLERS_DATASET USING (SELLER_ID)
	 LEFT JOIN PRODUCTS_DATASET USING (PRODUCT_ID)
	 WHERE CATEGORY_NAME IS NOT NULL
	 GROUP BY 1, 2, 3, 4
	 
	 
	), SELLERS_NUM_OF_ORDERS AS
	
	(SELECT OI.SELLER_ID,
			COUNT(DISTINCT O.ORDER_ID) AS NUM_OF_TOTAL_ORDERS
	 
	 FROM ORDERS AS O
	 LEFT JOIN ORDER_ITEMS AS OI USING (ORDER_ID)
	 WHERE SELLER_ID IS NOT NULL
	 GROUP BY 1
	 
	)
		
SELECT SELLER_ID,
		SELLER_CITY,
		SELLER_STATE,
		SELLER_ZIP_CODE_PREFIX AS SELLER_ZIP_CODE,
		NUM_OF_CATEGORY_OFFERED,
		NUM_OF_TOTAL_ORDERS
	
FROM CATEGORY_DIVERSITY_OF_SELLERS
INNER JOIN SELLERS_NUM_OF_ORDERS USING (SELLER_ID) 
--The reason I utilised Inner Join is to completely disable the records of all sellers whose category group is not specified in my last table. 
--As I mentioned above, about 60 sellers are missing categorical information.
ORDER BY 5 DESC, 6 DESC

