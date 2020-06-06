
-- insert into flowerproduct
CREATE OR REPLACE PROCEDURE
insert_new_flower_product (
varchar,
decimal(12,2),
decimal(12,2),
VARCHAR(50),
DECIMAL(4,2),
VARCHAR(24),
VARCHAR(255))
LANGUAGE plpgsql
AS $$
BEGIN
    insert into flower_product(product_name, purchase_price,
     sell_price, color, length, product_image, description )
     values ($1, $2, $3, $4, $5, $6, $7);
END;
$$;

-- delete customer
CREATE OR REPLACE PROCEDURE
remove_customer_record(
    Integer
)
LANGUAGE plpgsql
AS $$
BEGIN
    DELETE FROM customer
    WHERE customer_id = $1;
END;
$$;

-- get average of cheapest number passed in
CREATE OR REPLACE FUNCTION average_of_products(integer)
RETURNS DECIMAL(4,2) AS $average$
DECLARE
    average DECIMAL(4,2);
BEGIN
    SELECT AVG (a.sell_price) INTO average FROM (
        SELECT sell_price FROM flower_product ORDER BY sell_price ASC LIMIT $1
    ) AS a;
    RETURN average;
END;
$average$ LANGUAGE plpgsql;

--updates employee ID when Changed
-- CREATE OR REPLACE FUNCTION update_employee_everywhere()
-- RETURNS trigger AS $BODY$
-- BEGIN
--     -- Disable FK constraint just for trigger
--     -- Not good idea normally
--     ALTER TABLE product_order ALTER CONSTRAINT fk_order_employee DEFERRABLE;
--     ALTER TABLE package ALTER CONSTRAINT fk_package_employee_id DEFERRABLE;
--     ALTER TABLE work_history ALTER CONSTRAINT fk_employee_history DEFERRABLE;
--     ALTER TABLE supply_purchase_order ALTER CONSTRAINT fk_purchase_order_employee DEFERRABLE;
--     ALTER TABLE work_shift ALTER CONSTRAINT fk_employee_id DEFERRABLE;
--     SET CONSTRAINTS fk_order_employee, fk_package_employee_id,
--     fk_employee_history, fk_purchase_order_employee, fk_employee_id DEFERRED;

--     IF NEW.employee_id <> OLD.employee_id THEN
--         UPDATE product_order SET employee_id = NEW.employee_id WHERE
--         employee_id = OLD.employee_id;
--         UPDATE package SET employee_id = NEW.employee_id WHERE
--         employee_id = OLD.employee_id; 
--         UPDATE work_history  SET employee_id = NEW.employee_id WHERE
--         employee_id = OLD.employee_id;
--         UPDATE supply_purchase_order SET employee_id = NEW.employee_id WHERE
--         employee_id = OLD.employee_id;
--         UPDATE work_shift SET employee_id = NEW.employee_id WHERE
--         employee_id = OLD.employee_id;
--     END IF;
--     RETURN NEW;
--     -- Fix FK constraint
--     ALTER TABLE product_order ALTER CONSTRAINT fk_order_employee NOT DEFERRABLE;
--     ALTER TABLE package ALTER CONSTRAINT fk_package_employee_id NOT DEFERRABLE;
--     ALTER TABLE work_history ALTER CONSTRAINT fk_employee_history NOT DEFERRABLE;
--     ALTER TABLE supply_purchase_order ALTER CONSTRAINT fk_purchase_order_employee NOT DEFERRABLE;
--     ALTER TABLE work_shift ALTER CONSTRAINT fk_employee_id NOT DEFERRABLE;
-- END;
-- $BODY$ LANGUAGE plpgsql;

DROP TRIGGER IF EXISTS update_employee ON employee;
-- CREATE TRIGGER update_employee
-- BEFORE UPDATE ON employee
-- FOR EACH ROW EXECUTE PROCEDURE update_employee_everywhere();

----

