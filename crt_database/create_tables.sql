
CREATE TABLE IF NOT EXISTS customer (
    customer_id SERIAL PRIMARY KEY not null,
    fname VARCHAR(50) not null,
	lname VARCHAR(50) not null,
	city VARCHAR(50) not null,
	state char(2) not null,
	street VARCHAR(50) not null,
	zip integer not null,
	username VARCHAR(50),
	password VARCHAR(50),
	email VARCHAR(50),
	acc_creation_date timestamp, 
	phone_number bigint not null

 );

 CREATE TABLE IF NOT EXISTS employee (
    employee_id SERIAL PRIMARY KEY not null, 
	fname VARCHAR(50) not null,
	lname VARCHAR(50) not null,
	city VARCHAR(11) not null,
	state VARCHAR(50) not null,
	street VARCHAR(50) not null,
	zip INT not null,
	phone_number bigint not null
);


CREATE TABLE IF NOT EXISTS delivery_address (
    address_id SERIAL PRIMARY KEY not null,
    city VARCHAR(50) not null,
	street VARCHAR(50) not null,
	state VARCHAR(50) not null,
	zip INT not null
 );


CREATE TABLE IF NOT EXISTS flower_product (
    product_id SERIAL PRIMARY KEY not null, 
	product_name VARCHAR(50) not null,
	purchase_price decimal(12,2) not null,
	sell_price decimal(12,2) not null,
	color VARCHAR(50) not null,
	length DECIMAL(4,2) not null,
	product_image VARCHAR(24) not null,
	description VARCHAR(255) not null
);


CREATE TABLE IF NOT EXISTS order_status (
    status_id INT PRIMARY KEY not null,
	status VARCHAR(50) not null
);


CREATE TABLE IF NOT EXISTS payment_type (
    payment_type_id INT PRIMARY KEY not null, 
    description VARCHAR(50) not null
);

CREATE TABLE IF NOT EXISTS supplier (
    supply_id SERIAL PRIMARY KEY not null,
    vendor_name VARCHAR(50) not null,
	city VARCHAR(50) not null,
	state VARCHAR(50) not null,
	street VARCHAR(50) not null,
	zip INT not null,
	phone_number bigint not null
);

CREATE TABLE IF NOT EXISTS product_order (
    p_order_number SERIAL PRIMARY KEY not null, 
    order_time timestamp not null,

    customer_id integer not null, 
    status_id integer not null, 
    employee_id integer not null, 
    address_id integer not null,

	CONSTRAINT fk_order_customer FOREIGN KEY (customer_id) 
		REFERENCES customer(customer_id),
	CONSTRAINT fk_order_status FOREIGN KEY (status_id) 
		REFERENCES order_status(status_id),
	CONSTRAINT fk_order_employee FOREIGN KEY (employee_id) 
		REFERENCES employee(employee_id),
	CONSTRAINT fk_order_address FOREIGN KEY (address_id) 
		REFERENCES delivery_address(address_id)

);

CREATE TABLE IF NOT EXISTS incoming_payment (
    incoming_payment_id SERIAL PRIMARY KEY not null,
	sales_tax DECIMAL(10,4) not null

);

CREATE TABLE IF NOT EXISTS outgoing_payment (
    outgoing_payment_id SERIAL PRIMARY KEY not null,
    supplier_invoice_id INT

);

CREATE TABLE IF NOT EXISTS payment(
	payment_time timestamp not null,
    amount decimal(12,2) not null default 0,
    payment_type_id integer not null,
	incoming_payment_id integer references incoming_payment(incoming_payment_id) UNIQUE,
	outgoing_payment_id integer references outgoing_payment(outgoing_payment_id) UNIQUE,

	CONSTRAINT ck_pay_amount CHECK (amount > 0)
);


CREATE TABLE IF NOT EXISTS package (
    package_id SERIAL PRIMARY KEY not null,
    expected_time timestamp not null,
	message VARCHAR(19) not null,
	p_order_number INT not null,
	employee_id INT not null,

	CONSTRAINT fk_package_order_number FOREIGN KEY (p_order_number)
		REFERENCES product_order(p_order_number),
	CONSTRAINT fk_package_employee_id FOREIGN KEY (employee_id)
		REFERENCES employee(employee_id)
);




