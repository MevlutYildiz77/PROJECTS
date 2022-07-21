use ProjectCustomerRetention




--1. Join all the tables and create a new table called combined_table. (market_fact, cust_dimen, orders_dimen, prod_dimen, shipping_dimen)


select m.Ord_id, m.Prod_id, m.Sales, m.Cust_id, m.Discount, m.Order_Quantity, m.Product_Base_Margin, o.Order_Date, o.Order_Priority, p.Product_Category, p.Product_Sub_Category, c.Customer_Name, c.Province, c.Region, c.Customer_Segment, s.Order_Id,s.Ship_Mode, s.Ship_Date  into combined_table
FROM dbo.market_fact as m
right outer JOIN dbo.orders_dimen as o
on m.Ord_id = o.Ord_id
right outer JOIN dbo.prod_dimen as p
on m.prod_id = p.prod_id
right outer JOIN dbo.cust_dimen as c
on m.Cust_id = c.Cust_id
right outer JOIN dbo.shipping_dimen as s
on m.Ship_id = s.Ship_id





/*
select * into combined_table  from                 

SELECT *
FROM  (dbo.cust_dimen AS A, dbo.market_fact AS B, dbo.orders_dimen AS C, dbo.shipping_dimen AS D, dbo.prod_dimen AS E) AS combined_table

--select * into dbo.combined_table

select * into dbo.combined_table


create table original_table as

select * into original_table

select * from dbo.orders_dimen C,

select * 
from dbo.cust_dimen A, dbo.market_fact B
where A.Cust_id=B.Cust_id
into AB

where AB.Cust_id=C.Cust_id



left outer join dbo.market_fact B 
on A.Cust_id=B.Cust_id

join dbo.orders_dimen C
on B.Ord_id=C.Ord_id

join dbo.shipping_dimen D
on  D.Ship_id=B.Ship_id

join dbo.prod_dimen E
on E.Prod_id=B.Prod_id;



FROM  dbo.cust_dimen A, dbo.market_fact B, dbo.orders_dimen C, dbo.shipping_dimen D, dbo.prod_dimen E AS combined_table;
CREATE TABLE dbo.combined_table AS SELECT *

select * into original
from dbo.cust_dimen A, dbo.market_fact B, 
where A.Cust_id=B.Cust_id

where A.Cust_id=B.Cust_id and B.Ord_id=C.Ord_id and B.Ord_id=C.Ord_id and D.Ship_id=B.Ship_id and E.Prod_id=B.Prod_id



from dbo.cust_dimen A, dbo.market_fact B, dbo.orders_dimen C, dbo.shipping_dimen D, dbo.prod_dimen E
where A.Cust_id=B.Cust_id, B.Ord_id=C.Ord_id, B.Ord_id=C.Ord_id, D.Ship_id=B.Ship_id, E.Prod_id=B.Prod_id;
where A.Cust_id=B.Cust_id and B.Ord_id=C.Ord_id and B.Ord_id=C.Ord_id and D.Ship_id=B.Ship_id and E.Prod_id=B.Prod_id

IF NOT EXISTS(SELECT * FROM sys.columns WHERE Name = 'Cust_id' 
              AND object_id = OBJECT_ID('YourTableName'))
BEGIN
   ALTER TABLE dbo.YourTableName
      ADD ColumnName INT    -- or whatever it is
END



create table dbo.combined_table 
as select Customer_Name, Province, Region, Customer_Segment, Cust_id, Ord_id, Prod_id, Ship_id                 --  Sales, Discount, Order_Quantity, Product_Base_Margin           -- Cust_id,        Order_Date, Order_Priority, Order_id, Order_ID, Ship_Mode, Ship_Date, Ship_id, Product_Category, Product_Sub_Category, Prod_id
from dbo.cust_dime A, dbo.market_fact B                                                                                                                                                --dbo.orders_dimen C, dbo.shipping_dimen D, dbo.prod_dimen E
where A.Cust_id=B.Cust_id;                              -- and B.Ord_id=C.Ord_id and B.Ord_id=C.Ord_id and D.Ship_id=B.Ship_id and E.Prod_id=B.Prod_id;

*/
--///////////////////////


