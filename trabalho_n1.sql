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


CREATE OR REPLACE FUNCTION lucro_obtido(date Date) returns decimal as $$

declare
    product products%ROWTYPE;
    orders_v orders%ROWTYPE;
    quantidade integer;
    cursor refcursor;
    lucro decimal := 0.0;

begin
    open cursor for SELECT orderdetails.quantityordered , orders.ordernumber, products.buyprice, products.msrp FROM orders JOIN orderdetails ON orderdetails.ordernumber = orders.ordernumber JOIN products ON orderdetails.productcode = products.productcode WHERE UPPER(orders.status) = 'SHIPPED' and orders.shippeddate BETWEEN date and NOW();    
    <<looplucro>>
	loop    
        fetch cursor into quantidade, orders_v.ordernumber, product.buyprice, product.msrp;
        
        IF NOT FOUND THEN
            EXIT;
        END IF;
        
        lucro := lucro + (product.msrp - product.buyprice) * quantidade;
    end loop looplucro;
    raise notice 'Lucro obtido desde %, foi: %', date, lucro;
    return lucro;
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