CREATE TABLE IF NOT EXISTS recipient (
    recipient_id SERIAL PRIMARY KEY not null,
   	fname VARCHAR(50) not null,
	lname VARCHAR(50) not null,
	phone_number bigint not null,
    package_id integer not null,

	CONSTRAINT fk_recipient_package FOREIGN KEY (package_id)
		REFERENCES package(package_id)
);


CREATE TABLE IF NOT EXISTS requires (
    p_order_number integer not null,
    incoming_payment_id integer not null UNIQUE,

	CONSTRAINT pk_supply_product_order 
		PRIMARY KEY (p_order_number, incoming_payment_id),

	CONSTRAINT fk_requires_order_number FOREIGN KEY (p_order_number)
		REFERENCES product_order(p_order_number),
	CONSTRAINT fk_requires_payment FOREIGN KEY (incoming_payment_id)
		REFERENCES incoming_payment(incoming_payment_id)

);


CREATE TABLE IF NOT EXISTS work_history (
    history_id serial PRIMARY KEY not null,
    start_date timestamp not null,
    end_date timestamp,
    job_title VARCHAR(50) not null,
	pay_rate decimal(12,2) not null,
	employee_id INT not null,
		
	CONSTRAINT fk_employee_history FOREIGN KEY (employee_id) 
		REFERENCES employee(employee_id)

	
);


CREATE TABLE IF NOT EXISTS contains (
    p_order_number integer not null,
	product_id integer not null,
	quantity_item integer not null,
    point_of_sale_price decimal(12,2), 

	CONSTRAINT pk_contains
		PRIMARY KEY (p_order_number, product_id),

	CONSTRAINT fk_contains_order_number FOREIGN KEY (p_order_number) 
		REFERENCES product_order(p_order_number),

	CONSTRAINT fk_contains_product FOREIGN KEY (product_id) 
		REFERENCES flower_product(product_id)
);


CREATE TABLE IF NOT EXISTS supply_purchase_order (
    supply_purchase_id SERIAL PRIMARY KEY not null,
    supply_purchase_time timestamp not null,
    employee_id int not null,
    supply_id int not null,

	CONSTRAINT fk_purchase_order_employee FOREIGN KEY (employee_id) 
		REFERENCES employee(employee_id),
	CONSTRAINT fk_purchase_order_supplier FOREIGN KEY (supply_id)
		REFERENCES supplier(supply_id)
);

 CREATE TABLE IF NOT EXISTS needs (
	supply_purchase_id INT not null,
 	outgoing_payment_id INT not null UNIQUE,

	CONSTRAINT pk_supply_needs_payment
		PRIMARY KEY (supply_purchase_id, outgoing_payment_id),

	CONSTRAINT fk_needs_supply_purchase FOREIGN KEY (supply_purchase_id)
		REFERENCES supply_purchase_order(supply_purchase_id),
	CONSTRAINT fk_needs_payment FOREIGN KEY (outgoing_payment_id)
		REFERENCES outgoing_payment(outgoing_payment_id)
 );


 CREATE TABLE IF NOT EXISTS refills (
    supply_purchase_id integer not null,
    product_id integer not null,
    quantity_item integer not null,
    supply_price decimal(12,2) not null,

	CONSTRAINT pk_refills_supply_purchase_product 
		PRIMARY KEY (supply_purchase_id, product_id),

	CONSTRAINT fk_supply_purchase FOREIGN KEY (supply_purchase_id) 
		REFERENCES supply_purchase_order(supply_purchase_id),
	CONSTRAINT fk_product FOREIGN KEY (product_id)
		REFERENCES flower_product(product_id)
);

CREATE TABLE IF NOT EXISTS work_shift (
	shift_id serial not null,
	employee_id integer not null,
	shift_date date not null,
	begin_time time not null,
	end_time time not null,

	CONSTRAINT pk_employee_shift
		PRIMARY KEY (shift_id, employee_id),

	CONSTRAINT fk_employee_id FOREIGN KEY (employee_id)
		REFERENCES employee(employee_id),
		-- make sure employee doesn't work same day twice business rule
	CONSTRAINT id_day_check UNIQUE(employee_id, shift_date)
);