--2. Find the top 3 customers who have the maximum count of orders.


select  top 3 C.Cust_id, count(B.Order_Quantity) as count_of_orders       ---CEVAP DOĞRU
from orders_dimen A
join market_fact B on A.Ord_id=B.Ord_id
join cust_dimen C on B.Cust_id=C.Cust_id
group by C.Cust_id
order by count(B.Order_Quantity) desc;


--/////////////////////////////////



--3.Create a new column at combined_table as DaysTakenForDelivery that contains the date difference of Order_Date and Ship_Date.
--Use "ALTER TABLE", "UPDATE" etc.

alter table combined_table                    --DOĞRU
add DaysTakenForDelivery int;

update combined_table
set DaysTakenForDelivery=datediff(day, Order_Date, Ship_Date)

select *
from combined_table;







--////////////////////////////////////


--4. Find the customer whose order took the maximum time to get delivered.
--Use "MAX" or "TOP"

--CEVAP DOĞRU

select top 1 Cust_id, Customer_Name, Order_Date, Ship_Date, max(DaysTakenForDelivery) as DaysTakenForDelivery
from combined_table
group by Cust_id, Customer_Name, Order_Date, Ship_Date
order by max(DaysTakenForDelivery) desc;



--////////////////////////////////



--5. Count the total number of unique customers in January and how many of them came back every month over the entire year in 2011
--You can use such date functions and subqueries



select MONTH(Order_Date) as [MONTH],                     
count(distinct Cust_id) as MONTHLY_NUM_OF_CUST  
from combined_table
where Cust_id in 
				(select distinct Cust_id
				 from combined_table
				 where Order_Date between '2011-01-01' and '2011-01-31' 
				 group by Cust_id)
				 and  year(Order_date) =2011
				 group by MONTH(Order_Date);







--////////////////////////////////////////////


--6. write a query to return for each user the time elapsed between the first purchasing and the third purchasing, 
--in ascending order by Customer ID
--Use "MIN" with Window Functions



select distinct Cust_id, Order_Date, DenseNumber, FirstOrderDate,
       datediff(DD, FirstOrderDate, Order_Date) as DaysElapsed

from (
	  select Cust_id, Order_Date,
	  min(Order_Date) over (partition by Cust_id order by Order_Date) as FirstOrderDate,
	  DENSE_RANK() over(partition by Cust_id order by Order_Date) as DenseNumber
	  from combined_table) as dates
where DenseNumber =3;





--//////////////////////////////////////

--7. Write a query that returns customers who purchased both product 11 and product 14, 
--as well as the ratio of these products to the total number of products purchased by the customer.
--Use CASE Expression, CTE, CAST AND such Aggregate Functions

select Cust_id,															
sum(CASE WHEN (Prod_id = 'Prod_11') then Order_Quantity else 0 END) as P11,
sum(CASE WHEN Prod_id = 'Prod_14' then Order_Quantity else 0 END) as P14,
sum(Order_Quantity) as TOTAL_PROD,
round(cast(sum(CASE WHEN (Prod_id = 'Prod_11') then Order_Quantity else 0 END) as float) / sum(Order_Quantity), 2) as RATIO_P11,
round(cast(sum(CASE WHEN Prod_id = 'Prod_14' then Order_Quantity else 0 END) as float) /   sum(Order_Quantity), 2) as RATIO_P14
from combined_table
where Cust_id in (
                  select Cust_id
				  from combined_table
				  where Prod_id in ('Prod_11', 'Prod_14')
				  group by Cust_id
				  having count(distinct Prod_id)=2
				  )
group by Cust_id;



--/////////////////



--CUSTOMER RETENTION ANALYSIS



