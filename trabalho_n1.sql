-- INSERT INTO orderdetails VALUES (10100, 'S72_3212', 1, 50.0, 2);

CREATE OR REPLACE FUNCTION manager_trigger_estoque() returns trigger as $$
declare 
	product products%ROWTYPE;
	soma integer := 0;

	
begin
	SELECT * into product FROM products WHERE productcode = NEW.productcode;
    
	IF (product.quantityinstock - NEW.quantityordered) >= 0 THEN
        UPDATE products SET quantityinstock = quantityinstock - NEW.quantityordered WHERE productcode = NEW.productcode;
    ELSE 
        raise notice 'QUANTIDADE % FALTANDO NO ESTOQUE', NEW.quantityordered;
        UPDATE orders SET status = 'CANCELLED' WHERE ordernumber = NEW.ordernumber;
    END IF;
    
    NEW.priceeach := product.msrp;
	
    return NEW;
end;

$$ language plpgsql;

CREATE OR REPLACE FUNCTION payments_manager_trigger() returns trigger as $$

declare
    orders_v orders%ROWTYPE;
    preco_orderdetails integer;
    quantidade_orderdetails integer;
	cursor1 refcursor;
begin
    
    open cursor1 for SELECT orders.customernumber, orders.status, orders.ordernumber FROM customers JOIN orders ON customers.customernumber = orders.customernumber WHERE customers.customernumber = NEW.customernumber AND UPPER(orders.status) NOT LIKE 'SHIPPED' AND UPPER(orders.status) NOT LIKE 'CANCELLED';
	fetch cursor1 into orders_v.customernumber, orders_v.status, orders_v.ordernumber;
	IF NOT FOUND THEN
		raise exception 'Não foi encontrado nenhum pedido do customernumber de % com status ON HOLD', NEW.customernumber;		
	END IF;	
    SELECT priceeach, quantityordered INTO preco_orderdetails, quantidade_orderdetails FROM orderdetails WHERE ordernumber = orders_v.ordernumber;
	    
	IF NEW.amount >= (preco_orderdetails * quantidade_orderdetails) THEN
        UPDATE orders SET status = 'SHIPPED' WHERE ordernumber = orders_v.ordernumber;
    END IF;    
    UPDATE orders SET shippeddate = NEW.paymentdate WHERE ordernumber = orders_v.ordernumber;
    return NEW;
end;

$$ language plpgsql;


CREATE TRIGGER trigger_estoque 
	BEFORE INSERT on orderdetails
	FOR EACH ROW
	EXECUTE FUNCTION manager_trigger_estoque();

CREATE TRIGGER trigger_pagamento 
    AFTER INSERT ON payments
    FOR EACH ROW
    EXECUTE FUNCTION payments_manager_trigger();