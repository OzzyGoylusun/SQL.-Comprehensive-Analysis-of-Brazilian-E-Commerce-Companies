# SQL Comprehensive Analysis of Brazilian E-Commerce 

## Table of Contents (EXAMPLE)

- [Project Overview](#project-overview)
- [Data Sources](#data-sources)
- [Recommendations](#recommendations)


### Project Overview
---

This data analysis project aims to provide insights into the sales performance of small Brazilian e-commerce companies who processes orders via a giant department store in Brazil, Olist, over the years 2016, 2017 and 2018 based upon the following four aspects:

1. Order Analysis
2. Customer Analysis
3. Vendor Analysis
4. Payment Analysis

By analyzing these aspects of the sales data, it seeks to identify trends, helps make data-driven recommendations while gaining a deeper understanding of the overall brazilian e-commerce atmosphere.


AN IMAGE COULD ALSO GO HERE TO SHOW THE AUDIENCE HOW OUR ENDGAME PROJECT WORK VISUALLY LOOKS LIKE

### Data Sources

Orders Data: Out of 8 datasets in total, the primary dataset used for this analysis is the "olist_orders_dataset.csv" file, containing detailed information about orders processed by a number of Brazilian e-commerce companies.

### Tools

- PostgreSQL Server - Data Manipulation and Analysis
  - [Download here](https://www.postgresql.org/download/)
- Excel - Data Visualisation 
  - [Download here](https://microsoft.com)

### Data Preparation:

In the initial data preparation works, I performed the following tasks:

1. Database Creation
2. Tables Creation, including assignment of Primary and Foreign Keys
3. Preparation of an Entity-Relationship Diagram
4. Data loading and inspection.

### Exploratory Data Analysis (EDA)

EDA involved exploring the commercial data to answer key questions, such as:

- What is the overall sales trend?
- Which products are top sellers?
- What are the peak sales periods?

<img width="892" alt="Example Pic" src="https://github.com/OzzyGoylusun/SQL-Case-Study-Analysing-Unicorn-Companies/assets/152992554/7fef48e9-12aa-425e-8394-72a1de395ef2">


### Data Analysis

Include some interesting code/features worked with

```sql
SELECT * FROM table1
WHERE cond = 2
```

### Results/Findings

The analysis results are summarised as follows:
1. The company's sales have been steadily increasing over the past year, with a noticeable peak during the holiday season.
2. Product Category A is the best-performing category in terms of sales and revenue.
3. Customer segments with high lifetime value (LTV) should be targeted for marketing efforts.

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

1. [Kaggle Dataset:](https://www.kaggle.com/datasets/olistbr/brazilian-ecommerce)
2. [PostgreSQL: TimeSeries](https://www.postgresql.org/docs/current/functions-datetime.html#FUNCTIONS-DATETIME-TABLE)
