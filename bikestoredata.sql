


--1.	Write a query to provide in-Depth revenue details of the store.

select 
o.order_id,
o.order_date,
concat(c.first_name,' ',c.last_name) as CustomerName,
c.city,
c.state,
br.Brand_Name,
ct.Category_Name,
pr.Product_name,
sum(oi.quantity)as TotalUnits,
sto.store_name,
CONCAT(stf.first_name,' ',stf.last_name) as Sales_Rep,
sum(oi.quantity*oi.list_price) as Revenue
from sales.orders o
join sales.customers c on o.customer_id=c.customer_id
join sales.order_items oi on oi.order_id=o.order_id
join production.products pr on oi.product_id=pr.product_id
join production.categories ct on ct.category_id=pr.category_id
join production.brands br on br.brand_id=pr.brand_id
join sales.stores sto on sto.store_id=o.store_id
join sales.staffs stf on stf.staff_id =o.staff_id
group by o.order_id,
o.order_date,concat(c.first_name,' ',c.last_name),
c.city,c.state,pr.Product_name,ct.Category_Name,br.Brand_Name,sto.store_name,CONCAT(stf.first_name,' ',stf.last_name);





--2.	Provide in-depth revenue details of the store using temp table.

DROP table if exists #BikeStoreAudit;            
create table #BikeStoreAudit(                           /*Temp table create command*/
order_id int,
order_date date,
CustomerName varchar(255),
city varchar(255),
state varchar(255),
Brand_Name varchar(255),
Category_Name varchar(255),
Product_Name varchar(255),
TotalUnits int,
Store_Name varchar(255),
Sales_Rep varchar(255),
Revenue float
);

INSERT INTO #BikeStoreAudit                        /*Inserting values in temp table*/
select 
o.order_id,
o.order_date,
concat(c.first_name,' ',c.last_name) as CustomerName,
c.city,
c.state,
br.Brand_Name,
ct.Category_Name,
pr.Product_name,
sum(oi.quantity)as TotalUnits,
sto.store_name,
CONCAT(stf.first_name,' ',stf.last_name) as Sales_Rep,
sum(oi.quantity*oi.list_price) as Revenue
from sales.orders o
join sales.customers c on o.customer_id=c.customer_id
join sales.order_items oi on oi.order_id=o.order_id
join production.products pr on oi.product_id=pr.product_id
join production.categories ct on ct.category_id=pr.category_id
join production.brands br on br.brand_id=pr.brand_id
join sales.stores sto on sto.store_id=o.store_id
join sales.staffs stf on stf.staff_id =o.staff_id
group by o.order_id,
o.order_date,concat(c.first_name,' ',c.last_name),
c.city,c.state,pr.Product_name,ct.Category_Name,br.Brand_Name,sto.store_name,CONCAT(stf.first_name,' ',stf.last_name);

select * from #BikeStoreAudit;            /*showing data in temp table*/




--3.	Write a query to get total revenue details of the store till now.

select sum(quantity)as TotalUnit,sum(quantity*list_price) as Revenue 
from sales.order_items;



--4.	Find out which store has given the highest profit(revenue).

select c.State,s.store_name, sum(oi.quantity*oi.list_price) as Revenue
from sales.customers c
join sales.orders o on c.customer_id=o.customer_id
join sales.order_items oi on oi.order_id=o.order_id
join sales.stores s on s.store_id=o.store_id
group by c.state,s.store_name
order by revenue desc;


--5.	Find out the store with highest invoices.

select c.State,s.store_name,sum(oi.quantity) as TotalOrders 
from sales.customers c
join sales.orders o on c.customer_id=o.customer_id
join sales.order_items oi on oi.order_id=o.order_id
join sales.stores s on s.store_id=o.store_id
group by c.state,s.store_name
order by TotalOrders desc;


--6.	Provide invoice and revenue data of each store in each year.

select c.State,s.store_name,year(order_date) as Year,sum(oi.quantity) as TotalOrders, sum(oi.quantity*oi.list_price) as Revenue
from sales.customers c
join sales.orders o on c.customer_id=o.customer_id
join sales.order_items oi on oi.order_id=o.order_id
join sales.stores s on s.store_id=o.store_id
group by c.State,s.store_name, year(o.order_date)
order by 1,3;

--7.	Write a query to find out in which year we earned the most.

select year(o.order_date) as Year,sum(oi.quantity) as TotalOrders, sum(oi.quantity*oi.list_price) as Revenue
from sales.customers c
join sales.orders o on c.customer_id=o.customer_id
join sales.order_items oi on oi.order_id=o.order_id
--where year(order_date)=2016
group by  year(o.order_date)
order by 3 desc;

--8.	Write a query using CTE to provide which store gave the most profit in each specific year.

with RevenueYear (state,store,year,totalorders,revenue)
as
(
    select c.State,s.store_name,year(order_date) as Year,sum(oi.quantity) as TotalOrders, sum(oi.quantity*oi.list_price) as Revenue
	from sales.customers c
	join sales.orders o on c.customer_id=o.customer_id
	join sales.order_items oi on oi.order_id=o.order_id
	join sales.stores s on s.store_id=o.store_id
	group by c.State,s.store_name, year(o.order_date)

)
select state,store,year,Revenue
from Revenueyear
where year='2016'
order by revenue desc;

--9.	Provide the number of employee details working in each store

select concat(stf.first_name,' ',stf.last_name) as FullName,st.state,st.Store_name, count(concat(stf.first_name,' ',stf.last_name)) over (partition by st.store_name) as TotalWorkers
from sales.stores st
join sales.staffs stf on stf.store_id=st.store_id;

--10.	Write a query to determine Top 5 brands.

select top 5  b.Brand_Name, sum(oi.quantity*oi.list_price) as Revenue
from production.brands b
join production.products pr on pr.brand_id=b.brand_id
join sales.order_items oi on oi.product_id= pr.product_id
join sales.orders o on o.order_id=oi.order_id
where year(o.order_date) =2017
group by b.brand_name
order by 2 desc;


--11.	Write a query to find out TOP 3 customer.

select TOP 3 concat(c.first_name,'',c.last_name) as Customer,sum(oi.quantity) as TotalOrders 
from sales.customers c 
join sales.orders o on c.customer_id=o.customer_id
join sales.order_items oi on oi.order_id=o.order_id
join sales.stores s on s.store_id=o.store_id
group by concat(c.first_name,'',c.last_name)
order by TotalOrders desc;
