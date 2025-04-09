#TASK 1

select distinct market
from dim_customer
where customer = "Atliq Exclusive"
and region = "APAC";

#Task 2

with X as 
         ( Select Count(distinct product_code) as unique_products_2020
           from fact_sales_monthly 
           where fiscal_year= 2020),
	Y as 
          ( Select Count(distinct product_code) as unique_products_2021
           from fact_sales_monthly 
           where fiscal_year= 2021)
Select 
      X.unique_products_2020,
      Y.unique_products_2021,
      round(((Y.unique_products_2021-X.unique_products_2020)/X.unique_products_2020)*100,2)
      as Percentage_change from X,Y;
      
#Task3

select segment , count(distinct product_code) as product_count
from dim_product
group by segment
order by product_count DESC;

#Task4

With X as 
         (Select p.segment , 
          count(distinct s.product_code) as product_count_2020 
          from dim_product p
          join fact_sales_monthly s on p.product_code = s.product_code
          where s.fiscal_year = 2020 group by p.segment),
	Y as 
        (Select p.segment , 
          count(distinct s.product_code) as product_count_2021 
          from dim_product p
          join fact_sales_monthly s on p.product_code = s.product_code
          where s.fiscal_year = 2021 group by p.segment)
select x.segment , product_count_2020 , 
       product_count_2021 , abs(x.product_count_2020 - y.product_count_2021) as difference
from x join y on x.segment = y.segment order by difference desc;

#Task5

Select m.product_code, p.product, m.manufacturing_cost
from fact_manufacturing_cost m join dim_product p 
using(product_code)
where m.manufacturing_cost = 
(select max(manufacturing_cost)
 from fact_manufacturing_cost )  or
 m.manufacturing_cost =
 (select min(manufacturing_cost)
 from fact_manufacturing_cost)
 order by m.manufacturing_cost desc;
 
 #task6 
 
 select i.customer_code , c.customer,
 round(avg(i.pre_invoice_discount_pct)*100,2) as avg_dis_pct
 from fact_pre_invoice_deductions i 
 join dim_customer c using(customer_code)
 where fiscal_year = 2021 and c.market="India"
 group by i.customer_code , c.customer
 order by avg_dis_pct Desc
 limit 5;
 
 #task7
 
 Select monthname(s.date), s.fiscal_year , 
 round(sum(g.gross_price*sold_quantity),2)
 as gross_sales_amt from fact_sales_monthly s
 join dim_customer c using(customer_code)
 join fact_gross_price g using(product_code)
 where customer = "Atliq Exclusive"
 group by monthname(s.date), s.fiscal_year
 order by fiscal_year;
 
 #task8
 
 select
 case 
      when month(date) in (9,10,11) then "Q1"
      when month(date) in (12,1,2) then "Q2"
      when month(date) in (3,4,5) then "Q3"
      else "Q4"
End as Quarters,
Sum(sold_quantity) as total_sold_qty
from fact_sales_monthly
where fiscal_year=2020
group by Quarters
order by total_sold_qty DESC;

#task9

with X as 
     ( select c.channel,
	   round(sum(g.gross_price*s.sold_quantity)/100000,2) as gross_sales_mln
       from fact_sales_monthly s
       join dim_customer c using(customer_code)
       join fact_gross_price g using(product_code)
	   where s.fiscal_year=2021
       group by c.channel)
select channel, gross_sales_mln,
round((gross_sales_mln/(select sum(gross_sales_mln)from x))*100,2)
as pct from X
order by gross_sales_mln Desc;

#task10

With X as 
(
Select P.division, S.product_code, P.product, Sum(S.sold_quantity) as Total_sold_quantity,
Rank() Over(Partition By P.division Order By Sum(S.sold_quantity) DESC) as "Rank_Order"
from dim_product P Join fact_sales_monthly S
on P.product_code = S.product_code
where S.fiscal_year = 2021
Group by P.division,S.product_code,P.product )

Select * from X
where Rank_Order In (1,2,3) order by division ,Rank_Order;    