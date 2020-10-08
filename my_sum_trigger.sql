CREATE OR REPLACE FUNCTION my_sum_trigger() returns trigger as $$
declare 
	curs1 refcursor;
	aux integer;
	soma integer := 0;
	
begin
	open curs1 for SELECT b FROM foo;
	<<somaloop>>
	loop
		fetch curs1 into aux;
		IF NOT FOUND THEN
			EXIT;
		end if;
		soma := soma + aux;
	end loop somaloop;
	raise notice 'Soma de % registros em b da tabela foo', soma;
	return NULL;
end;

$$ language plpgsql;