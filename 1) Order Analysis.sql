
-- CASE 1: Order Analysis

--Please note that we do not apply any filtering on our "order_status" column unless explicitly stated.


--Q1.1: Examine the order distribution as Year-Monthly. "purchase_time" should be used for date data.

SELECT TO_CHAR(PURCHASE_TIME,'YYYY-MM') AS YEAR_MONTHLY_DATE,
	COUNT(ORDER_ID) AS ORDER_COUNT
	
FROM ORDERS
WHERE PURCHASE_TIME IS NOT NULL
GROUP BY 1
ORDER BY 1 ASC





--Q1.2: Examine the number of orders in the "order_status" breakdown on a monthly basis. Visualise the output of the query with Excel.
--Are there any months with a dramatic decrease or increase? Analyse and interpret the data.

SELECT TO_CHAR(PURCHASE_TIME,'YYYY-MM') AS YEAR_MONTHLY_DATE,
	ORDER_STATUS,
	COUNT(ORDER_ID) AS ORDER_COUNT_PER_DATE_AND_STATUS
	
FROM ORDERS
WHERE PURCHASE_TIME IS NOT NULL
GROUP BY 1, 2
ORDER BY 1 ASC, 2 ASC





--Q1.3: Examine the number of orders by product category. What are the prominent categories on special days?
--For example, New Year's Day, Valentine's Day, etc.

--MAIN TABLE: For each case, please run the following query using the relevant SELECT statement, that is with the Complete_Category_Translation and Orders_And_Categories tables

WITH COMPLETE_CATEGORY_TRANSLATION AS

	(SELECT PRODUCT_ID,
			CATEGORY_NAME,
			CASE WHEN CATEGORY_NAME = 'portateis_cozinha_e_preparadores_de_alimentos' THEN 'kitchen_portables_and_food_preparers'
	 			WHEN CATEGORY_NAME = 'pc_gamer' THEN 'pc_gamer'
	 			--Although there are 73 categories in total, when we switched from Portuguese to English, I found that there was no translation provided for the top 2 categories in the applicable translation table.
	 			--For this reason, I use this Case-When statement in order to preserve data integrity.
	 
	 			ELSE CATEGORY_NAME_IN_ENGLISH
	 			END AS TRANSLATED_CATEGORY_NAME
	 
		FROM PRODUCT_CATEGORY_TRANSLATION
		RIGHT JOIN PRODUCTS_DATASET USING (CATEGORY_NAME)
		WHERE CATEGORY_NAME IS NOT NULL   --I exclude all product ids which do not have any categories specified.
	 
	), 
	
	ORDERS_AND_CATEGORIES AS(
		
		SELECT DISTINCT ORDER_ID,
		--When I combine the Orders table with the Order_Items table, there is a multiplexing/duplication that pollutes the analysis because there are multiple items belonging to the same category.
		--(e.g., '04993613aee4046caf92ea17b316dcfb'. Therefore, I assign DISTINCT to ORDER_ID in this table).
				TRANSLATED_CATEGORY_NAME,
				PURCHASE_TIME
		
		FROM ORDERS AS O
		INNER JOIN ORDER_ITEMS AS OI USING (ORDER_ID)
		INNER JOIN COMPLETE_CATEGORY_TRANSLATION USING (PRODUCT_ID)
		WHERE CATEGORY_NAME IS NOT NULL

	)



--1st Case: Total Number Of Orders Per Category

SELECT TRANSLATED_CATEGORY_NAME, 
		COUNT(ORDER_ID) AS TOTAL_ORDER_COUNT_PER_CATEGORY  
		--The reason why I do not assign DISTINCT to Count() is that there are products part of more than one category in the same order (e.g, '1fcbc88015c88c1a14d4b8ec35ea8ed7')
		--That's why we need to count the same Order_ID more than once for different categories - without using DISTINCT.
		
		--According to my calculations, there are products from 3 categories at maximum in an order in this dataset. The order distribution is as follows:
		
		--97277 orders from 1 category (Among them, 1 order from the Health_Beauty category has no payment information).
		--7277 orders from 2 categories
		--15 orders from 3 categories
		
FROM ORDERS_AND_CATEGORIES
GROUP BY 1
ORDER BY 2 DESC



