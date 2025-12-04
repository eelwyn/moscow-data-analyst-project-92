---запрос 1: количество покупателей в возрастных группах
with customers_age as (
select customer_id, case
	when age between '16' and '25' then '16-25'
	when age between '26' and '40' then '26-40'
	when age >= '41' then '40+'
end age_category
from customers)
select ca.age_category, count(distinct cu.customer_id) as age_count
from customers_age as ca inner join customers as cu
on ca.customer_id = cu.customer_id
group by ca.age_category;

--- запрос 2: количество уникальных покупателей и выручка в разрезе месяца и года
select to_char (sa.sale_date, 'YYYY-MM') as selling_month, 
count (distinct customer_id) as total_customers,
floor (sum(sa.quantity * pr.price)) as income
from sales as sa
inner join products as pr
on sa.product_id = pr.product_id
group by to_char (sa.sale_date, 'YYYY-MM') order by selling_month asc;

--- запрос 3: отчет о покупателях, чья первая покупка была с акционными товарами
with bonus_sales as (
select sa.customer_id as customer_id, min(sale_date) as sale_date
from sales as sa 
inner join products as pr
on sa.product_id = pr.product_id
where pr.price = 0
group by sa.customer_id)
select distinct
concat (cu.first_name, ' ', cu.last_name) as customer, bs.sale_date, concat (em.first_name, ' ', em.last_name) as seller
from bonus_sales as bs inner join customers as cu 
on cu.customer_id = bs.customer_id
inner join sales as sa on 
sa.customer_id = bs.customer_id and sa.sale_date = bs.sale_date
inner join employees as em
on em.employee_id = sa.sales_person_id
order by customer;

select count (distinct c.customer_id )
from customers c 
limit 100



