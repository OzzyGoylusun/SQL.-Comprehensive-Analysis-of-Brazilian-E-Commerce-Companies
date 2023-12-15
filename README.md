# SQL Comprehensive Analysis of Brazilian E-Commerce Companies

## Table of Contents

- [Exploratory Data Analysis](#exploratory-data-analysis)
- [Findings](#findings)
- [Recommendations](#recommendations)


### Project Overview
---

This data analysis project aims to provide insights into the sales performance of small Brazilian e-commerce companies who processed orders via the largest department store in Brazil, **Olist**, over the years 2016, 2017 and 2018 based upon the following four aspects:

1. Order Analysis (OA)
2. Customer Analysis (CA)
3. Vendor Analysis (VA)
4. Payment Analysis (PA)

By analyzing these aspects of the orders data, the project seeks to identify trends, gaps and assists these firms with making data-driven recommendations while gaining a deeper understanding of the overall brazilian e-commerce atmosphere that may have been glossed over.

<img width="718" alt="Overall Sales Trend" src="https://github.com/OzzyGoylusun/SQL-Comprehensive-Analysis-of-Brazilian-E-Commerce-Companies/assets/152992554/10a291ec-f800-46b2-b9d5-7c936f411b8f">

For instance, above shows the overall uptrend trend in sales in the e-commerce sector.

### Data Sources

Orders Data: Out of 8 datasets in total, the primary dataset used for this analysis is the "olist_orders_dataset.csv" file, containing detailed information about orders processed by a number of Brazilian e-commerce companies.

### Tools

- PostgreSQL Server - Data Manipulation and Analysis
  - [Download here](https://www.postgresql.org/download/)
- Excel - Data Visualisation 
  - [Download here](https://microsoft.com)

### Data Preparation

In the initial data preparation works, I performed the following tasks:

1. Database creation from scratch
2. Tables creation, including assignment of primary and foreign keys
3. Preparation of an entity-relationship diagram (ERD)
4. Data import and inspection

### Exploratory Data Analysis

EDA involved exploring the commercial data to answer some key questions, including but not limited

- What is the overall sales trend?
- What are the most preferred product categories leading up to/on/after special days?
- What is the favorite city of each customer when it comes to where they place their orders from?
- Who are the top 5 sellers who deliver orders to customers the fastest? 
- Which product categories experienced installment payments the most?

### Data Analysis

As part of my Order Analysis series, I created a major customised table that brings together orders, which category they are part of and their purchase time by customers.

```sql
...
WITH ORDERS_AND_CATEGORIES AS(
		
  SELECT DISTINCT ORDER_ID,
              TRANSLATED_CATEGORY_NAME,
              PURCHASE_TIME
		
  FROM ORDERS AS O
  INNER JOIN ORDER_ITEMS AS OI USING (ORDER_ID)
  INNER JOIN COMPLETE_CATEGORY_TRANSLATION USING (PRODUCT_ID)
  WHERE CATEGORY_NAME IS NOT NULL

)
...
```

Afterwards, what stroke me most by far was to face the need to subfilter this customised table in several ways and join them together 
in order to find out **the most preferred product categories leading up to and on specific days:**

```sql
SELECT ...
FROM (

	SELECT TRANSLATED_CATEGORY_NAME,  
		COUNT(ORDER_ID) AS ORDER_COUNT_PER_CATEGORY_ONE_WEEK_BEFORE_DIADOS
	
	FROM ORDERS_AND_CATEGORIES
	WHERE TO_CHAR((PURCHASE_TIME + interval '1 week'), 'DD-MM') = '12-06'   
	GROUP BY 1

) AS ORDER_COUNT_PER_CATEGORY_BEFORE_DIADOS 

FULL OUTER JOIN (

	...
	FROM ORDERS_AND_CATEGORIES
	WHERE TO_CHAR(PURCHASE_TIME,'DD-MM') = '12-06'
	...

) AS ORDER_COUNT_PER_CATEGORY_ON_DIADOS USING(TRANSLATED_CATEGORY_NAME)
...
```

### Findings

The critical analysis results are summarised as follows:

1. The e-commerce businesses' sales have been aggresively increasing in 2017 and 2018, however with **noticeable drops during the last days of each month**, sliding below the 8-period fibonacci moving average.

<img width="1178" alt="Screen Shot 2023-12-15 at 12 53 59" src="https://github.com/OzzyGoylusun/SQL-Comprehensive-Analysis-of-Brazilian-E-Commerce-Companies/assets/152992554/874627fb-6fe6-45d4-9fc8-833a3cb0b705">

2. Unlike other global department stores, only **37%** of all orders were placed on **weekends**, even including Friday as a weekend day.
3. Top reviewed vendors have gained most appreciation owing to exceeding customer expectations about **order delivery speed.**
4. **Credit card** by far is the most preferred method to pay by installments with most customers living in **Sao Paulo** choosing this method.
   
### Recommendations

Based on the analysis, we recommend the following actions:

- Invest further in marketing and promotions to slow down and 
- Adopt a data-driven customer segmentation strategy also to target sensitive customers who can only rely on their paychecks to go online shopping.
- Communicate with vendors the need to continue to improve order delivery speed to enhance customer satisfaction levels.
- Promote 
  

### Limitations:

The Geolocation dataset was excluded from the comprehensive data analysis.

### References:

1. [Kaggle Dataset](https://www.kaggle.com/datasets/olistbr/brazilian-ecommerce)
2. [PostgreSQL: TimeSeries](https://www.postgresql.org/docs/current/functions-datetime.html#FUNCTIONS-DATETIME-TABLE)
