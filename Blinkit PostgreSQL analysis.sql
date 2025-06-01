create table customer(
   C_ID varchar(300) primary key ,	
   CName char(200),	
   email varchar(400),
   gender char(100),
   Age int,
   City char(200),
   States char(200),
   Address varchar(500),
   created_date date );

create table product( 
   P_ID	varchar(300) primary key,
   PName char(250),
   Category char(250),
   Brand varchar(260),
   Price float );

create table orders(
  Or_ID	varchar(300) primary key,
  C_ID varchar(300),
  P_ID varchar(300),
  Order_Date date,
  Order_Time time,
  Qty int,
  Coupon varchar(250),
  Coupon_Discount float,
  DP_ID varchar(300) );

create table transactions( 
   Tr_ID varchar(300) primary key,
   Or_ID varchar(300),
   Transaction_Mode char(250),
   Rewards char(200) );

create table rating( 
   RT_ID varchar(300)primary key,
   Or_ID varchar(300),
   Prod_Rating float,
   Delivery_Service_Rating float );

create table delivery( 
   DP_ID varchar(300) primary key,
   DP_name char(250),
   DP_Ratings float,
   Percent_Cut float );

/* Column Changes */
alter table orders add constraint c_fk foreign key (C_ID) references customer(C_ID), add constraint p_fk foreign key (P_ID) references product(P_ID),
add constraint dp_fk foreign key (DP_ID) references delivery(DP_ID);
alter table transactions add constraint o_fk foreign key (Or_ID) references orders(Or_ID);
alter table rating add constraint o_fk2 foreign key (Or_ID) references orders(Or_ID); 
alter table customer add column Tier varchar(200);
alter table customer add column Region char(200);

/* Import Data */
copy customer from 'C:\Capstone Project\Blinkit Tableau and Postgre SQL Analysis\Import File\CustomerX.csv'  delimiter ','  csv header;
copy product from 'C:\Capstone Project\Blinkit Tableau and Postgre SQL Analysis\Import File\ProductX.csv'  delimiter ','  csv header;
copy orders from 'C:\Capstone Project\Blinkit Tableau and Postgre SQL Analysis\Import File\OrdersX.csv'  delimiter ','  csv header;
copy transactions from 'C:\Capstone Project\Blinkit Tableau and Postgre SQL Analysis\Import File\TransactionX.csv'  delimiter ','  csv header;
copy rating from 'C:\Capstone Project\Blinkit Tableau and Postgre SQL Analysis\Import File\RatingX.csv'  delimiter ','  csv header;
copy delivery from 'C:\Capstone Project\Blinkit Tableau and Postgre SQL Analysis\Import File\DeliveryX.csv'  delimiter ','  csv header;

update  customer set tier =
case 
when city in ('Mumbai', 'Delhi', 'Bangalore', 'Hyderabad', 'Chennai', 'Kolkata', 'Pune', 'Ahmedabad') then 'Tier 1'
when city in ( 'Jaipur', 'Surat', 'Lucknow', 'Kanpur', 'Nagpur', 'Visakhapatnam', 'Bhopal','Patna', 'Ludhiana', 'Agra', 'Vadodara', 'Nashik', 
                'Rajkot', 'Amritsar','Varanasi', 'Allahabad', 'Ranchi', 'Coimbatore', 'Jabalpur', 'Guwahati',
                 'Chandigarh', 'Thiruvananthapuram', 'Madurai', 'Gurgaon', 'Noida', 'Faridabad') then 'Tier 2'
when city in (  'Vijayawada', 'Raipur', 'Kollam', 'Tiruchirappalli', 'Jodhpur', 'Salem', 'Gaya', 'Udaipur', 'Hubli', 'Mysore', 
                 'Tirupati', 'Jamshedpur', 'Dhanbad', 'Bhavnagar', 'Bilaspur', 'Warangal', 'Bhagalpur', 'Nellore', 'Jalandhar',
                 'Bhilai', 'Guntur', 'Ajmer', 'Howrah', 'Kolhapur', 'Tirunelveli', 'Dehradun','Bareilly', 'Kozhikode', 'Mangalore', 
				 'Belgaum', 'Durgapur', 'Silchar', 'Muzaffarpur', 'Panipat', 'Asansol', 'Durg', 'Bokaro', 'Bhiwani') then 'Tier 3'
else 'Tier 4' end;
update customer set region =
case 
when states in ( 'Bihar', 'Jharkhand', 'Odisha', 'West Bengal', 'Chhattisgarh', 'Assam' ) then 'East'
when states in ( 'Rajasthan', 'Gujarat', 'Maharashtra') then 'West'
when states in ( 'Haryana', 'Punjab', 'Uttar Pradesh', 'Madhya Pradesh') then 'North'
else 'South' end;

select * from customer;
select * from product;
select * from orders;
select * from transactions;
select * from rating;
select * from delivery;


/* BASIC ANALYSIS */
/* A. Customer Analysis */
-- 1.	How are customers buying by gender across states, and what is the ratio of male to female customers?
with MF_ratio as 
(select c.states,sum(case when c.gender='Male' then 1 else 0 end) as Male, sum(case when c.gender='Female' then 1 else 0 end) as Female
from customer as c join orders as o on o.c_id=c.c_id group by c.states)
select *, round(Male/Female::numeric,2)  as MF_Ratio from MF_ratio;

-- 2.	What are the youngest and oldest customers (based on Age Group) in each city, and how many customers are there per city, along with average spending?
with overall_cust as 
(select * from 
(with cust_total as 
(with cust_age as
(with customer as 
(select *, case when age between 18 and 25 then '18-25' when age between 26 and 35 then '26-35' when age between 36 and 45 then '36-45' when age
between 46 and 60 then '46-60' else '>60' end as Age_grp from customer)
select c.city,c.Age_grp, count(c.C_ID) as Total_Customers,concat('₹ ',round((avg(p.price)*avg(o.qty)*(1-avg(coupon_discount)/100))::numeric,2)) as 
Avg_Spending from customer as c join
orders as o on o.c_id=c.c_id join product as p on p.p_id=o.p_id group by c.city,c.Age_grp order by c.city)
select *, row_number() over(partition by city order by total_customers desc) as ranks  from cust_age)
select * from cust_total where ranks=1) union all
select * from 
(with cust_total as 
(with cust_age as
(with customer as 
(select *, case when age between 18 and 25 then '18-25' when age between 26 and 35 then '26-35' when age between 36 and 45 then '36-45' when age
between 46 and 60 then '46-60' else '>60' end as Age_grp from customer)
select c.city,c.Age_grp, count(c.C_ID) as Total_Customers,concat('₹ ',round((avg(p.price)*avg(o.qty)*(1-avg(coupon_discount)/100))::numeric,2)) as 
Avg_Spending from customer as c join
orders as o on o.c_id=c.c_id join product as p on p.p_id=o.p_id group by c.city,c.Age_grp order by c.city)
select *, row_number() over(partition by city order by total_customers asc) as ranks  from cust_age)
select * from cust_total where ranks=1))
select city,age_grp,total_customers,avg_spending from overall_cust order by city asc , total_customers desc;

-- 3.	Which cities have the most and fewest young customers (all young customers under 25) and divide it by gender,statewise ?
with city_max_min as
(select * from 
(with max_city as
(with city_max as
(with c_max as
(select c.states,c.city,sum(case when c.gender='Male' then 1 else 0 end ) as Male , sum(case when c.gender='Female' then 1 else 0 end) as Female from 
customer as c join orders as o on o.c_id=c.c_id where c.age<=25  group by c.states,c.city) 
select *,Male+Female as Total_Customers from c_max)
select * , row_number() over( partition by states order by total_customers desc ) as ranks from city_max)
select * from max_city where ranks=1) union all 
select * from 
(with min_city as
(with city_min as
(with c_min as
(select c.states,c.city,sum(case when c.gender='Male' then 1 else 0 end ) as Male , sum(case when c.gender='Female' then 1 else 0 end) as Female from 
customer as c join orders as o on o.c_id=c.c_id where c.age<=25  group by c.states,c.city) 
select *,Male+Female as Total_Customers from c_min)
select * , row_number() over( partition by states order by total_customers asc ) as ranks from city_min)
select * from min_city where ranks=1) )
select states,city,male,female,total_customers from  city_max_min order by states ;

-- 4.	Which states have the highest number of customers, also divide by quarter by quarter (top 15)?
with city_qtr as 
(with orders as 
(select *, concat('Qtr ',extract('quarter' from order_date)) as quarter from orders)
select c.states, sum(case when quarter='Qtr 1' then 1 else 0 end) as Qtr_1,sum(case when quarter='Qtr 2' then 1 else 0 end) as Qtr_2,
sum(case when quarter='Qtr 3' then 1 else 0 end) as Qtr_3,sum(case when quarter='Qtr 4' then 1 else 0 end) as Qtr_4
from orders as o join customer as c on c.c_id=o.c_id group by c.states) select *,Qtr_1+Qtr_2+Qtr_3+Qtr_4 as Total_cust from city_qtr
order by total_cust desc limit 15;

-- 5.	How does the percentage of all gender based customers change monthly compared to the previous month?
with Male_Female_Change as
(with MF_Count as
(select months,Male,lag(Male,1,0) over() as Male_pre,Female,lag(Female,1,0) over() as Female_pre from 
(with orders as (select *,  to_char(order_date,'month') as Months , extract('month' from order_date) as Month_N from orders)
select Months,Month_N,sum(case when gender='Male' then 1 else 0 end) as Male,sum(case when gender='Female' then 1 else 0 end) as Female
from orders as o join customer as c on c.c_id=o.c_id group by Months,Month_N order by month_n) as ranks)
select months, Male, Male_Pre,
case when Male_Pre IS NULL OR Male_Pre = 0 then '0' else to_char(round(((Male - Male_Pre)::numeric / Male_Pre) * 100, 2), 'FM999999.00') 
end as "% Male Change",
Female,Female_Pre,
case when Female_Pre isnull or Female_Pre=0 then '0' else to_char(round(((Female-Female_Pre)::numeric/Female_Pre)*100,2),'FM999999.00')
end  as "% Female Change"
from MF_Count) select months, "% Male Change","% Female Change" from  Male_Female_Change;

-- 6.	Which state has customers with the widest  average spending for
with min_val as
(select c.states,round( (min(p.price)*min(o.qty)*(1-min(o.coupon_discount)/100))::numeric,2) as min_spending 
from customer as c join orders as o on
o.c_id=c.c_id join product as p on p.p_id=o.p_id   group by c.states),
max_val as
(select c.states, round((max(p.price)*max(o.qty)*(1-max(o.coupon_discount)/100))::numeric,2) as max_spending 
from customer as c join orders as o on
o.c_id=c.c_id join product as p on p.p_id=o.p_id  group by c.states)
select mn.states, concat(mn.min_spending,' - ',mx.max_spending) as spending_range from
min_val as mn join max_val as mx on mn.states=mx.states;

-- 7.   Divide the customer into different age group and count their based on each city and identify top 20
with c_max as
(with customer as
(select *, case when age between 18 and 25 then '18-25' when age between 26 and 35 then '26-35' when age between 36 and 45 then '36-45' when age
between 46 and 60 then '46-60' else '>60' end as Age_grp from customer )
select c.city,sum(case when c.Age_grp ='18-25' then 1 else 0 end) as "Age 18-25",sum(case when c.Age_grp ='26-35' then 1 else 0 end) as "Age 26-35",
sum(case when c.Age_grp ='36-45' then 1 else 0 end) as "Age 36-45",sum(case when c.Age_grp ='46-60' then 1 else 0 end) as "Age 46-60",
sum(case when c.Age_grp ='>60' then 1 else 0 end) as "Age >60" from customer as c join orders as o on c.c_id=o.c_id group by c.city)
select *, "Age 18-25"+"Age 26-35"+"Age 36-45"+"Age 46-60"+"Age >60" as total_customer from c_max order by total_customer desc limit 20;

-- 8.	Group customers into age brackets (e.g., 18–25, 26–35) and count how many fall into each bracket by brand, along with average spending.
with customer as
(select *, case when age between 18 and 25 then '18-25' when age between 26 and 35 then '26-35' when age between 36 and 45 then '36-45' when age
between 46 and 60 then '46-60' else '>60' end as Age_grp from customer )
select p.brand,sum(case when c.Age_grp ='18-25' then 1 else 0 end) as "Customer 18-25",
round(avg(case when c.Age_grp ='18-25' then p.price*o.qty*(1-o.coupon_discount/100) else 0 end)::numeric,2) as "Spending 18-25",
sum(case when c.Age_grp ='26-35' then 1 else 0 end) as "Customer 26-35",
round(avg(case when c.Age_grp ='26-35' then p.price*o.qty*(1-o.coupon_discount/100) else 0 end)::numeric,2) as "Spending 26-35",
sum(case when c.Age_grp ='36-45' then 1 else 0 end) as "Customer 36-45",
round(avg(case when c.Age_grp ='36-45' then p.price*o.qty*(1-o.coupon_discount/100) else 0 end)::numeric,2) as "Spending 36-45",
sum(case when c.Age_grp ='46-60' then 1 else 0 end) as "Customer 46-60",
round(avg(case when c.Age_grp ='46-60' then p.price*o.qty*(1-o.coupon_discount/100) else 0 end)::numeric,2) as "Spending 46-60",
sum(case when c.Age_grp ='>60' then 1 else 0 end) as "Customer >60",
round(avg(case when c.Age_grp ='>60' then p.price*o.qty*(1-o.coupon_discount/100) else 0 end)::numeric,2) as "Spending >60"
from customer as c join orders as o on o.c_id=c.c_id join product as p on p.p_id=o.p_id group by p.brand ;

-- 9.	Who are the top 50 customers with the most favourite brand, orders and average spending,based on spending ?
with net_customer as 
(with c_brand as
(select c.cname,p.brand,count(o.or_id) as total_orders,sum(o.qty) as quantity
,round((avg(p.price)*avg(o.qty)*avg(1-o.coupon_discount/100))::numeric,2) as avg_spending from 
customer as c join orders as o on c.c_id=o.c_id join product as p on p.p_id=o.p_id group by c.cname,p.brand )
select *, row_number() over(partition by cname order by avg_spending desc) as ranks from c_brand)
select cname,brand,total_orders,quantity,avg_spending from net_customer where ranks=1 order by avg_spending desc limit 50;

-- 10.	Which cities show the highest and lowest  customer numbers month over month, along with its average spending ?
with total_city as
(select * from
(with rnkng as 
(select *, row_number() over (partition by months order by total_customers desc) as ranks from
(with orders as 
(select *,to_char(order_date,'month') as Months,extract('month' from order_date) as Month_N from orders)
select o.Months,o.Month_N,c.city,count(c.C_ID) as total_customers,
round((avg(p.price)*avg(o.qty)*avg(1-o.coupon_discount/100))::numeric,2) as avg_spending
from orders as o join customer as c on c.c_id=o.c_id join product as p on p.p_id=o.p_id
group by o.Months,o.Month_N,c.city order by o.Month_N) as rnk )
select * from rnkng where ranks=1 order by month_n) union all
select * from
(with rnkng as 
(select *, row_number() over (partition by months order by total_customers asc) as ranks from
(with orders as 
(select *,to_char(order_date,'month') as Months,extract('month' from order_date) as Month_N from orders)
select o.Months,o.Month_N,c.city,count(c.C_ID) as total_customers,
round((avg(p.price)*avg(o.qty)*avg(1-o.coupon_discount/100))::numeric,2) as avg_spending
from orders as o join customer as c on c.c_id=o.c_id join product as p on p.p_id=o.p_id
group by o.Months,o.Month_N,c.city order by o.Month_N) as rnk )
select * from rnkng where ranks=1 order by month_n) )
select months,city,total_customers,avg_spending from total_city order by month_n ;

-- 11.	What percentage of the total customer base comes from each state, in different quarter?
with total_orders as
(with orders as
(select *, concat('Qtr ',extract('quarter' from order_date) ) as quarters from orders)
select c.states,sum(case when o.quarters='Qtr 1' then 1 else 0 end) as "Qtr 1",
sum(case when o.quarters='Qtr 2' then 1 else 0 end) as "Qtr 2",
sum(case when o.quarters='Qtr 3' then 1 else 0 end) as "Qtr 3",
sum(case when o.quarters='Qtr 4' then 1 else 0 end) as "Qtr 4"
from orders as o join customer as c on c.c_id=o.c_id group by c.states)
select states,"Qtr 1",round("Qtr 1"/(select sum("Qtr 1") from total_orders)*100::numeric,2) as "% Qtr 1" ,
"Qtr 2",round("Qtr 2"/(select sum("Qtr 2") from total_orders)*100::numeric,2) as "% Qtr 2" ,
"Qtr 3",round("Qtr 3"/(select sum("Qtr 3") from total_orders)*100::numeric,2) as "% Qtr 3" ,
"Qtr 4",round("Qtr 4"/(select sum("Qtr 4") from total_orders)*100::numeric,2) as "% Qtr 4" from total_orders;

/* B. Product Analysis */
-- 1.	Which product category is most popular among buyers each month (identify top ), and how many items were sold, in different tiers?
with tier1 as 
(with tier1_rank as
(select *,row_number() over (partition by months order by Orders_Tier1 desc) as rank1 from 
(with o_tier1 as
(select *, to_char(order_date,'month') as months,extract('month' from order_date) as month_n from orders)
select o1.months,o1.month_n,p.category,count(o1.Or_ID) as Orders_Tier1,sum(o1.qty) as Qty_Tier1,
round( (avg(o1.qty)*avg(p.price)*(1-avg(o1.coupon_discount)/100))::numeric,2) as Avg_Spending_Tier1 from o_tier1 as o1 join product as p
on o1.p_id=p.p_id join customer as c on c.c_id=o1.c_id where c.tier='Tier 1' group by o1.months,o1.month_n,p.category order by o1.month_n) as ranks
order by month_n ) select * from tier1_rank where rank1=1),
tier2 as 
(with tier2_rank as
(select *,row_number() over (partition by months order by Orders_Tier2 desc) as rank2 from 
(with o_tier2 as
(select *, to_char(order_date,'month') as months,extract('month' from order_date) as month_n from orders)
select o2.months,o2.month_n,p.category,count(o2.Or_ID) as Orders_Tier2,sum(o2.qty) as Qty_Tier2,
round( (avg(o2.qty)*avg(p.price)*(1-avg(o2.coupon_discount)/100))::numeric,2) as Avg_Spending_Tier2 from o_tier2 as o2 join product as p
on o2.p_id=p.p_id join customer as c on c.c_id=o2.c_id where c.tier='Tier 2' group by o2.months,o2.month_n,p.category order by o2.month_n) as ranks
order by month_n ) select * from tier2_rank where rank2=1),
tier3 as 
(with tier3_rank as
(select *,row_number() over (partition by months order by Orders_Tier3 desc) as rank3 from 
(with o_tier3 as
(select *, to_char(order_date,'month') as months,extract('month' from order_date) as month_n from orders)
select o3.months,o3.month_n,p.category,count(o3.Or_ID) as Orders_Tier3,sum(o3.qty) as Qty_Tier3,
round( (avg(o3.qty)*avg(p.price)*(1-avg(o3.coupon_discount)/100))::numeric,2) as Avg_Spending_Tier3 from o_tier3 as o3 join product as p
on o3.p_id=p.p_id join customer as c on c.c_id=o3.c_id where c.tier='Tier 3' group by o3.months,o3.month_n,p.category order by o3.month_n) as ranks
order by month_n ) select * from tier3_rank where rank3=1),
tier4 as 
(with tier4_rank as
(select *,row_number() over (partition by months order by Orders_Tier4 desc) as rank4 from 
(with o_tier4 as
(select *, to_char(order_date,'month') as months,extract('month' from order_date) as month_n from orders)
select o4.months,o4.month_n,p.category,count(o4.Or_ID) as Orders_Tier4,sum(o4.qty) as Qty_Tier4,
round( (avg(o4.qty)*avg(p.price)*(1-avg(o4.coupon_discount)/100))::numeric,2) as Avg_Spending_Tier4 from o_tier4 as o4 join product as p
on o4.p_id=p.p_id join customer as c on c.c_id=o4.c_id where c.tier='Tier 1' group by o4.months,o4.month_n,p.category order by o4.month_n) as ranks
order by month_n ) select * from tier4_rank where rank4=1)
select t1.months, t1.category,t1.Orders_Tier1,t1.Qty_Tier1,t1.Avg_Spending_Tier1,
t2.category,t2.Orders_Tier2,t2.Qty_Tier2,t2.Avg_Spending_Tier2,
t3.category,t3.Orders_Tier3,t3.Qty_Tier3,t3.Avg_Spending_Tier3,
t4.category,t4.Orders_Tier4,t4.Qty_Tier4,t4.Avg_Spending_Tier4
from tier1 as t1  join tier2 as t2 on t1.months=t2.months join tier3 as t3 on t1.months=t3.months join tier4 as t4 on t1.months=t4.months
order by t1.month_n;

-- 2.	What is the average  revenue,total orders and total quantity sold for each company, broken down by region
with r_east as 
(select p.brand,count(o.or_id) as orders_east,sum(o.qty) as qty_east,
round( (avg(o.qty)*avg(p.price)*(1-avg(o.coupon_discount)/100))::numeric,2) as Avg_revenue_east
from customer as c join orders as o on o.c_id=c.c_id join product as p on p.p_id=o.p_id where c.region='East' group by p.brand ),
r_west as 
(select p.brand,count(o.or_id) as orders_west,sum(o.qty) as qty_west,
round( (avg(o.qty)*avg(p.price)*(1-avg(o.coupon_discount)/100))::numeric,2) as Avg_revenue_west
from customer as c join orders as o on o.c_id=c.c_id join product as p on p.p_id=o.p_id where c.region='West' group by p.brand),
r_north as 
(select p.brand,count(o.or_id) as orders_north,sum(o.qty) as qty_north,
round( (avg(o.qty)*avg(p.price)*(1-avg(o.coupon_discount)/100))::numeric,2) as Avg_revenue_north
from customer as c join orders as o on o.c_id=c.c_id join product as p on p.p_id=o.p_id where c.region='North' group by p.brand),
r_south as 
(select p.brand,count(o.or_id) as orders_south,sum(o.qty) as qty_south,
round( (avg(o.qty)*avg(p.price)*(1-avg(o.coupon_discount)/100))::numeric,2) as Avg_revenue_south
from customer as c join orders as o on o.c_id=c.c_id join product as p on p.p_id=o.p_id where c.region='South' group by p.brand)
select e.brand,e.orders_east,e.qty_east,e.Avg_revenue_east,w.orders_west,w.qty_west,w.Avg_revenue_west,
n.orders_north,n.qty_north,n.Avg_revenue_north,s.orders_south,s.qty_south,s.Avg_revenue_south from 
r_east as e join r_west as w on e.brand=w.brand join r_north as n on n.brand=e.brand join r_south as s on s.brand=e.brand;

