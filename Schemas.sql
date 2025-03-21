create table pizzas  (
	pizza_id varchar(15) not null,
	pizza_type_id varchar(15) not null,
	pizza_size varchar(5) not null,
	price float not null
);

create table pizza_types (
	pizza_type_id varchar(15) not null,
	pizza_name varchar(50) not null,
	pizza_category varchar(10) ,
	pizza_ingredient varchar(100)
);

create table orders (
	order_id int not null,
	order_date date not null,
	order_time time not null
);

create table order_details(
	order_id int not null,
	pizza_id varchar(15) not null,
	quantity int not null
);


select * from pizzas

select * from pizza_types

select * from orders

select * from order_details