--2nd Case: Dia Dos Namorados: Lovers' Day in Brazil. Instead of on February 14th, it is celebrated on June 12nd.

SELECT TRANSLATED_CATEGORY_NAME, 
		CASE WHEN ORDER_COUNT_PER_CATEGORY_ONE_WEEK_BEFORE_DIADOS IS NULL THEN 0
			ELSE ORDER_COUNT_PER_CATEGORY_ONE_WEEK_BEFORE_DIADOS
			END, --One week before
		CASE WHEN ORDER_COUNT_PER_CATEGORY_ON_DIADOS_DAY IS NULL THEN 0
			ELSE ORDER_COUNT_PER_CATEGORY_ON_DIADOS_DAY
			END, --On the day
		CASE WHEN ORDER_COUNT_PER_CATEGORY_ONE_WEEK_AFTER_DIADOS IS NULL THEN 0
			ELSE ORDER_COUNT_PER_CATEGORY_ONE_WEEK_AFTER_DIADOS
			END --One week after

FROM (

		SELECT TRANSLATED_CATEGORY_NAME,  
				COUNT(ORDER_ID) AS ORDER_COUNT_PER_CATEGORY_ONE_WEEK_BEFORE_DIADOS
	
		FROM ORDERS_AND_CATEGORIES
		WHERE TO_CHAR((PURCHASE_TIME + interval '1 week'), 'DD-MM') = '12-06'   
		--There is reverse logic in this filter, because if I add 1 week to the current date and arrive at the day I want, it means that I am actually filtering the data of the day 1 week ago.
		GROUP BY 1

) AS ORDER_COUNT_PER_CATEGORY_BEFORE_DIADOS 

FULL OUTER JOIN (
		
		SELECT TRANSLATED_CATEGORY_NAME, 
				COUNT(ORDER_ID) AS ORDER_COUNT_PER_CATEGORY_ON_DIADOS_DAY

		FROM ORDERS_AND_CATEGORIES
		WHERE TO_CHAR(PURCHASE_TIME,'DD-MM') = '12-06'
		GROUP BY 1

) AS ORDER_COUNT_PER_CATEGORY_ON_DIADOS USING(TRANSLATED_CATEGORY_NAME)

FULL OUTER JOIN (

		SELECT TRANSLATED_CATEGORY_NAME,  
				COUNT(ORDER_ID) AS ORDER_COUNT_PER_CATEGORY_ONE_WEEK_AFTER_DIADOS
	
		FROM ORDERS_AND_CATEGORIES
		WHERE TO_CHAR((PURCHASE_TIME - interval '1 week'), 'DD-MM') = '12-06'
		GROUP BY 1
	
) AS ORDER_COUNT_PER_CATEGORY_AFTER_DIADOS USING(TRANSLATED_CATEGORY_NAME)

ORDER BY 2 DESC, 3 DESC, 4 DESC



--3rd Case: New Year's Celebrations

SELECT TRANSLATED_CATEGORY_NAME,
		CASE WHEN ORDER_COUNT_PER_CATEGORY_ONE_WEEK_BEFORE_NEWYEARSEVE IS NULL THEN 0
			ELSE ORDER_COUNT_PER_CATEGORY_ONE_WEEK_BEFORE_NEWYEARSEVE
			END,
		CASE WHEN ORDER_COUNT_PER_CATEGORY_ON_NEWYEARSEVE IS NULL THEN 0
			ELSE ORDER_COUNT_PER_CATEGORY_ON_NEWYEARSEVE
			END, 
		CASE WHEN ORDER_COUNT_PER_CATEGORY_ONE_WEEK_AFTER_NEWYEARSEVE IS NULL THEN 0
			ELSE ORDER_COUNT_PER_CATEGORY_ONE_WEEK_AFTER_NEWYEARSEVE
			END

FROM (

		SELECT TRANSLATED_CATEGORY_NAME,  
				COUNT(ORDER_ID) AS ORDER_COUNT_PER_CATEGORY_ONE_WEEK_BEFORE_NEWYEARSEVE
	
		FROM ORDERS_AND_CATEGORIES
		WHERE TO_CHAR((PURCHASE_TIME + interval '1 week'), 'DD-MM') = '31-12'
		GROUP BY 1
	
) AS ORDER_COUNT_PER_CATEGORY_ONEWEEK_BEFORE_NEWYEARSEVE 


