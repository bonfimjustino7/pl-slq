CREATE OR REPLACE FUNCTION my_sum(col varchar(255), tb varchar(255)) returns integer as $$
declare 
	soma integer := 0;
	curs1 refcursor;
	aux integer;
	
begin
	open curs1 for execute format('SELECT %I FROM %I ', col, tb);
	<<somaloop>>
	loop
		fetch curs1 into aux;
		IF NOT FOUND THEN
			EXIT;
		end if;
		soma := soma + aux;
	end loop somaloop;
	
	return soma;
end;

$$ language plpgsql;