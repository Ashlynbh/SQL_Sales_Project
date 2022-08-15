-- Inspecting Data 
SELECT * FROM sales_info1;


---checking data type for date column 
---SELECT column_name, data_type FROM information_schema.columns WHERE 
---table_name = 'sales_info1' AND column_name = 'orderdate';

---converting date column from text to datetime

ALTER TABLE sales_info1 ALTER COLUMN orderdate TYPE DATE using to_date(orderdate, 'MM-DD-YYYY');

SELECT * from sales_info1

-- checking unique values 
SELECT distinct status from sales_info1;
SELECT distinct year_id from sales_info1;
SELECT distinct productline from sales_info1;
SELECT distinct country from sales_info1;
SELECT distinct dealsize from sales_info1;
SELECT distinct territory from sales_info1;


--Analysis 
--Sales by product line
SELECT productline, SUM (sales)Revenue
from sales_info1
group by productline
order by 2 desc

-- Year by sales 
select year_id, sum(sales) Revenue
from sales_info1
group by year_id
order by 2 desc

-- why 2005 is so low- did not have a full year revenue
select distinct month_id from sales_info1
where year_id = 2005

-- dealsize by revenue
select dealsize, sum(sales)Revenue
from sales_info1
group by dealsize 

-- what was the best month for sales? How much was earned that month?
select month_id, sum(sales) Revenue, count(ordernumber) Frequency
from sales_info1
where year_id = 2003
group by month_id
order by 2 desc

--November is the most succesful month, what product is selling?
select month_id, productline, sum(sales) Revenue, count (ordernumber) Frequency
from sales_info1
where year_id = 2003 and month_id = 11
group by month_id, productline
order by 3 desc


-- who is the best customer using RFM
drop table if exists rfm_table;
with rfm as 
(
		select 
			  customername,
			  sum(sales) MonetaryValue,
			  avg(sales) AvgMonetaryValue,
			  count(ordernumber) Frequency,
			  max(orderdate) last_order_date,
			  (select max(orderdate) from sales_info1) max_date,
			  (select max(orderdate) from sales_info1) - max(orderdate) AS Recency
		from sales_info1
		group by customername
),
rfm_calc as 
(
	select r.*,
		 NTILE(4) OVER (ORDER BY Recency desc) AS rfm_recency,
		 NTILE(4) OVER (ORDER BY Frequency) AS rfm_frequency,
		 NTILE(4) OVER (ORDER BY MonetaryValue) AS rfm_monetary
	from rfm r
	
)
select 
	c.*, rfm_recency+ rfm_frequency + rfm_monetary as rfm_cell,
	concat_ws('', rfm_recency, rfm_frequency, rfm_monetary) AS rfm_cell_string
into rfm_table
from rfm_calc c

ALTER TABLE rfm_table ALTER COLUMN rfm_cell_string TYPE integer

select * from rfm_table


select customername, rfm_recency, rfm_frequency, rfm_monetary,
		case 
				when rfm_cell_string::integer in (111, 112 , 121, 122, 123, 132, 211, 212, 114, 141) then 'lost_customers'  --lost customers
				when rfm_cell_string::integer in (133, 134, 143, 244, 334, 343, 344, 144) then 'slipping away, cannot lose' -- (Big spenders who haven’t purchased lately) slipping away
				when rfm_cell_string::integer in (311, 411, 331) then 'new customers'
				when rfm_cell_string::integer in (222, 223, 233, 322) then 'potential churners'
				when rfm_cell_string::integer in (323, 333,321, 422, 332, 432) then 'active' --(Customers who buy often & recently, but at low price points)
				when rfm_cell_string::integer in (433, 434, 443, 444) then 'loyal'
			end rfm_segment

from rfm_table

select ordernumber, count(*) rn
from sales_info1
where status = 'Shipped'
group by ordernumber

ALTER TABLE sales_info1 ALTER COLUMN orderdate TYPE VARCHAR
ALTER TABLE sales_info1 ALTER COLUMN productcode TYPE VARCHAR

--What products are most often sold together? 
--select * from [dbo].[sales_data_sample] where ORDERNUMBER =  10411
select distinct orderdate, string_agg(
    (productcode ',')
	from sales_info1 
	where ordernumber in 
	 (
	 select ordernumber 
		 from (
		 select ordernumber, count (*) rn
		 from sales_info1 
		 where status = 'Shipped'
		 group by ordernumber
		 )m
		 where rn = 2
	)
	)
from sales_info1 
order by 2 desc

---EXTRAs----
--What city has the highest number of sales in a specific country
select city, sum (sales) Revenue
from sales_info1
where country = 'UK'
group by city
order by 2 desc



---What is the best product in United States?
select country, year_id, productline, sum(sales) Revenue
from sales_info1
where country = 'USA'
group by  country, year_id, productline
order by 4 desc

ALTER TABLE sales_info1 ALTER COLUMN orderdate TYPE DATE using to_date(orderdate, 'MM-DD-YYYY');

SELECT * from sales_info1