-- 3.	How many products does each company sell, and what are their price ranges and average ratings?
with min_price as
(select p.brand,count(distinct p.p_id) as total_product, min(p.price) as price_mn,round(avg(r.prod_rating)::numeric,2) as rating
from product as p join orders as o on o.p_id=p.p_id join rating as r on r.or_id=o.or_id group by p.brand),
max_price as 
(select p.brand, max(p.price) as price_mx 
from product as p join orders as o on o.p_id=p.p_id join rating as r on r.or_id=o.or_id group by p.brand)
select mn.brand,concat(mn.price_mn,' - ',mx.price_mx) as price_range,
mn.rating from min_price as mn join max_price as mx on mx.brand=mn.brand;

-- 4.	Which product are the least purchased, catgorywise , based on quantity sold, tier by tier?
with tier1 as
(select * from
(select * , row_number() over(partition by brand order by qty_tier1 asc) as rank1 from 
(select p.brand,p.category as category_tier1,sum(o.qty) as qty_tier1 ,count(o.or_id) as order_tier1
from product as p join orders as o on o.p_id=p.p_id join customer as c on c.c_id=o.c_id where  c.tier='Tier 1'
group by p.brand,p.category) as rnk1 ) as rank_tier1 where rank_tier1.rank1=1),
tier2 as
(select * from
(select * , row_number() over(partition by brand order by qty_tier2 asc) as rank1 from 
(select p.brand,p.category as category_tier2,sum(o.qty) as qty_tier2 ,count(o.or_id) as order_tier2
from product as p join orders as o on o.p_id=p.p_id join customer as c on c.c_id=o.c_id where  c.tier='Tier 2'
group by p.brand,p.category) as rnk1 ) as rank_tier2 where rank_tier2.rank1=1),
tier3 as
(select * from
(select * , row_number() over(partition by brand order by qty_tier3 asc) as rank1 from 
(select p.brand,p.category as category_tier3,sum(o.qty) as qty_tier3 ,count(o.or_id) as order_tier3
from product as p join orders as o on o.p_id=p.p_id join customer as c on c.c_id=o.c_id where  c.tier='Tier 3'
group by p.brand,p.category) as rnk1 ) as rank_tier3 where rank_tier3.rank1=1),
tier4 as
(select * from
(select * , row_number() over(partition by brand order by qty_tier4 asc) as rank1 from 
(select p.brand,p.category as category_tier4,sum(o.qty) as qty_tier4 ,count(o.or_id) as order_tier4
from product as p join orders as o on o.p_id=p.p_id join customer as c on c.c_id=o.c_id where  c.tier='Tier 4'
group by p.brand,p.category) as rnk1 ) as rank_tier4 where rank_tier4.rank1=1)
select t1.brand,t1.category_tier1,t1.qty_tier1,t1.order_tier1,t2.category_tier2,t2.qty_tier2,t2.order_tier2,
t3.category_tier3,t3.qty_tier3,t3.order_tier3,t4.category_tier4,t4.qty_tier4,t4.order_tier4
from tier1 as t1 join tier2 as t2 on t1.brand=t2.brand join tier3 as t3 on t1.brand=t3.brand join tier4 as t4 on t1.brand=t4.brand;

-- 5.	Which  brands have the most orders, highest quantities sold, and best ratings, statwise, identify highest and lowest orders?
with state_order as 
(select * from 
(select * from 
(select *, row_number() over (partition by states order by orders desc) as ranks from 
(select c.states,p.brand,count(o.or_id) as orders, sum(o.qty) as quantity,round(avg(r.prod_rating)::numeric,2) as ratings
from customer as c join orders as o on o.c_id=c.c_id join product as p on p.p_id=o.p_id join rating as r on r.or_id=o.or_id
group by c.states,p.brand) as rnk) as h_rank where h_rank.ranks=1) union all
select * from 
(select * from 
(select *, row_number() over (partition by states order by orders asc) as ranks from 
(select c.states,p.brand,count(o.or_id) as orders, sum(o.qty) as quantity,round(avg(r.prod_rating)::numeric,2) as ratings
from customer as c join orders as o on o.c_id=c.c_id join product as p on p.p_id=o.p_id join rating as r on r.or_id=o.or_id
group by c.states,p.brand) as rnk) as h_rank where h_rank.ranks=1) )
select states,brand,orders,quantity,ratings from state_order order by states asc, orders desc;

-- 6.	Which  products highest priced  by companies , and how do their orders, quantities, and ratings compare by region, priced above ₹300?
with p_east as
(select * from 
(select * , row_number() over (partition by brand order by price_east desc) as rank1 from
(with product as (select * from product where price>300) 
select p.brand,p.pname as product_east,round(avg(p.price)::numeric,2) as price_east, count(o.or_id) as orders_east, 
sum(o.qty) as quantity_east from orders as o join product as p on p.p_id=o.p_id join customer as c on c.c_id=o.c_id 
where c.region='East' group by p.brand,p.pname) as rnk) as rk where rk.rank1=1),
p_west as 
(select * from 
(select * , row_number() over (partition by brand order by price_west desc) as rank1 from
(with product as (select * from product where price>300) 
select p.brand,p.pname as product_west,round(avg(p.price)::numeric,2) as price_west, count(o.or_id) as orders_west, 
sum(o.qty) as quantity_west from orders as o join product as p on p.p_id=o.p_id join customer as c on c.c_id=o.c_id 
where c.region='West' group by p.brand,p.pname) as rnk) as rk where rk.rank1=1),
p_north as
(select * from 
(select * , row_number() over (partition by brand order by price_north desc) as rank1 from
(with product as (select * from product where price>300) 
select p.brand,p.pname as product_north,round(avg(p.price)::numeric,2) as price_north, count(o.or_id) as orders_north, 
sum(o.qty) as quantity_north from orders as o join product as p on p.p_id=o.p_id join customer as c on c.c_id=o.c_id 
where c.region='North' group by p.brand,p.pname) as rnk) as rk where rk.rank1=1),
p_south as 
(select * from 
(select * , row_number() over (partition by brand order by price_south desc) as rank1 from
(with product as (select * from product where price>300) 
select p.brand,p.pname as product_south,round(avg(p.price)::numeric,2) as price_south, count(o.or_id) as orders_south, 
sum(o.qty) as quantity_south from orders as o join product as p on p.p_id=o.p_id join customer as c on c.c_id=o.c_id 
where c.region='South' group by p.brand,p.pname) as rnk) as rk where rk.rank1=1)
select e.brand,e.product_east,e.price_east,e.orders_east,quantity_east,w.product_west,w.price_west,w.orders_west,w.quantity_west,
n.product_north,n.price_north,n.orders_north,n.quantity_north,s.product_south,s.price_south,s.orders_south,s.quantity_south from 
p_east as e join p_west as w on e.brand=w.brand join p_north as n on n.brand=e.brand join p_south as s on s.brand=e.brand;

-- 7.	Which product category has the highest and lowest average prices, and what are their price ranges, quantities sold, avg revenue, and ratings?
with p_min as 
(select p.category,min(p.price) as min_price,count(o.or_id) as orders, sum(o.qty) as quantity,
round((avg(p.price)*avg(o.qty)*(1-avg(o.coupon_discount)/100))::numeric,2)
as avg_revenue, round(avg(r.prod_rating)::numeric,2) as rating from product as p join orders as o on o.p_id=p.p_id join rating as r on r.or_id=o.or_id
group by p.category),
p_max as
(select p.category,max(p.price) as max_price from product as p join orders as o on o.p_id=p.p_id group by p.category)
select mn.category,concat(mn.min_price,' - ',mx.max_price) as price_range,mn.orders,mn.quantity,mn.avg_revenue,mn.rating from p_min as mn join 
p_max as mx on mn.category=mx.category; 

-- 8.	Which products are the most and least popular based on order volume, along quantity sold, and avg revenue and rating , in different brand?
with prod_max_min as
(select * from
(select * from
(select *, row_number() over (partition by brand order by orders desc) as ranks from
(select p.brand,p.pname,count(o.or_id) as orders,sum(o.qty) as quantity, round((avg(p.price)*avg(o.qty)*(1-avg(o.coupon_discount)/100))::numeric,2)
as avg_revenue, round(avg(r.prod_rating)::numeric,2) as rating from product as p join orders as o on o.p_id=p.p_id join rating as r on r.or_id=o.or_id
group by p.brand,p.pname ) as rnk ) as rk where rk.ranks=1) union all
select * from
(select * from
(select *, row_number() over (partition by brand order by orders asc) as ranks from
(select p.brand,p.pname,count(o.or_id) as orders,sum(o.qty) as quantity, round((avg(p.price)*avg(o.qty)*(1-avg(o.coupon_discount)/100))::numeric,2)
as avg_revenue, round(avg(r.prod_rating)::numeric,2) as rating from product as p join orders as o on o.p_id=p.p_id join rating as r on r.or_id=o.or_id
group by p.brand,p.pname ) as rnk ) as rk where rk.ranks=1))
select brand,pname as product_name,orders,quantity,avg_revenue,rating from prod_max_min order by brand asc, orders desc;

-- 9.	Which product  are highest & least frequently purchased by gender, categories , based on rating, along with orders, quantity and avg revenue    ?
with rating_male_female as
(select * from
(with rank_male as
(select * from 
(select *, row_number() over (partition by category order by rating_male desc) as rank_m from
(select p.category,p.pname as product_male,count(o.or_id) as orders_male,sum(o.qty) as qty_male,
round((avg(p.price)*avg(o.qty)*(1-avg(o.coupon_discount)/100))::numeric,2) as avg_revenue_male,round(avg(r.prod_rating)::numeric,2) as rating_male
from product as p join orders as o on o.p_id=p.p_id join customer as c on c.c_id=o.c_id join rating as r on r.or_id=o.or_id where c.gender='Male'
group by p.category,p.pname) as rk_m ) as rnk_m where rnk_m.rank_m=1),
rank_female as
(select * from 
(select *, row_number() over (partition by category order by rating_female desc) as rank_f from
(select p.category,p.pname as product_female,count(o.or_id) as orders_female,sum(o.qty) as qty_female,
round((avg(p.price)*avg(o.qty)*(1-avg(o.coupon_discount)/100))::numeric,2) as avg_revenue_female,round(avg(r.prod_rating)::numeric,2) as rating_female
from product as p join orders as o on o.p_id=p.p_id join customer as c on c.c_id=o.c_id join rating as r on r.or_id=o.or_id where c.gender='Female'
group by p.category,p.pname) as rk_f) as rnk_f where rnk_f.rank_f=1)
select m.category,m.product_male,m.orders_male,m.qty_male,m.avg_revenue_male,
m.rating_male,f.product_female ,f.orders_female,f.qty_female,f.avg_revenue_female,f.rating_female 
from rank_male as m join rank_female as f on f.category=m.category ) union all
select * from 
(with rank_male as
(select * from 
(select *, row_number() over (partition by category order by rating_male asc) as rank_m from
(select p.category,p.pname as product_male,count(o.or_id) as orders_male,sum(o.qty) as qty_male,
round((avg(p.price)*avg(o.qty)*(1-avg(o.coupon_discount)/100))::numeric,2) as avg_revenue_male,round(avg(r.prod_rating)::numeric,2) as rating_male
from product as p join orders as o on o.p_id=p.p_id join customer as c on c.c_id=o.c_id join rating as r on r.or_id=o.or_id where c.gender='Male'
group by p.category,p.pname) as rk_m ) as rnk_m where rnk_m.rank_m=1),
rank_female as
(select * from 
(select *, row_number() over (partition by category order by rating_female asc) as rank_f from
(select p.category,p.pname as product_female,count(o.or_id) as orders_female,sum(o.qty) as qty_female,
round((avg(p.price)*avg(o.qty)*(1-avg(o.coupon_discount)/100))::numeric,2) as avg_revenue_female,round(avg(r.prod_rating)::numeric,2) as rating_female
from product as p join orders as o on o.p_id=p.p_id join customer as c on c.c_id=o.c_id join rating as r on r.or_id=o.or_id where c.gender='Female'
group by p.category,p.pname) as rk_f) as rnk_f where rnk_f.rank_f=1)
select m.category,m.product_male,m.orders_male,m.qty_male,m.avg_revenue_male,
m.rating_male,f.product_female ,f.orders_female,f.qty_female,f.avg_revenue_female,f.rating_female 
from rank_male as m join rank_female as f on f.category=m.category ) )
select * from rating_male_female order by category  asc ;

/* C. Sales Analysis */
-- 1.	What are the total sales, orders, customers, quantities sold, average order value, and revenue per customer?
with order_val as
(select round((sum(o.qty)*avg(p.price)*(1-avg(o.coupon_discount)/100))::numeric,2) as total_sales, count(o.or_id) as total_order,
count(distinct c.c_id) as active_customer, sum(o.qty) as total_quantity from customer as c join orders as o on o.c_id=c.c_id
join product as p on p.p_id=o.p_id ) select * , round((total_sales/total_order)::numeric,2) as average_order_value,
round((total_sales/active_customer)::numeric,2) as revenue_per_customer from order_val;

-- 2.	When (morning, afternoon, evening, night) do most orders occur, along with quantity and avg_revenue ?
 with orders as 
 (with orders as (select *,  extract('hours' from order_time) as hr from orders) select *,
 case when hr between 6 and 11 then 'Morning' when hr between 12 and 16 then 'Afternoon' when hr between 17 and 21 then 'Evening'
else 'Night' end as hr_grp from orders)
select o.hr_grp, count(o.or_id) as orders,count(distinct c.c_id) as total_customer ,sum(o.qty) as quantity , 
round((avg(o.qty)*avg(p.price)*(1-avg(o.coupon_discount)/100))::numeric,2) as avg_revenue from orders as o join customer as c on c.c_id=o.c_id
join product as p on p.p_id=o.p_id group by o.hr_grp;

-- 3.	Who are the top 20 customers with the most orders in the last 6 months (as of March 3, 2025)?
with orders as
(select * from orders where order_date between (select max(order_date)-interval '6 month' from orders) and (select max(order_date) from orders) )
select c.cname,count(o.or_id) as c_orders, sum(o.qty) as quantity,round((sum(o.qty)*avg(p.price)*(1-avg(o.coupon_discount)/100))::numeric,2) 
as total_spending, round(avg(r.prod_rating)::numeric,2) as rating from customer as c join orders as o on o.c_id=c.c_id join product as p on
p.p_id=o.p_id join rating as r on r.or_id=o.or_id group by c.cname order by c_orders desc limit 20;

-- 4.	How do orders of the product trends vary by month , among different gender?
with male_ord as
(select * from
(select *, row_number() over (partition by months order by order_male desc ) as rk_male from
(with orders as 
(select *, to_char(order_date,'month') as months,extract('month' from order_date) as month_n from orders)
select o.months,o.month_n,p.pname as product_male,count(o.or_id) as order_male,sum(o.qty) as qty_male ,
round((sum(o.qty)*avg(p.price)*(1-avg(o.coupon_discount)/100))::numeric,2) as sales_male,round(avg(r.prod_rating)::numeric,2) as rating_male
from orders as o join product as p on p.p_id=o.p_id join customer as c on c.c_id=o.c_id join rating as r on r.or_id=o.or_id where 
c.gender='Male' group by o.months,o.month_n,p.pname order by o.month_n) as rnk) as rk where rk.rk_male=1 order by rk.month_n),
female_ord as 
(select * from
(select *, row_number() over (partition by months order by order_female desc ) as rk_female from
(with orders as 
(select *, to_char(order_date,'month') as months,extract('month' from order_date) as month_n from orders)
select o.months,o.month_n,p.pname as product_female,count(o.or_id) as order_female,sum(o.qty) as qty_female ,
round((sum(o.qty)*avg(p.price)*(1-avg(o.coupon_discount)/100))::numeric,2) as sales_female,round(avg(r.prod_rating)::numeric,2) as rating_female
from orders as o join product as p on p.p_id=o.p_id join customer as c on c.c_id=o.c_id join rating as r on r.or_id=o.or_id where 
c.gender='Male' group by o.months,o.month_n,p.pname order by o.month_n) as rnk) as rk where rk.rk_female=1 order by rk.month_n) 
select m.months,m.product_male,m.order_male,m.qty_male,m.sales_male,m.rating_male,
f.product_female,f.order_female,f.qty_female,f.sales_female,f.rating_female from male_ord as m join female_ord as f on
m.months=f.months order by m.month_n; 

-- 5.	Which top and bottom companies in different category generated the highest revenue, along with highest orders and rating each region ?
with total_orders as 
(select * from 
(with s_south as
(select * from 
(select *, row_number() over (partition by category order by sales_south desc) as rnk_s from
(select p.category,p.brand as brand_south ,count(o.or_id) as orders_south, sum(o.qty) as quantity_south ,
round((sum(o.qty)*avg(p.price)*(1-avg(o.coupon_discount)/100))::numeric,2) as sales_south,
round(avg(r.prod_rating)::numeric,2) as rating_south from product as p join orders as o on o.p_id=p.p_id join customer as c on c.c_id=o.c_id
join rating as r on r.or_id=o.or_id where c.region='South' group by p.category,p.brand) as rnks ) as rk_st where rnk_s=1),
s_north as
(select * from 
(select *, row_number() over (partition by category order by sales_north desc) as rnk_n from
(select p.category,p.brand as brand_north,count(o.or_id) as orders_north, sum(o.qty) as quantity_north ,
round((sum(o.qty)*avg(p.price)*(1-avg(o.coupon_discount)/100))::numeric,2) as sales_north,
round(avg(r.prod_rating)::numeric,2) as rating_north from product as p join orders as o on o.p_id=p.p_id join customer as c on c.c_id=o.c_id
join rating as r on r.or_id=o.or_id where c.region='North' group by p.category,p.brand) as rnks ) as rk_nt where rnk_n=1),
s_east as
(select * from 
(select *, row_number() over (partition by category order by sales_east desc) as rnk_e from
(select p.category,p.brand as brand_east,count(o.or_id) as orders_east, sum(o.qty) as quantity_east ,
round((sum(o.qty)*avg(p.price)*(1-avg(o.coupon_discount)/100))::numeric,2) as sales_east,
round(avg(r.prod_rating)::numeric,2) as rating_east from product as p join orders as o on o.p_id=p.p_id join customer as c on c.c_id=o.c_id
join rating as r on r.or_id=o.or_id where c.region='East' group by p.category,p.brand) as rnks ) as rk_et where rnk_e=1),
s_west as
(select * from 
(select *, row_number() over (partition by category order by sales_west desc) as rnk_w from
(select p.category,p.brand as brand_west,count(o.or_id) as orders_west, sum(o.qty) as quantity_west ,
round((sum(o.qty)*avg(p.price)*(1-avg(o.coupon_discount)/100))::numeric,2) as sales_west,
round(avg(r.prod_rating)::numeric,2) as rating_west from product as p join orders as o on o.p_id=p.p_id join customer as c on c.c_id=o.c_id
join rating as r on r.or_id=o.or_id where c.region='West' group by p.category,p.brand) as rnks ) as rk_wt where rnk_w=1)
select s.category,s.brand_south,s.orders_south,s.quantity_south,s.sales_south,s.rating_south,
n.brand_north,n.orders_north,n.quantity_north,n.sales_north,n.rating_north,
w.brand_west,w.orders_west,w.quantity_west,w.sales_west,w.rating_west,
e.brand_east,e.orders_east,e.quantity_east,e.sales_east,e.rating_east
from s_south as s join s_north as n on s.category=n.category join s_west as w on w.category=s.category join s_east as e on
e.category=s.category ) union all
select * from 
(with s_south as
(select * from 
(select *, row_number() over (partition by category order by sales_south asc) as rnk_s from
(select p.category,p.brand as brand_south ,count(o.or_id) as orders_south, sum(o.qty) as quantity_south ,
round((sum(o.qty)*avg(p.price)*(1-avg(o.coupon_discount)/100))::numeric,2) as sales_south,
round(avg(r.prod_rating)::numeric,2) as rating_south from product as p join orders as o on o.p_id=p.p_id join customer as c on c.c_id=o.c_id
join rating as r on r.or_id=o.or_id where c.region='South' group by p.category,p.brand) as rnks ) as rk_st where rnk_s=1),
s_north as
(select * from 
(select *, row_number() over (partition by category order by sales_north asc) as rnk_n from
(select p.category,p.brand as brand_north,count(o.or_id) as orders_north, sum(o.qty) as quantity_north ,
round((sum(o.qty)*avg(p.price)*(1-avg(o.coupon_discount)/100))::numeric,2) as sales_north,
round(avg(r.prod_rating)::numeric,2) as rating_north from product as p join orders as o on o.p_id=p.p_id join customer as c on c.c_id=o.c_id
join rating as r on r.or_id=o.or_id where c.region='North' group by p.category,p.brand) as rnks ) as rk_nt where rnk_n=1),
s_east as
(select * from 
(select *, row_number() over (partition by category order by sales_east asc) as rnk_e from
(select p.category,p.brand as brand_east,count(o.or_id) as orders_east, sum(o.qty) as quantity_east ,
round((sum(o.qty)*avg(p.price)*(1-avg(o.coupon_discount)/100))::numeric,2) as sales_east,
round(avg(r.prod_rating)::numeric,2) as rating_east from product as p join orders as o on o.p_id=p.p_id join customer as c on c.c_id=o.c_id
join rating as r on r.or_id=o.or_id where c.region='East' group by p.category,p.brand) as rnks ) as rk_et where rnk_e=1),
s_west as
(select * from 
(select *, row_number() over (partition by category order by sales_west asc) as rnk_w from
(select p.category,p.brand as brand_west,count(o.or_id) as orders_west, sum(o.qty) as quantity_west ,
round((sum(o.qty)*avg(p.price)*(1-avg(o.coupon_discount)/100))::numeric,2) as sales_west,
round(avg(r.prod_rating)::numeric,2) as rating_west from product as p join orders as o on o.p_id=p.p_id join customer as c on c.c_id=o.c_id
join rating as r on r.or_id=o.or_id where c.region='West' group by p.category,p.brand) as rnks ) as rk_wt where rnk_w=1)
select s.category,s.brand_south,s.orders_south,s.quantity_south,s.sales_south,s.rating_south,
n.brand_north,n.orders_north,n.quantity_north,n.sales_north,n.rating_north,
w.brand_west,w.orders_west,w.quantity_west,w.sales_west,w.rating_west,
e.brand_east,e.orders_east,e.quantity_east,e.sales_east,e.rating_east
from s_south as s join s_north as n on s.category=n.category join s_west as w on w.category=s.category join s_east as e on
e.category=s.category )) select * from total_orders order by category;

