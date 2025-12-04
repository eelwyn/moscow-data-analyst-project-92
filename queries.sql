----запрос 1: 10 лучших продавцов по сумме продаж
select
    concat(em.first_name, ' ', em.last_name) as seller,
    count(sa.sales_id) as operations,
    floor(sum(sa.quantity * pr.price)) as income
from employees as em
left join sales as sa on em.employee_id = sa.sales_person_id
inner join products as pr on sa.product_id = pr.product_id
group by concat(em.first_name, ' ', em.last_name)
order by income desc
limit 10;

----запрос 2: продавцы со средней выручкой ниже средней выручки по всем продацам
with seller_avg as (
    select
        sa.sales_person_id,
        floor(avg(sa.quantity * pr.price)) as av_income
    from sales as sa
    inner join products as pr on sa.product_id = pr.product_id
    group by sa.sales_person_id
),

all_avg as (
    select floor(avg(sa.quantity * pr.price)) as avg_income
    from sales as sa
    inner join products as pr on sa.product_id = pr.product_id
)

select
    sa.av_income,
    concat(em.first_name, ' ', em.last_name) as seller
from employees as em
inner join seller_avg as sa on em.employee_id = sa.sales_person_id
cross join all_avg as aa
where sa.av_income < aa.avg_income
order by av_income asc;

---запрос 3: продажи по дням недели в разрезе продавцов
select
    sa.day_of_week,
    concat(em.first_name, ' ', em.last_name) as seller,
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

---запрос 4: количество покупателей в возрастных группах
with customers_age as (
    select
        customer_id,
        case
            when age between '16' and '25' then '16-25'
            when age between '26' and '40' then '26-40'
            when age >= '41' then '40+'
        end as age_category
    from customers
)

select
    ca.age_category,
    count(distinct cu.customer_id) as age_count
from customers_age as ca inner join customers as cu
    on ca.customer_id = cu.customer_id
group by ca.age_category;

--- запрос 5: количество уникальных покупателей и выручка в разрезе месяца и года
select
    to_char(sa.sale_date, 'YYYY-MM') as selling_month,
    count(distinct customer_id) as total_customers,
    floor(sum(sa.quantity * pr.price)) as income
from sales as sa
inner join products as pr
    on sa.product_id = pr.product_id
group by to_char(sa.sale_date, 'YYYY-MM')
order by selling_month asc;

--- запрос 6: отчет о покупателях, чья первая покупка была с акционными товарами
with bonus_sales as (
    select
        sa.customer_id,
        min(sale_date) as sale_date
    from sales as sa
    inner join products as pr
        on sa.product_id = pr.product_id
    where pr.price = 0
    group by sa.customer_id
),

t_final as (
    select
        bs.sale_date,
        concat(cu.first_name, ' ', cu.last_name) as customer,
        concat(em.first_name, ' ', em.last_name) as seller
    from bonus_sales as bs inner join customers as cu
        on bs.customer_id = cu.customer_id
    inner join sales as sa
        on
            bs.customer_id = sa.customer_id and bs.sale_date = sa.sale_date
    inner join employees as em
        on sa.sales_person_id = em.employee_id
    order by bs.customer_id
)

select distinct t.* from t_final as t;