-- Deletion Trigger 
CREATE OR REPLACE FUNCTION remove_customer_records()
RETURNS TRIGGER as $BODY$
BEGIN
    DELETE FROM requires
    WHERE p_order_number = ANY(
        SELECT requires.p_order_number
        FROM requires 
        INNER JOIN product_order ON product_order.p_order_number = requires.p_order_number
        WHERE product_order.customer_id = OLD.customer_id
        );
    DELETE FROM recipient
    WHERE package_id = ANY(
        SELECT package.package_id
        FROM package 
        INNER JOIN product_order ON product_order.p_order_number = package.p_order_number
        INNER JOIN customer ON customer.customer_id = product_order.customer_id
        WHERE product_order.customer_id = OLD.customer_id
    );
    DELETE FROM contains
    WHERE p_order_number = ANY(
        SELECT contains.p_order_number
        FROM contains
        INNER JOIN product_order ON contains.p_order_number = product_order.p_order_number
        INNER JOIN customer ON customer.customer_id = product_order.customer_id
        WHERE product_order.customer_id = OLD.customer_id
    );
    DELETE FROM package
    WHERE p_order_number = ANY(
        SELECT package.p_order_number
        FROM package 
        INNER JOIN product_order ON product_order.p_order_number = package.p_order_number
        WHERE product_order.customer_id = OLD.customer_id
    );
    
    DELETE FROM product_order WHERE customer_id = OLD.customer_id;
    RETURN OLD;
END;
$BODY$ LANGUAGE plpgsql;

DROP TRIGGER IF EXISTS remove_customer ON customer;
CREATE TRIGGER remove_customer
BEFORE DELETE ON customer
FOR EACH ROW EXECUTE PROCEDURE remove_customer_records();


-- Update an Employees Name
-- weird issues if earlier query is not commented out
CREATE OR REPLACE FUNCTION update_employee_name()
RETURNS trigger AS $BODY$
BEGIN
    IF NEW.employee_name <> OLD.employee_name THEN
        UPDATE employee set fname = split_part(NEW.employee_name, ' ', 1),
        lname = split_part(NEW.employee_name, ' ', 2)
        WHERE employee_id = OLD.employee_id;
    END IF;

    RETURN NEW;
END;
$BODY$ LANGUAGE plpgsql;


DROP TRIGGER IF EXISTS edit_employee_name ON view_manager_scheduling;
CREATE TRIGGER edit_employee_name
INSTEAD OF UPDATE ON view_manager_scheduling
FOR EACH ROW
    EXECUTE PROCEDURE update_employee_name();



CREATE OR REPLACE PROCEDURE fillCustomerRandomly()
LANGUAGE plpgsql
AS $$
BEGIN
    -- fill customer todo add random password and times
    FOR counter in 1..1000 LOOP
        insert into customer(fname, lname, city, state, street, zip, username, password, email, acc_creation_date, phone_number)
        values (
            (SELECT name from first_names WHERE id=(SELECT floor(random() * 10000 + 1)::int)),
            (SELECT name from last_names WHERE id=(SELECT floor(random() * 10000 + 1)::int)),
            'Bakersfield',
             'CA',
              concat((floor(random() * 10000 + 1)::int) ,' ', (SELECT name from last_names WHERE id=(SELECT floor(random() * 10000 + 1)::int)), ' Street'),
               93312,
                concat( (SELECT name from last_names WHERE id=(SELECT floor(random() * 10000 + 1)::int)), ' ', (floor(random() * 10000 + 1)::int)),
                'passwordRand',
                 concat( (SELECT name from first_names WHERE id=(SELECT floor(random() * 10000 + 1)::int)), '@gmail.com'),
                  NOW(),
                   (SELECT floor(random() * 8999999999 + 1000000000)::bigint)
          ) ;
    END LOOP;
END;
$$;

CREATE OR REPLACE PROCEDURE fillEmployeeRandomly()
LANGUAGE plpgsql
AS $$
BEGIN
    -- fill employee
    FOR counter in 1..1000 LOOP
        insert into employee(fname, lname, city, state, street, zip, phone_number)
        values (
            (SELECT name from first_names WHERE id=(SELECT floor(random() * 10000 + 1)::int)),
            (SELECT name from last_names WHERE id=(SELECT floor(random() * 10000 + 1)::int)),
            'Bakersfield',
             'CA',
              concat((floor(random() * 10000 + 1)::int) ,' ', (SELECT name from last_names WHERE id=(SELECT floor(random() * 10000 + 1)::int)), ' Street'),
               93312,
                   (SELECT floor(random() * 8999999999 + 1000000000)::bigint)
          ) ;
    END LOOP;
END;
$$;


