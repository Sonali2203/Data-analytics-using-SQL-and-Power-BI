create database coffee_shop_sales_db

select * from coffee_shop_sales

describe coffee_shop_sales 

-- To update the date format
update coffee_shop_sales  #changing date type from string to date format
set transaction_date = str_to_date(transaction_date, '%d-%m-%Y');

alter table coffee_shop_sales
modify	column transaction_date date;

describe coffee_shop_sales

update coffee_shop_sales  #changing time type from string to time format
set transaction_time = str_to_date(transaction_time, '%H:%i:%s');

alter table coffee_shop_sales
modify	column transaction_time time;

alter table coffee_shop_sales  #changing id type from string to int format
change column ï»¿transaction_id transaction_id int;

select round(sum(unit_price * transaction_qty),1) as total_sales
from coffee_shop_sales
where month(transaction_date) = 5; #total sales for month of may

select round(sum(unit_price * transaction_qty)) as total_sales
from coffee_shop_sales
where month(transaction_date) = 3; #total sales for month of march

select 
month(transaction_date) as month, -- NUmber of months
	round(sum(unit_price * transaction_qty)) as total_sales, -- Total sales column
	(sum(unit_price * transaction_qty) - lag(sum(unit_price * transaction_qty), 1) -- month sales difference
	over (order by month(transaction_date))) / lag(sum(unit_price * transaction_qty), 1) -- division by previous month sales
	over (order by month(transaction_date)) * 100 as mom_increase_percentage -- percentage
from 
	coffee_shop_sales
where
	month(transaction_date) in (4,5) -- for months of april(previous month-4) amd may(current month-5)
group by
	month(transaction_date)
order by
	month(transaction_date);
    
select * from coffee_shop_sales

select count(transaction_id) as total_orders
from coffee_shop_sales
where month(transaction_date) = 3; -- total orders of month of march, similarly we can do for other months by changing the number e.g. 5 for may

select 
month(transaction_date) as month, -- NUmber of months
	round(count(transaction_id)) as total_orders, -- Total orders column
	(count(transaction_id) - lag(count(transaction_id), 1) -- month orders difference
	over (order by month(transaction_date))) / lag(count(transaction_id), 1) -- division by previous month sales
	over (order by month(transaction_date)) * 100 as mom_increase_percentage -- percentage
from 
	coffee_shop_sales
where
	month(transaction_date) in (4,5) -- for months of april(previous month-4) amd may(current month-5)
group by
	month(transaction_date)
order by
	month(transaction_date);
    
select sum(transaction_qty) as total_quantity_sold -- total quantity sold
from coffee_shop_sales
where month(transaction_date) = 5;


select 
month(transaction_date) as month, -- NUmber of months
	round(sum(transaction_qty)) as total_quantity_sold, -- Total quantity sold column
	(sum(transaction_qty) - lag(sum(transaction_qty), 1) -- month orders difference
	over (order by month(transaction_date))) / lag(sum(transaction_qty), 1) -- division by previous month sales
	over (order by month(transaction_date)) * 100 as mom_increase_percentage -- percentage
from 
	coffee_shop_sales
where
	month(transaction_date) in (4,5) -- for months of april(previous month-4) amd may(current month-5)
group by
	month(transaction_date)
order by
	month(transaction_date);
    
select 
	concat(round(sum(unit_price * transaction_qty)/1000,1), 'k') as total_sales,
    concat(round(sum(transaction_qty)/1000,1), 'k') as total_qty_sold,
    concat(round(count(transaction_id)/1000,1), 'k') as total_orders
from coffee_shop_sales
where transaction_date = '2023-05-18';
    
    
    -- to show total sales on weekends and weekdays
select
		case when dayofweek(transaction_date) in (1,7) then 'weekends'
        else 'weekdays'
        end as day_type,
        concat(round(sum(unit_price * transaction_qty)/1000, 1), 'k') as total_sales
from coffee_shop_sales
where month(transaction_date) = 5
group by
		case when dayofweek(transaction_date) in (1,7) then 'weekends'
		else 'weekdays'
		end;

-- total sales for each store
select
store_location,
concat(round(sum(unit_price * transaction_qty)/1000, 1), 'k') as total_sales
from coffee_shop_sales
where month(transaction_date) = 5
group by store_location
order by sum(unit_price * transaction_qty) desc;

