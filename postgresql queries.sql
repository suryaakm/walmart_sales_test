select * from walmart
--
select count(*) from walmart;


---business problems
--Q.1) find different paymentmethod and number of transactions ,number of qty sold

select payment_method ,
count(*)as no_payments,
sum(quantity)as no_qty_sold
from walmart
group by payment_method


---Q.2)Identify the highest-rated category in each branch , displaying the branch, category
----Avg rating

select *
from
 
(select    
      Branch,
	  category,
	  avg (rating) as avg_rating,
	  rank() over(partition by branch 
	  order by avg (rating) desc) as rank
from walmart
group by 1,2
)
where rank =1

---Q.3) Identify  the business day for each branch on the number of tranaction

select * from
(select branch ,
      to_char( to_date(date,'dd/mm/yy'),'day')as day_name,
	  count(*)as no_transactions,
	  rank() over(partition by branch order by count(*) desc) as rank
from walmart 
group by 1,2
)
where rank =1


---Q.4) calculate the total qantity of items sold par payment method . list payment_method 
---     and  total_qantity

select payment_method,
sum (quantity)as no_qty_sold
from walmart
group by payment_method


---Q.5)determine the average ,minimum ,and maximum rating of category for each city
----   list the city_rating ,min_rating and max_rating

select 
     city,
	 category,
	 min(rating) as min_rating,
	 max(rating) as max_rating,
     avg(rating) as avg_rating
from walmart
group by 1,2

--Q.6)calculate the total profit for each category by considring total_profit as
--    (unit_price * quantity * profit_margin).list category and total_profit,ordered from highest
--    to lowest profit

select 
      category,
	  sum(total) as total_revenue,
	  sum(total * profit_margin) as profit
from walmart
group by 1


---Q.7) determine the most common payment method for each branch.
---     display branch and preferred_payment_method
with cte
as
(select branch,
       payment_method,
	   count(*)as total_trans,
	   rank() over(partition by branch order by count(*)desc)as rank
from walmart
group by 1,2
)
select *
from cte
where rank= 1

---Q.8)category sales into 3 group morning ,afternoon, evening
---    find out each of the shift and number of invoices

select branch,

case when extract (hour from(time:: time)) <12 then 'morning'
     when extract (hour from(time:: time)) between 12 and 17 then 'afternoon'
	 else 'evening'
	 end day_time,
	 count(*)
from walmart
group by 1 ,2
order by 1,3 desc

--Q.9) identify 5 branch with highest decrease ratio in
-- revenue compare to last year (current year 2023 and last year 2022)

---rdr == last_rev-cr_rev/ls_rev *100



--2022 sales

with revenue_2022
as 
(
select 
    branch,
	sum(total)as revenue
from walmart
where extract(year from to_date(date,'dd/mm/yy'))=2022
group by 1
),


revenue_2023 as

(
select 
    branch,
	sum(total )as revenue
    from walmart
    where extract(year from to_date(date,'dd/mm/yy'))=2023
    group by 1
)
select 
ls.branch,
ls.revenue as last_year_revenue,
cs.revenue as cr_year_revenue,
(ls.revenue -cs.revenue):: numeric/ls.revenue::numeric * 100,2 as rev_dec_ratio
from revenue_2022 as ls
join
revenue_2023 as cs
on ls.branch = cs.branch 
where
   ls.revenue > cs.revenue
order by 4 desc 
limit 5