CREATE OR REPLACE PROCEDURE fillIncomingPaymentsRandomly()
LANGUAGE plpgsql
AS $$
DECLARE
incoming_payment_insert integer := 1;
product_order_num integer := ((SELECT floor(random() * (SELECT count(*) FROM product_order) + 1)));
BEGIN

    FOR COUNTER IN 1..100 LOOP
        product_order_num := ((SELECT floor(random() * (SELECT count(*) FROM product_order))));
        IF product_order_num = 0 THEN
            product_order_num := 1; -- EDGE CASE RANDOM PK-0
        END IF;

        insert into incoming_payment(sales_tax) values (.0700);

        incoming_payment_insert := ((SELECT count(*) FROM incoming_payment));
        insert into requires(p_order_number, incoming_payment_id) values (product_order_num, incoming_payment_insert);


        insert into payment(payment_time, amount, payment_type_id, incoming_payment_id)
         values ( (select timestamp '2000-01-10 20:00:00' +
       random() * (timestamp '2020-01-20 20:00:00' -
                   timestamp '2000-01-10 10:00:00')), (SELECT floor(random() * 10 + 15)), (SELECT floor(random() * 10 + 1)), incoming_payment_insert);
   END LOOP;
END;
$$;

CREATE OR REPLACE PROCEDURE fillOutgoingPaymentsRandomly()
LANGUAGE plpgsql
AS $$
DECLARE
outgoing_payment_insert integer := 1;
supply_order_num integer := ((SELECT floor(random() * (SELECT count(*) FROM supply_purchase_order) + 1)));
BEGIN

    FOR COUNTER IN 1..70 LOOP
        supply_order_num := ((SELECT floor(random() * (SELECT count(*) FROM supply_purchase_order))));
        IF supply_order_num = 0 THEN
            supply_order_num := 1; -- EDGE CASE RANDOM PK-0
        END IF;

        insert into outgoing_payment(supplier_invoice_id) values ((floor(random() * 1000000 + 1)::int));

        outgoing_payment_insert := ((SELECT count(*) FROM outgoing_payment));
        insert into needs(supply_purchase_id, outgoing_payment_id) values (supply_order_num, outgoing_payment_insert);


        insert into payment(payment_time, amount, payment_type_id, outgoing_payment_id)
         values ( (select timestamp '2000-01-10 20:00:00' +
       random() * (timestamp '2020-01-20 20:00:00' -
                   timestamp '2000-01-10 10:00:00')), (SELECT floor(random() * 10 + 15)), (SELECT floor(random() * 10 + 1)), outgoing_payment_insert);
   END LOOP;
END;
$$;

CREATE OR REPLACE PROCEDURE fill_work_shift(
    startDate timestamp
)
LANGUAGE plpgsql
AS $$
DECLARE
startTime time := '8:00 AM';
endDate date := startDate + '7 Days';
chosen_emp_id int := 1;
BEGIN

    FOR COUNTER IN 1..30 LOOP
    chosen_emp_id := ((SELECT floor(random() * (SELECT count(*) FROM employee))));
        IF chosen_emp_id = 0 THEN
            chosen_emp_id := 1; -- EDGE CASE RANDOM PK-0
        END IF;

        startTime := date_trunc('hour', (select time ' 8:00:00' +
       random() * (time ' 18:00:00' -
                   time '8:00:00')));

       INSERT INTO work_shift(employee_id, shift_date, begin_time, end_time) values 
            (chosen_emp_id,
            (select  startDate +
       random() * ( endDate -
                    startDate)),
                   startTime,
                   startTime + '4 hours')
                   ON CONFLICT ON CONSTRAINT id_day_check DO NOTHING;
    END LOOP;
END;
$$;

CREATE OR REPLACE FUNCTION check_work_shift()
RETURNS TRIGGER AS $BODY$
DECLARE
placehold time := '8:00 AM';
BEGIN
    IF OLD.begin_time > OLD.end_time THEN
        placehold := end_time;
        UPDATE work_shift set begin_time = end_time, end_time = placehold
        WHERE work_shift.shift_id = NEW.shift_id;
    END IF;
    RETURN NEW;
END;
$BODY$ LANGUAGE plpgsql;

DROP TRIGGER IF EXISTS time_switch ON work_shift;
CREATE TRIGGER time_switch
before insert ON work_shift
FOR EACH ROW EXECUTE PROCEDURE check_work_shift();


CREATE OR REPLACE PROCEDURE randomGenStressTest()
LANGUAGE plpgsql
AS $$
BEGIN
    FOR COUNTER IN 1..10 LOOP
        CALL fillOutgoingPaymentsRandomly();
        CALL fillIncomingPaymentsRandomly();
    END LOOP;

END;
$$;

