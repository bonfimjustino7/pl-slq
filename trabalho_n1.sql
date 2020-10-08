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



CREATE TRIGGER trigger_estoque 
	BEFORE INSERT on orderdetails
	FOR EACH ROW
	EXECUTE FUNCTION manager_trigger_estoque();