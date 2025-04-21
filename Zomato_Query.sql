CREATE TABLE goldusers_signup(userid integer,gold_signup_date date); INSERT INTO goldusers_signup(userid,gold_signup_date) VALUES (1,'2017-09-22'), (3,'2017-04-21'); CREATE TABLE product(product_id integer,product_name text,price integer);
CREATE TABLE users(userid integer,signup_date date); INSERT INTO users(userid,signup_date) VALUES (1,'2014-02-09'), (2,'2014-01-15'), (3,'2014-04-11'); INSERT INTO product(product_id,product_name,price) VALUES (1,'p1',980), (2,'p2',870), (3,'p3',330); select * from product; CREATE TABLE sales(userid integer,created_date date,product_id integer);
INSERT INTO sales(userid,created_date,product_id) VALUES (1,'2017-04-19',2), (3,'2019-12-18',1), (2,'2020-07-20',3), (1,'2019-10-23',2), (1,'2018-03-19',3), (3,'2016-12-20',2), (1,'2016-11-09',1), (1,'2016-05-20',3), (2,'2017-09-24',1), (1,'2017-03-11',2), (1,'2016-03-11',1), (3,'2016-11-10',1), (3,'2017-12-07',2), (3,'2016-12-15',2), (2,'2017-11-08',2), (2,'2018-09-10',3);
--users 
select * from users; 
--goldusers_signup 
select * from goldusers_signup; 
--product
 select * from product; 
 --sales
  select * from sales;
-- 1)Total number of Customers in Zomato? 
select count(distinct userid) from users; 
--2)Total amout spent by each customer on Zomato? 
select a.userid,sum(b.price) from sales as a inner join product as b on a.product_id=b.product_id group by a.userid order by userid asc;
--3)How many days each customer visited zomato?
 select userid,count(DISTINCT created_date) as no_of_days FROM sales group by userid
--4)What was the first product purchased by each user? 
select * from (select *,rank() over (PARTITION BY userid ORDER BY created_date) as  rnk from sales) as subquery where  rnk=1; 
--📌Data-Driven Recommendations for Zomato: 
--i. If a user’s first purchase was a specific cuisine (e.g., Italian food), Zomato can send them personalized offers or recommend similar restaurants. --   They can use this data to create a "first-order favorites" campaign, highlighting popular first purchases.
--ii.If a user’s first purchase was a specific cuisine (e.g., Italian food), Zomato can send them personalized offers or recommend similar restaurants. --   They can use this data to create a "first-order favorites" campaign, highlighting popular first purchases.
--5)What is the most purchased item in menu.
 --how many times it was purchased by each user? 
 select userid, count(product_id)  from sales where product_id = (select product_id from sales group by product_id order by count(product_id) desc limit 1) group by userid order by userid;
  --📌Data-Driven Recommendations for Zomato:
   --i.Suggest similar dishes based on purchase patterns. 
   --ii.Offer discounts on related meals to enhance user retention. 
   --iii. Analyze cuisine preferences across different user regions for better restaurant partnerships.
--6) Which item is the most popular item for each user? 
select * FROM (select *,rank() over (PARTITION BY userid ORDER BY product_id desc) as rnk FROM (select userid,product_id,count(product_id) as cnt from sales GROUP BY userid,product_id) a)b where rnk=1;
 --📌Data-Driven Recommendations for Zomato: 
 --i.Suggest similar items based on user prefernces 
 --ii.Offer combo deals featuring their most-purchased product. 
 --iii.Send exclusive discounts for frequently purchased items
--7) Whic item was first purchased by user after they became a member? 
select * from ( select c.*,ROW_NUMBER() over (PARTITION BY userid ORDER BY created_date)  rnk
 from (select a.userid,a.created_date,b.gold_signup_date from sales a inner join 
 goldusers_signup b on a.userid=b.userid where a.created_date>=b.gold_signup_date) as c) as d where rnk=1;
