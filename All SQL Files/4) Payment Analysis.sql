
-- CASE 4: Payment Analysis

--Q4.1: In which region do users who pay in installments live the most?
--Please note that when we refer to the users paying in installments, we consider that the number of installments per order placed needs to be 2 or more.

WITH INSTALLMENT_PAYMENTS_INFO AS( 
	--In this customised table, we first calculate the amount of all payments made in installments and match it with the related order.

	SELECT ORDER_ID, 
			SUM(INSTALLMENTS) AS TOTAL_INSTALLMENT_AMOUNT_PER_ORDER 
			--Since more than one installment payment record is kept for an order, we first need to aggregate the total amount.
	
	FROM PAYMENT
	WHERE TYPE = 'credit_card' AND INSTALLMENTS > 1 
	--If the payment method of each record kept in the payment table is Credit Card only, and that these records happen to have two or more installments, 
	--we can only then treat them as payments made in installments.
	
	--This hands-on approach is articulated further in Q4.3.
	GROUP BY 1
		
), ORDERS_PAID_BY_INSTALLMENTS AS( 
	--Then, in order to fetch the proper records from the Customer table in our main query, we take 1-1 matching orders from the Orders table using INNER JOIN
	--through which we would only be able to access the appropriate customer IDs.

	SELECT CUSTOMER_ID, 
			O.ORDER_ID, 
			TOTAL_INSTALLMENT_AMOUNT_PER_ORDER
	
	FROM ORDERS AS O
	INNER JOIN INSTALLMENT_PAYMENTS_INFO USING(ORDER_ID)
		
)

SELECT CITY, 
		STATE, 
		SUM(TOTAL_INSTALLMENT_AMOUNT_PER_ORDER) AS TOTAL_NUMBER_OF_INSTALLMENTS_MADE
		
FROM CUSTOMERS
INNER JOIN ORDERS_PAID_BY_INSTALLMENTS  USING(CUSTOMER_ID) 
--At the end, I group the resulting installment amounts by city and state via matching customer IDs.

GROUP BY 1, 2
ORDER BY 3 DESC





--Q4.2: Calculate the number of successful orders and total amount of successful payments by payment type. 
--Sort out the outcome from the most used payment type to the least.

SELECT TYPE AS PAYMENT_TYPE, 
		COUNT(DISTINCT ORDER_ID) AS TOTAL_SUCC_ORDER_COUNT, 
		SUM(VALUE)::NUMERIC AS TOTAL_SUCC_AMOUNT --BIGINT could also be used as our casting method to convert the total monetary amount for each payment type.

FROM ORDERS
LEFT JOIN PAYMENT USING (ORDER_ID)
WHERE ORDER_STATUS = 'delivered' AND TYPE IS NOT NULL --I only consider successful orders, i.e. orders with a completed delivery and payment type defined.
GROUP BY 1
ORDER BY 2 DESC, 3 DESC





--Q4.3: Make a category-based analysis of orders paid as lump-sum/single or by installments. Which categories also resort to installment payments the most?

--If you decide to review the entire code, please first understand the context as it is paramount in order to be able to comprehend the logic on which the queries are based.



--Based on all valid orders, all possible scenarios related to each payment method are as follows:

--Debit Card: 

--If an order is paid with a debit card, it is a lump-sum/single payment both by nature and in this dataset. 
--However, there is one order record (i.e., 'a4431cbd79dbddaae7988ce6091cbc3c') linked to a debit-card payment which includes two separate payment records,
--which we consider Partial/Fragmented payments.

--In order to distinguish between Partial/Fragmented and Installment payments, I refer to the 'INSTALLMENTS' parameter/column in each record. 
--Accordingly, if it says '1' for a specific record/row, even if the payment is partial, I categorize the payment method of that order as 'By Installments'.



--Boleto: 

--Since there is no partial payment situation related to this payment method and that the number of installments in such records is only 1,
--all orders completed with this payment method is also categorized as 'Lump-Sum Payment'.

--Please also note that Debit Card and Boleto cannot be combined with any other form of payments, including between themselves. 
--For example, if an order is paid with the Boleto method, then it cannot be combined with anything else.
--Same goes for all orders paid with the Debit Card method.



