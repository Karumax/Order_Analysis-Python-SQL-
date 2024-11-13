select* from df_orders


--find top 5 highest selling products in each region
with cte as (
	select region,product_id,sum(sale_price) as sales
	from  df_orders
	group by region,product_id)
select* from (
select*
,rank() over (partition by region order by sales desc) as sales_rank
from cte) A
where sales_rank<=5


--find month over month growth comparison for 2022 and 2023 sales eg : jan 2022 vs jan 2023
with cte as(
select year(order_date) as annual_orders,month(order_date) as monthly_orders,
sum(sale_price) as sales
from df_orders
group by year(order_date),month(order_date)
--order by year(order_date),month(order_date)
	)
select monthly_orders
, sum(case when annual_orders=2022 then sales else 0 end) as sales_2022
, sum(case when annual_orders=2023 then sales else 0 end) as sales_2023
from cte
group by monthly_orders
order by monthly_orders 



--for each category which month had highest sales 
with cte as(
select category,month(order_date) as monthly_order,year(order_date) as annual_order
,sum(sale_price) as sales
from df_orders
group by category,month(order_date) ,year(order_date)
--order by category,year(order_date),month(order_date)
)
select* from(
select*,
rank() over (partition by category order by sales desc) as category_rank
from cte
) a
where category_rank=1


--which sub category had highest growth by profit in 2023 compare to 2022
with cte as (
select sub_category,year(order_date) as order_year,
sum(sale_price) as sales
from df_orders
group by sub_category,year(order_date)
--order by year(order_date),month(order_date)
	)
, cte2 as (
select sub_category
, sum(case when order_year=2022 then sales else 0 end) as sales_2022
, sum(case when order_year=2023 then sales else 0 end) as sales_2023
from cte 
group by sub_category
)
select top 1 *
,(sales_2023-sales_2022)
from  cte2
order by (sales_2023-sales_2022) desc