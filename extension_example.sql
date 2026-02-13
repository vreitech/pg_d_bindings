CREATE OR REPLACE FUNCTION myfunction_debug(int) RETURNS int AS '$libdir/extension_example', 'myfunction_debug' LANGUAGE C STRICT;
CREATE OR REPLACE FUNCTION myfunction(int) returns int as '$libdir/extension_example', 'myfunction' LANGUAGE C STRICT;
CREATE OR REPLACE FUNCTION add_numbers(int, int) RETURNS int AS '$libdir/extension_example','add_numbers' LANGUAGE C STRICT;
CREATE OR REPLACE FUNCTION print_text(text) RETURNS text AS '$libdir/extension_example','print_text' LANGUAGE C STRICT;
CREATE OR REPLACE FUNCTION print_varchar(varchar) RETURNS varchar AS '$libdir/extension_example','print_varchar' LANGUAGE C STRICT;
CREATE OR REPLACE FUNCTION print_name(name) RETURNS name AS '$libdir/extension_example','print_name' LANGUAGE C STRICT;
CREATE OR REPLACE FUNCTION print_bytea(bytea) RETURNS bytea AS '$libdir/extension_example', 'print_bytea' LANGUAGE C STRICT;

SELECT myfunction_debug(42); -- 1
SELECT myfunction(42); -- 42
SELECT add_numbers(42,44); -- 86
SELECT print_text('Test text') AS value, pg_typeof(print_text('Test text')) AS type; -- 'Test text', 'text'
SELECT length(repeat('x', 5000)) AS expected_len,
    length(print_text(repeat('x', 5000))) AS returned_len,
    print_text(repeat('x', 5000)) = repeat('x', 5000) AS equal_direct,
    pg_column_size(repeat('x', 5000)::text) AS storage_bytes_direct; -- 5000, 5000, t, 5004
BEGIN;
CREATE TEMP TABLE t_toast_test(id int GENERATED ALWAYS AS IDENTITY PRIMARY KEY, t text)
ON COMMIT DROP;
INSERT INTO t_toast_test(t) VALUES (repeat('x', 5000));
SELECT id,
    pg_column_size(t) AS storage_bytes
FROM t_toast_test; -- 69
SELECT id,
    length(print_text(t)) AS returned_len,
    print_text(t) = t AS equal_from_table
FROM t_toast_test; -- 1, 5000, t
SELECT
    (length(print_text(t)) = length(t)) AS len_matches,
    (print_text(t) = t) AS content_matches
FROM t_toast_test; -- t, t
COMMIT;
SELECT print_varchar('Test varchar') AS value, pg_typeof(print_varchar('Test varchar')) AS type; -- 'Test varchar', 'character varying'
SELECT print_name('Test name') AS value, pg_typeof(print_name('Test name')) AS type; -- 'Test name', 'name'
SELECT print_bytea('\x010203'::bytea) AS value, pg_typeof(print_bytea('\x010203'::bytea)) AS type; -- '\x010203', 'bytea'
SELECT
    '\x01020304ff'::bytea AS input,
    print_bytea('\x01020304ff'::bytea) AS output,
    print_bytea('\x01020304ff'::bytea) = '\x01020304ff'::bytea AS equal_short; -- '\x01020304ff', '\x01020304ff', t
SELECT
    length(decode(repeat('AA', 1000), 'hex')) AS expected_len,
    length(print_bytea(decode(repeat('AA', 1000), 'hex'))) AS returned_len,
    encode(print_bytea(decode(repeat('AA', 1000), 'hex')), 'hex')
        = encode(decode(repeat('AA', 1000), 'hex'), 'hex') AS equal_direct; -- 1000, 1000, t
BEGIN;
CREATE TEMP TABLE t_bytea_toast(id int GENERATED ALWAYS AS IDENTITY PRIMARY KEY, b bytea)
ON COMMIT DROP;
INSERT INTO t_bytea_toast(b) VALUES (decode(repeat('DEADBEEF', 2000), 'hex'));
SELECT id,
    pg_column_size(b) AS storage_bytes
FROM t_bytea_toast; -- 107
SELECT
    id,
    length(print_bytea(b)) AS returned_len,
    encode(print_bytea(b), 'hex') = encode(b, 'hex') AS equal_from_table
FROM t_bytea_toast; -- 1, 8000, t
SELECT
    (length(print_bytea(b)) = length(b)) AS len_matches,
    (encode(print_bytea(b), 'hex') = encode(b, 'hex')) AS content_matches
FROM t_bytea_toast; -- t, t
COMMIT;