--Voucher: 

--This payment method also involves partial/fragmented payments. Very important to note that there are no orders that have more than one installment and have been paid by a voucher.

--For example, there are exactly 29 different voucher payment-type records for an order 'fa65dad1b0e818e3ccc5cb0e39231352'.
--However, due to the fact that the number of installments in all of them (i.e., each separate record) is only 1, it is determined that this payment method is considered partial rather than by installments.
--Therefore, all such cases have been regarded as 'Lump-Sum Payment'.



--Credit Card: 

--Credit Card is the only payment method where payment can be categorised as 'Lump-Sum' or 'By Installments'.
--There are cases where it is used alone or only with Vouchers:

--In cases where it is used alone, if the number of installments is above 1, it is categorized as a payment made 'By Installments'. If not, it counts as 'Lump-Sum Payment'.

--There is also an interesting situation when used with Vouchers (e.g., ORDER_ID = '00b4a910f64f24dbcac04fe54088a443')
--If an order contains both Voucher and Credit Card payments, but the number of installments is only 1 for each record, 
--this type of payments has been categorized as 'Lump-Sum Payment' via the Partial/Fragmented payment logic.

--On the other hand, if there is an order paid with a credit card, using multiple installments, which may or may not include use of any voucher, then it is categorized as a payment made 'By Installments'.
--(e.g., ORDER_ID = "02ec4da9d03014f06d711d60eb37cc22")

--There exist 2 more orders whose payments were made by a credit card but over 0 installments. These are also categorized as 'Lump-Sum Payment' to protect the data integrity.


--I am implementing a simple filter that enables all of the above scenarios to come to life, under my "SINGLE_OR_MULTIPLE_PAYMENTS" table.


WITH ORDER_PAYMENT_TYPES_AND_CATEGORIES AS
						
	(WITH SINGLE_OR_MULTIPLE_PAYMENTS AS
	
			(SELECT ORDER_ID,
					CASE WHEN (SUM(INSTALLMENTS) * 1.0) / (COUNT(ORDER_ID) * 1.0) <= 1 THEN 'Lump Sum Payment' 
			 			--This Case-When statement also includes the two remaining orders paid with a credit card but via 0 installments, as mentioned right above.
			 			--'00c95282163553a982f38481f9488481'  '0814daa4d12a646aeb73c429d5852f4d'
						WHEN (SUM(INSTALLMENTS) * 1.0) / (COUNT(ORDER_ID) * 1.0) > 1 THEN 'By Installments'
			 			ELSE 'Not Determined'
			 			END AS BINARY_PAYMENT_APPROACH
			 
			 	--The CASE/WHEN expresison above binarily assigns each order a label as to whether it is a 'Lump-Sum Payment' or 'By Installments'.
			 
				FROM PAYMENT
				WHERE TYPE != 'not_defined' --I am removing all records that do not have any payment method defined.
				GROUP BY 1 --With this GROUP BY structure, I avoid all duplicating order IDs. 
			),
	 

		PRODUCTS_TRANSLATION AS
	 
			(SELECT PRODUCT_ID,
					CATEGORY_NAME,
					CASE WHEN CATEGORY_NAME = 'portateis_cozinha_e_preparadores_de_alimentos' THEN 'kitchen_portables_and_food_preparers'
			 			WHEN CATEGORY_NAME = 'pc_gamer' THEN 'pc_gamer'
			 			ELSE CATEGORY_NAME_IN_ENGLISH
			 		--The CASE/WHEN statement above is designed to add 2 more category names, written in Portuguese, to the query that do not have any equivalent in the English translation table.
						END AS TRANSLATED_CATEGORY_NAMES
			 
				FROM PRODUCT_CATEGORY_TRANSLATION
				RIGHT JOIN PRODUCTS_DATASET USING (CATEGORY_NAME)
				WHERE CATEGORY_NAME IS NOT NULL
			),
	 
	 
		ORDER_CATEGORY_TYPE AS
	 
			(SELECT DISTINCT ORDER_ID,
					TRANSLATED_CATEGORY_NAMES
			 
				FROM ORDER_ITEMS
				LEFT JOIN PRODUCTS_TRANSLATION USING (PRODUCT_ID)
				WHERE TRANSLATED_CATEGORY_NAMES IS NOT NULL 
			)
	 
	 SELECT ORDER_ID,
			BINARY_PAYMENT_APPROACH,
			TRANSLATED_CATEGORY_NAMES
	 
	 FROM ORDERS
	 INNER JOIN SINGLE_OR_MULTIPLE_PAYMENTS USING (ORDER_ID)
	 INNER JOIN ORDER_CATEGORY_TYPE USING (ORDER_ID)
	 --Via these INNER JOINs, I bring in to our major customised table, ORDER_PAYMENT_TYPES_AND_CATEGORIES, 
	 --both the binary payment approach of each order and the category(ies) to which each order belongs.

)

