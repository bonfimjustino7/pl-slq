create procedure my_proc_may(inout a integer, inout b integer) as $$

declare
	var1 foo%rowtype;
begin
	execute 'select * from foo where a = 5' into var1;
	a := var1.a + 5;
	b := var1.b - 5;
	
end;

$$ LANGUAGE plpgsql;
