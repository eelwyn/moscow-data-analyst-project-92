---запрос 1: 10 лучших продавцов по сумме продаж
select concat (em.first_name, ' ', em.last_name) as seller,
count(sa.sales_id) as operations, 
floor(sum (sa.quantity * pr.price)) as income from employees as em
left join sales as sa on em.employee_id = sa.sales_person_id
inner join products as pr on sa.product_id = pr.product_id
group by concat (em.first_name, ' ', em.last_name)
order by income desc
limit 10;

---запрос 2: продавцы со средней выручкой ниже средней выручки по всем продацам
with seller_avg as (
select sa.sales_person_id,
floor (avg(sa.quantity * pr.price)) as average_income
from sales sa
inner join products pr on sa.product_id = pr.product_id
group by sa.sales_person_id
),
all_avg AS (
select 
floor(avg(sa.quantity * pr.price)) as avg_income
from sales sa
inner join products pr on sa.product_id = pr.product_id)
select concat(em.first_name, ' ', em.last_name) as seller,
sa.average_income as average_income
from employees em
inner join seller_avg sa on em.employee_id = sa.sales_person_id
cross join all_avg aa
where sa.average_income < aa.avg_income
order by average_income asc;

---запрос 3: продажи продацом по дням недели
select concat (em.first_name, ' ', em.last_name) as seller,
sa.day_of_week,
floor (sum (sa.quantity * pr.price)) as income 
from employees as em
left join (select to_char (sa.sale_date-1, 'd' ) as num, to_char (sa.sale_date, 'day' ) as day_of_week, sales_person_id, 
product_id, quantity
from sales as sa order by num) as sa 
on em.employee_id = sa.sales_person_id
inner join products as pr on sa.product_id = pr.product_id
group by concat (em.first_name, ' ', em.last_name), sa.day_of_week, sa.num
order by sa.num;