--Please feel free to run both views separately in conjunction with our main customised table - ORDER_PAYMENT_TYPES_AND_CATEGORIES


--First View: Category-based analysis of orders paid as 'Lump-Sum' or 'By Installments'

SELECT TRANSLATED_CATEGORY_NAMES,
		BINARY_PAYMENT_APPROACH,
		COUNT(ORDER_ID) AS TOTAL_RESPECTIVE_ORDER_COUNT 
		--Due to the architecture of the query, we could also count the total payment type here, but we should never use DISTINCT because there are orders belonging to more than one category.
		
FROM ORDER_PAYMENT_TYPES_AND_CATEGORIES 
GROUP BY 1, 2
ORDER BY 3 DESC, 2 ASC



--Second View - More Holistic: Category-based analysis of orders paid as 'Lump-Sum' or 'By Installments'

SELECT TRANSLATED_CATEGORY_NAMES,
		CASE WHEN ORDER_COUNT_BY_INSTALLMENTS IS NULL THEN 0
			ELSE ORDER_COUNT_BY_INSTALLMENTS
			END,
		CASE WHEN ORDER_COUNT_BY_LUMP_SUM IS NULL THEN 0
			ELSE ORDER_COUNT_BY_LUMP_SUM
			END
		
FROM (
	
	SELECT TRANSLATED_CATEGORY_NAMES,
			COUNT(ORDER_ID) AS ORDER_COUNT_BY_INSTALLMENTS
	
	FROM ORDER_PAYMENT_TYPES_AND_CATEGORIES
	WHERE BINARY_PAYMENT_APPROACH = 'By Installments'
	GROUP BY 1
		
) AS FILTERED_TABLE_1_FOR_INSTALLMENTS

FULL OUTER JOIN (
	
	SELECT TRANSLATED_CATEGORY_NAMES,
			COUNT(ORDER_ID) AS ORDER_COUNT_BY_LUMP_SUM
		
	FROM ORDER_PAYMENT_TYPES_AND_CATEGORIES
	WHERE BINARY_PAYMENT_APPROACH = 'Lump Sum Payment'
	GROUP BY 1
	
) AS FILTERED_TABLE_2_FOR_LUMP_SUM USING(TRANSLATED_CATEGORY_NAMES)

ORDER BY 3 DESC



--Second Aspect of the Question 4.3: Which categories also resort to installment payments the most? (TOP 10)

SELECT TRANSLATED_CATEGORY_NAMES, 
		BINARY_PAYMENT_APPROACH, 
		COUNT(ORDER_ID) AS TOTAL_RESPECTIVE_ORDER_COUNT
		
FROM ORDER_PAYMENT_TYPES_AND_CATEGORIES
WHERE BINARY_PAYMENT_APPROACH = 'By Installments'
GROUP BY 1, 2
ORDER BY 3 DESC, 2 ASC
LIMIT 10


--The following orders do not have any payment types defined:

--"00b1cb0320190ca0daa2c88b35206009"
--"4637ca194b6387e2d538dc89b124b0ee"
--"c8c528189310eaa44a745b8d9d26908b"

--The following order has no payment information found:

--"bfbd0f9bdef84302105ad712db648a6c" 