-- 6.	How do discounts of brand affect sales before and after application, in different category ?
select p.brand,
round(sum(case when p.category='Home Care' then p.price*o.qty else 0 end)::numeric,2) as Home_Care_before_discount,
round(sum(case when p.category='Home Care' then p.price*o.qty*(1-o.coupon_discount/100) else 0 end)::numeric,2) as Home_Care_after_discount,
round(sum(case when p.category='Beverages' then p.price*o.qty else 0 end)::numeric,2) as Beverages_before_discount,
round(sum(case when p.category='Beverages' then p.price*o.qty*(1-o.coupon_discount/100) else 0 end)::numeric,2) as Beverages_after_discount,
round(sum(case when p.category='Snacks' then p.price*o.qty else 0 end)::numeric,2) as Snacks_before_discount,
round(sum(case when p.category='Snacks' then p.price*o.qty*(1-o.coupon_discount/100) else 0 end)::numeric,2) as Snacks_after_discount,
round(sum(case when p.category='Presonal Care' then p.price*o.qty else 0 end)::numeric,2) as Presonal_Care_before_discount,
round(sum(case when p.category='Presonal Care' then p.price*o.qty*(1-o.coupon_discount/100) else 0 end)::numeric,2) as Presonal_Care_after_discount,
round(sum(case when p.category='Dairy' then p.price*o.qty else 0 end)::numeric,2) as Dairy_before_discount,
round(sum(case when p.category='Dairy' then p.price*o.qty*(1-o.coupon_discount/100) else 0 end)::numeric,2) as Dairy_after_discount,
round(sum(case when p.category='Groceries' then p.price*o.qty else 0 end)::numeric,2) as Groceries_before_discount,
round(sum(case when p.category='Groceries' then p.price*o.qty*(1-o.coupon_discount/100) else 0 end)::numeric,2) as Groceries_after_discount
from product as p join orders as o on o.p_id=p.p_id group by p.brand;

-- 7.	Which brand sells the most in each state, based on sales , identify top 3  ?
select states,brand,orders,quantity,sales, rating from 
(select *, row_number() over (partition by states order by sales desc) as ranks from
(select c.states,p.brand, count(o.or_id) as orders, sum(o.qty) as quantity,
round((sum(o.qty)*avg(p.price)*(1-avg(o.coupon_discount)/100))::numeric,2) as sales,round(avg(r.prod_rating)::numeric,2) as rating
from orders as o join product as p on p.p_id=o.p_id join customer as c on c.c_id=o.c_id join rating as r on r.or_id=o.or_id 
group by c.states,p.brand ) as rnk) as rk where rk.ranks<=3;
 
-- 8.	What are the top 20 products by orders, along with average customer age range, quantity,sales and rating?
with min_order as
(select p.pname,count(o.or_id) as orders, min(age) as min_age, sum(o.qty) as quantity,min(o.coupon_discount) as min_discount,
round((sum(o.qty)*avg(p.price)*(1-avg(o.coupon_discount)/100))::numeric,2) as sales,
round(avg(r.prod_rating)::numeric,2) as rating from orders as o join product as p on p.p_id=o.p_id join customer as c on c.c_id=o.c_id
join rating as r on r.or_id=o.or_id group by p.pname),
max_order as
(select p.pname, max(age) as max_age,  max(o.coupon_discount) as max_discount
 from orders as o join product as p on p.p_id=o.p_id join customer as c on c.c_id=o.c_id
join rating as r on r.or_id=o.or_id group by p.pname)
select mn.pname,mn.orders,concat(mn.min_age,' - ',mx.max_age) as age_range, mn.quantity, concat(mn.min_discount,' - ',mx.max_discount) as discount_range,
mn.sales,mn.rating from min_order as mn join max_order as mx on mn.pname=mx.pname order by mn.orders desc limit 20;

-- 9.	Calculate  MOM sales, tierwise 
with tier1 as
(with tier1_mom as 
(select *, case when pre_sales_tier1=0 then 0 else round(((sales_tier1-pre_sales_tier1)/pre_sales_tier1*100)::numeric,2) end as MOM_tier1 from
(select *,lag(sales_tier1,1,0) over () as pre_sales_tier1 from
(with orders as 
(select *,to_char(order_date,'month') as months,extract('month' from order_date) as month_n from orders )
select months,month_n,round((sum(o.qty)*avg(p.price)*(1-avg(o.coupon_discount)/100))::numeric,2) as sales_tier1 from orders as o join product as p
on p.p_id=o.p_id join customer as c on c.c_id=o.c_id where c.tier='Tier 1' group by months,month_n  order by month_n ) as pr_s_1) as mom_t1)
select months,month_n,mom_tier1 from tier1_mom),
tier2 as
(with tier2_mom as 
(select *, case when pre_sales_tier2=0 then 0 else round(((sales_tier2-pre_sales_tier2)/pre_sales_tier2*100)::numeric,2) end as MOM_tier2 from
(select *,lag(sales_tier2,1,0) over () as pre_sales_tier2 from
(with orders as 
(select *,to_char(order_date,'month') as months,extract('month' from order_date) as month_n from orders )
select months,month_n,round((sum(o.qty)*avg(p.price)*(1-avg(o.coupon_discount)/100))::numeric,2) as sales_tier2 from orders as o join product as p
on p.p_id=o.p_id join customer as c on c.c_id=o.c_id where c.tier='Tier 2' group by months,month_n  order by month_n  ) as pr_s_2) as mom_t2)
select months,month_n,mom_tier2 from tier2_mom),
tier3 as
(with tier3_mom as 
(select *, case when pre_sales_tier3=0 then 0 else round(((sales_tier3-pre_sales_tier3)/pre_sales_tier3*100)::numeric,2) end as MOM_tier3 from
(select *,lag(sales_tier3,1,0) over () as pre_sales_tier3 from
(with orders as 
(select *,to_char(order_date,'month') as months,extract('month' from order_date) as month_n from orders )
select months,month_n,round((sum(o.qty)*avg(p.price)*(1-avg(o.coupon_discount)/100))::numeric,2) as sales_tier3 from orders as o join product as p
on p.p_id=o.p_id join customer as c on c.c_id=o.c_id where c.tier='Tier 3' group by months,month_n  order by month_n  ) as pr_s_3) as mom_t3)
select months,month_n,mom_tier3 from tier3_mom),
tier4 as
(with tier4_mom as 
(select *, case when pre_sales_tier4=0 then 0 else round(((sales_tier4-pre_sales_tier4)/pre_sales_tier4*100)::numeric,2) end as MOM_tier4 from
(select *,lag(sales_tier4,1,0) over () as pre_sales_tier4 from
(with orders as 
(select *,to_char(order_date,'month') as months,extract('month' from order_date) as month_n from orders )
select months,month_n,round((sum(o.qty)*avg(p.price)*(1-avg(o.coupon_discount)/100))::numeric,2) as sales_tier4 from orders as o join product as p
on p.p_id=o.p_id join customer as c on c.c_id=o.c_id where c.tier='Tier 4' group by months,month_n  order by month_n ) as pr_s_4) as mom_t4)
select months,month_n,mom_tier4 from tier4_mom)
select t1.months,t1.MOM_tier1,t2.MOM_tier2,t3.MOM_tier3,t4.MOM_tier4 from tier1 as t1 join tier2 as t2 on t1.months=t2.months join tier3 as 
t3 on t1.months=t3.months join tier4 as t4 on t1.months =t4.months order by t1.month_n;

/* D. Transaction Analysis */
-- 1.	How many transactions included rewards and how many not, based on payment methods used, in different regiom?
with south as 
(select t.transaction_mode, sum( case when t.rewards='Yes' then 1 else 0 end ) as South_Y,
sum( case when t.rewards='No' then 1 else 0 end ) as South_N from transactions as t join orders as o on o.or_id=t.or_id join customer as c on 
c.c_id=o.c_id where c.region='South'  group by t.transaction_mode),
north as 
(select t.transaction_mode, sum( case when t.rewards='Yes' then 1 else 0 end ) as North_Y,
sum( case when t.rewards='No' then 1 else 0 end ) as North_N from transactions as t join orders as o on o.or_id=t.or_id join customer as c on 
c.c_id=o.c_id where c.region='North'  group by t.transaction_mode),
east as 
(select t.transaction_mode, sum( case when t.rewards='Yes' then 1 else 0 end ) as East_Y,
sum( case when t.rewards='No' then 1 else 0 end ) as East_N from transactions as t join orders as o on o.or_id=t.or_id join customer as c on 
c.c_id=o.c_id where c.region='East'  group by t.transaction_mode),
west as
(select t.transaction_mode, sum( case when t.rewards='Yes' then 1 else 0 end ) as West_Y,
sum( case when t.rewards='No' then 1 else 0 end ) as West_N from transactions as t join orders as o on o.or_id=t.or_id join customer as c on 
c.c_id=o.c_id where c.region='West'  group by t.transaction_mode)
select s.transaction_mode,s.South_Y,s.South_N,n.North_Y,n.North_N,e.East_Y,e.East_N,w.West_Y,w.West_N from south as s join north as n on
s.transaction_mode=n.transaction_mode join west as w on s.transaction_mode=w.transaction_mode join east as e on s.transaction_mode=e.transaction_mode;
 
-- 2.	how much companies offered the most and least rewards, and for which payment methods?
with Wallet as
(select p.brand,sum(case when t.rewards='Yes' then 1 else 0 end) as Wallet_Y,
sum(case when t.rewards='No' then 1 else 0 end) as Wallet_N from transactions as t join orders as o on o.or_id=t.or_id join product as p on p.p_id=o.p_id
where t.transaction_mode='Wallet'  group by p.brand),
UPI as
(select p.brand,sum(case when t.rewards='Yes' then 1 else 0 end) as UPI_Y,
sum(case when t.rewards='No' then 1 else 0 end) as UPI_N from transactions as t join orders as o on o.or_id=t.or_id join product as p on p.p_id=o.p_id
where t.transaction_mode='UPI'  group by p.brand),
Debit_Card as
(select p.brand,sum(case when t.rewards='Yes' then 1 else 0 end) as Debit_Card_Y,
sum(case when t.rewards='No' then 1 else 0 end) as Debit_Card_N from transactions as t join orders as o on o.or_id=t.or_id join product as p on p.p_id=o.p_id
where t.transaction_mode='Debit Card'  group by p.brand),
Credit_Card as
(select p.brand,sum(case when t.rewards='Yes' then 1 else 0 end) as Credit_Card_Y,
sum(case when t.rewards='No' then 1 else 0 end) as Credit_Card_N from transactions as t join orders as o on o.or_id=t.or_id join product as p on p.p_id=o.p_id
where t.transaction_mode='Credit Card'  group by p.brand),
COD as
(select p.brand,sum(case when t.rewards='Yes' then 1 else 0 end) as COD_Y,
sum(case when t.rewards='No' then 1 else 0 end) as COD_N from transactions as t join orders as o on o.or_id=t.or_id join product as p on p.p_id=o.p_id
where t.transaction_mode='COD'  group by p.brand)
select w.brand,w.Wallet_Y,w.Wallet_N,u.UPI_Y,u.UPI_N,d.Debit_Card_Y,d.Debit_Card_N,c.Credit_Card_Y,c.Credit_Card_N,co.COD_Y,co.COD_N
from Wallet as w join UPI as u on w.brand=u.brand join Debit_Card as d on d.brand=w.brand join Credit_Card  as c on c.brand=w.brand join
COD as co on co.brand=w.brand ;

-- 3.	Which payment method is most popular, and how much was transacted each state, quarterwise , find top and bottom ?
with total_qtr as 
(select * from 
(with qtr1 as
(select * from 
(select *, row_number() over (partition by states order by transactions_qtr1 desc) as rk_qtr1 from 
(with orders as (select *,concat('Qtr ',extract('quarter' from order_date)) as qtr from orders)
select c.states,t.transaction_mode as mode_qtr1, count(o.or_id) as transactions_qtr1,
round((sum(o.qty)*avg(p.price)*(1-avg(o.coupon_discount)/100))::numeric,2) 
as amount_qtr1 from customer as c join orders as o on o.c_id=c.c_id join transactions as t on t.or_id=o.or_id join product as p on p.p_id=o.p_id 
where o.qtr='Qtr 1' group by c.states,t.transaction_mode) as rk_1) as rkn_1 where rkn_1.rk_qtr1=1),
qtr2 as
(select * from 
(select *, row_number() over (partition by states order by transactions_qtr2 desc) as rk_qtr2 from 
(with orders as (select *,concat('Qtr ',extract('quarter' from order_date)) as qtr from orders)
select c.states,t.transaction_mode as mode_qtr2, count(o.or_id) as transactions_qtr2,
round((sum(o.qty)*avg(p.price)*(1-avg(o.coupon_discount)/100))::numeric,2) 
as amount_qtr2 from customer as c join orders as o on o.c_id=c.c_id join transactions as t on t.or_id=o.or_id join product as p on p.p_id=o.p_id 
where o.qtr='Qtr 2' group by c.states,t.transaction_mode) as rk_2) as rkn_2 where rkn_2.rk_qtr2=1),
qtr3 as
(select * from 
(select *, row_number() over (partition by states order by transactions_qtr3 desc) as rk_qtr3 from 
(with orders as (select *,concat('Qtr ',extract('quarter' from order_date)) as qtr from orders)
select c.states,t.transaction_mode as mode_qtr3, count(o.or_id) as transactions_qtr3,
round((sum(o.qty)*avg(p.price)*(1-avg(o.coupon_discount)/100))::numeric,2) 
as amount_qtr3 from customer as c join orders as o on o.c_id=c.c_id join transactions as t on t.or_id=o.or_id join product as p on p.p_id=o.p_id 
where o.qtr='Qtr 3' group by c.states,t.transaction_mode) as rk_3) as rkn_3 where rkn_3.rk_qtr3=1),
qtr4 as
(select * from 
(select *, row_number() over (partition by states order by transactions_qtr4 desc) as rk_qtr4 from 
(with orders as (select *,concat('Qtr ',extract('quarter' from order_date)) as qtr from orders)
select c.states,t.transaction_mode as mode_qtr4, count(o.or_id) as transactions_qtr4,
round((sum(o.qty)*avg(p.price)*(1-avg(o.coupon_discount)/100))::numeric,2) 
as amount_qtr4 from customer as c join orders as o on o.c_id=c.c_id join transactions as t on t.or_id=o.or_id join product as p on p.p_id=o.p_id 
where o.qtr='Qtr 4' group by c.states,t.transaction_mode) as rk_4) as rkn_4 where rkn_4.rk_qtr4=1)
select q1.states,q1.mode_qtr1,q1.transactions_qtr1,q1.amount_qtr1,q2.mode_qtr2,q2.transactions_qtr2,q2.amount_qtr2,
q3.mode_qtr3,q3.transactions_qtr3,q3.amount_qtr3,q4.mode_qtr4,q4.transactions_qtr4,q4.amount_qtr4 from qtr1 as q1 join qtr2 as q2 on
q1.states=q2.states join qtr3 as q3 on q3.states=q1.states join qtr4 as q4 on q4.states=q1.states) union all
select * from
(with qtr1 as
(select * from 
(select *, row_number() over (partition by states order by transactions_qtr1 asc) as rk_qtr1 from 
(with orders as (select *,concat('Qtr ',extract('quarter' from order_date)) as qtr from orders)
select c.states,t.transaction_mode as mode_qtr1, count(o.or_id) as transactions_qtr1,
round((sum(o.qty)*avg(p.price)*(1-avg(o.coupon_discount)/100))::numeric,2) 
as amount_qtr1 from customer as c join orders as o on o.c_id=c.c_id join transactions as t on t.or_id=o.or_id join product as p on p.p_id=o.p_id 
where o.qtr='Qtr 1' group by c.states,t.transaction_mode) as rk_1) as rkn_1 where rkn_1.rk_qtr1=1),
qtr2 as
(select * from 
(select *, row_number() over (partition by states order by transactions_qtr2 asc) as rk_qtr2 from 
(with orders as (select *,concat('Qtr ',extract('quarter' from order_date)) as qtr from orders)
select c.states,t.transaction_mode as mode_qtr2, count(o.or_id) as transactions_qtr2,
round((sum(o.qty)*avg(p.price)*(1-avg(o.coupon_discount)/100))::numeric,2) 
as amount_qtr2 from customer as c join orders as o on o.c_id=c.c_id join transactions as t on t.or_id=o.or_id join product as p on p.p_id=o.p_id 
where o.qtr='Qtr 2' group by c.states,t.transaction_mode) as rk_2) as rkn_2 where rkn_2.rk_qtr2=1),
qtr3 as
(select * from 
(select *, row_number() over (partition by states order by transactions_qtr3 asc) as rk_qtr3 from 
(with orders as (select *,concat('Qtr ',extract('quarter' from order_date)) as qtr from orders)
select c.states,t.transaction_mode as mode_qtr3, count(o.or_id) as transactions_qtr3,
round((sum(o.qty)*avg(p.price)*(1-avg(o.coupon_discount)/100))::numeric,2) 
as amount_qtr3 from customer as c join orders as o on o.c_id=c.c_id join transactions as t on t.or_id=o.or_id join product as p on p.p_id=o.p_id 
where o.qtr='Qtr 3' group by c.states,t.transaction_mode) as rk_3) as rkn_3 where rkn_3.rk_qtr3=1),
qtr4 as
(select * from 
(select *, row_number() over (partition by states order by transactions_qtr4 asc) as rk_qtr4 from 
(with orders as (select *,concat('Qtr ',extract('quarter' from order_date)) as qtr from orders)
select c.states,t.transaction_mode as mode_qtr4, count(o.or_id) as transactions_qtr4,
round((sum(o.qty)*avg(p.price)*(1-avg(o.coupon_discount)/100))::numeric,2) 
as amount_qtr4 from customer as c join orders as o on o.c_id=c.c_id join transactions as t on t.or_id=o.or_id join product as p on p.p_id=o.p_id 
where o.qtr='Qtr 4' group by c.states,t.transaction_mode) as rk_4) as rkn_4 where rkn_4.rk_qtr4=1)
select q1.states,q1.mode_qtr1,q1.transactions_qtr1,q1.amount_qtr1,q2.mode_qtr2,q2.transactions_qtr2,q2.amount_qtr2,
q3.mode_qtr3,q3.transactions_qtr3,q3.amount_qtr3,q4.mode_qtr4,q4.transactions_qtr4,q4.amount_qtr4 from qtr1 as q1 join qtr2 as q2 on
q1.states=q2.states join qtr3 as q3 on q3.states=q1.states join qtr4 as q4 on q4.states=q1.states) )
select * from total_qtr order by  states ;