FULL OUTER JOIN (
		
		SELECT TRANSLATED_CATEGORY_NAME, 
				COUNT(ORDER_ID) AS ORDER_COUNT_PER_CATEGORY_ON_NEWYEARSEVE

		FROM ORDERS_AND_CATEGORIES
		WHERE TO_CHAR(PURCHASE_TIME,'DD-MM') = '31-12'
		GROUP BY 1

) AS ORDER_COUNT_PER_CATEGORY_ON_NEWYEARS_EVE USING(TRANSLATED_CATEGORY_NAME)


FULL OUTER JOIN (

		SELECT TRANSLATED_CATEGORY_NAME,  
				COUNT(ORDER_ID) AS ORDER_COUNT_PER_CATEGORY_ONE_WEEK_AFTER_NEWYEARSEVE
	
		FROM ORDERS_AND_CATEGORIES
		WHERE TO_CHAR((PURCHASE_TIME - interval '1 week'), 'DD-MM') = '31-12'
		GROUP BY 1
	
) AS ORDER_COUNT_PER_CATEGORY_AFTER_NEWYEARSEVE USING(TRANSLATED_CATEGORY_NAME)

ORDER BY 2 DESC, 3 DESC, 4 DESC




--Q1.4: Examine the number of orders on the basis of days of the week (Monday, Thursday, etc.) and days of the month (such as the 1st, 2nd of the month). 
--Create and interpret a visual in Excel with the output of the query you wrote.

--Q1.4.1: Breakdown in terms of days of the week

SELECT CASE 
		WHEN EXTRACT(DOW from PURCHASE_TIME) = '0' THEN 'Sunday' 
		WHEN EXTRACT(DOW from PURCHASE_TIME) = '1' THEN 'Monday'
		WHEN EXTRACT(DOW from PURCHASE_TIME) = '2' THEN 'Tuesday'
		WHEN EXTRACT(DOW from PURCHASE_TIME) = '3' THEN 'Wednesday'
		WHEN EXTRACT(DOW from PURCHASE_TIME) = '4' THEN 'Thursday'
		WHEN EXTRACT(DOW from PURCHASE_TIME) = '5' THEN 'Friday'
		ELSE 'Saturday' 
		END AS DAY_OF_THE_WEEK,
	   COUNT(DISTINCT ORDER_ID) AS DOW_ORDER_COUNT
	   
FROM ORDERS
WHERE PURCHASE_TIME IS NOT NULL
GROUP BY 1
ORDER BY 2 DESC



--Q1.4.2: Breakdown in terms of days of the month between 2016-2018:

--Please run this query with the Select statement in Query 1 or 2 with the DISTINCT_ORDER_COUNT table.
--The reason why I did not combine in a single query is that the data in the order of the days of the month in the other query is naturally multiplexed because the record will come from the extra breakdown from the year.

WITH DISTINCT_ORDER_COUNT AS(

	SELECT DISTINCT ORDER_ID,
			TO_CHAR(PURCHASE_TIME,'DD') AS DAY_OF_EACH_MONTH,
			TO_CHAR(PURCHASE_TIME,'YYYY-DD') AS DAY_OF_EACH_MONTH_W_YEAR
			
	FROM ORDERS
	WHERE PURCHASE_TIME IS NOT NULL
)



--1st Query: Total number of orders in the distribution of days of each month only, not including the year
SELECT DISTINCT DAY_OF_EACH_MONTH,
		COUNT(ORDER_ID) AS TOTAL_ORDER_COUNT_PER_DAY

FROM DISTINCT_ORDER_COUNT
GROUP BY 1
ORDER BY 2 DESC
	


--2nd Query: Total number of orders in the distribution of days of each month, taking the year as a criterion
SELECT DISTINCT DAY_OF_EACH_MONTH_W_YEAR, 
		COUNT(ORDER_ID) AS TOTAL_ORDER_COUNT_PER_DAY_AND_YEAR
		
FROM DISTINCT_ORDER_COUNT
GROUP BY 1
ORDER BY 2 DESC