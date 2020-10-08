create or replace function call_proc() returns void as $$

declare
	a integer;
	b integer;
begin
	call my_proc_may(a, b);
	raise notice 'value of a is %', a;
	raise notice 'value of b is %', b;
	return;
end;

$$ LANGUAGE plpgsql;