-- 4.	How many transactions occurred citywise in each transaction, and what was the average transaction amount, in each quarter.
with qtr1 as
(with orders as (select *, concat('Qtr ',extract('quarter' from order_date)) as qtr from orders )
select c.city,
sum(case when t.transaction_mode='Wallet' then 1 else 0 end) as Wallet_transaction_Qtr1,
round(avg(case when t.transaction_mode='Wallet' then o.qty*p.price*(1-o.coupon_discount/100)  else 0 end)::numeric,2) as Wallet_Avg_Amt_Qtr1,
sum(case when t.transaction_mode='UPI' then 1 else 0 end) as UPI_transaction_Qtr1,
round(avg(case when t.transaction_mode='UPI' then o.qty*p.price*(1-o.coupon_discount/100)  else 0 end)::numeric,2) as UPI_Avg_Amt_Qtr1,
sum(case when t.transaction_mode='Debit Card' then 1 else 0 end) as Debit_Card_transaction_Qtr1,
round(avg(case when t.transaction_mode='Debit Card' then o.qty*p.price*(1-o.coupon_discount/100)  else 0 end)::numeric,2) as Debit_Card_Avg_Amt_Qtr1,
sum(case when t.transaction_mode='Credit Card' then 1 else 0 end) as Credit_Card_transaction_Qtr1,
round(avg(case when t.transaction_mode='Credit Card' then o.qty*p.price*(1-o.coupon_discount/100)  else 0 end)::numeric,2) as Credit_Card_Avg_Amt_Qtr1,
sum(case when t.transaction_mode='COD' then 1 else 0 end) as COD_transaction_Qtr1,
round(avg(case when t.transaction_mode='COD' then o.qty*p.price*(1-o.coupon_discount/100)  else 0 end)::numeric,2) as COD_Avg_Amt_Qtr1
from customer as c join orders as o on o.c_id=c.c_id join product as p on p.p_id=o.p_id join transactions as t
on t.or_id=o.or_id where o.qtr='Qtr 1' group by c.city),
qtr2 as
(with orders as (select *, concat('Qtr ',extract('quarter' from order_date)) as qtr from orders )
select c.city,
sum(case when t.transaction_mode='Wallet' then 1 else 0 end) as Wallet_transaction_Qtr2,
round(avg(case when t.transaction_mode='Wallet' then o.qty*p.price*(1-o.coupon_discount/100)  else 0 end)::numeric,2) as Wallet_Avg_Amt_Qtr2,
sum(case when t.transaction_mode='UPI' then 1 else 0 end) as UPI_transaction_Qtr2,
round(avg(case when t.transaction_mode='UPI' then o.qty*p.price*(1-o.coupon_discount/100)  else 0 end)::numeric,2) as UPI_Avg_Amt_Qtr2,
sum(case when t.transaction_mode='Debit Card' then 1 else 0 end) as Debit_Card_transaction_Qtr2,
round(avg(case when t.transaction_mode='Debit Card' then o.qty*p.price*(1-o.coupon_discount/100)  else 0 end)::numeric,2) as Debit_Card_Avg_Amt_Qtr2,
sum(case when t.transaction_mode='Credit Card' then 1 else 0 end) as Credit_Card_transaction_Qtr2,
round(avg(case when t.transaction_mode='Credit Card' then o.qty*p.price*(1-o.coupon_discount/100)  else 0 end)::numeric,2) as Credit_Card_Avg_Amt_Qtr2,
sum(case when t.transaction_mode='COD' then 1 else 0 end) as COD_transaction_Qtr2,
round(avg(case when t.transaction_mode='COD' then o.qty*p.price*(1-o.coupon_discount/100)  else 0 end)::numeric,2) as COD_Avg_Amt_Qtr2
from customer as c join orders as o on o.c_id=c.c_id join product as p on p.p_id=o.p_id join transactions as t
on t.or_id=o.or_id where o.qtr='Qtr 2' group by c.city),
qtr3 as
(with orders as (select *, concat('Qtr ',extract('quarter' from order_date)) as qtr from orders )
select c.city,
sum(case when t.transaction_mode='Wallet' then 1 else 0 end) as Wallet_transaction_Qtr3,
round(avg(case when t.transaction_mode='Wallet' then o.qty*p.price*(1-o.coupon_discount/100)  else 0 end)::numeric,2) as Wallet_Avg_Amt_Qtr3,
sum(case when t.transaction_mode='UPI' then 1 else 0 end) as UPI_transaction_Qtr3,
round(avg(case when t.transaction_mode='UPI' then o.qty*p.price*(1-o.coupon_discount/100)  else 0 end)::numeric,2) as UPI_Avg_Amt_Qtr3,
sum(case when t.transaction_mode='Debit Card' then 1 else 0 end) as Debit_Card_transaction_Qtr3,
round(avg(case when t.transaction_mode='Debit Card' then o.qty*p.price*(1-o.coupon_discount/100)  else 0 end)::numeric,2) as Debit_Card_Avg_Amt_Qtr3,
sum(case when t.transaction_mode='Credit Card' then 1 else 0 end) as Credit_Card_transaction_Qtr3,
round(avg(case when t.transaction_mode='Credit Card' then o.qty*p.price*(1-o.coupon_discount/100)  else 0 end)::numeric,2) as Credit_Card_Avg_Amt_Qtr3,
sum(case when t.transaction_mode='COD' then 1 else 0 end) as COD_transaction_Qtr3,
round(avg(case when t.transaction_mode='COD' then o.qty*p.price*(1-o.coupon_discount/100)  else 0 end)::numeric,2) as COD_Avg_Amt_Qtr3
from customer as c join orders as o on o.c_id=c.c_id join product as p on p.p_id=o.p_id join transactions as t
on t.or_id=o.or_id where o.qtr='Qtr 3' group by c.city),
qtr4 as
(with orders as (select *, concat('Qtr ',extract('quarter' from order_date)) as qtr from orders )
select c.city,
sum(case when t.transaction_mode='Wallet' then 1 else 0 end) as Wallet_transaction_Qtr4,
round(avg(case when t.transaction_mode='Wallet' then o.qty*p.price*(1-o.coupon_discount/100)  else 0 end)::numeric,2) as Wallet_Avg_Amt_Qtr4,
sum(case when t.transaction_mode='UPI' then 1 else 0 end) as UPI_transaction_Qtr4,
round(avg(case when t.transaction_mode='UPI' then o.qty*p.price*(1-o.coupon_discount/100)  else 0 end)::numeric,2) as UPI_Avg_Amt_Qtr4,
sum(case when t.transaction_mode='Debit Card' then 1 else 0 end) as Debit_Card_transaction_Qtr4,
round(avg(case when t.transaction_mode='Debit Card' then o.qty*p.price*(1-o.coupon_discount/100)  else 0 end)::numeric,2) as Debit_Card_Avg_Amt_Qtr4,
sum(case when t.transaction_mode='Credit Card' then 1 else 0 end) as Credit_Card_transaction_Qtr4,
round(avg(case when t.transaction_mode='Credit Card' then o.qty*p.price*(1-o.coupon_discount/100)  else 0 end)::numeric,2) as Credit_Card_Avg_Amt_Qtr4,
sum(case when t.transaction_mode='COD' then 1 else 0 end) as COD_transaction_Qtr4,
round(avg(case when t.transaction_mode='COD' then o.qty*p.price*(1-o.coupon_discount/100)  else 0 end)::numeric,2) as COD_Avg_Amt_Qtr4
from customer as c join orders as o on o.c_id=c.c_id join product as p on p.p_id=o.p_id join transactions as t
on t.or_id=o.or_id where o.qtr='Qtr 4' group by c.city)
select q1.city, 
q1.Wallet_transaction_Qtr1, q1.Wallet_Avg_Amt_Qtr1, q1.UPI_transaction_Qtr1, q1.UPI_Avg_Amt_Qtr1, q1.Debit_Card_transaction_Qtr1,
q1.Debit_Card_Avg_Amt_Qtr1,q1.Credit_Card_transaction_Qtr1,q1.Credit_Card_Avg_Amt_Qtr1,q1.COD_transaction_Qtr1,q1.COD_Avg_Amt_Qtr1,
q2.Wallet_transaction_Qtr2, q2.Wallet_Avg_Amt_Qtr2, q2.UPI_transaction_Qtr2, q2.UPI_Avg_Amt_Qtr2, q2.Debit_Card_transaction_Qtr2,
q2.Debit_Card_Avg_Amt_Qtr2,q2.Credit_Card_transaction_Qtr2,q2.Credit_Card_Avg_Amt_Qtr2,q2.COD_transaction_Qtr2,q2.COD_Avg_Amt_Qtr2,
q3.Wallet_transaction_Qtr3, q3.Wallet_Avg_Amt_Qtr3, q3.UPI_transaction_Qtr3, q3.UPI_Avg_Amt_Qtr3, q3.Debit_Card_transaction_Qtr3,
q3.Debit_Card_Avg_Amt_Qtr3,q3.Credit_Card_transaction_Qtr3,q3.Credit_Card_Avg_Amt_Qtr3,q3.COD_transaction_Qtr3,q3.COD_Avg_Amt_Qtr3,
q4.Wallet_transaction_Qtr4, q4.Wallet_Avg_Amt_Qtr4, q4.UPI_transaction_Qtr4, q4.UPI_Avg_Amt_Qtr4, q4.Debit_Card_transaction_Qtr4,
q4.Debit_Card_Avg_Amt_Qtr4,q4.Credit_Card_transaction_Qtr4,q4.Credit_Card_Avg_Amt_Qtr4,q4.COD_transaction_Qtr4,q4.COD_Avg_Amt_Qtr4
from qtr1 as q1 join qtr2 as q2 on q1.city=q2.city  join qtr3 as q3 on q3.city=q1.city join qtr4 as q4 on q4.city=q1.city;

-- 5.	What is the MOM  transactions for each mode ?
with Wallet as
(with Wallet_amt as 
(select *, lag(Wallet_amt,1,0) over() as pre_Wallet_amt from
(with orders as ( select *,to_char(order_date,'month') as months, extract('month' from order_date) as month_n from orders)
select o.months,o.month_n,round((sum(o.qty)*avg(p.price)*(1-avg(o.coupon_discount)/100))::numeric,2) as Wallet_amt from 
product as p join orders as o on o.p_id=p.p_id join transactions as t on t.or_id=o.or_id where t.transaction_mode='Wallet'
group by o.months,o.month_n order by o.month_n asc) as wlt)
select months,month_n, case when pre_Wallet_amt=0 then 0 else round(((Wallet_amt-pre_Wallet_amt)/pre_Wallet_amt*100)::numeric,2) end as MOM_Wallet 
from Wallet_amt),
UPI as
(with UPI_amt as 
(select *, lag(UPI_amt,1,0) over() as pre_UPI_amt from
(with orders as ( select *,to_char(order_date,'month') as months, extract('month' from order_date) as month_n from orders)
select o.months,o.month_n,round((sum(o.qty)*avg(p.price)*(1-avg(o.coupon_discount)/100))::numeric,2) as UPI_amt from 
product as p join orders as o on o.p_id=p.p_id join transactions as t on t.or_id=o.or_id where t.transaction_mode='UPI'
group by o.months,o.month_n order by o.month_n asc) as UPI)
select months,month_n, case when pre_UPI_amt=0 then 0 else round(((UPI_amt-pre_UPI_amt)/pre_UPI_amt*100)::numeric,2) end as MOM_UPI 
from UPI_amt),
Debit_Card as
(with Debit_Card_amt as 
(select *, lag(Debit_Card_amt,1,0) over() as pre_Debit_Card_amt from
(with orders as ( select *,to_char(order_date,'month') as months, extract('month' from order_date) as month_n from orders)
select o.months,o.month_n,round((sum(o.qty)*avg(p.price)*(1-avg(o.coupon_discount)/100))::numeric,2) as Debit_Card_amt from 
product as p join orders as o on o.p_id=p.p_id join transactions as t on t.or_id=o.or_id where t.transaction_mode='Debit Card'
group by o.months,o.month_n order by o.month_n asc) as Debit_Card)
select months,month_n, case when pre_Debit_Card_amt=0 then 0 else round(((Debit_Card_amt-pre_Debit_Card_amt)/pre_Debit_Card_amt*100)::numeric,2) 
end as MOM_Debit_Card from Debit_Card_amt),
Credit_Card as
(with Credit_Card_amt as 
(select *, lag(Credit_Card_amt,1,0) over() as pre_Credit_Card_amt from
(with orders as ( select *,to_char(order_date,'month') as months, extract('month' from order_date) as month_n from orders)
select o.months,o.month_n,round((sum(o.qty)*avg(p.price)*(1-avg(o.coupon_discount)/100))::numeric,2) as Credit_Card_amt from 
product as p join orders as o on o.p_id=p.p_id join transactions as t on t.or_id=o.or_id where t.transaction_mode='Credit Card'
group by o.months,o.month_n order by o.month_n asc) as Credit_Card)
select months,month_n, case when pre_Credit_Card_amt=0 then 0 else round(((Credit_Card_amt-pre_Credit_Card_amt)/pre_Credit_Card_amt*100)::numeric,2) 
end as MOM_Credit_Card from Credit_Card_amt),
COD as
(with COD_amt as 
(select *, lag(COD_amt,1,0) over() as pre_COD_amt from
(with orders as ( select *,to_char(order_date,'month') as months, extract('month' from order_date) as month_n from orders)
select o.months,o.month_n,round((sum(o.qty)*avg(p.price)*(1-avg(o.coupon_discount)/100))::numeric,2) as COD_amt from 
product as p join orders as o on o.p_id=p.p_id join transactions as t on t.or_id=o.or_id where t.transaction_mode='COD'
group by o.months,o.month_n order by o.month_n asc) as COD)
select months,month_n, case when pre_COD_amt=0 then 0 else round(((COD_amt-pre_COD_amt)/pre_COD_amt*100)::numeric,2) 
end as MOM_COD from COD_amt)
select w.months,w.MOM_Wallet,u.MOM_UPI,dc.MOM_Debit_Card,cc.MOM_Credit_Card,co.MOM_COD from Wallet as w join UPI as u on 
u.months=w.months join Debit_Card as dc on dc.months=w.months join Credit_Card as cc on cc.months=w.months join COD as co 
on co.months=w.months order by w.month_n ;

/* E. Delivery Partner Analysis */
-- 1.	What is the average rating for each delivery partner, along with earnings and orders handled, Tier by Tier ?
with tier_1 as
(select d.dp_name,round(avg(r.delivery_service_rating)::numeric,2) as rating_tier_1 ,
round((sum(o.qty)*avg(p.price)*(1-avg(o.coupon_discount)/100)*(avg(d.percent_cut)/100))::numeric,2) as amount_tier_1 
from customer as c join orders as o on o.c_id=c.c_id join product as p on p.p_id=o.p_id 
join delivery as d on d.dp_id=o.dp_id join rating as r on r.or_id=o.or_id  where c.tier='Tier 1'  
group by d.dp_name),
tier_2 as
(select d.dp_name,round(avg(r.delivery_service_rating)::numeric,2) as rating_tier_2 ,
round((sum(o.qty)*avg(p.price)*(1-avg(o.coupon_discount)/100)*(avg(d.percent_cut)/100))::numeric,2) as amount_tier_2 
from customer as c join orders as o on o.c_id=c.c_id join product as p on p.p_id=o.p_id 
join delivery as d on d.dp_id=o.dp_id join rating as r on r.or_id=o.or_id  where c.tier='Tier 2'  
group by d.dp_name),
tier_3 as
(select d.dp_name,round(avg(r.delivery_service_rating)::numeric,2) as rating_tier_3 ,
round((sum(o.qty)*avg(p.price)*(1-avg(o.coupon_discount)/100)*(avg(d.percent_cut)/100))::numeric,2) as amount_tier_3 
from customer as c join orders as o on o.c_id=c.c_id join product as p on p.p_id=o.p_id 
join delivery as d on d.dp_id=o.dp_id join rating as r on r.or_id=o.or_id  where c.tier='Tier 3'  
group by d.dp_name),
tier_4 as
(select d.dp_name,round(avg(r.delivery_service_rating)::numeric,2) as rating_tier_4 ,
round((sum(o.qty)*avg(p.price)*(1-avg(o.coupon_discount)/100)*(avg(d.percent_cut)/100))::numeric,2) as amount_tier_4
from customer as c join orders as o on o.c_id=c.c_id join product as p on p.p_id=o.p_id 
join delivery as d on d.dp_id=o.dp_id join rating as r on r.or_id=o.or_id  where c.tier='Tier 4'  
group by d.dp_name)
select t1.dp_name,t1.rating_tier_1,t1.amount_tier_1,t2.rating_tier_2,t2.amount_tier_2,t3.rating_tier_3,t3.amount_tier_3,
t4.rating_tier_4,t4.amount_tier_4 from tier_1 as t1 join tier_2 as t2 on t1.dp_name=t2.dp_name join tier_3 as t3 on 
t3.dp_name=t1.dp_name join tier_4 as t4 on t4.dp_name=t1.dp_name;

-- 2.	Which delivery partners have the highest and lowest ratings by product category  in different Company, along with amount?
with total_dev as 
(select * from
(with Britannia as
(select * from 
(select * , row_number() over (partition by category order by rating_Britannia desc) as rk_Britannia from 
(select p.category,d.dp_name as Britannia_delivery,round(avg(r.delivery_service_rating)::numeric,2) as rating_Britannia,
round((sum(o.qty)*avg(p.price)*(1-avg(o.coupon_discount)/100)*(avg(d.percent_cut)/100))::numeric,2) as amount_Britannia
from product as p join orders as o on o.p_id=p.p_id join delivery as d on d.dp_id=o.dp_id join rating as r
on r.or_id=o.or_id where p.brand='Britannia'  group by p.category,d.dp_name) as r_Britannia) as Britannia_r where rk_Britannia=1),
Nestle as
(select * from 
(select * , row_number() over (partition by category order by rating_Nestle desc) as rk_Nestle from 
(select p.category,d.dp_name as Nestle_delivery,round(avg(r.delivery_service_rating)::numeric,2) as rating_Nestle,
round((sum(o.qty)*avg(p.price)*(1-avg(o.coupon_discount)/100)*(avg(d.percent_cut)/100))::numeric,2) as amount_Nestle
from product as p join orders as o on o.p_id=p.p_id join delivery as d on d.dp_id=o.dp_id join rating as r
on r.or_id=o.or_id where p.brand='Nestle'  group by p.category,d.dp_name) as r_Nestle) as Nestle_r where rk_Nestle=1),
Haldirams as
(select * from 
(select * , row_number() over (partition by category order by rating_Haldirams desc) as rk_Haldirams from 
(select p.category,d.dp_name as Haldirams_delivery,round(avg(r.delivery_service_rating)::numeric,2) as rating_Haldirams,
round((sum(o.qty)*avg(p.price)*(1-avg(o.coupon_discount)/100)*(avg(d.percent_cut)/100))::numeric,2) as amount_Haldirams
from product as p join orders as o on o.p_id=p.p_id join delivery as d on d.dp_id=o.dp_id join rating as r
on r.or_id=o.or_id where p.brand='Haldirams'  group by p.category,d.dp_name) as r_Haldirams) as Haldirams_r where rk_Haldirams=1),
Parle as
(select * from 
(select * , row_number() over (partition by category order by rating_Parle desc) as rk_Parle from 
(select p.category,d.dp_name as Parle_delivery,round(avg(r.delivery_service_rating)::numeric,2) as rating_Parle,
round((sum(o.qty)*avg(p.price)*(1-avg(o.coupon_discount)/100)*(avg(d.percent_cut)/100))::numeric,2) as amount_Parle
from product as p join orders as o on o.p_id=p.p_id join delivery as d on d.dp_id=o.dp_id join rating as r
on r.or_id=o.or_id where p.brand='Parle'  group by p.category,d.dp_name) as r_Parle) as Parle_r where rk_Parle=1),
Dabur as
(select * from 
(select * , row_number() over (partition by category order by rating_Dabur desc) as rk_Dabur from 
(select p.category,d.dp_name as Dabur_delivery,round(avg(r.delivery_service_rating)::numeric,2) as rating_Dabur,
round((sum(o.qty)*avg(p.price)*(1-avg(o.coupon_discount)/100)*(avg(d.percent_cut)/100))::numeric,2) as amount_Dabur
from product as p join orders as o on o.p_id=p.p_id join delivery as d on d.dp_id=o.dp_id join rating as r
on r.or_id=o.or_id where p.brand='Dabur'  group by p.category,d.dp_name) as r_Dabur) as Dabur_r where rk_Dabur=1),
Amul as
(select * from 
(select * , row_number() over (partition by category order by rating_Amul desc) as rk_Amul from 
(select p.category,d.dp_name as Amul_delivery,round(avg(r.delivery_service_rating)::numeric,2) as rating_Amul,
round((sum(o.qty)*avg(p.price)*(1-avg(o.coupon_discount)/100)*(avg(d.percent_cut)/100))::numeric,2) as amount_Amul
from product as p join orders as o on o.p_id=p.p_id join delivery as d on d.dp_id=o.dp_id join rating as r
on r.or_id=o.or_id where p.brand='Amul'  group by p.category,d.dp_name) as r_Amul) as Amul_r where rk_Amul=1)
select b.category,b.Britannia_delivery,b.rating_Britannia,b.amount_Britannia,n.Nestle_delivery,n.rating_Nestle,n.amount_Nestle,
h.Haldirams_delivery,h.rating_Haldirams,h.amount_Haldirams,p.Parle_delivery,p.rating_Parle,p.amount_Parle,
d.Dabur_delivery,d.rating_Dabur,d.amount_Dabur,a.Amul_delivery,a.rating_Amul,a.amount_Amul from  Britannia as b join
Nestle as n on n.category=b.category join Haldirams as h on h.category=b.category join Parle as p on p.category = b.category join
Dabur as d on d.category=b.category join Amul as a on a.category=b.category ) union all
select * from
(with Britannia as
(select * from 
(select * , row_number() over (partition by category order by rating_Britannia asc) as rk_Britannia from 
(select p.category,d.dp_name as Britannia_delivery,round(avg(r.delivery_service_rating)::numeric,2) as rating_Britannia,
round((sum(o.qty)*avg(p.price)*(1-avg(o.coupon_discount)/100)*(avg(d.percent_cut)/100))::numeric,2) as amount_Britannia
from product as p join orders as o on o.p_id=p.p_id join delivery as d on d.dp_id=o.dp_id join rating as r
on r.or_id=o.or_id where p.brand='Britannia'  group by p.category,d.dp_name) as r_Britannia) as Britannia_r where rk_Britannia=1),
Nestle as
(select * from 
(select * , row_number() over (partition by category order by rating_Nestle asc) as rk_Nestle from 
(select p.category,d.dp_name as Nestle_delivery,round(avg(r.delivery_service_rating)::numeric,2) as rating_Nestle,
round((sum(o.qty)*avg(p.price)*(1-avg(o.coupon_discount)/100)*(avg(d.percent_cut)/100))::numeric,2) as amount_Nestle
from product as p join orders as o on o.p_id=p.p_id join delivery as d on d.dp_id=o.dp_id join rating as r
on r.or_id=o.or_id where p.brand='Nestle'  group by p.category,d.dp_name) as r_Nestle) as Nestle_r where rk_Nestle=1),
Haldirams as
(select * from 
(select * , row_number() over (partition by category order by rating_Haldirams asc) as rk_Haldirams from 
(select p.category,d.dp_name as Haldirams_delivery,round(avg(r.delivery_service_rating)::numeric,2) as rating_Haldirams,
round((sum(o.qty)*avg(p.price)*(1-avg(o.coupon_discount)/100)*(avg(d.percent_cut)/100))::numeric,2) as amount_Haldirams
from product as p join orders as o on o.p_id=p.p_id join delivery as d on d.dp_id=o.dp_id join rating as r
on r.or_id=o.or_id where p.brand='Haldirams'  group by p.category,d.dp_name) as r_Haldirams) as Haldirams_r where rk_Haldirams=1),
Parle as
(select * from 
(select * , row_number() over (partition by category order by rating_Parle asc) as rk_Parle from 
(select p.category,d.dp_name as Parle_delivery,round(avg(r.delivery_service_rating)::numeric,2) as rating_Parle,
round((sum(o.qty)*avg(p.price)*(1-avg(o.coupon_discount)/100)*(avg(d.percent_cut)/100))::numeric,2) as amount_Parle
from product as p join orders as o on o.p_id=p.p_id join delivery as d on d.dp_id=o.dp_id join rating as r
on r.or_id=o.or_id where p.brand='Parle'  group by p.category,d.dp_name) as r_Parle) as Parle_r where rk_Parle=1),
Dabur as
(select * from 
(select * , row_number() over (partition by category order by rating_Dabur asc) as rk_Dabur from 
(select p.category,d.dp_name as Dabur_delivery,round(avg(r.delivery_service_rating)::numeric,2) as rating_Dabur,
round((sum(o.qty)*avg(p.price)*(1-avg(o.coupon_discount)/100)*(avg(d.percent_cut)/100))::numeric,2) as amount_Dabur
from product as p join orders as o on o.p_id=p.p_id join delivery as d on d.dp_id=o.dp_id join rating as r
on r.or_id=o.or_id where p.brand='Dabur'  group by p.category,d.dp_name) as r_Dabur) as Dabur_r where rk_Dabur=1),
Amul as
(select * from 
(select * , row_number() over (partition by category order by rating_Amul asc) as rk_Amul from 
(select p.category,d.dp_name as Amul_delivery,round(avg(r.delivery_service_rating)::numeric,2) as rating_Amul,
round((sum(o.qty)*avg(p.price)*(1-avg(o.coupon_discount)/100)*(avg(d.percent_cut)/100))::numeric,2) as amount_Amul
from product as p join orders as o on o.p_id=p.p_id join delivery as d on d.dp_id=o.dp_id join rating as r
on r.or_id=o.or_id where p.brand='Amul'  group by p.category,d.dp_name) as r_Amul) as Amul_r where rk_Amul=1)
select b.category,b.Britannia_delivery,b.rating_Britannia,b.amount_Britannia,n.Nestle_delivery,n.rating_Nestle,n.amount_Nestle,
h.Haldirams_delivery,h.rating_Haldirams,h.amount_Haldirams,p.Parle_delivery,p.rating_Parle,p.amount_Parle,
d.Dabur_delivery,d.rating_Dabur,d.amount_Dabur,a.Amul_delivery,a.rating_Amul,a.amount_Amul from  Britannia as b join
Nestle as n on n.category=b.category join Haldirams as h on h.category=b.category join Parle as p on p.category = b.category join
Dabur as d on d.category=b.category join Amul as a on a.category=b.category) )
select * from total_dev order by category;