--1. Create a view that keeps visit logs of customers on a monthly basis. (For each log, three field is kept: Cust_id, Year, Month)
--Use such date functions. Don't forget to call up columns you might need later.


create view visit_log as
select Cust_id, year(Order_Date) as [YEAR],     
month(Order_Date) as [MONTH]
from combined_table;


select *
from visit_log
order by Cust_id, [YEAR], [MONTH];


--//////////////////////////////////


--2. Create a view that keeps the number of monthly visits by users. (Separately for all months from the business beginning)
--Don't forget to call up columns you might need later.


create view monthly_visit AS
select Cust_id, year(Order_Date) as year,        
month(Order_Date) as month,
count(Order_Date) NUM_OF_LOG
from combined_table
GROUP BY Cust_id, year(Order_Date), month(Order_Date);

select * from monthly_visit


--//////////////////////////////////


--3. For each visit of customers, create the next month of the visit as a separate column.
--You can number the months with "DENSE_RANK" function.
--then create a new column for each month showing the next month using the numbering you have made. (use "LEAD" function.)
--Don't forget to call up columns you might need later.

create view next_visit as
		select *, lead(current_month) over(Partition by Cust_id order by [YEAR], [MONTH]) as NEXT_VISIT_MONTH
		from(select *, 
		     DENSE_RANK() over(order by [YEAR], [MONTH]) as CURRENT_MONTH 
			 from monthly_visit) as mv

select * from next_visit



--/////////////////////////////////



--4. Calculate the monthly time gap between two consecutive visits by each customer.
--Don't forget to call up columns you might need later.


create view monthly_time_gap as 
select *, NEXT_VISIT_MONTH-CURRENT_MONTH as TIME_GAPS
		  from next_visit


select * from monthly_time_gap







--/////////////////////////////////////////


--5.Categorise customers using time gaps. Choose the most fitted labeling model for you.
--  For example: 
--	Labeled as churn if the customer hasn't made another purchase in the months since they made their first purchase.
--	Labeled as regular if the customer has made a purchase every month.
--  Etc.

SELECT Cust_id, AVG(TIME_GAPS) AS AvgTimeGap,
       CASE WHEN AVG(TIME_GAPS) IS NULL THEN 'Churn'
	    WHEN MAX(TIME_GAPS) = 1 THEN 'regular'
	    ELSE 'irregular'	
       END CUST_LABELS
FROM monthly_time_gap
GROUP BY Cust_id;






--/////////////////////////////////////




--MONTH-W�SE RETENT�ON RATE


--Find month-by-month customer retention rate  since the start of the business.


--1. Find the number of customers retained month-wise. (You can use time gaps)
--Use Time Gaps

select *, count(Cust_id) over(partition by [YEAR], [MONTH]) as RETENSION_MONTH_WISE
from monthly_time_gap
where TIME_GAPS=1
order by Cust_id;



--//////////////////////


--2. Calculate the month-wise retention rate.

--Basic formula: o	Month-Wise Retention Rate = 1.0 * Total Number of Customers in The Previous Month / Number of Customers Retained in The Next Nonth

--It is easier to divide the operations into parts rather than in a single ad-hoc query. It is recommended to use View. 
--You can also use CTE or Subquery if you want.

--You should pay attention to the join type and join columns between your views or tables.


with cte as
     (select [YEAR], [MONTH], count(Cust_id) as PerMonthOfTotalCustomer,
      sum(case when TIME_GAPS=1 then 1 end) as Month_Wise_Retention
      from monthly_time_gap
      group by [YEAR], [MONTH])
select *
from(select [YEAR], [MONTH], lag(RETENTION_RATE) over(order by [YEAR], [MONTH]) AS RETENTION_RATE
     from(select cte.[YEAR], cte.[MONTH],
		 round(cast(cte.Month_Wise_Retention as float) / cte.PerMonthOfTotalCustomer,2) AS RETENTION_RATE
          from cte) as sq) as sq1
where RETENTION_RATE IS NOT NULL




---///////////////////////////////////
--Good luck!




