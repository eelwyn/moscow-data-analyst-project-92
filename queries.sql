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
select to_char (sa.sale_date, 'YYYY-MM') as selling_month, count (distinct customer_id) as total_customers,floor (sum(sa.quantity * pr.price)) as income
from sales as sa
inner join products as pr
on sa.product_id = pr.product_id
group by to_char (sa.sale_date, 'YYYY-MM') order by selling_month asc;

--- запрос 3: отчет о покупателях, чья первая покупка была с акционнытми товарами
with bonus_sales as (
select sa.customer_id as customer_id, min(sale_date) as min_sd
from sales as sa 
inner join products as pr
on sa.product_id = pr.product_id
where pr.price = 0
group by sa.customer_id)
select concat (cu.first_name, ' ', cu.last_name) as customer, sa.sale_date, concat (em.first_name, ' ', em.last_name) as seller
from customers as cu 
inner join sales as sa on cu.customer_id = sa.customer_id
inner join employees as em
on em.employee_id = sa.sales_person_id
inner join bonus_sales as bs on sa.customer_id = bs.customer_id
order by sa.customer_id;