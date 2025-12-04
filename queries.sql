---запрос 3: продажи по дням недели в разрезе продавцов
select
concat(em.first_name, ' ', em.last_name) as seller,
sa.day_of_week,
floor(sum(sa.quantity * pr.price)) as income
from employees as em
left join (select
sa.sales_person_id,
sa.product_id,
sa.quantity,
to_char(sa.sale_date - 1, 'd') as num,
to_char(sa.sale_date, 'day') as day_of_week
from sales as sa
order by num) as sa
on em.employee_id = sa.sales_person_id
inner join products as pr on sa.product_id = pr.product_id
group by concat(em.first_name, ' ', em.last_name), sa.day_of_week, sa.num
order by sa.num;