-- 3.	How many orders did each delivery partner handle, and what are their ratings, by product ?
with Delhivery as 
(select p.pname,count(o.or_id) as orders_Delhivery, round(avg(r.delivery_service_rating)::numeric,2) as delivery_rating_Delhivery, 
round((sum(o.qty)*avg(p.price)*(1-avg(o.coupon_discount)/100)*avg(d.percent_cut)/100)::numeric,2) as amount_Delhivery
from product as p join orders as o on o.p_id=p.p_id join rating as r on r.or_id=o.or_id join delivery as d on
d.dp_id=o.dp_id where d.dp_name='Delhivery'  group by p.pname ),
Blue_Dart as
(select p.pname,count(o.or_id) as orders_Blue_Dart , round(avg(r.delivery_service_rating)::numeric,2) as delivery_rating_Blue_Dart, 
round((sum(o.qty)*avg(p.price)*(1-avg(o.coupon_discount)/100)*avg(d.percent_cut)/100)::numeric,2) as amount_Blue_Dart
from product as p join orders as o on o.p_id=p.p_id join rating as r on r.or_id=o.or_id join delivery as d on
d.dp_id=o.dp_id where d.dp_name='Blue Dart' group by p.pname),
Ecom_Express as
(select p.pname,count(o.or_id) as orders_Ecom_Express , round(avg(r.delivery_service_rating)::numeric,2) as delivery_rating_Ecom_Express, 
round((sum(o.qty)*avg(p.price)*(1-avg(o.coupon_discount)/100)*avg(d.percent_cut)/100)::numeric,2) as amount_Ecom_Express
from product as p join orders as o on o.p_id=p.p_id join rating as r on r.or_id=o.or_id join delivery as d on
d.dp_id=o.dp_id where d.dp_name='Ecom Express' group by p.pname), 
Shadowfax as
(select p.pname,count(o.or_id) as orders_Shadowfax , round(avg(r.delivery_service_rating)::numeric,2) as delivery_rating_Shadowfax, 
round((sum(o.qty)*avg(p.price)*(1-avg(o.coupon_discount)/100)*avg(d.percent_cut)/100)::numeric,2) as amount_Shadowfax
from product as p join orders as o on o.p_id=p.p_id join rating as r on r.or_id=o.or_id join delivery as d on
d.dp_id=o.dp_id where d.dp_name='Shadowfax' group by p.pname),
Xpressbees  as
(select p.pname,count(o.or_id) as orders_Xpressbees , round(avg(r.delivery_service_rating)::numeric,2) as delivery_rating_Xpressbees, 
round((sum(o.qty)*avg(p.price)*(1-avg(o.coupon_discount)/100)*avg(d.percent_cut)/100)::numeric,2) as amount_Xpressbees
from product as p join orders as o on o.p_id=p.p_id join rating as r on r.or_id=o.or_id join delivery as d on
d.dp_id=o.dp_id where d.dp_name='Xpressbees' group by p.pname)
select d.pname,d.orders_Delhivery,d.delivery_rating_Delhivery,d.amount_Delhivery,b.orders_Blue_Dart,b.delivery_rating_Blue_Dart,
b.amount_Blue_Dart,e.orders_Ecom_Express,e.delivery_rating_Ecom_Express, e.amount_Ecom_Express,s.orders_Shadowfax,
s.delivery_rating_Shadowfax,s.amount_Shadowfax,x.orders_Xpressbees,x.delivery_rating_Xpressbees,x.amount_Xpressbees
from Delhivery as d join Blue_Dart as b on d.pname=b.pname join Ecom_Express as e on e.pname=d.pname join Shadowfax
as s on s.pname=d.pname join Xpressbees as x on x.pname=d.pname ;

-- 4.	Which delivery partner had the highest and lowest order volumes for each month , along with earnings, in different tier?
with tier1 as
(select * from 
(select *, row_number() over (partition by months order by qty_Tier_1 desc) as rank_Tier_1 from 
(with orders as (select *, to_char(order_date,'month') as months, extract('months' from order_date) month_n from orders )
select o.months,o.month_n,d.dp_name as Delivery_Tier_1,sum(o.qty) as qty_Tier_1,
round((sum(o.qty)*avg(p.price)*(1-avg(o.coupon_discount)/100)*avg(d.percent_cut)/100)::numeric,2) as amount_Tier_1
from orders as o join customer as c on c.c_id=o.c_id join product as p on p.p_id=o.p_id join delivery as d on d.dp_id=o.dp_id
where c.tier='Tier 1' group by o.months,o.month_n,d.dp_name order by o.month_n) as rk_Tier_1) 
as r_Tier_1 where r_Tier_1.rank_Tier_1=1 order by month_n),
tier2 as
(select * from 
(select *, row_number() over (partition by months order by qty_Tier_2 desc) as rank_Tier_2 from 
(with orders as (select *, to_char(order_date,'month') as months, extract('months' from order_date) month_n from orders )
select o.months,o.month_n,d.dp_name as Delivery_Tier_2,sum(o.qty) as qty_Tier_2,
round((sum(o.qty)*avg(p.price)*(1-avg(o.coupon_discount)/100)*avg(d.percent_cut)/100)::numeric,2) as amount_Tier_2
from orders as o join customer as c on c.c_id=o.c_id join product as p on p.p_id=o.p_id join delivery as d on d.dp_id=o.dp_id
where c.tier='Tier 2' group by o.months,o.month_n,d.dp_name order by o.month_n) as rk_Tier_2) 
as r_Tier_2 where r_Tier_2.rank_Tier_2=1 order by month_n),
tier3 as
(select * from 
(select *, row_number() over (partition by months order by qty_Tier_3 desc) as rank_Tier_3 from 
(with orders as (select *, to_char(order_date,'month') as months, extract('months' from order_date) month_n from orders )
select o.months,o.month_n,d.dp_name as Delivery_Tier_3,sum(o.qty) as qty_Tier_3,
round((sum(o.qty)*avg(p.price)*(1-avg(o.coupon_discount)/100)*avg(d.percent_cut)/100)::numeric,2) as amount_Tier_3
from orders as o join customer as c on c.c_id=o.c_id join product as p on p.p_id=o.p_id join delivery as d on d.dp_id=o.dp_id
where c.tier='Tier 3' group by o.months,o.month_n,d.dp_name order by o.month_n) as rk_Tier_2) 
as r_Tier_3 where r_Tier_3.rank_Tier_3=1 order by month_n),
tier4 as
(select * from 
(select *, row_number() over (partition by months order by qty_Tier_4 desc) as rank_Tier_4 from 
(with orders as (select *, to_char(order_date,'month') as months, extract('months' from order_date) month_n from orders )
select o.months,o.month_n,d.dp_name as Delivery_Tier_4,sum(o.qty) as qty_Tier_4,
round((sum(o.qty)*avg(p.price)*(1-avg(o.coupon_discount)/100)*avg(d.percent_cut)/100)::numeric,2) as amount_Tier_4
from orders as o join customer as c on c.c_id=o.c_id join product as p on p.p_id=o.p_id join delivery as d on d.dp_id=o.dp_id
where c.tier='Tier 4' group by o.months,o.month_n,d.dp_name order by o.month_n) as rk_Tier_4) 
as r_Tier_4 where r_Tier_4.rank_Tier_4=1 order by month_n)
select t1.months,t1.month_n,t1.Delivery_Tier_1,t1.qty_Tier_1,t1.amount_Tier_1,t2.Delivery_Tier_2,t2.qty_Tier_2,t2.amount_Tier_2,
t3.Delivery_Tier_3,t3.qty_Tier_3,t3.amount_Tier_3,t4.Delivery_Tier_4,t4.qty_Tier_4,t4.amount_Tier_4 from tier1 as t1 join tier2 as t2 
on t1.months=t2.months join tier3 as t3 on t1.months=t3.months join tier4 as t4 on t4.months=t1.months order by t1.month_n;


-- 4.	Which delivery partner had the highest and lowest order volumes for each month , along with earnings, in different tier?
with total_tier as 
(select * from 
(with tier1 as
(select * from 
(select *, row_number() over (partition by months order by qty_Tier_1 desc) as rank_Tier_1 from 
(with orders as (select *, to_char(order_date,'month') as months, extract('months' from order_date) month_n from orders )
select o.months,o.month_n,d.dp_name as Delivery_Tier_1,sum(o.qty) as qty_Tier_1,
round((sum(o.qty)*avg(p.price)*(1-avg(o.coupon_discount)/100)*avg(d.percent_cut)/100)::numeric,2) as amount_Tier_1
from orders as o join customer as c on c.c_id=o.c_id join product as p on p.p_id=o.p_id join delivery as d on d.dp_id=o.dp_id
where c.tier='Tier 1' group by o.months,o.month_n,d.dp_name order by o.month_n) as rk_Tier_1) 
as r_Tier_1 where r_Tier_1.rank_Tier_1=1 order by month_n),
tier2 as
(select * from 
(select *, row_number() over (partition by months order by qty_Tier_2 desc) as rank_Tier_2 from 
(with orders as (select *, to_char(order_date,'month') as months, extract('months' from order_date) month_n from orders )
select o.months,o.month_n,d.dp_name as Delivery_Tier_2,sum(o.qty) as qty_Tier_2,
round((sum(o.qty)*avg(p.price)*(1-avg(o.coupon_discount)/100)*avg(d.percent_cut)/100)::numeric,2) as amount_Tier_2
from orders as o join customer as c on c.c_id=o.c_id join product as p on p.p_id=o.p_id join delivery as d on d.dp_id=o.dp_id
where c.tier='Tier 2' group by o.months,o.month_n,d.dp_name order by o.month_n) as rk_Tier_2) 
as r_Tier_2 where r_Tier_2.rank_Tier_2=1 order by month_n),
tier3 as
(select * from 
(select *, row_number() over (partition by months order by qty_Tier_3 desc) as rank_Tier_3 from 
(with orders as (select *, to_char(order_date,'month') as months, extract('months' from order_date) month_n from orders )
select o.months,o.month_n,d.dp_name as Delivery_Tier_3,sum(o.qty) as qty_Tier_3,
round((sum(o.qty)*avg(p.price)*(1-avg(o.coupon_discount)/100)*avg(d.percent_cut)/100)::numeric,2) as amount_Tier_3
from orders as o join customer as c on c.c_id=o.c_id join product as p on p.p_id=o.p_id join delivery as d on d.dp_id=o.dp_id
where c.tier='Tier 3' group by o.months,o.month_n,d.dp_name order by o.month_n) as rk_Tier_2) 
as r_Tier_3 where r_Tier_3.rank_Tier_3=1 order by month_n),
tier4 as
(select * from 
(select *, row_number() over (partition by months order by qty_Tier_4 desc) as rank_Tier_4 from 
(with orders as (select *, to_char(order_date,'month') as months, extract('months' from order_date) month_n from orders )
select o.months,o.month_n,d.dp_name as Delivery_Tier_4,sum(o.qty) as qty_Tier_4,
round((sum(o.qty)*avg(p.price)*(1-avg(o.coupon_discount)/100)*avg(d.percent_cut)/100)::numeric,2) as amount_Tier_4
from orders as o join customer as c on c.c_id=o.c_id join product as p on p.p_id=o.p_id join delivery as d on d.dp_id=o.dp_id
where c.tier='Tier 4' group by o.months,o.month_n,d.dp_name order by o.month_n) as rk_Tier_4) 
as r_Tier_4 where r_Tier_4.rank_Tier_4=1 order by month_n)
select t1.months,t1.month_n,t1.Delivery_Tier_1,t1.qty_Tier_1,t1.amount_Tier_1,t2.Delivery_Tier_2,t2.qty_Tier_2,t2.amount_Tier_2,
t3.Delivery_Tier_3,t3.qty_Tier_3,t3.amount_Tier_3,t4.Delivery_Tier_4,t4.qty_Tier_4,t4.amount_Tier_4 from tier1 as t1 join tier2 as t2 
on t1.months=t2.months join tier3 as t3 on t1.months=t3.months join tier4 as t4 on t4.months=t1.months order by t1.month_n) union all
select * from
(with tier1 as
(select * from 
(select *, row_number() over (partition by months order by qty_Tier_1 asc) as rank_Tier_1 from 
(with orders as (select *, to_char(order_date,'month') as months, extract('months' from order_date) month_n from orders )
select o.months,o.month_n,d.dp_name as Delivery_Tier_1,sum(o.qty) as qty_Tier_1,
round((sum(o.qty)*avg(p.price)*(1-avg(o.coupon_discount)/100)*avg(d.percent_cut)/100)::numeric,2) as amount_Tier_1
from orders as o join customer as c on c.c_id=o.c_id join product as p on p.p_id=o.p_id join delivery as d on d.dp_id=o.dp_id
where c.tier='Tier 1' group by o.months,o.month_n,d.dp_name order by o.month_n) as rk_Tier_1) 
as r_Tier_1 where r_Tier_1.rank_Tier_1=1 order by month_n),
tier2 as
(select * from 
(select *, row_number() over (partition by months order by qty_Tier_2 asc) as rank_Tier_2 from 
(with orders as (select *, to_char(order_date,'month') as months, extract('months' from order_date) month_n from orders )
select o.months,o.month_n,d.dp_name as Delivery_Tier_2,sum(o.qty) as qty_Tier_2,
round((sum(o.qty)*avg(p.price)*(1-avg(o.coupon_discount)/100)*avg(d.percent_cut)/100)::numeric,2) as amount_Tier_2
from orders as o join customer as c on c.c_id=o.c_id join product as p on p.p_id=o.p_id join delivery as d on d.dp_id=o.dp_id
where c.tier='Tier 2' group by o.months,o.month_n,d.dp_name order by o.month_n) as rk_Tier_2) 
as r_Tier_2 where r_Tier_2.rank_Tier_2=1 order by month_n),
tier3 as
(select * from 
(select *, row_number() over (partition by months order by qty_Tier_3 asc) as rank_Tier_3 from 
(with orders as (select *, to_char(order_date,'month') as months, extract('months' from order_date) month_n from orders )
select o.months,o.month_n,d.dp_name as Delivery_Tier_3,sum(o.qty) as qty_Tier_3,
round((sum(o.qty)*avg(p.price)*(1-avg(o.coupon_discount)/100)*avg(d.percent_cut)/100)::numeric,2) as amount_Tier_3
from orders as o join customer as c on c.c_id=o.c_id join product as p on p.p_id=o.p_id join delivery as d on d.dp_id=o.dp_id
where c.tier='Tier 3' group by o.months,o.month_n,d.dp_name order by o.month_n) as rk_Tier_2) 
as r_Tier_3 where r_Tier_3.rank_Tier_3=1 order by month_n),
tier4 as
(select * from 
(select *, row_number() over (partition by months order by qty_Tier_4 asc) as rank_Tier_4 from 
(with orders as (select *, to_char(order_date,'month') as months, extract('months' from order_date) month_n from orders )
select o.months,o.month_n,d.dp_name as Delivery_Tier_4,sum(o.qty) as qty_Tier_4,
round((sum(o.qty)*avg(p.price)*(1-avg(o.coupon_discount)/100)*avg(d.percent_cut)/100)::numeric,2) as amount_Tier_4
from orders as o join customer as c on c.c_id=o.c_id join product as p on p.p_id=o.p_id join delivery as d on d.dp_id=o.dp_id
where c.tier='Tier 4' group by o.months,o.month_n,d.dp_name order by o.month_n) as rk_Tier_4) 
as r_Tier_4 where r_Tier_4.rank_Tier_4=1 order by month_n)
select t1.months,t1.month_n,t1.Delivery_Tier_1,t1.qty_Tier_1,t1.amount_Tier_1,t2.Delivery_Tier_2,t2.qty_Tier_2,t2.amount_Tier_2,
t3.Delivery_Tier_3,t3.qty_Tier_3,t3.amount_Tier_3,t4.Delivery_Tier_4,t4.qty_Tier_4,t4.amount_Tier_4 from tier1 as t1 join tier2 as t2 
on t1.months=t2.months join tier3 as t3 on t1.months=t3.months join tier4 as t4 on t4.months=t1.months order by t1.month_n) )
select months,Delivery_Tier_1,qty_Tier_1,amount_Tier_1,Delivery_Tier_2,qty_Tier_2,amount_Tier_2,
Delivery_Tier_3,qty_Tier_3,amount_Tier_3,Delivery_Tier_4,qty_Tier_4,amount_Tier_4 from total_tier order by month_n ;

-- 5.	How many orders, ratings, and average earnings do delivery partners have by product category , find top 2?
select category,dp_name,orders,delivery_rating,avg_amount from 
(select *, row_number() over(partition by category order by orders desc) as ranks from
(select p.category,d.dp_name,count(o.or_id) as orders, round(avg(r.delivery_service_rating)::numeric,2) as delivery_rating ,
round((avg(o.qty)*avg(p.price)*(1-avg(o.coupon_discount)/100)*avg(d.percent_cut)/100)::numeric,2) as avg_amount
from product as p join orders as o on o.p_id=p.p_id join delivery as d on d.dp_id=o.dp_id join customer as c on c.c_id=o.c_id
join rating as r on r.or_id=o.or_id group by p.category,d.dp_name) as rnk) as rk where rk.ranks<=2;

-- 6.	How do delivery partner earnings change month over month (MOM) ?
with Delhivery as
(with m_Delhivery as 
(select *, lag(amount_Delhivery,1,0) over() as pre_amount_Delhivery from 
(with orders as (select *, to_char(order_date,'month') as months, extract('months' from order_date) month_n from orders )
select o.months,o.month_n,round((sum(o.qty)*avg(p.price)*(1-avg(o.coupon_discount)/100)*avg(d.percent_cut)/100)::numeric,2) as amount_Delhivery
from orders as o join product as p on p.p_id=o.p_id join delivery as d on d.dp_id=o.dp_id where d.dp_name='Delhivery' group by o.months,o.month_n 
order by o.month_n ) as a_Delhivery)  select months,month_n, case when pre_amount_Delhivery=0 then 0 else 
round( ((amount_Delhivery-pre_amount_Delhivery)/pre_amount_Delhivery*100)::numeric,2) end as MOM_Delhivery from m_Delhivery),
Blue_Dart as
(with m_Blue_Dart as 
(select *, lag(amount_Blue_Dart,1,0) over() as pre_amount_Blue_Dart from 
(with orders as (select *, to_char(order_date,'month') as months, extract('months' from order_date) month_n from orders )
select o.months,o.month_n,round((sum(o.qty)*avg(p.price)*(1-avg(o.coupon_discount)/100)*avg(d.percent_cut)/100)::numeric,2) as amount_Blue_Dart
from orders as o join product as p on p.p_id=o.p_id join delivery as d on d.dp_id=o.dp_id where d.dp_name='Blue Dart' group by o.months,o.month_n 
order by o.month_n ) as a_Blue_Dart)  select months,month_n, case when pre_amount_Blue_Dart=0 then 0 else 
round( ((amount_Blue_Dart-pre_amount_Blue_Dart)/pre_amount_Blue_Dart*100)::numeric,2) end as MOM_Blue_Dart from m_Blue_Dart),
Ecom_Express as
(with m_Ecom_Express as 
(select *, lag(amount_Ecom_Express,1,0) over() as pre_amount_Ecom_Express from 
(with orders as (select *, to_char(order_date,'month') as months, extract('months' from order_date) month_n from orders )
select o.months,o.month_n,round((sum(o.qty)*avg(p.price)*(1-avg(o.coupon_discount)/100)*avg(d.percent_cut)/100)::numeric,2) as amount_Ecom_Express
from orders as o join product as p on p.p_id=o.p_id join delivery as d on d.dp_id=o.dp_id where d.dp_name='Ecom Express' group by o.months,o.month_n 
order by o.month_n ) as a_Ecom_Express)  select months,month_n, case when pre_amount_Ecom_Express=0 then 0 else 
round( ((amount_Ecom_Express-pre_amount_Ecom_Express)/pre_amount_Ecom_Express*100)::numeric,2) end as MOM_Ecom_Express from m_Ecom_Express),
Shadowfax as
(with m_Shadowfax as 
(select *, lag(amount_Shadowfax,1,0) over() as pre_amount_Shadowfax from 
(with orders as (select *, to_char(order_date,'month') as months, extract('months' from order_date) month_n from orders )
select o.months,o.month_n,round((sum(o.qty)*avg(p.price)*(1-avg(o.coupon_discount)/100)*avg(d.percent_cut)/100)::numeric,2) as amount_Shadowfax
from orders as o join product as p on p.p_id=o.p_id join delivery as d on d.dp_id=o.dp_id where d.dp_name='Shadowfax' group by o.months,o.month_n 
order by o.month_n ) as a_Shadowfax)  select months,month_n, case when pre_amount_Shadowfax=0 then 0 else 
round( ((amount_Shadowfax-pre_amount_Shadowfax)/pre_amount_Shadowfax*100)::numeric,2) end as MOM_Shadowfax from m_Shadowfax),
Xpressbees as
(with m_Xpressbees as 
(select *, lag(amount_Xpressbees,1,0) over() as pre_amount_Xpressbees from 
(with orders as (select *, to_char(order_date,'month') as months, extract('months' from order_date) month_n from orders )
select o.months,o.month_n,round((sum(o.qty)*avg(p.price)*(1-avg(o.coupon_discount)/100)*avg(d.percent_cut)/100)::numeric,2) as amount_Xpressbees
from orders as o join product as p on p.p_id=o.p_id join delivery as d on d.dp_id=o.dp_id where d.dp_name='Xpressbees' group by o.months,o.month_n 
order by o.month_n ) as a_Xpressbees)  select months,month_n, case when pre_amount_Xpressbees=0 then 0 else 
round( ((amount_Xpressbees-pre_amount_Xpressbees)/pre_amount_Xpressbees*100)::numeric,2) end as MOM_Xpressbees from m_Xpressbees)
select d.months,d.MOM_Delhivery,b.MOM_Blue_Dart, e.MOM_Ecom_Express, s.MOM_Shadowfax, x.MOM_Xpressbees 
from Delhivery as d join Blue_Dart as b on d.months=b.months join Ecom_Express as e on e.months=d.months join Shadowfax as s
on s.months=d.months join Xpressbees  as x on x.months=d.months order by d.month_n;

