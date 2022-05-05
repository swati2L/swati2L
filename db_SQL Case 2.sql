--SQL Advance Case Study

USE db_SQLCaseStudies;

--Q1--BEGIN List all the states in which we have customers who have bought cellphones from 2005 till today
SELECT STATE,Date
FROM FACT_TRANSACTIONS T
INNER JOIN DIM_LOCATION DL ON T.IDLOCATION= DL.IDLocation
INNER JOIN DIM_MODEL DM ON T.IDMODEL= DM.IDMODEL
WHERE Date BETWEEN '01-01-2005' AND '01-01-2022'
GROUP BY State,Date;

--Q1--END

--Q2--BEGIN . What state in the US is buying the most 'Samsung' cell phones
SELECT TOP 1 STATE  FROM DIM_LOCATION AS DL
INNER JOIN FACT_TRANSACTIONS AS FT ON DL.IDLocation=FT.IDLocation
INNER JOIN DIM_MODEL AS DM ON FT.IDModel=DM.IDModel
INNER JOIN DIM_MANUFACTURER AS MF ON DM.IDManufacturer=MF.IDManufacturer
WHERE Manufacturer_Name='SAMSUNG'
GROUP BY STATE
ORDER BY SUM(QUANTITY) DESC; 


--Q2--END

--Q3--BEGIN Show the number of transactions for each model per zip code per state.     
SELECT ZipCode,IDModel,STATE,COUNT(IDModel) AS NO_OF_TRANSACTION FROM FACT_TRANSACTIONS
INNER JOIN DIM_LOCATION ON FACT_TRANSACTIONS.IDLocation=DIM_LOCATION.IDLocation 
GROUP BY ZipCode,idmodel,State

--Q3--END

--Q4--BEGIN Show the cheapest cellphone (Output should contain the price also)
SELECT top 1 Manufacturer_Name,model_name ,min(Unit_price ) AS PRICE  FROM FACT_TRANSACTIONS
INNER JOIN DIM_MODEL ON FACT_TRANSACTIONS.IDModel=DIM_MODEL.IDModel 
inner join DIM_MANUFACTURER on DIM_MODEL.IDManufacturer=DIM_MANUFACTURER.IDManufacturer
GROUP BY Manufacturer_Name,Model_Name
ORDER BY PRICE ;

--Q4--END

--Q5--BEGIN . Find out the average price for each model in the top5 manufacturers in terms of sales quantity and order by average price. 
SELECT TOP 5 MANUFACTURER_NAME,MODEL_NAME, SUM(QUANTITY) AS SALES_QTY, AVG(Unit_price) AS AVG_PRICE FROM FACT_TRANSACTIONS
INNER JOIN DIM_MODEL ON FACT_TRANSACTIONS.IDModel=DIM_MODEL.IDModel
LEFT JOIN DIM_MANUFACTURER ON DIM_MODEL.IDManufacturer=DIM_MANUFACTURER.IDManufacturer
GROUP BY Manufacturer_Name,Model_Name
ORDER BY AVG_PRICE DESC ;

--Q5--END

--Q6--BEGIN . List the names of the customers and the average amount spent in 2009,where the average is higher than 500 
SELECT CUSTOMER_NAME,year, AVG(TOTALPRICE ) AS AVG_AMt FROM FACT_TRANSACTIONS
INNER JOIN DIM_CUSTOMER ON FACT_TRANSACTIONS.IDCustomer=DIM_CUSTOMER.IDCustomer 
left JOIN DIM_DATE ON FACT_TRANSACTIONS.Date=DIM_DATE.DATE
where YEAR='2009' 
group by Customer_Name,YEAR
having(avg(totalprice ) > 500 )

--Q6--END
	
--Q7--BEGIN . List if there is any model that was in the top 5 in terms of quantity,simultaneously in 2008, 2009 and 2010 
select top 5 Model_Name,YEAR,count(Quantity) as qty  from FACT_TRANSACTIONS
inner join DIM_MODEL on FACT_TRANSACTIONS.IDModel=DIM_MODEL.IDModel
inner join DIM_DATE on FACT_TRANSACTIONS.Date=DIM_DATE.DATE
where YEAR='2008'
group by year,Model_Name
 
