
--------------- DATA PREPARATION AND UNDERSTANDING ---------------------

--CREATE DATABASE
CREATE DATABASE retails;

--MAKE THE DATABASE ACTIVE
USE retails;

--Question 1 and 2
SELECT COUNT(*) TOTAL_ROWS_IN_CUSTOMER_TABLE FROM   dbo.customer
UNION ALL
SELECT COUNT(*) TOTAL_ROWS_IN_Transactions_TABLE FROM   dbo.Transactions
UNION ALL
SELECT COUNT(*) TOTAL_ROWS_IN_prod_cat_info_TABLE FROM   dbo.prod_cat_info;

--Question 3
SELECT *,
       Format(CONVERT(DATETIME, dob, 103), 'dd-MM-yyyy') AS dob_as_date
FROM   customer;


--Question 4
SELECT *,
       Format(CONVERT(DATETIME, dob, 103), 'dd')   AS Day,
       Format(CONVERT(DATETIME, dob, 103), 'MM')   AS Month,
       Format(CONVERT(DATETIME, dob, 103), 'yyyy') AS Year,
       (SELECT Cast(Max(Format(CONVERT(DATETIME, dob, 103), 'dd')) AS INT)
               - Cast(
                       Min(Format(CONVERT(DATETIME, dob, 103), 'dd')) AS INT) AS
               dob_as_date
        FROM   customer)  AS time_range_tranc
FROM   customer;

--Question 5

SELECT *
FROM   prod_cat_info
WHERE  prod_subcat = 'DIY';

------------------------Data Analysis------------------------------

-- question 1
SELECT TOP 1 store_type,
             Count(store_type) "frequent_channel"
FROM   transactions
GROUP  BY store_type
ORDER  BY 2 DESC;

--Question 2
SELECT gender,
       Count(gender) 'count_of_male_female'
FROM   customer
WHERE  gender IS NOT NULL
GROUP  BY gender;

--question 3
--approch 1
SELECT TOP 1 a.city_code,
             Count(b.cust_id)
FROM   customer a,
       transactions b
WHERE  a.customer_id = b.cust_id
GROUP  BY a.city_code
ORDER  BY 2 DESC;

--approch 2
SELECT TOP 1 city_code,
             Count(cust_id)
FROM   customer
       RIGHT JOIN transactions
               ON customer_id = cust_id
GROUP  BY city_code
ORDER  BY 2 DESC;

--question 4
SELECT prod_cat,
       Count(prod_subcat) AS prod_subcat_under_book
FROM   prod_cat_info
WHERE  prod_cat = 'Books'
GROUP  BY prod_cat;

--question 5
SELECT prod_cat,
       Count(transaction_id) max_quantity
FROM   transactions
       RIGHT JOIN prod_cat_info
               ON prod_cat_info.prod_cat_code = transactions.prod_cat_code
GROUP  BY prod_cat;

--Question 6
--Approch 1
SELECT prod_cat,
       Round(Sum(total_amt), 2) total_revenue
FROM   transactions
       LEFT JOIN prod_cat_info
              ON transactions.prod_cat_code = transactions.prod_cat_code
WHERE  prod_cat IN ( 'Electronics', 'Books' )
GROUP  BY prod_cat;

--Approch 2
SELECT prod_cat,
       Round(Sum(total_amt), 2) total_revenue
FROM   transactions,
       prod_cat_info
WHERE  transactions.prod_cat_code = transactions.prod_cat_code
       AND prod_cat IN ( 'Electronics', 'Books' )
GROUP  BY prod_cat;

--Question 7
SELECT DISTINCT Count(*)
                  OVER () AS Total_cuatomer_gr_10_trans
FROM   transactions
WHERE  qty > 0
GROUP  BY cust_id
HAVING Count(transaction_id) > 10;

--Question 8
SELECT Round(Sum(total_amt), 2) combined_revenue
FROM   transactions,
       prod_cat_info
WHERE  transactions.prod_cat_code = transactions.prod_cat_code
       AND prod_cat IN ( 'Electronics', 'Clothing' )
       AND store_type = 'Flagship store';

--Question 9
SELECT prod_subcat,
       Round(Sum(total_amt), 2) combined_revenue
FROM   transactions,
       prod_cat_info,
       customer
WHERE  customer_id = cust_id
       AND transactions.prod_subcat_code = prod_cat_info.prod_sub_cat_code
       AND prod_cat = 'Electronics'
       AND gender = 'M'
GROUP  BY prod_subcat;

--Question 10 


select top 5 round( (select sum(qty) from Transactions 
where qty >0 ) /(select sum(qty)  from Transactions ),5)*100 total_sale_by_cat  ,
round((select sum(qty) from Transactions 
where qty <0)/(select sum(qty)  from Transactions) ,5) total_ret_by_cat  ,
prod_subcat_code
from Transactions t
group by prod_subcat_code;


--Question 11

--Invalid question as customer's age not provided in the data.
--Question 12
SELECT TOP 1 b.prod_cat,
             Min(rate) max_value_of_return
FROM   transactions a,
       prod_cat_info b
WHERE  qty < 0
       AND a.prod_cat_code = b.prod_cat_code
--and tran_date >DATEADD(MONTH, -3, GETDATE()) --uncomment to get last 3 months. last three month data not present.
GROUP  BY a.prod_cat_code,
          prod_cat
ORDER  BY 2;

--Question 13
SELECT TOP 1 store_type,
             Sum(qty)                 total_qty,
             Round(Sum(total_amt), 2) total_sale
FROM   transactions
GROUP  BY store_type
ORDER  BY 3 DESC;

--Question 14
SELECT prod_cat_code,
       Round(Avg(total_amt), 2) avg_revenue
FROM   transactions
GROUP  BY prod_cat_code
HAVING Avg(total_amt) > (SELECT Avg(total_amt)
                         FROM   transactions);

--Question 15
SELECT Round(Avg(total_amt), 2) avg_sale,
       Round(Sum(total_amt), 2) total_revenue,
       prod_subcat_code,
       prod_subcat
FROM   transactions trans,
       prod_cat_info info
WHERE  trans.prod_subcat_code = info.prod_sub_cat_code
       AND trans.prod_cat_code IN (SELECT prod_cat_code
                                   FROM   (SELECT TOP 5 prod_cat_code,
                                                        Sum(qty) total_quantity
                                           FROM   transactions
                                           GROUP  BY prod_cat_code
                                           ORDER  BY 2 DESC) AS t1)
GROUP  BY prod_subcat_code,
          prod_subcat; 