/* F. Ratings & Customer Feedback */
-- 1.	Which products have the highest and lowest ratings for each company, in each quarter?
with final_rate as
(select * from 
(with qtr1 as
(select * from 
(select *, row_number() over (partition by brand order by ratings_qtr1 desc ) as rank_qtr1 from
(with orders as ( select *, concat( 'Qtr ',extract('quarter' from order_date)) as qtr from orders)
select p.brand,p.pname as product_qtr1,round(avg(r.prod_rating)::numeric,2) as ratings_qtr1 ,
sum(o.qty) as qty_orders_qtr1  from product as p join orders as o
on o.p_id=p.p_id join rating as r on r.or_id=o.or_id where o.qtr='Qtr 1' group by p.brand,p.pname) as rk_qtr1)
r_qtr1 where r_qtr1.rank_qtr1=1),
qtr2 as
(select * from 
(select *, row_number() over (partition by brand order by ratings_qtr2 desc ) as rank_qtr2 from
(with orders as ( select *, concat( 'Qtr ',extract('quarter' from order_date)) as qtr from orders)
select p.brand,p.pname as product_qtr2,round(avg(r.prod_rating)::numeric,2) as ratings_qtr2,
sum(o.qty) as qty_orders_qtr2  from product as p join orders as o
on o.p_id=p.p_id join rating as r on r.or_id=o.or_id where o.qtr='Qtr 2' group by p.brand,p.pname) as rk_qtr2)
r_qtr2 where r_qtr2.rank_qtr2=1),
qtr3 as
(select * from 
(select *, row_number() over (partition by brand order by ratings_qtr3 desc ) as rank_qtr3 from
(with orders as ( select *, concat( 'Qtr ',extract('quarter' from order_date)) as qtr from orders)
select p.brand,p.pname as product_qtr3,round(avg(r.prod_rating)::numeric,2) as ratings_qtr3, 
sum(o.qty) as qty_orders_qtr3  from product as p join orders as o
on o.p_id=p.p_id join rating as r on r.or_id=o.or_id where o.qtr='Qtr 3' group by p.brand,p.pname) as rk_qtr3)
r_qtr3 where r_qtr3.rank_qtr3=1),
qtr4 as
(select * from 
(select *, row_number() over (partition by brand order by ratings_qtr4 desc ) as rank_qtr4 from
(with orders as ( select *, concat( 'Qtr ',extract('quarter' from order_date)) as qtr from orders)
select p.brand,p.pname as product_qtr4,round(avg(r.prod_rating)::numeric,2) as ratings_qtr4, 
sum(o.qty) as qty_orders_qtr4  from product as p join orders as o
on o.p_id=p.p_id join rating as r on r.or_id=o.or_id where o.qtr='Qtr 4' group by p.brand,p.pname) as rk_qtr4)
r_qtr4 where r_qtr4.rank_qtr4=1)
select q1.brand,q1.product_qtr1,ratings_qtr1,q1.qty_orders_qtr1 ,q2.product_qtr2,q2.ratings_qtr2,q2.qty_orders_qtr2,q3.product_qtr3,q3.ratings_qtr3,
q3.qty_orders_qtr3 , q4.product_qtr4,q4.ratings_qtr4, q4.qty_orders_qtr4  from qtr1 as q1 join qtr2 as q2 on q1.brand=q2.brand join qtr3 as q3 
on q3.brand=q1.brand join qtr4 as q4 on q4.brand=q1.brand ) union all
select * from
(with qtr1 as
(select * from 
(select *, row_number() over (partition by brand order by ratings_qtr1 asc ) as rank_qtr1 from
(with orders as ( select *, concat( 'Qtr ',extract('quarter' from order_date)) as qtr from orders)
select p.brand,p.pname as product_qtr1,round(avg(r.prod_rating)::numeric,2) as ratings_qtr1 ,
sum(o.qty) as qty_orders_qtr1  from product as p join orders as o
on o.p_id=p.p_id join rating as r on r.or_id=o.or_id where o.qtr='Qtr 1' group by p.brand,p.pname) as rk_qtr1)
r_qtr1 where r_qtr1.rank_qtr1=1),
qtr2 as
(select * from 
(select *, row_number() over (partition by brand order by ratings_qtr2 asc ) as rank_qtr2 from
(with orders as ( select *, concat( 'Qtr ',extract('quarter' from order_date)) as qtr from orders)
select p.brand,p.pname as product_qtr2,round(avg(r.prod_rating)::numeric,2) as ratings_qtr2,
sum(o.qty) as qty_orders_qtr2  from product as p join orders as o
on o.p_id=p.p_id join rating as r on r.or_id=o.or_id where o.qtr='Qtr 2' group by p.brand,p.pname) as rk_qtr2)
r_qtr2 where r_qtr2.rank_qtr2=1),
qtr3 as
(select * from 
(select *, row_number() over (partition by brand order by ratings_qtr3 asc ) as rank_qtr3 from
(with orders as ( select *, concat( 'Qtr ',extract('quarter' from order_date)) as qtr from orders)
select p.brand,p.pname as product_qtr3,round(avg(r.prod_rating)::numeric,2) as ratings_qtr3, 
sum(o.qty) as qty_orders_qtr3  from product as p join orders as o
on o.p_id=p.p_id join rating as r on r.or_id=o.or_id where o.qtr='Qtr 3' group by p.brand,p.pname) as rk_qtr3)
r_qtr3 where r_qtr3.rank_qtr3=1),
qtr4 as
(select * from 
(select *, row_number() over (partition by brand order by ratings_qtr4 asc ) as rank_qtr4 from
(with orders as ( select *, concat( 'Qtr ',extract('quarter' from order_date)) as qtr from orders)
select p.brand,p.pname as product_qtr4,round(avg(r.prod_rating)::numeric,2) as ratings_qtr4, 
sum(o.qty) as qty_orders_qtr4  from product as p join orders as o
on o.p_id=p.p_id join rating as r on r.or_id=o.or_id where o.qtr='Qtr 4' group by p.brand,p.pname) as rk_qtr4)
r_qtr4 where r_qtr4.rank_qtr4=1)
select q1.brand,q1.product_qtr1,ratings_qtr1,q1.qty_orders_qtr1 ,q2.product_qtr2,q2.ratings_qtr2,q2.qty_orders_qtr2,q3.product_qtr3,q3.ratings_qtr3,
q3.qty_orders_qtr3 , q4.product_qtr4,q4.ratings_qtr4, q4.qty_orders_qtr4  from qtr1 as q1 join qtr2 as q2 on q1.brand=q2.brand join qtr3 as q3 
on q3.brand=q1.brand join qtr4 as q4 on q4.brand=q1.brand) )
select * from final_rate order by brand ;

-- 2.	How many orders had delivery ratings below 3, by city and delivery partner, along with quantity and its total revenue ?
with Delhivery as
(with rating as (select * from rating where prod_rating<=3)
select c.city,count(o.or_id) as orders_Delhivery , sum(o.qty) as qty_Delhivery ,
round(( sum(o.qty)*avg(p.price)*(1-avg(o.coupon_discount)/100)*(avg(d.percent_cut)/100))::numeric,2)  as revenue_Delhivery
from customer as c join orders as o on o.c_id=c.c_id join 
rating as r on r.or_id=o.or_id join delivery as d on d.dp_id=o.dp_id join product as p on p.p_id=o.p_id
where d.dp_name='Delhivery' group by c.city),
Ecom_Express as
(with rating as (select * from rating where prod_rating<=3)
select c.city,count(o.or_id) as orders_Ecom_Express , sum(o.qty) as qty_Ecom_Express ,
round(( sum(o.qty)*avg(p.price)*(1-avg(o.coupon_discount)/100)*(avg(d.percent_cut)/100))::numeric,2)  as revenue_Ecom_Express
from customer as c join orders as o on o.c_id=c.c_id join 
rating as r on r.or_id=o.or_id join delivery as d on d.dp_id=o.dp_id join product as p on p.p_id=o.p_id
where d.dp_name='Ecom Express' group by c.city),
Blue_Dart as
(with rating as (select * from rating where prod_rating<=3)
select c.city,count(o.or_id) as orders_Blue_Dart , sum(o.qty) as qty_Blue_Dart ,
round(( sum(o.qty)*avg(p.price)*(1-avg(o.coupon_discount)/100)*(avg(d.percent_cut)/100))::numeric,2)  as revenue_Blue_Dart
from customer as c join orders as o on o.c_id=c.c_id join 
rating as r on r.or_id=o.or_id join delivery as d on d.dp_id=o.dp_id join product as p on p.p_id=o.p_id
where d.dp_name='Blue Dart' group by c.city),
Xpressbees as
(with rating as (select * from rating where prod_rating<=3)
select c.city,count(o.or_id) as orders_Xpressbees , sum(o.qty) as qty_Xpressbees ,
round(( sum(o.qty)*avg(p.price)*(1-avg(o.coupon_discount)/100)*(avg(d.percent_cut)/100))::numeric,2)  as revenue_Xpressbees
from customer as c join orders as o on o.c_id=c.c_id join 
rating as r on r.or_id=o.or_id join delivery as d on d.dp_id=o.dp_id join product as p on p.p_id=o.p_id
where d.dp_name='Xpressbees' group by c.city),
Shadowfax as
(with rating as (select * from rating where prod_rating<=3)
select c.city,count(o.or_id) as orders_Shadowfax , sum(o.qty) as qty_Shadowfax ,
round(( sum(o.qty)*avg(p.price)*(1-avg(o.coupon_discount)/100)*(avg(d.percent_cut)/100))::numeric,2)  as revenue_Shadowfax
from customer as c join orders as o on o.c_id=c.c_id join 
rating as r on r.or_id=o.or_id join delivery as d on d.dp_id=o.dp_id join product as p on p.p_id=o.p_id
where d.dp_name='Shadowfax' group by c.city)
select d.city,d.orders_Delhivery,d.qty_Delhivery,d.revenue_Delhivery,e.orders_Ecom_Express,e.qty_Ecom_Express,e.revenue_Ecom_Express,
b.orders_Blue_Dart,b.qty_Blue_Dart,b.revenue_Blue_Dart,x.orders_Xpressbees,x.qty_Xpressbees,x.revenue_Xpressbees,
s.orders_Shadowfax,s.qty_Shadowfax,s.revenue_Shadowfax from Delhivery as d join Ecom_Express as e on e.city=d.city join  
Blue_Dart as b on b.city=d.city join  Shadowfax as s on s.city=d.city join Xpressbees as x on x.city=d.city ;

-- 3.   How many orders gave the highest and lowest product ratings by category, in different region?
with pd_region as
(select * from 
(with North as
(select * from
(select *,row_number() over(partition by category order by rating_North desc) as ranks_North from
(select p.category,p.pname as Product_North, count( o.or_id) as orders_North,round(avg(r.prod_rating)::numeric,2) as rating_North 
from customer as c join orders as o on o.c_id=c.c_id join product as p on p.p_Id=o.p_id join rating as r on 
r.or_id=o.or_id where c.region='North'  group by p.category,p.pname) as rnk_North) as rk_North where rk_North.ranks_North=1), 
South as
(select * from
(select *,row_number() over(partition by category order by rating_South desc) as ranks_South from
(select p.category,p.pname as Product_South, count( o.or_id) as orders_South,round(avg(r.prod_rating)::numeric,2) as rating_South 
from customer as c join orders as o on o.c_id=c.c_id join product as p on p.p_Id=o.p_id join rating as r on 
r.or_id=o.or_id where c.region='South'  group by p.category,p.pname) as rnk_South) as rk_South where rk_South.ranks_South=1 ),
West as
(select * from
(select *,row_number() over(partition by category order by rating_West desc) as ranks_West from
(select p.category,p.pname as Product_West, count( o.or_id) as orders_West,round(avg(r.prod_rating)::numeric,2) as rating_West 
from customer as c join orders as o on o.c_id=c.c_id join product as p on p.p_Id=o.p_id join rating as r on 
r.or_id=o.or_id where c.region='West'  group by p.category,p.pname) as rnk_South) as rk_West where rk_West.ranks_West=1 ),
East as
(select * from
(select *,row_number() over(partition by category order by rating_East desc) as ranks_East from
(select p.category,p.pname as Product_East, count( o.or_id) as orders_East,round(avg(r.prod_rating)::numeric,2) as rating_East 
from customer as c join orders as o on o.c_id=c.c_id join product as p on p.p_Id=o.p_id join rating as r on 
r.or_id=o.or_id where c.region='East'  group by p.category,p.pname) as rnk_East) as rk_East where rk_East.ranks_East=1 )
select n.category,n.Product_North,n.orders_North,n.rating_North,s.Product_South,s.orders_South,s.rating_South,
e.Product_East,e.orders_East,e.rating_East,w.Product_West,w.orders_West,w.rating_West from North as n join South as s on 
n.category=s.category join east as e on e.category=n.category join west as w on w.category=n.category) union all
select * from 
(with North as
(select * from
(select *,row_number() over(partition by category order by rating_North asc) as ranks_North from
(select p.category,p.pname as Product_North, count( o.or_id) as orders_North,round(avg(r.prod_rating)::numeric,2) as rating_North 
from customer as c join orders as o on o.c_id=c.c_id join product as p on p.p_Id=o.p_id join rating as r on 
r.or_id=o.or_id where c.region='North'  group by p.category,p.pname) as rnk_North) as rk_North where rk_North.ranks_North=1), 
South as
(select * from
(select *,row_number() over(partition by category order by rating_South asc) as ranks_South from
(select p.category,p.pname as Product_South, count( o.or_id) as orders_South,round(avg(r.prod_rating)::numeric,2) as rating_South 
from customer as c join orders as o on o.c_id=c.c_id join product as p on p.p_Id=o.p_id join rating as r on 
r.or_id=o.or_id where c.region='South'  group by p.category,p.pname) as rnk_South) as rk_South where rk_South.ranks_South=1 ),
West as
(select * from
(select *,row_number() over(partition by category order by rating_West asc) as ranks_West from
(select p.category,p.pname as Product_West, count( o.or_id) as orders_West,round(avg(r.prod_rating)::numeric,2) as rating_West 
from customer as c join orders as o on o.c_id=c.c_id join product as p on p.p_Id=o.p_id join rating as r on 
r.or_id=o.or_id where c.region='West'  group by p.category,p.pname) as rnk_South) as rk_West where rk_West.ranks_West=1 ),
East as
(select * from
(select *,row_number() over(partition by category order by rating_East asc) as ranks_East from
(select p.category,p.pname as Product_East, count( o.or_id) as orders_East,round(avg(r.prod_rating)::numeric,2) as rating_East 
from customer as c join orders as o on o.c_id=c.c_id join product as p on p.p_Id=o.p_id join rating as r on 
r.or_id=o.or_id where c.region='East'  group by p.category,p.pname) as rnk_East) as rk_East where rk_East.ranks_East=1 )
select n.category,n.Product_North,n.orders_North,n.rating_North,s.Product_South,s.orders_South,s.rating_South,
e.Product_East,e.orders_East,e.rating_East,w.Product_West,w.orders_West,w.rating_West from North as n join South as s on 
n.category=s.category join east as e on e.category=n.category join west as w on w.category=n.category))
select * from pd_region order by category;

-- 4.	Which months had unusually high or low product ratings, in different company, categorywise?
with comp_rt as
(select * from 
(with Home_Care as 
(select * from
(select *, row_number() over (partition by brand order by rating_Home_Care desc) as rank_Home_Care from 
(with orders as (select *, to_char(order_date,'month') as months from orders)
select p.brand,o.months as month_Home_Care,round(avg(r.prod_rating)::numeric,2) as rating_Home_Care ,
round(( sum(o.qty)*avg(p.price)*(1-avg(o.coupon_discount)/100))::numeric,2) as revenue_Home_Care
from product as p join orders as o on o.p_id=p.p_id join rating as r on r.or_id=o.or_id
where p.category='Home Care'  group by p.brand,o.months) as r_Home_Care) as rk_Home_Care
where rk_Home_Care.rank_Home_Care=1),
Beverages as
(select * from
(select *, row_number() over (partition by brand order by rating_Beverages desc) as rank_Beverages from 
(with orders as (select *, to_char(order_date,'month') as months from orders)
select p.brand,o.months as month_Beverages,round(avg(r.prod_rating)::numeric,2) as rating_Beverages ,
round(( sum(o.qty)*avg(p.price)*(1-avg(o.coupon_discount)/100))::numeric,2) as revenue_Beverages
from product as p join orders as o on o.p_id=p.p_id join rating as r on r.or_id=o.or_id
where p.category='Beverages'  group by p.brand,o.months) as r_Beverages) as rk_Beverages
where rk_Beverages.rank_Beverages=1),
Snacks as
(select * from
(select *, row_number() over (partition by brand order by rating_Snacks desc) as rank_Snacks from 
(with orders as (select *, to_char(order_date,'month') as months from orders)
select p.brand,o.months as month_Snacks,round(avg(r.prod_rating)::numeric,2) as rating_Snacks ,
round(( sum(o.qty)*avg(p.price)*(1-avg(o.coupon_discount)/100))::numeric,2) as revenue_Snacks
from product as p join orders as o on o.p_id=p.p_id join rating as r on r.or_id=o.or_id
where p.category='Snacks'  group by p.brand,o.months) as r_Snacks) as rk_Snacks
where rk_Snacks.rank_Snacks=1) ,
Personal_Care as
(select * from
(select *, row_number() over (partition by brand order by rating_Personal_Care desc) as rank_Personal_Care from 
(with orders as (select *, to_char(order_date,'month') as months from orders)
select p.brand,o.months as month_Personal_Care,round(avg(r.prod_rating)::numeric,2) as rating_Personal_Care ,
round(( sum(o.qty)*avg(p.price)*(1-avg(o.coupon_discount)/100))::numeric,2) as revenue_Personal_Care
from product as p join orders as o on o.p_id=p.p_id join rating as r on r.or_id=o.or_id
where p.category='Personal Care'  group by p.brand,o.months) as r_Personal_Care) as rk_Personal_Care
where rk_Personal_Care.rank_Personal_Care=1),
Dairy as
(select * from
(select *, row_number() over (partition by brand order by rating_Dairy desc) as rank_Dairy from 
(with orders as (select *, to_char(order_date,'month') as months from orders)
select p.brand,o.months as month_Dairy,round(avg(r.prod_rating)::numeric,2) as rating_Dairy ,
round(( sum(o.qty)*avg(p.price)*(1-avg(o.coupon_discount)/100))::numeric,2) as revenue_Dairy
from product as p join orders as o on o.p_id=p.p_id join rating as r on r.or_id=o.or_id
where p.category='Dairy'  group by p.brand,o.months) as r_Dairy) as rk_Dairy
where rk_Dairy.rank_Dairy=1),
Groceries as
(select * from
(select *, row_number() over (partition by brand order by rating_Groceries desc) as rank_Groceries from 
(with orders as (select *, to_char(order_date,'month') as months from orders)
select p.brand,o.months as month_Groceries,round(avg(r.prod_rating)::numeric,2) as rating_Groceries ,
round(( sum(o.qty)*avg(p.price)*(1-avg(o.coupon_discount)/100))::numeric,2) as revenue_Groceries
from product as p join orders as o on o.p_id=p.p_id join rating as r on r.or_id=o.or_id
where p.category='Groceries'  group by p.brand,o.months) as r_Groceries) as rk_Groceries
where rk_Groceries.rank_Groceries=1)
select h.brand,h.month_Home_Care,h.rating_Home_Care,h.revenue_Home_Care,b.month_Beverages,b.rating_Beverages,b.revenue_Beverages,
s.month_Snacks,s.rating_Snacks,s.revenue_Snacks,p.month_Personal_Care,p.rating_Personal_Care,p.revenue_Personal_Care,
d.month_Dairy,d.rating_Dairy,d.revenue_Dairy,g.month_Groceries,g.rating_Groceries,g.revenue_Groceries from Home_Care as h join
Beverages as b on b.brand=h.brand join Snacks as s on s.brand=h.brand join Personal_Care as p on p.brand=h.brand join Dairy as d
on d.brand=h.brand join Groceries as g on g.brand=h.brand ) union all
select * from
(with Home_Care as 
(select * from
(select *, row_number() over (partition by brand order by rating_Home_Care asc) as rank_Home_Care from 
(with orders as (select *, to_char(order_date,'month') as months from orders)
select p.brand,o.months as month_Home_Care,round(avg(r.prod_rating)::numeric,2) as rating_Home_Care ,
round(( sum(o.qty)*avg(p.price)*(1-avg(o.coupon_discount)/100))::numeric,2) as revenue_Home_Care
from product as p join orders as o on o.p_id=p.p_id join rating as r on r.or_id=o.or_id
where p.category='Home Care'  group by p.brand,o.months) as r_Home_Care) as rk_Home_Care
where rk_Home_Care.rank_Home_Care=1),
Beverages as
(select * from
(select *, row_number() over (partition by brand order by rating_Beverages asc) as rank_Beverages from 
(with orders as (select *, to_char(order_date,'month') as months from orders)
select p.brand,o.months as month_Beverages,round(avg(r.prod_rating)::numeric,2) as rating_Beverages ,
round(( sum(o.qty)*avg(p.price)*(1-avg(o.coupon_discount)/100))::numeric,2) as revenue_Beverages
from product as p join orders as o on o.p_id=p.p_id join rating as r on r.or_id=o.or_id
where p.category='Beverages'  group by p.brand,o.months) as r_Beverages) as rk_Beverages
where rk_Beverages.rank_Beverages=1),
Snacks as
(select * from
(select *, row_number() over (partition by brand order by rating_Snacks asc) as rank_Snacks from 
(with orders as (select *, to_char(order_date,'month') as months from orders)
select p.brand,o.months as month_Snacks,round(avg(r.prod_rating)::numeric,2) as rating_Snacks ,
round(( sum(o.qty)*avg(p.price)*(1-avg(o.coupon_discount)/100))::numeric,2) as revenue_Snacks
from product as p join orders as o on o.p_id=p.p_id join rating as r on r.or_id=o.or_id
where p.category='Snacks'  group by p.brand,o.months) as r_Snacks) as rk_Snacks
where rk_Snacks.rank_Snacks=1) ,
Personal_Care as
(select * from
(select *, row_number() over (partition by brand order by rating_Personal_Care asc) as rank_Personal_Care from 
(with orders as (select *, to_char(order_date,'month') as months from orders)
select p.brand,o.months as month_Personal_Care,round(avg(r.prod_rating)::numeric,2) as rating_Personal_Care ,
round(( sum(o.qty)*avg(p.price)*(1-avg(o.coupon_discount)/100))::numeric,2) as revenue_Personal_Care
from product as p join orders as o on o.p_id=p.p_id join rating as r on r.or_id=o.or_id
where p.category='Personal Care'  group by p.brand,o.months) as r_Personal_Care) as rk_Personal_Care
where rk_Personal_Care.rank_Personal_Care=1),
Dairy as
(select * from
(select *, row_number() over (partition by brand order by rating_Dairy asc) as rank_Dairy from 
(with orders as (select *, to_char(order_date,'month') as months from orders)
select p.brand,o.months as month_Dairy,round(avg(r.prod_rating)::numeric,2) as rating_Dairy ,
round(( sum(o.qty)*avg(p.price)*(1-avg(o.coupon_discount)/100))::numeric,2) as revenue_Dairy
from product as p join orders as o on o.p_id=p.p_id join rating as r on r.or_id=o.or_id
where p.category='Dairy'  group by p.brand,o.months) as r_Dairy) as rk_Dairy
where rk_Dairy.rank_Dairy=1),
Groceries as
(select * from
(select *, row_number() over (partition by brand order by rating_Groceries asc) as rank_Groceries from 
(with orders as (select *, to_char(order_date,'month') as months from orders)
select p.brand,o.months as month_Groceries,round(avg(r.prod_rating)::numeric,2) as rating_Groceries ,
round(( sum(o.qty)*avg(p.price)*(1-avg(o.coupon_discount)/100))::numeric,2) as revenue_Groceries
from product as p join orders as o on o.p_id=p.p_id join rating as r on r.or_id=o.or_id
where p.category='Groceries'  group by p.brand,o.months) as r_Groceries) as rk_Groceries
where rk_Groceries.rank_Groceries=1)
select h.brand,h.month_Home_Care,h.rating_Home_Care,h.revenue_Home_Care,b.month_Beverages,b.rating_Beverages,b.revenue_Beverages,
s.month_Snacks,s.rating_Snacks,s.revenue_Snacks,p.month_Personal_Care,p.rating_Personal_Care,p.revenue_Personal_Care,
d.month_Dairy,d.rating_Dairy,d.revenue_Dairy,g.month_Groceries,g.rating_Groceries,g.revenue_Groceries from Home_Care as h join
Beverages as b on b.brand=h.brand join Snacks as s on s.brand=h.brand join Personal_Care as p on p.brand=h.brand join Dairy as d
on d.brand=h.brand join Groceries as g on g.brand=h.brand ) )
select * from comp_rt order by brand;


