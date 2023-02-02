
select * from menu;
select * from sales;
select * from members;

--1. What is the total amount each customer spent at the restaurant? DONE
with amount(customer_id, total_amount)
as
(
select s.customer_id, count(s.product_id) * m.price as total_amount from 
sales s join menu m
on s.product_id = m.product_id
group by  s.customer_id, s.product_id, m.price)

select customer_id, sum(total_amount) as total_amount from amount
group by customer_id
;

--2. How many days has each customer visited the restaurant? DONE
select customer_id, count(distinct(order_date)) as days_visited  from sales
group by customer_id;


--3. What was the first item from the menu purchased by each customer? DONE
with date_rank as
(select s.customer_id, s.order_date, m.product_name,
rank() over(partition by s.customer_id order by s.order_date) as [rank]
from sales s
join menu m on
s.product_id = m.product_id)

select customer_id, product_name from date_rank
where rank = 1
;


--4. What is the most purchased item on the menu and how many times was it purchased by all customers? DONE
select s.customer_id, count(s.product_id) as most_purchased_item, m.product_name
from sales s
join menu m
on s.product_id = m.product_id
where s.product_id = (select max(product_id) from sales)
group by s.customer_id, m.product_name;

--5. Which item was the most popular for each customer? DONE
with temp_table(cust_id, prod_name, prod_id, [rank]) as 
(select s.customer_id, m.product_name, s.product_id, 
dense_rank() over (partition by s.customer_id order by count(s.customer_id) desc) as [rank]
from sales s
inner join menu m on s.product_id = m.product_id 
group by s.customer_id, m.product_name, s.product_id)

select cust_id, prod_name
from temp_table
where [rank] = 1
;

--6. Which item was purchased first by the customer after they became a member? DONE

with date_rank as
(select s.customer_id, s.order_date, m.product_name,
rank() over(partition by s.customer_id order by s.order_date) as [rank]
from sales s
join menu m on
s.product_id = m.product_id
join members mem on
mem.customer_id = s.customer_id
where mem.join_date <= s.order_date)

select customer_id, product_name from date_rank
where rank = 1
;

--7. Which item was purchased just before the customer became a member? DOUBT DONE
with date_rank as
(select s.customer_id, s.order_date, m.product_name,
rank() over(partition by s.customer_id order by s.order_date) as [rank]
from sales s
join menu m on
s.product_id = m.product_id
join members mem on
mem.customer_id = s.customer_id
where mem.join_date > s.order_date
)

select customer_id, product_name,
dense_rank() over(partition by customer_id order by order_date desc) as [rank]
from date_rank
where [rank] = 1
;


--8. What is the total items and amount spent for each member before they became a member?


--9. If each $1 spent equates to 10 points and sushi has a 2x points multiplier - how many points would each customer have? DONE
with POINTS as 
(select s.customer_id, m.product_name,
CASE
	WHEN m.product_name = 'sushi' THEN m.price*20 ELSE m.price*10
END as points
from sales s
join menu m 
on s.product_id = m.product_id)

select customer_id, sum(points) as Total_points
from POINTS
group by customer_id
;

--10. In the first week after a customer joins the program (including their join date) they earn 2x points on 
--all items, not just sushi - how many points do customer A and B have at the end of January?