union all
select top 5 model_name,YEAR,count(quantity) as qty from FACT_TRANSACTIONS
inner join DIM_MODEL on FACT_TRANSACTIONS.IDModel=DIM_MODEL.IDModel
inner join DIM_DATE on FACT_TRANSACTIONS.Date=DIM_DATE.DATE
where YEAR='2009'
group by YEAR, Model_Name

union all
select top 5 model_name,year,count(quantity) as qty from FACT_TRANSACTIONS
inner join DIM_MODEL on FACT_TRANSACTIONS.IDModel=DIM_MODEL.IDModel
inner join DIM_DATE on FACT_TRANSACTIONS.Date=DIM_DATE.DATE
where YEAR='2010'
group by YEAR,Model_Name
;
--Q7--END	

--Q8--BEGIN Show the manufacturer with the 2nd top sales in the year of 2009 and themanufacturer with the 2nd top sales in the year of 2010. 
 select top 2 manufacturer_name,year, sum(totalprice) as sales 
 from FACT_TRANSACTIONS
 inner join DIM_MODEL on FACT_TRANSACTIONS.IDModel=DIM_MODEL.IDModel
 inner join DIM_MANUFACTURER on DIM_MODEL.IDManufacturer=DIM_MANUFACTURER.IDManufacturer
 inner join DIM_DATE on FACT_TRANSACTIONS.Date=DIM_DATE.DATE
 where YEAR='2009'
 group by Manufacturer_Name,YEAR
 union 
 select top 2 manufacturer_name,year, sum(totalprice) as sales 
 from FACT_TRANSACTIONS
 inner join DIM_MODEL on FACT_TRANSACTIONS.IDModel=DIM_MODEL.IDModel
 inner join DIM_MANUFACTURER on DIM_MODEL.IDManufacturer=DIM_MANUFACTURER.IDManufacturer
 inner join DIM_DATE on FACT_TRANSACTIONS.Date=DIM_DATE.DATE
 where YEAR='2010'
 group by Manufacturer_Name,YEAR
 order by sales;

--Q8--END
--Q9--BEGIN Show the manufacturers that sold cellphones in 2010 but did not in 2009.
select manufacturer_name from DIM_MANUFACTURER	
inner join DIM_MODEL on DIM_MANUFACTURER.IDManufacturer=DIM_MODEL.IDManufacturer
inner join FACT_TRANSACTIONS on DIM_MODEL.IDModel=FACT_TRANSACTIONS.IDModel
inner join DIM_DATE on FACT_TRANSACTIONS.Date=DIM_DATE.DATE
where YEAR='2010'
except
select manufacturer_name from DIM_MANUFACTURER	
inner join DIM_MODEL on DIM_MANUFACTURER.IDManufacturer=DIM_MODEL.IDManufacturer
inner join FACT_TRANSACTIONS on DIM_MODEL.IDModel=FACT_TRANSACTIONS.IDModel
inner join DIM_DATE on FACT_TRANSACTIONS.Date=DIM_DATE.DATE
where YEAR='2009'


--Q9--END

--Q10--BEGIN Find top 100 customers and their average spend, average quantity by each year. Also find the percentage of change in their spends

SELECT TOP 100
Customer_Name, Year, AverageSpend, AverageQuantity, Difference/PreviousSpend * 100 AS [% of Change in Spend]
FROM(SELECT 
     Customer_Name, YEAR(Date) AS [Year], AVG(TotalPrice) AS [AverageSpend], AVG(Quantity) AS [AverageQuantity],
	 AVG(TotalPrice) - LAG(AVG(TotalPrice)) OVER (PARTITION BY Customer_Name ORDER BY YEAR(Date)) AS [Difference],
	 LAG(AVG(TotalPrice)) OVER (PARTITION BY Customer_Name ORDER BY YEAR(Date)) AS [PreviousSpend]
     FROM DIM_CUSTOMER INNER JOIN FACT_TRANSACTIONS ON DIM_CUSTOMER.IDCustomer = FACT_TRANSACTIONS.IDCustomer
	 GROUP BY Customer_Name, YEAR(Date)) AS [T1]
ORDER BY AverageSpend DESC, AverageQuantity DESC;

 

--Q10--END
use db_SQLCaseStudies;	