/* Advanced Analysis */
-- 1.	Which product has the most orders and which one is least ,highest quantity sold, best rating, highest sales, categorywise, in different region ?
with total_order as 
(select * from 
(with South as 
(select * from  (select *, row_number() over (partition by category order by orders_South desc) as rank_South from
(select p.category,p.pname as Product_South,count(o.or_id) as orders_South, sum(o.qty) as qty_South, round(avg(r.prod_rating)::numeric,2) as rating_South ,
round((sum(o.qty)*avg(p.price)*(1-avg(o.coupon_discount)/100))::numeric,2) as sales_South from customer as c join orders as o on o.c_id=c.c_id
join product as p on p.p_id=o.p_id join rating as r on r.or_id=o.or_id where c.region='South'  group by p.category,p.pname) as rk_South) as 
r_South where r_South.rank_South=1),
North as 
(select * from  (select *, row_number() over (partition by category order by orders_North desc) as rank_North from
(select p.category,p.pname as Product_North,count(o.or_id) as orders_North, sum(o.qty) as qty_North, round(avg(r.prod_rating)::numeric,2) as rating_North ,
round((sum(o.qty)*avg(p.price)*(1-avg(o.coupon_discount)/100))::numeric,2) as sales_North from customer as c join orders as o on o.c_id=c.c_id
join product as p on p.p_id=o.p_id join rating as r on r.or_id=o.or_id where c.region='North'  group by p.category,p.pname) as rk_North) as 
r_North where r_North.rank_North=1),
East as 
(select * from  (select *, row_number() over (partition by category order by orders_East desc) as rank_East from
(select p.category,p.pname as Product_East,count(o.or_id) as orders_East, sum(o.qty) as qty_East, round(avg(r.prod_rating)::numeric,2) as rating_East ,
round((sum(o.qty)*avg(p.price)*(1-avg(o.coupon_discount)/100))::numeric,2) as sales_East from customer as c join orders as o on o.c_id=c.c_id
join product as p on p.p_id=o.p_id join rating as r on r.or_id=o.or_id where c.region='East'  group by p.category,p.pname) as rk_East) as 
r_East where r_East.rank_East=1),
West as
(select * from  (select *, row_number() over (partition by category order by orders_West desc) as rank_West from
(select p.category,p.pname as Product_West,count(o.or_id) as orders_West, sum(o.qty) as qty_West, round(avg(r.prod_rating)::numeric,2) as rating_West ,
round((sum(o.qty)*avg(p.price)*(1-avg(o.coupon_discount)/100))::numeric,2) as sales_West from customer as c join orders as o on o.c_id=c.c_id
join product as p on p.p_id=o.p_id join rating as r on r.or_id=o.or_id where c.region='West'  group by p.category,p.pname) as rk_West) as 
r_West where r_West.rank_West=1)
select s.category,s.Product_South,s.orders_South,s.qty_South,s.rating_South,s.sales_South,
n.Product_North,n.orders_North,n.qty_North,n.rating_North,n.sales_North,
e.Product_East,e.orders_East,e.qty_East,e.rating_East,e.sales_East,
w.Product_West,w.orders_West,w.qty_West,w.rating_West,w.sales_West
from South as s join North as N on s.category=n.category join west as w on w.category=s.category join East as e on e.category=s.category) union all
select * from 
(with South as 
(select * from  (select *, row_number() over (partition by category order by orders_South asc) as rank_South from
(select p.category,p.pname as Product_South,count(o.or_id) as orders_South, sum(o.qty) as qty_South, round(avg(r.prod_rating)::numeric,2) as rating_South ,
round((sum(o.qty)*avg(p.price)*(1-avg(o.coupon_discount)/100))::numeric,2) as sales_South from customer as c join orders as o on o.c_id=c.c_id
join product as p on p.p_id=o.p_id join rating as r on r.or_id=o.or_id where c.region='South'  group by p.category,p.pname) as rk_South) as 
r_South where r_South.rank_South=1),
North as 
(select * from  (select *, row_number() over (partition by category order by orders_North asc) as rank_North from
(select p.category,p.pname as Product_North,count(o.or_id) as orders_North, sum(o.qty) as qty_North, round(avg(r.prod_rating)::numeric,2) as rating_North ,
round((sum(o.qty)*avg(p.price)*(1-avg(o.coupon_discount)/100))::numeric,2) as sales_North from customer as c join orders as o on o.c_id=c.c_id
join product as p on p.p_id=o.p_id join rating as r on r.or_id=o.or_id where c.region='North'  group by p.category,p.pname) as rk_North) as 
r_North where r_North.rank_North=1),
East as 
(select * from  (select *, row_number() over (partition by category order by orders_East asc) as rank_East from
(select p.category,p.pname as Product_East,count(o.or_id) as orders_East, sum(o.qty) as qty_East, round(avg(r.prod_rating)::numeric,2) as rating_East ,
round((sum(o.qty)*avg(p.price)*(1-avg(o.coupon_discount)/100))::numeric,2) as sales_East from customer as c join orders as o on o.c_id=c.c_id
join product as p on p.p_id=o.p_id join rating as r on r.or_id=o.or_id where c.region='East'  group by p.category,p.pname) as rk_East) as 
r_East where r_East.rank_East=1),
West as
(select * from  (select *, row_number() over (partition by category order by orders_West asc) as rank_West from
(select p.category,p.pname as Product_West,count(o.or_id) as orders_West, sum(o.qty) as qty_West, round(avg(r.prod_rating)::numeric,2) as rating_West ,
round((sum(o.qty)*avg(p.price)*(1-avg(o.coupon_discount)/100))::numeric,2) as sales_West from customer as c join orders as o on o.c_id=c.c_id
join product as p on p.p_id=o.p_id join rating as r on r.or_id=o.or_id where c.region='West'  group by p.category,p.pname) as rk_West) as 
r_West where r_West.rank_West=1)
select s.category,s.Product_South,s.orders_South,s.qty_South,s.rating_South,s.sales_South,
n.Product_North,n.orders_North,n.qty_North,n.rating_North,n.sales_North,
e.Product_East,e.orders_East,e.qty_East,e.rating_East,e.sales_East,
w.Product_West,w.orders_West,w.qty_West,w.rating_West,w.sales_West
from South as s join North as N on s.category=n.category join west as w on w.category=s.category join East as e on e.category=s.category))
select * from total_order order by category;

-- 2.	How do delivery partners perform in orders,quantity ,revenue, ratings , find top 5 states for each partner  ?
select * from  (select *, row_number() over(partition by dp_name order by orders desc) as ranks from 
(select d.dp_name,c.states,count(o.or_id) as orders , sum(o.qty) as Quantity, 
round((sum(o.qty)*avg(p.price)*(1-avg(o.coupon_discount)/100)*(avg(d.percent_cut)/100))::numeric,2) as sales,
round(avg(r.delivery_service_rating)::numeric,2) as delivery_rating from customer as c join orders as o on o.c_id =c.c_id join product
as p on p.p_id=o.p_id join delivery as d on d.dp_id=o.dp_id join rating as r on r.or_id=o.or_id group by d.dp_name,c.states) as rnk) as rk 
where rk.ranks<=5;

-- 3.	How do order and revenue patterns along with its percentage in different company , Monthwise, in different region ? 
select months,brand,orders,round((orders/(sum(orders) over (partition by months))*100)::numeric,2) 
as  percent_orders, sales, round((sales/(sum(sales) over (partition by months))*100)::numeric,2) as percent_sales from 
(with orders as ( select * ,to_char(order_date,'month') as months, extract('month' from order_date) as month_n from orders) 
select o.months,o.month_n,p.brand as brand ,count(o.or_id) as orders, 
round((sum(o.qty)*avg(p.price)*(1-avg(o.coupon_discount)/100))::numeric,2) as sales
from orders as o join product as p on p.p_id=o.p_id join customer as c on c.c_id=o.c_id 
group by o.months,o.month_n,p.brand order by month_n) as rnk order by rnk.month_n;

-- 4.	How does revenue vary by month for each delivery partner ?
select months,brand,orders,round((orders/(sum(orders) over (partition by months))*100)::numeric,2) 
as  percent_orders, revenue, round((revenue/(sum(revenue) over (partition by months))*100)::numeric,2) as percent_revenue from 
(with orders as ( select * ,to_char(order_date,'month') as months, extract('month' from order_date) as month_n from orders) 
select o.months,o.month_n,d.dp_name as brand ,count(o.or_id) as orders, 
round((sum(o.qty)*avg(p.price)*(1-avg(o.coupon_discount)/100)*(avg(d.percent_cut)/100))::numeric,2) as revenue
from orders as o left join product as p on p.p_id=o.p_id left join customer as c on c.c_id=o.c_id left join delivery as d on d.dp_id=o.dp_id
group by o.months,o.month_n,d.dp_name order by month_n) as rnk order by rnk.month_n;

-- 5.	Which months were most and least profitable for delivery partners, region by region?
with total_order as 
(select * from 
(with North as 
(select dp_name,month_North,revenue_North,rating_North from 
(select * , row_number() over (partition by dp_name order by revenue_North desc) as rank_North from 
(with orders as ( select * ,to_char(order_date,'month') as months from orders)
select d.dp_name,o.months as month_North,
round((sum(o.qty)*avg(p.price)*(1-avg(o.coupon_discount)/100)*(avg(d.percent_cut)/100))::numeric,2) as revenue_North,
round(avg(r.delivery_service_rating)::numeric,2) as rating_North
from customer as c join orders as o on o.c_id=c.c_id join product as p on p.p_id=o.p_id join delivery as d on d.dp_id=o.dp_id
left join rating as r on r.or_id=o.or_id where c.region='North' group by d.dp_name,o.months ) as rk_North) as r_North where r_North.rank_North=1),
South as
(select dp_name,month_South,revenue_South,rating_South from 
(select * , row_number() over (partition by dp_name order by revenue_South desc) as rank_South from 
(with orders as ( select * ,to_char(order_date,'month') as months from orders)
select d.dp_name,o.months as month_South,
round((sum(o.qty)*avg(p.price)*(1-avg(o.coupon_discount)/100)*(avg(d.percent_cut)/100))::numeric,2) as revenue_South,
round(avg(r.delivery_service_rating)::numeric,2) as rating_South
from customer as c join orders as o on o.c_id=c.c_id join product as p on p.p_id=o.p_id join delivery as d on d.dp_id=o.dp_id
left join rating as r on r.or_id=o.or_id where c.region='South' group by d.dp_name,o.months ) as rk_South) as r_South where r_South.rank_South=1),
East as
(select dp_name,month_East,revenue_East,rating_East from 
(select * , row_number() over (partition by dp_name order by revenue_East) as rank_East from 
(with orders as ( select * ,to_char(order_date,'month') as months from orders)
select d.dp_name,o.months as month_East,
round((sum(o.qty)*avg(p.price)*(1-avg(o.coupon_discount)/100)*(avg(d.percent_cut)/100))::numeric,2) as revenue_East,
round(avg(r.delivery_service_rating)::numeric,2) as rating_East
from customer as c join orders as o on o.c_id=c.c_id join product as p on p.p_id=o.p_id join delivery as d on d.dp_id=o.dp_id
left join rating as r on r.or_id=o.or_id where c.region='East' group by d.dp_name,o.months ) as rk_East) as r_East where r_East.rank_East=1),
West as
(select dp_name,month_West,revenue_West,rating_West from 
(select * , row_number() over (partition by dp_name order by revenue_West desc) as rank_West from 
(with orders as ( select * ,to_char(order_date,'month') as months from orders)
select d.dp_name,o.months as month_West,
round((sum(o.qty)*avg(p.price)*(1-avg(o.coupon_discount)/100)*(avg(d.percent_cut)/100))::numeric,2) as revenue_West,
round(avg(r.delivery_service_rating)::numeric,2) as rating_West
from customer as c join orders as o on o.c_id=c.c_id join product as p on p.p_id=o.p_id join delivery as d on d.dp_id=o.dp_id
left join rating as r on r.or_id=o.or_id where c.region='West' group by d.dp_name,o.months ) as rk_West) as r_West where r_West.rank_West=1)
select n.dp_name,n.month_North,n.revenue_North,n.rating_North,s.month_South,s.revenue_South,s.rating_South,
e.month_East,e.revenue_East,e.rating_East,w.month_West,w.revenue_West,w.rating_West from North as n join South as s on 
s.dp_name=n.dp_name join East as e on e.dp_name=n.dp_name join West as w on w.dp_name=n.dp_name ) union all
select * from 
(with North as 
(select dp_name,month_North,revenue_North,rating_North from 
(select * , row_number() over (partition by dp_name order by revenue_North asc ) as rank_North from 
(with orders as ( select * ,to_char(order_date,'month') as months from orders)
select d.dp_name,o.months as month_North,
round((sum(o.qty)*avg(p.price)*(1-avg(o.coupon_discount)/100)*(avg(d.percent_cut)/100))::numeric,2) as revenue_North,
round(avg(r.delivery_service_rating)::numeric,2) as rating_North
from customer as c join orders as o on o.c_id=c.c_id join product as p on p.p_id=o.p_id join delivery as d on d.dp_id=o.dp_id
left join rating as r on r.or_id=o.or_id where c.region='North' group by d.dp_name,o.months ) as rk_North) as r_North where r_North.rank_North=1),
South as
(select dp_name,month_South,revenue_South,rating_South from 
(select * , row_number() over (partition by dp_name order by revenue_South asc) as rank_South from 
(with orders as ( select * ,to_char(order_date,'month') as months from orders)
select d.dp_name,o.months as month_South,
round((sum(o.qty)*avg(p.price)*(1-avg(o.coupon_discount)/100)*(avg(d.percent_cut)/100))::numeric,2) as revenue_South,
round(avg(r.delivery_service_rating)::numeric,2) as rating_South
from customer as c join orders as o on o.c_id=c.c_id join product as p on p.p_id=o.p_id join delivery as d on d.dp_id=o.dp_id
left join rating as r on r.or_id=o.or_id where c.region='South' group by d.dp_name,o.months ) as rk_South) as r_South where r_South.rank_South=1),
East as
(select dp_name,month_East,revenue_East,rating_East from 
(select * , row_number() over (partition by dp_name order by revenue_East asc) as rank_East from 
(with orders as ( select * ,to_char(order_date,'month') as months from orders)
select d.dp_name,o.months as month_East,
round((sum(o.qty)*avg(p.price)*(1-avg(o.coupon_discount)/100)*(avg(d.percent_cut)/100))::numeric,2) as revenue_East,
round(avg(r.delivery_service_rating)::numeric,2) as rating_East
from customer as c join orders as o on o.c_id=c.c_id join product as p on p.p_id=o.p_id join delivery as d on d.dp_id=o.dp_id
left join rating as r on r.or_id=o.or_id where c.region='East' group by d.dp_name,o.months ) as rk_East) as r_East where r_East.rank_East=1),
West as
(select dp_name,month_West,revenue_West,rating_West from 
(select * , row_number() over (partition by dp_name order by revenue_West asc) as rank_West from 
(with orders as ( select * ,to_char(order_date,'month') as months from orders)
select d.dp_name,o.months as month_West,
round((sum(o.qty)*avg(p.price)*(1-avg(o.coupon_discount)/100)*(avg(d.percent_cut)/100))::numeric,2) as revenue_West,
round(avg(r.delivery_service_rating)::numeric,2) as rating_West
from customer as c join orders as o on o.c_id=c.c_id join product as p on p.p_id=o.p_id join delivery as d on d.dp_id=o.dp_id
left join rating as r on r.or_id=o.or_id where c.region='West' group by d.dp_name,o.months ) as rk_West) as r_West where r_West.rank_West=1)
select n.dp_name,n.month_North,n.revenue_North,n.rating_North,s.month_South,s.revenue_South,s.rating_South,
e.month_East,e.revenue_East,e.rating_East,w.month_West,w.revenue_West,w.rating_West from North as n join South as s on 
s.dp_name=n.dp_name join East as e on e.dp_name=n.dp_name join West as w on w.dp_name=n.dp_name ))
select * from total_order order by dp_name;