--8)Whic item purchased by user before they became a member? 
select * from ( select c.*,ROW_NUMBER() over (PARTITION BY userid ORDER BY created_date desc)  rnk 
from (select a.userid,a.created_date,b.gold_signup_date from sales a inner join 
goldusers_signup b on a.userid=b.userid where a.created_date<=b.gold_signup_date) as c) as d where rnk=1;
--9)What is the total number of orders and amount spent by user before they became a member?
 SELECT userid,count( created_date) as total_num_of_orders,sum( price) as total_price from (select c.*,d.price FROM (select a.userid,a.created_date,a.product_id,b.gold_signup_date from 
 sales a inner join goldusers_signup b on a.userid=b.userid where a.created_date<=b.gold_signup_date)as c 
 inner join product as d on c.product_id=d.product_id )e group by userid; 
 --10)Rank all the transcations of the Customers ?
  select *,rank() over (PARTITION BY userid ORDER BY created_date) rnk from sales ;
--11)If buying a each product generates a point for eg 5rs=2 zomato point and each point has diferent purchasing points for p1 5rs=1 zomato point,for p2 10rs=5 zomato points and p3 5rs=1 zomato point 2rs=1 zomato point --calculates point collected by each customer and for which product have most points till now
select userid,sum(total_points)2.5 as total_money_earned from (select e.,amt/points as total_points  from (select d.,case when product_id=1 then 5 when product_id=2 then 2 when product_id=3 then 5 else 0 end as points from (select c.userid,c.product_id,sum(price) as amt from (select a.,b.price from sales a inner join product b on a.product_id=b.product_id ) c group by userid,product_id )d) e)f group by userid; 
--12)what is best-selling product category based on revenue? 
select product_name,sum(price) as total_revenue 
from sales inner join product ON sales.product_id=product.product_id 
group by product_name order by total_revenue desc;
 --📌Use Case:
 --Identify the most profitable product for pricing and promotions
--13)How many users have made purchases more than once?
select userid,count(DISTINCT created_date) as purchase_count 
from sales
 group by userid having purchase_count>1; 
--📌Use Case:
--Identify loyal customers and target them with discounts or membership perks.
--14)Ranking customers according to their purchasecount? 
select userid,rank() over ( ORDER BY purchase_count desc) 
FROM 
(select userid,count(DISTINCT created_date) as purchase_count from sales
 group by userid having purchase_count)c; 
 --📌Use Case:
 --Identify highly active users who place orders frequently and reward them with loyalty points or exclusive discounts.
--15)Ranking products based on their total sale volume?
SELECT c.*, RANK() OVER (ORDER BY total_sales DESC) AS product_rank 
FROM (
    SELECT b.product_name, COUNT(*) AS total_sales  
    FROM sales a 
    INNER JOIN product b ON a.product_id = b.product_id 
    GROUP BY b.product_name 
    ORDER BY b.product_name ASC
) c 
ORDER BY c.product_name;
 
--📌Use Case:
--i.Understand which product is most popular among customers.
--ii.Helps businesses prioritize stocking and promotions for high-demand items. 
--iii.If a product ranks consistently high, you can increase its price slightly to maximize revenue.
 --iv.For lower-ranked products, discounts or bundling can help boost sales.
--16) Peak Purchase Months: When do users buy the most?
 select Extract(Month from created_date) as purchase_month,count(*) 
 as total_orders from sales 
 group by purchase_month order by purchase_month asc;
--📌Use Case: 
-- Identify seasonal trends in purchases and plan marketing campaigns accordingly.
--📌Conclusion for Your Zomato Sales Analysis Project --My project provides a comprehensive and insightful analysis 
--of Zomato's sales data, focusing on customer behavior, --product performance, and business optimization strategies.
--With 16 well-crafted SQL queries, you've successfully captured key aspects such as purchase trends,
--loyalty segmentation, revenue insights, and personalized recommendations—making it highly valuable for decision-making.
--is this report for this qeries are good or can I do any improvemnrt rank my project aslo
