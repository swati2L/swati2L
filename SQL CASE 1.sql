USE [CASE STUDY ];

--DATA PREPARATION AND UNDERSTANDING

--Q1)
SELECT * FROM Transactions;

SELECT COUNT(*) FROM Customer;
SELECT COUNT(*) FROM Transactions;
SELECT COUNT(*) FROM prod_cat_info;

--Q2)

SELECT * FROM Transactions WHERE Rate>0 ; 

--Q3)

SELECT  tran_date,CONVERT(date,tran_date,103) AS NewDATE FROM Transactions;

SELECT dob,CONVERT(date,dob,103) AS NewDATE FROM Customer;

--Q4) 

SELECT DATEDIFF(DAY, MIN(CONVERT(DATE, TRAN_DATE, 105)), MAX(CONVERT(DATE, TRAN_DATE, 105))), 
DATEDIFF(MONTH, MIN(CONVERT(DATE, TRAN_DATE, 105)), MAX(CONVERT(DATE, TRAN_DATE, 105))),  
DATEDIFF(YEAR, MIN(CONVERT(DATE, TRAN_DATE, 105)), MAX(CONVERT(DATE, TRAN_DATE, 105))) 
FROM Transactions;

--Q5)

SELECT *FROM prod_cat_info WHERE prod_subcat ='DIY';

--DATA ANALYSIS
--Q1)

SELECT STORE_TYPE, COUNT(TRANSACTION_ID) AS CNT_TRANSACTION FROM Transactions GROUP BY Store_type ORDER BY CNT_TRANSACTION DESC;

--Q2)

SELECT GENDER, COUNT(*) FROM CUSTOMER WHERE Gender IN ('M' ,'F') GROUP BY Gender;

--Q3)

SELECT TOP 1 city_code, COUNT(customer_Id) AS CUSTOMERS FROM Customer GROUP BY city_code ORDER BY CUSTOMERS DESC;

--Q4)

SELECT * FROM prod_cat_info WHERE prod_cat='BOOKS';

--Q5)

SELECT TOP 1 PROD_CAT ,COUNT(CUST_ID)AS CUSTOMER FROM prod_cat_info INNER JOIN Transactions ON prod_cat_info.prod_cat_code=Transactions.prod_cat_code GROUP BY prod_cat
ORDER BY CUSTOMER DESC; 

--Q6)

SELECT PROD_CAT, SUM(CAST(total_amt AS float)) AS AMOUNT
FROM Transactions AS T
INNER JOIN prod_cat_info AS P ON P. prod_cat_code = T.prod_cat_code 
AND prod_sub_cat_code = prod_subcat_code
WHERE prod_cat IN ('BOOKS' , 'ELECTRONICS') GROUP BY ROLLUP(prod_cat);

--Q7)

  SELECT COUNT(customer_Id) AS CUSTOMERS
FROM Customer WHERE customer_Id IN 
(
SELECT cust_id
FROM Transactions
LEFT JOIN Customer ON customer_Id = cust_id
WHERE TOTAL_AMT NOT LIKE '-%'
GROUP BY
CUST_ID
HAVING 
COUNT(TRANSACTION_ID) > 10)

--Q8)

SELECT  STORE_TYPE,SUM(CAST(total_amt as float)) as TOTAL_AMT
FROM prod_cat_info as P
INNER JOIN Transactions AS T ON P.prod_sub_cat_code=T.prod_subcat_code
INNER JOIN prod_cat_info ON T.prod_cat_code=P.prod_cat_code WHERE P.prod_cat IN ('BOOKS','ELECTRONICS') GROUP BY Store_type ;

--Q9)

SELECT prod_subcat,prod_cat,Gender,SUM(CAST(total_amt AS float)) AS TOTAL_REVENUE
FROM prod_cat_info 
INNER JOIN Transactions ON prod_cat_info.prod_sub_cat_code=Transactions.prod_subcat_code
INNER JOIN Customer ON Transactions.cust_id=Customer.customer_Id
WHERE prod_cat='ELECTRONICS' AND Gender='M'
GROUP BY prod_subcat,prod_cat,Gender ORDER BY TOTAL_REVENUE;

