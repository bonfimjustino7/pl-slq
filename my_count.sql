CREATE OR REPLACE FUNCTION my_count(col varchar(255), tb varchar(255)) returns integer as $$
declare 
	cont integer := 0;
	curs1 refcursor;
	aux integer;
	
begin
	open curs1 for execute format('SELECT %I FROM %I', col, tb);
	<<countloop>>
	loop
		fetch curs1 into aux;
		IF NOT FOUND THEN
			EXIT;
		end if;
		cont := cont + 1;
	end loop countloop;
	
	return cont;
end;

$$ language plpgsql;