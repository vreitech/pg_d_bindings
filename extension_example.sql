CREATE OR REPLACE FUNCTION myfunction_debug(int) RETURNS int AS '$libdir/extension_example', 'myfunction_debug' LANGUAGE C STRICT;
CREATE OR REPLACE FUNCTION myfunction(int) returns int as '$libdir/extension_example', 'myfunction' LANGUAGE C STRICT;
CREATE OR REPLACE FUNCTION add_numbers(int, int) RETURNS int AS '$libdir/extension_example','add_numbers' LANGUAGE C STRICT;
CREATE OR REPLACE FUNCTION printt(text) RETURNS text AS '$libdir/extension_example','printt' LANGUAGE C STRICT;

select myfunction_debug(42);
select myfunction(42);
select add_numbers(42,44);
select printt('asdf qQq');