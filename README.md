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

By analyzing these aspects of the orders data, the project seeks to identify trends, gaps and assists with making data-driven recommendations while gaining a deeper understanding of the overall brazilian e-commerce atmosphere that may have been glossed over.


<<IMAGE>>

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
- What is the favorite city of each customer when it comes to placing orders from?
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

1. The small e-commerce businesses' sales have been aggresively increasing in 2017 and 2018, however with **noticeable drops during the last days of each month**, sliding below the 8-period fibonacci moving average.

<img width="1187" alt="Aggregated Order Count for Days of Each Year" src="https://github.com/OzzyGoylusun/SQL-Comprehensive-Analysis-of-Brazilian-E-Commerce-Companies/assets/152992554/bdc794a7-7368-42ba-b533-8e71ce2df7f5">


2. Unlike other global department stores, only **37%** of all orders were placed on **weekends**, even including Friday as a weekend day.
3. Top reviewed vendors have gained most appreciation owing to exceeding customer expectations about **order delivery speed.**
4. **Credit card** by far is the most preferred method to pay by installments with most customers living in **Sao Paulo** choosing this method.
   
### Recommendations

This part actually empowers data analysts to provide value to the firms for which they are undertaking work.

Based on the analysis, we recommend the following actions:

- Invest in marketing and promotions during peak sales seasons to maximize revenue.
- Focus on expanding and promoting products in Category A.
- Implement a customer segmentation strategy to target high-LTV customers effectively.

### Limitations: Records that you have been compelled to take out of your analysis (e.g., outliers, NaNs etc.). This can help you work as your Disclaimer.

I had to remove all zero values from budget and revenue columns because they would have affected the accuracy of my conclusions from the analysis. There are still a
few outliers even after the omissions but even then we can still see that there is a positive correlatation between both budget and number of votes with revenue.

### References:

1. [Kaggle Dataset](https://www.kaggle.com/datasets/olistbr/brazilian-ecommerce)
2. [PostgreSQL: TimeSeries](https://www.postgresql.org/docs/current/functions-datetime.html#FUNCTIONS-DATETIME-TABLE)