-- avg of sales for each month using inner and uter query e.g 5 for may
select concat(round(avg(total_sales)/1000, 1),'k') as avg_sales
from
	(
    select sum(transaction_qty * unit_price) as total_sales
    from coffee_shop_sales
    where month(transaction_date) = 5
    group by transaction_date
    ) as inner_query;
 
 
-- sales for each day of a month
select
day(transaction_date),
concat(round(sum(unit_price * transaction_qty)/1000, 1), 'k') as total_sales
from coffee_shop_sales
where month(transaction_date) = 5
group by day(transaction_date)
order by day(transaction_date) ;

-- to show sales are either above or below average for each day of the month
SELECT
day_of_month,
CASE
WHEN total_sales > avg_sales THEN 'Above Average'
WHEN total_sales < avg_sales THEN 'Below Average'
ELSE 'Average'
END AS sales_status,
total_sales
FROM (
SELECT
DAY(transaction_date) AS day_of_month,
SUM(unit_price * transaction_qty) AS total_sales,
AVG(SUM(unit_price * transaction_qty)) OVER () AS avg_sales
FROM
coffee_shop_sales
WHERE
MONTH(transaction_date) = 5 -- Filter for May
GROUP BY
DAY(transaction_date)
) AS sales_data
ORDER BY
day_of_month;

-- total sales according to product category
select 
	product_category,
    concat(round(sum(unit_price * transaction_qty)/1000, 1), 'k') as total_sales
from coffee_shop_sales
where month(transaction_date) = 5
group by product_category
order by sum(unit_price * transaction_qty) desc;

-- for top 10 product type
select 
	product_type,
    concat(round(sum(unit_price * transaction_qty)/1000, 1), 'k') as total_sales
from coffee_shop_sales
where month(transaction_date) = 5 
group by product_type
order by sum(unit_price * transaction_qty) desc
limit 10;

-- sales analysis by days and hours
SELECT
ROUND(SUM(unit_price * transaction_qty)) AS Total_Sales,
SUM(transaction_qty) AS Total_Quantity,
COUNT(*) AS Total_Orders
FROM
coffee_shop_sales
WHERE
DAYOFWEEK(transaction_date) = 3 -- Filter for Tuesday (1 is Sunday, 2 is Monday, ..., 7 is Saturday)
AND HOUR(transaction_time) = 8 -- Filter for hour number 8
AND MONTH(transaction_date) = 5; -- Filter for May (month number 5)

-- sales for all hours for the month
SELECT
HOUR(transaction_time) AS Hour_of_Day,
ROUND(SUM(unit_price * transaction_qty)) AS Total_Sales
FROM
coffee_shop_sales
WHERE
MONTH(transaction_date) = 5 -- Filter for May (month number 5)
GROUP BY
HOUR(transaction_time)
ORDER BY
HOUR(transaction_time);

-- to get sales from monday to sunday for the required month
SELECT
CASE
WHEN DAYOFWEEK(transaction_date) = 2 THEN 'Monday'
WHEN DAYOFWEEK(transaction_date) = 3 THEN 'Tuesday'
WHEN DAYOFWEEK(transaction_date) = 4 THEN 'Wednesday'
WHEN DAYOFWEEK(transaction_date) = 5 THEN 'Thursday'
WHEN DAYOFWEEK(transaction_date) = 6 THEN 'Friday'
WHEN DAYOFWEEK(transaction_date) = 7 THEN 'Saturday'
ELSE 'Sunday'
END AS Day_of_Week,
ROUND(SUM(unit_price * transaction_qty)) AS Total_Sales
FROM
coffee_shop_sales
WHERE
MONTH(transaction_date) = 5 -- Filter for May (month number 5)

GROUP BY
CASE
WHEN DAYOFWEEK(transaction_date) = 2 THEN 'Monday'
WHEN DAYOFWEEK(transaction_date) = 3 THEN 'Tuesday'
WHEN DAYOFWEEK(transaction_date) = 4 THEN 'Wednesday'
WHEN DAYOFWEEK(transaction_date) = 5 THEN 'Thursday'
WHEN DAYOFWEEK(transaction_date) = 6 THEN 'Friday'
WHEN DAYOFWEEK(transaction_date) = 7 THEN 'Saturday'
ELSE 'Sunday'
END;
