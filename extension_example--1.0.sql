CREATE OR REPLACE FUNCTION myfunction_debug(int) RETURNS int AS '$libdir/extension_example', 'myfunction_debug' LANGUAGE C STRICT;
CREATE OR REPLACE FUNCTION myfunction(int) returns int as '$libdir/extension_example', 'myfunction' LANGUAGE C STRICT;
CREATE OR REPLACE FUNCTION add_numbers(int, int) RETURNS int AS '$libdir/extension_example','add_numbers' LANGUAGE C STRICT;
CREATE OR REPLACE FUNCTION print_text(text) RETURNS text AS '$libdir/extension_example','print_text' LANGUAGE C STRICT;
CREATE OR REPLACE FUNCTION print_varchar(varchar) RETURNS varchar AS '$libdir/extension_example','print_varchar' LANGUAGE C STRICT;
CREATE OR REPLACE FUNCTION print_name(name) RETURNS name AS '$libdir/extension_example','print_name' LANGUAGE C STRICT;
CREATE OR REPLACE FUNCTION print_bytea(bytea) RETURNS bytea AS '$libdir/extension_example', 'print_bytea' LANGUAGE C STRICT;