-- 6.	Which company sell best and worst in each state, quarter by quarter, based on order , also finding its quantity, rating and revenue?
with total_order as 
(select * from 
(with Qtr_1 as
(select states, brand_Qtr_1, orders_Qtr_1,qty_Qtr_1, rating_Qtr_1, sales_Qtr_1 from 
(select * , row_number() over (partition by states order by orders_Qtr_1 desc) as rank_Qtr_1 from 
(with orders as (select *, concat('Qtr ',extract('quarter' from order_date)) as qtr from orders  ) 
select c.states,p.brand as brand_Qtr_1,count(o.or_id) as orders_Qtr_1,sum(o.qty) as qty_Qtr_1, round(avg(r.prod_rating)::numeric,2) as rating_Qtr_1,
round((sum(o.qty)*avg(p.price)*(1-avg(o.coupon_discount)/100))::numeric,2) as sales_Qtr_1
from customer as c right join orders as o on o.c_id=c.c_id left join rating as r on r.or_id=o.or_id left join product as p on p.p_id=o.p_id
where o.qtr='Qtr 1' group by c.states,p.brand) as rnk_Qtr_1 ) as r_Qtr_1 where r_Qtr_1.rank_Qtr_1=1), 
Qtr_2 as
(select states, brand_Qtr_2, orders_Qtr_2,qty_Qtr_2, rating_Qtr_2, sales_Qtr_2 from 
(select * , row_number() over (partition by states order by orders_Qtr_2 desc) as rank_Qtr_2 from 
(with orders as (select *, concat('Qtr ',extract('quarter' from order_date)) as qtr from orders  ) 
select c.states,p.brand as brand_Qtr_2,count(o.or_id) as orders_Qtr_2,sum(o.qty) as qty_Qtr_2, round(avg(r.prod_rating)::numeric,2) as rating_Qtr_2,
round((sum(o.qty)*avg(p.price)*(1-avg(o.coupon_discount)/100))::numeric,2) as sales_Qtr_2
from customer as c right join orders as o on o.c_id=c.c_id left join rating as r on r.or_id=o.or_id left join product as p on p.p_id=o.p_id
where o.qtr='Qtr 2' group by c.states,p.brand) as rnk_Qtr_2 ) as r_Qtr_2 where r_Qtr_2.rank_Qtr_2=1), 
Qtr_3 as
(select states, brand_Qtr_3, orders_Qtr_3,qty_Qtr_3, rating_Qtr_3, sales_Qtr_3 from 
(select * , row_number() over (partition by states order by orders_Qtr_3 desc) as rank_Qtr_3 from 
(with orders as (select *, concat('Qtr ',extract('quarter' from order_date)) as qtr from orders  ) 
select c.states,p.brand as brand_Qtr_3,count(o.or_id) as orders_Qtr_3,sum(o.qty) as qty_Qtr_3, round(avg(r.prod_rating)::numeric,2) as rating_Qtr_3,
round((sum(o.qty)*avg(p.price)*(1-avg(o.coupon_discount)/100))::numeric,2) as sales_Qtr_3
from customer as c right join orders as o on o.c_id=c.c_id left join rating as r on r.or_id=o.or_id left join product as p on p.p_id=o.p_id
where o.qtr='Qtr 3' group by c.states,p.brand) as rnk_Qtr_3 ) as r_Qtr_3 where r_Qtr_3.rank_Qtr_3=1),
Qtr_4 as
(select states, brand_Qtr_4, orders_Qtr_4,qty_Qtr_4, rating_Qtr_4, sales_Qtr_4 from 
(select * , row_number() over (partition by states order by orders_Qtr_4 desc) as rank_Qtr_4 from 
(with orders as (select *, concat('Qtr ',extract('quarter' from order_date)) as qtr from orders  ) 
select c.states,p.brand as brand_Qtr_4,count(o.or_id) as orders_Qtr_4,sum(o.qty) as qty_Qtr_4, round(avg(r.prod_rating)::numeric,2) as rating_Qtr_4,
round((sum(o.qty)*avg(p.price)*(1-avg(o.coupon_discount)/100))::numeric,2) as sales_Qtr_4
from customer as c right join orders as o on o.c_id=c.c_id left join rating as r on r.or_id=o.or_id left join product as p on p.p_id=o.p_id
where o.qtr='Qtr 4' group by c.states,p.brand) as rnk_Qtr_4 ) as r_Qtr_4 where r_Qtr_4.rank_Qtr_4=1)
select q1.states, q1.brand_Qtr_1, q1.orders_Qtr_1,q1.qty_Qtr_1, q1.rating_Qtr_1, q1.sales_Qtr_1,
q2.brand_Qtr_2, q2.orders_Qtr_2,q2.qty_Qtr_2, q2.rating_Qtr_2, q2.sales_Qtr_2,
q3.brand_Qtr_3, q3.orders_Qtr_3,q3.qty_Qtr_3, q3.rating_Qtr_3, q3.sales_Qtr_3,
q4.brand_Qtr_4, q4.orders_Qtr_4,q4.qty_Qtr_4, q4.rating_Qtr_4, q4.sales_Qtr_4
from Qtr_1  as q1 join Qtr_2 as q2 on q1.states=q2.states join Qtr_3 as q3 on q1.states=q3.states join Qtr_4 as q4 on q1.states=q4.states ) union all
select * from
(with Qtr_1 as
(select states, brand_Qtr_1, orders_Qtr_1,qty_Qtr_1, rating_Qtr_1, sales_Qtr_1 from 
(select * , row_number() over (partition by states order by orders_Qtr_1 asc) as rank_Qtr_1 from 
(with orders as (select *, concat('Qtr ',extract('quarter' from order_date)) as qtr from orders  ) 
select c.states,p.brand as brand_Qtr_1,count(o.or_id) as orders_Qtr_1,sum(o.qty) as qty_Qtr_1, round(avg(r.prod_rating)::numeric,2) as rating_Qtr_1,
round((sum(o.qty)*avg(p.price)*(1-avg(o.coupon_discount)/100))::numeric,2) as sales_Qtr_1
from customer as c right join orders as o on o.c_id=c.c_id left join rating as r on r.or_id=o.or_id left join product as p on p.p_id=o.p_id
where o.qtr='Qtr 1' group by c.states,p.brand) as rnk_Qtr_1 ) as r_Qtr_1 where r_Qtr_1.rank_Qtr_1=1), 
Qtr_2 as
(select states, brand_Qtr_2, orders_Qtr_2,qty_Qtr_2, rating_Qtr_2, sales_Qtr_2 from 
(select * , row_number() over (partition by states order by orders_Qtr_2 asc) as rank_Qtr_2 from 
(with orders as (select *, concat('Qtr ',extract('quarter' from order_date)) as qtr from orders  ) 
select c.states,p.brand as brand_Qtr_2,count(o.or_id) as orders_Qtr_2,sum(o.qty) as qty_Qtr_2, round(avg(r.prod_rating)::numeric,2) as rating_Qtr_2,
round((sum(o.qty)*avg(p.price)*(1-avg(o.coupon_discount)/100))::numeric,2) as sales_Qtr_2
from customer as c right join orders as o on o.c_id=c.c_id left join rating as r on r.or_id=o.or_id left join product as p on p.p_id=o.p_id
where o.qtr='Qtr 2' group by c.states,p.brand) as rnk_Qtr_2 ) as r_Qtr_2 where r_Qtr_2.rank_Qtr_2=1), 
Qtr_3 as
(select states, brand_Qtr_3, orders_Qtr_3,qty_Qtr_3, rating_Qtr_3, sales_Qtr_3 from 
(select * , row_number() over (partition by states order by orders_Qtr_3 asc) as rank_Qtr_3 from 
(with orders as (select *, concat('Qtr ',extract('quarter' from order_date)) as qtr from orders  ) 
select c.states,p.brand as brand_Qtr_3,count(o.or_id) as orders_Qtr_3,sum(o.qty) as qty_Qtr_3, round(avg(r.prod_rating)::numeric,2) as rating_Qtr_3,
round((sum(o.qty)*avg(p.price)*(1-avg(o.coupon_discount)/100))::numeric,2) as sales_Qtr_3
from customer as c right join orders as o on o.c_id=c.c_id left join rating as r on r.or_id=o.or_id left join product as p on p.p_id=o.p_id
where o.qtr='Qtr 3' group by c.states,p.brand) as rnk_Qtr_3 ) as r_Qtr_3 where r_Qtr_3.rank_Qtr_3=1),
Qtr_4 as
(select states, brand_Qtr_4, orders_Qtr_4,qty_Qtr_4, rating_Qtr_4, sales_Qtr_4 from 
(select * , row_number() over (partition by states order by orders_Qtr_4 asc) as rank_Qtr_4 from 
(with orders as (select *, concat('Qtr ',extract('quarter' from order_date)) as qtr from orders  ) 
select c.states,p.brand as brand_Qtr_4,count(o.or_id) as orders_Qtr_4,sum(o.qty) as qty_Qtr_4, round(avg(r.prod_rating)::numeric,2) as rating_Qtr_4,
round((sum(o.qty)*avg(p.price)*(1-avg(o.coupon_discount)/100))::numeric,2) as sales_Qtr_4
from customer as c right join orders as o on o.c_id=c.c_id left join rating as r on r.or_id=o.or_id left join product as p on p.p_id=o.p_id
where o.qtr='Qtr 4' group by c.states,p.brand) as rnk_Qtr_4 ) as r_Qtr_4 where r_Qtr_4.rank_Qtr_4=1)
select q1.states, q1.brand_Qtr_1, q1.orders_Qtr_1,q1.qty_Qtr_1, q1.rating_Qtr_1, q1.sales_Qtr_1,
q2.brand_Qtr_2, q2.orders_Qtr_2,q2.qty_Qtr_2, q2.rating_Qtr_2, q2.sales_Qtr_2,
q3.brand_Qtr_3, q3.orders_Qtr_3,q3.qty_Qtr_3, q3.rating_Qtr_3, q3.sales_Qtr_3,
q4.brand_Qtr_4, q4.orders_Qtr_4,q4.qty_Qtr_4, q4.rating_Qtr_4, q4.sales_Qtr_4
from Qtr_1  as q1 join Qtr_2 as q2 on q1.states=q2.states join Qtr_3 as q3 on q1.states=q3.states join Qtr_4 as q4 on q1.states=q4.states ))
select * from total_order order by states;
 
-- 7.	Which companies dominate sales in which city, and which struggle, in different region 
with total_order as 
(select * from 
(with North as
(select * from (select *, row_number() over(partition by brand order by sales_North desc ) as rank_North from
(select p.brand,c.city as city_North,count(o.or_id) as orders_North ,
round((sum(o.qty)*avg(p.price)*(1-avg(o.coupon_discount)/100))::numeric,2) as sales_North
from customer as c right join orders as o on o.c_id=c.c_id left join product as p on p.p_id=o.p_id 
where c.region='North'  group by p.brand,c.city ) as rk_North) as r_North where r_North.rank_North=1),
South as
(select * from (select *, row_number() over(partition by brand order by sales_South desc ) as rank_South from
(select p.brand,c.city as city_South,count(o.or_id) as orders_South ,
round((sum(o.qty)*avg(p.price)*(1-avg(o.coupon_discount)/100))::numeric,2) as sales_South
from customer as c right join orders as o on o.c_id=c.c_id left join product as p on p.p_id=o.p_id 
where c.region='South'  group by p.brand,c.city ) as rk_South) as r_South where r_South.rank_South=1),
East as
(select * from (select *, row_number() over(partition by brand order by sales_East desc ) as rank_East from
(select p.brand,c.city as city_East,count(o.or_id) as orders_East ,
round((sum(o.qty)*avg(p.price)*(1-avg(o.coupon_discount)/100))::numeric,2) as sales_East
from customer as c right join orders as o on o.c_id=c.c_id left join product as p on p.p_id=o.p_id 
where c.region='East'  group by p.brand,c.city ) as rk_East) as r_East where r_East.rank_East=1),
West as
(select * from (select *, row_number() over(partition by brand order by sales_West desc ) as rank_West from
(select p.brand,c.city as city_West,count(o.or_id) as orders_West ,
round((sum(o.qty)*avg(p.price)*(1-avg(o.coupon_discount)/100))::numeric,2) as sales_West
from customer as c right join orders as o on o.c_id=c.c_id left join product as p on p.p_id=o.p_id 
where c.region='West'  group by p.brand,c.city ) as rk_West) as r_West where r_West.rank_West=1)
select n.brand,n.city_North,n.orders_North,n.sales_North,s.city_South,s.orders_South,s.sales_South,
e.city_East,e.orders_East,e.sales_East,w.city_West,w.orders_West,w.sales_West from North as n join South as s on
n.brand=s.brand join East as e on e.brand=n.brand join West as w on w.brand=n.brand) union all
select * from
(with North as
(select * from (select *, row_number() over(partition by brand order by sales_North asc ) as rank_North from
(select p.brand,c.city as city_North,count(o.or_id) as orders_North ,
round((sum(o.qty)*avg(p.price)*(1-avg(o.coupon_discount)/100))::numeric,2) as sales_North
from customer as c right join orders as o on o.c_id=c.c_id left join product as p on p.p_id=o.p_id 
where c.region='North'  group by p.brand,c.city ) as rk_North) as r_North where r_North.rank_North=1),
South as
(select * from (select *, row_number() over(partition by brand order by sales_South asc ) as rank_South from
(select p.brand,c.city as city_South,count(o.or_id) as orders_South ,
round((sum(o.qty)*avg(p.price)*(1-avg(o.coupon_discount)/100))::numeric,2) as sales_South
from customer as c right join orders as o on o.c_id=c.c_id left join product as p on p.p_id=o.p_id 
where c.region='South'  group by p.brand,c.city ) as rk_South) as r_South where r_South.rank_South=1),
East as
(select * from (select *, row_number() over(partition by brand order by sales_East asc ) as rank_East from
(select p.brand,c.city as city_East,count(o.or_id) as orders_East ,
round((sum(o.qty)*avg(p.price)*(1-avg(o.coupon_discount)/100))::numeric,2) as sales_East
from customer as c right join orders as o on o.c_id=c.c_id left join product as p on p.p_id=o.p_id 
where c.region='East'  group by p.brand,c.city ) as rk_East) as r_East where r_East.rank_East=1),
West as
(select * from (select *, row_number() over(partition by brand order by sales_West asc ) as rank_West from
(select p.brand,c.city as city_West,count(o.or_id) as orders_West ,
round((sum(o.qty)*avg(p.price)*(1-avg(o.coupon_discount)/100))::numeric,2) as sales_West
from customer as c right join orders as o on o.c_id=c.c_id left join product as p on p.p_id=o.p_id 
where c.region='West'  group by p.brand,c.city ) as rk_West) as r_West where r_West.rank_West=1)
select n.brand,n.city_North,n.orders_North,n.sales_North,s.city_South,s.orders_South,s.sales_South,
e.city_East,e.orders_East,e.sales_East,w.city_West,w.orders_West,w.sales_West from North as n join South as s on
n.brand=s.brand join East as e on e.brand=n.brand join West as w on w.brand=n.brand))
select * from total_order order by brand;

-- 8.	How do monthly trends (MOM) in orders, quantities, sales, compare tier over tier?
with Tier1 as
(with MOM_Tier1 as (select months,month_n,
sales_Tier1, lag(sales_Tier1,1,0) over () as pre_sales_Tier1 from 
(with orders as ( select *, to_char(order_date,'month') as months, extract('month' from order_date) as month_n from orders )
select o.months,o.month_n, round((sum(o.qty)*avg(p.price)*(1-avg(o.coupon_discount)/100))::numeric,2) as sales_Tier1
from customer as c right join orders as o on o.c_id=c.c_id left join product as p on p.p_id=o.p_id 
where c.tier='Tier 1'  group by o.months,o.month_n order by month_n ) as rnk)
select months,month_n, 
case when pre_sales_Tier1=0 then 0 else round(((sales_Tier1-pre_sales_Tier1)/pre_sales_Tier1*100)::numeric,2) end as MOM_sales_Tier1
from MOM_Tier1),
Tier2 as
(with MOM_Tier2 as (select months,month_n,
sales_Tier2, lag(sales_Tier2,1,0) over () as pre_sales_Tier2 from 
(with orders as ( select *, to_char(order_date,'month') as months, extract('month' from order_date) as month_n from orders )
select o.months,o.month_n, round((sum(o.qty)*avg(p.price)*(1-avg(o.coupon_discount)/100))::numeric,2) as sales_Tier2
from customer as c right join orders as o on o.c_id=c.c_id left join product as p on p.p_id=o.p_id 
where c.tier='Tier 2'  group by o.months,o.month_n order by month_n ) as rnk)
select months,month_n, 
case when pre_sales_Tier2=0 then 0 else round(((sales_Tier2-pre_sales_Tier2)/pre_sales_Tier2*100)::numeric,2) end as MOM_sales_Tier2
from MOM_Tier2),
Tier3 as
(with MOM_Tier3 as (select months,month_n,
sales_Tier3, lag(sales_Tier3,1,0) over () as pre_sales_Tier3 from 
(with orders as ( select *, to_char(order_date,'month') as months, extract('month' from order_date) as month_n from orders )
select o.months,o.month_n, round((sum(o.qty)*avg(p.price)*(1-avg(o.coupon_discount)/100))::numeric,2) as sales_Tier3
from customer as c right join orders as o on o.c_id=c.c_id left join product as p on p.p_id=o.p_id 
where c.tier='Tier 3'  group by o.months,o.month_n order by month_n ) as rnk)
select months,month_n, 
case when pre_sales_Tier3=0 then 0 else round(((sales_Tier3-pre_sales_Tier3)/pre_sales_Tier3*100)::numeric,2) end as MOM_sales_Tier3
from MOM_Tier3),
Tier4 as
(with MOM_Tier4 as (select months,month_n,
sales_Tier4, lag(sales_Tier4,1,0) over () as pre_sales_Tier4 from 
(with orders as ( select *, to_char(order_date,'month') as months, extract('month' from order_date) as month_n from orders )
select o.months,o.month_n, round((sum(o.qty)*avg(p.price)*(1-avg(o.coupon_discount)/100))::numeric,2) as sales_Tier4
from customer as c right join orders as o on o.c_id=c.c_id left join product as p on p.p_id=o.p_id 
where c.tier='Tier 4'  group by o.months,o.month_n order by month_n ) as rnk)
select months,month_n, 
case when pre_sales_Tier4=0 then 0 else round(((sales_Tier4-pre_sales_Tier4)/pre_sales_Tier4*100)::numeric,2) end as MOM_sales_Tier4
from MOM_Tier4)
select t1.months,t1.MOM_sales_Tier1,t2.MOM_sales_Tier2,t3.MOM_sales_Tier3,t4.MOM_sales_Tier4 from Tier1 as t1 join Tier2 as t2 on t1.months=t2.months
join Tier3 as t3 on t3.months=t1.months join Tier4 as t4 on t4.months=t1.months order by t1.month_n ;  

-- 9.	How do delivery partner earnings vary by month (MOM) ?
with Delhivery as 
(with MOM_Delhivery as (select months,month_n,
sales_Delhivery, lag(sales_Delhivery,1,0) over () as pre_sales_Delhivery from 
(with orders as ( select *, to_char(order_date,'month') as months, extract('month' from order_date) as month_n from orders )
select o.months,o.month_n, 
round((sum(o.qty)*avg(p.price)*(1-avg(o.coupon_discount)/100)*(avg(d.percent_cut)/100))::numeric,2) as sales_Delhivery
from customer as c right join orders as o on o.c_id=c.c_id left join product as p on p.p_id=o.p_id join delivery as d 
on d.dp_id=o.dp_id where d.dp_name='Delhivery'  group by o.months,o.month_n order by month_n ) as rnk)
select months,month_n, 
case when pre_sales_Delhivery=0 then 0 else round(((sales_Delhivery-pre_sales_Delhivery)/pre_sales_Delhivery*100)::numeric,2) end as MOM_sales_Delhivery
from MOM_Delhivery),
Ecom_Express as
(with MOM_Ecom_Express as (select months,month_n,
sales_Ecom_Express, lag(sales_Ecom_Express,1,0) over () as pre_sales_Ecom_Express from 
(with orders as ( select *, to_char(order_date,'month') as months, extract('month' from order_date) as month_n from orders )
select o.months,o.month_n, 
round((sum(o.qty)*avg(p.price)*(1-avg(o.coupon_discount)/100)*(avg(d.percent_cut)/100))::numeric,2) as sales_Ecom_Express
from customer as c right join orders as o on o.c_id=c.c_id left join product as p on p.p_id=o.p_id join delivery as d 
on d.dp_id=o.dp_id where d.dp_name='Ecom Express'  group by o.months,o.month_n order by month_n ) as rnk)
select months,month_n, 
case when pre_sales_Ecom_Express=0 then 0 else 
round(((sales_Ecom_Express-pre_sales_Ecom_Express)/pre_sales_Ecom_Express*100)::numeric,2) end as MOM_sales_Ecom_Express
from MOM_Ecom_Express),
Blue_Dart as
(with MOM_Blue_Dart as (select months,month_n,
sales_Blue_Dart, lag(sales_Blue_Dart,1,0) over () as pre_sales_Blue_Dart from 
(with orders as ( select *, to_char(order_date,'month') as months, extract('month' from order_date) as month_n from orders )
select o.months,o.month_n, 
round((sum(o.qty)*avg(p.price)*(1-avg(o.coupon_discount)/100)*(avg(d.percent_cut)/100))::numeric,2) as sales_Blue_Dart
from customer as c right join orders as o on o.c_id=c.c_id left join product as p on p.p_id=o.p_id join delivery as d 
on d.dp_id=o.dp_id where d.dp_name='Blue Dart'  group by o.months,o.month_n order by month_n ) as rnk)
select months,month_n, 
case when pre_sales_Blue_Dart=0 then 0 else round(((sales_Blue_Dart-pre_sales_Blue_Dart)/pre_sales_Blue_Dart*100)::numeric,2) end as MOM_sales_Blue_Dart
from MOM_Blue_Dart),
Xpressbees as
(with MOM_Xpressbees as (select months,month_n,
sales_Xpressbees, lag(sales_Xpressbees,1,0) over () as pre_sales_Xpressbees from 
(with orders as ( select *, to_char(order_date,'month') as months, extract('month' from order_date) as month_n from orders )
select o.months,o.month_n, 
round((sum(o.qty)*avg(p.price)*(1-avg(o.coupon_discount)/100)*(avg(d.percent_cut)/100))::numeric,2) as sales_Xpressbees
from customer as c right join orders as o on o.c_id=c.c_id left join product as p on p.p_id=o.p_id join delivery as d 
on d.dp_id=o.dp_id where d.dp_name='Delhivery'  group by o.months,o.month_n order by month_n ) as rnk)
select months,month_n, 
case when pre_sales_Xpressbees=0 then 0 else 
round(((sales_Xpressbees-pre_sales_Xpressbees)/pre_sales_Xpressbees*100)::numeric,2) end as MOM_sales_Xpressbees
from MOM_Xpressbees),
Shadowfax as
(with MOM_Shadowfax as (select months,month_n,
sales_Shadowfax, lag(sales_Shadowfax,1,0) over () as pre_sales_Shadowfax from 
(with orders as ( select *, to_char(order_date,'month') as months, extract('month' from order_date) as month_n from orders )
select o.months,o.month_n, 
round((sum(o.qty)*avg(p.price)*(1-avg(o.coupon_discount)/100)*(avg(d.percent_cut)/100))::numeric,2) as sales_Shadowfax
from customer as c right join orders as o on o.c_id=c.c_id left join product as p on p.p_id=o.p_id join delivery as d 
on d.dp_id=o.dp_id where d.dp_name='Shadowfax'  group by o.months,o.month_n order by month_n ) as rnk)
select months,month_n, 
case when pre_sales_Shadowfax=0 then 0 else round(((sales_Shadowfax-pre_sales_Shadowfax)/pre_sales_Shadowfax*100)::numeric,2) end as MOM_sales_Shadowfax
from MOM_Shadowfax)
select d.months,d.MOM_sales_Delhivery,e.MOM_sales_Ecom_Express,b.MOM_sales_Blue_Dart,x.MOM_sales_Xpressbees,s.MOM_sales_Shadowfax from 
Delhivery as d join Ecom_Express as e on d.months=e.months join Blue_Dart as b on b.months=d.months join Xpressbees as x
on x.months=d.months join Shadowfax as s on s.months=d.months order by d.month_n;



