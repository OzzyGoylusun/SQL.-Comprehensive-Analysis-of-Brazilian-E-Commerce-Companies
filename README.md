# SQL Comprehensive Analysis of Brazilian E-Commerce 

## Table of Contents (EXAMPLE)

- [Project Overview](#project-overview)
- [Data Sources](#data-sources)
- [Recommendations](#recommendations)


### Project Overview
---

This data analysis project aims to provide insights into the sales performance of an e-commerce company over the past year. By analyzing various aspoects of the sales data,
we seek to identify trends, make data-driven recommendations, and gain a deeper understanding of the company's performance.

AN IMAGE COULD ALSO GO HERE TO SHOW THE AUDIENCE HOW OUR ENDGAME PROJECT WORK VISUALLY LOOKS LIKE

### Data Sources

Sales Data: The primary dataset used for this analysis is the "sales_data.csv" file, containing detailed information about each sale made by the company.

### Tools

- Excel - Data Cleaning 
  - [Download here](https://microsoft.com)
- SQL Server - Data Analysis
- Power BI - Creating Reports

### Data Cleaning/Preparation

In the initial data preparation phase, we performed the following tasks:

1. Data loading and inspection.
2. Handling missing values.
3. Data cleaning and formatting.

### Exploratory Data Analysis (EDA)

EDA involved exploring the sales data to answer key questions, such as:

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

### References: Let's say you checked something online, Googled, or simply source of your data and case study content etc.

1. SQL for Businesses by Werty. (Book Name)
2. [PostgreSQL: TimeSeries](https://www.postgresql.org/docs/current/functions-datetime.html#FUNCTIONS-DATETIME-TABLE)