--Q10) 

SELECT TOP 5 prod_subcat_code,
ROUND(SUM(CAST(CASE WHEN QTY>0 THEN QTY ELSE 0 END AS FLOAT)),2) AS PERCENTAGE_OF_SALES,
ROUND(SUM(CAST(CASE WHEN QTY<0 THEN QTY ELSE 0 END AS FLOAT)),2) AS TOTAL_RETURN,
ROUND(SUM(CAST(CASE WHEN QTY<0 THEN QTY ELSE 0 END AS FLOAT)),2)* 100/ROUND(SUM(CAST(CASE WHEN QTY>0 THEN QTY ELSE 0 END AS FLOAT)),2) AS [%_OF_RETURN],
100+ ROUND(SUM(CAST(CASE WHEN QTY<0 THEN QTY ELSE 0 END AS FLOAT)),2)*100/ROUND(SUM(CAST(CASE WHEN QTY>0 THEN QTY ELSE 0 END AS FLOAT)),2) AS [%_OF_SALES]
FROM Transactions
GROUP BY prod_subcat_code
ORDER BY [%_OF_SALES];

--Q11)

SELECT cust_id,SUM(CAST(total_amt AS float)) AS TOTAL_AMOUNT FROM Transactions
WHERE CUST_ID IN 
	(SELECT customer_Id
	 FROM Customer
     WHERE DATEDIFF(YEAR,CONVERT(DATE,DOB,103),GETDATE()) BETWEEN 25 AND 35)
     AND CONVERT(DATE,tran_date,103) BETWEEN DATEADD(DAY,-30,(SELECT MAX(CONVERT(DATE,tran_date,103)) FROM Transactions)) 
	 AND (SELECT MAX(CONVERT(DATE,tran_date,103)) FROM Transactions)
GROUP BY cust_id;

--Q12)

SELECT TOP 1 prod_cat, SUM(CAST(TOTAL_AMT AS float)) AS RETURN_VALUES FROM Transactions AS T 
 INNER JOIN prod_cat_info AS P ON T.prod_cat_code=P.prod_cat_code 
 AND prod_sub_cat_code=prod_subcat_code 
 where convert(date,tran_date,103)>= dateadd(month,-3,convert(date,tran_date,103))
 group by prod_cat;
 
 
 




--Q13)

 SELECT  store_type, MAX(total_amt)AS SALES_AMOUNT, MAX(Qty)_QTY_SOLD
FROM Transactions
group by  Store_type
ORDER BY  MAX(total_amt) DESC,  MAX(Qty) DESC 

--Q14)

SELECT PROD_CAT, AVG(cast(TOTAL_AMT as float)) AS AVERAGE
FROM Transactions
INNER JOIN prod_cat_info ON transactions.prod_cat_code=prod_cat_info.prod_cat_code AND transactions.prod_subcat_code=prod_cat_info.prod_sub_cat_code
GROUP BY PROD_CAT
HAVING AVG(cast(TOTAL_AMT as float))> (SELECT AVG(cast(TOTAL_AMT as float)) FROM Transactions) 


--Q15)
select top 5 prod_cat, prod_subcat_code,sum(cast(total_amt as float)) as total_revenue ,avg(cast(total_amt as float)) as average ,sum(cast(Qty as float)) as qty_sold
from Transactions inner join prod_cat_info on Transactions.prod_cat_code=prod_cat_info.prod_cat_code
and  prod_cat_info.prod_sub_cat_code=Transactions.prod_subcat_code
 where prod_cat in ( select top 5  prod_cat  from Transactions inner join prod_cat_info on Transactions.prod_cat_code=prod_cat_info.prod_cat_code
 and prod_sub_cat_code=prod_subcat_code group by prod_cat order by(sum(cast(qty as float))))  group by prod_cat,prod_subcat_code;

 

 
