CREATE OR REPLACE FUNCTION myfunction_debug(int) RETURNS int AS '$libdir/extension_example', 'myfunction_debug' LANGUAGE C STRICT;
CREATE OR REPLACE FUNCTION myfunction(int) returns int as '$libdir/extension_example', 'myfunction' LANGUAGE C STRICT;
CREATE OR REPLACE FUNCTION add_numbers(int, int) RETURNS int AS '$libdir/extension_example','add_numbers' LANGUAGE C STRICT;
CREATE OR REPLACE FUNCTION printt(text) RETURNS text AS '$libdir/extension_example','printt' LANGUAGE C STRICT;
CREATE OR REPLACE FUNCTION printb(bytea) RETURNS bytea AS '$libdir/extension_example', 'printb' LANGUAGE C STRICT;

SELECT myfunction_debug(42); -- 1
SELECT myfunction(42); -- 42
SELECT add_numbers(42,44); -- 86
SELECT printt('Test string'); -- 'Test string'
SELECT length(repeat('x', 5000)) AS expected_len,
    length(printt(repeat('x', 5000))) AS returned_len,
    printt(repeat('x', 5000)) = repeat('x', 5000) AS equal_direct,
    pg_column_size(repeat('x', 5000)::text) AS storage_bytes_direct; -- 5000, 5000, t, 5004
BEGIN;
CREATE TEMP TABLE t_toast_test(id int GENERATED ALWAYS AS IDENTITY PRIMARY KEY, t text)
ON COMMIT DROP;
INSERT INTO t_toast_test(t) VALUES (repeat('x', 5000));
SELECT id,
    pg_column_size(t) AS storage_bytes
FROM t_toast_test; -- 69
SELECT id,
    length(printt(t)) AS returned_len,
    printt(t) = t AS equal_from_table
FROM t_toast_test; -- 1, 5000, t
SELECT
    (length(printt(t)) = length(t)) AS len_matches,
    (printt(t) = t) AS content_matches
FROM t_toast_test; -- t, t
COMMIT;
SELECT printb('\x010203'::bytea); -- '\x010203'
SELECT
    '\x01020304ff'::bytea AS input,
    printb('\x01020304ff'::bytea) AS output,
    printb('\x01020304ff'::bytea) = '\x01020304ff'::bytea AS equal_short; -- '\x01020304ff', '\x01020304ff', t
SELECT
    length(decode(repeat('AA', 1000), 'hex')) AS expected_len,
    length(printb(decode(repeat('AA', 1000), 'hex'))) AS returned_len,
    encode(printb(decode(repeat('AA', 1000), 'hex')), 'hex')
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
    length(printb(b)) AS returned_len,
    encode(printb(b), 'hex') = encode(b, 'hex') AS equal_from_table
FROM t_bytea_toast; -- 1, 8000, t
SELECT
    (length(printb(b)) = length(b)) AS len_matches,
    (encode(printb(b), 'hex') = encode(b, 'hex')) AS content_matches
FROM t_bytea_toast; -- t, t
COMMIT;
