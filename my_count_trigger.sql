CREATE OR REPLACE FUNCTION my_count_trigger() returns trigger as $$
declare 
	cont integer := 0;
	curs1 refcursor;
	aux integer;
	
begin
	open curs1 for SELECT b FROM foo;
	<<countloop>>
	loop
		fetch curs1 into aux;
		IF NOT FOUND THEN
			EXIT;
		end if;
		cont := cont + 1;
	end loop countloop;
	raise notice '% registros em foo', cont;
	return NULL;
end;

$$ language plpgsql;