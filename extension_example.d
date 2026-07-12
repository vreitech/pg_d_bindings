module extension_example;

import pg_d.helper;  // RegisterAllPgFunctions
import pg_d.abi;     // Datum, FunctionCallInfo, Pg_finfo_record
import pg_d.fmgr;    // PG_GETARG_* / PG_RETURN_* helpers
import pg_d.srf;     // SRF functions
// import pg_d.pgtext;  // optional extra text helpers

extern (C):

/**
myfunction: doubles int
*/
@PgFunction
export extern(C) Datum myfunction(FunctionCallInfo fcinfo)
{
    int arg = PG_GETARG_INT32(fcinfo, 0);
    return PG_RETURN_INT32(fcinfo, arg * 2);
}

/**
myfunction_debug: returns nargs
*/
@PgFunction
export extern(C) Datum myfunction_debug(FunctionCallInfo fcinfo)
{
    int nargs = cast(int)fcinfo.nargs;
    return PG_RETURN_INT32(fcinfo, nargs);
}

/**
add_numbers: addition of two numbers
*/
@PgFunction
export extern(C) Datum add_numbers(FunctionCallInfo fcinfo)
{
    int arg1 = PG_GETARG_INT32(fcinfo, 0);
    int arg2 = PG_GETARG_INT32(fcinfo, 1);
    return PG_RETURN_INT32(fcinfo, arg1 + arg2);
}

/**
print_text: prints text
*/
@PgFunction
export extern(C) Datum print_text(FunctionCallInfo fcinfo)
{
    text* arg = PG_GETARG_TEXT_PP(fcinfo, 0);  // detoast-safe text
    return PG_RETURN_TEXT(fcinfo, arg);
}

/**
print_varchar: prints varchar
*/
@PgFunction
export extern(C) Datum print_varchar(FunctionCallInfo fcinfo)
{
    text* arg = PG_GETARG_TEXT_PP(fcinfo, 0);  // detoast-safe text
    return PG_RETURN_VARCHAR(fcinfo, arg);
}

/**
print_name: prints name
*/
@PgFunction
export extern(C) Datum print_name(FunctionCallInfo fcinfo)
{
    bytea* arg = PG_GETARG_BYTEA_PP(fcinfo, 0);  // detoast-safe text
    return PG_RETURN_BYTEA(fcinfo, arg);
}

/**
print_bytea: prints bytea (binary data)
*/
@PgFunction
export extern(C) Datum print_bytea(FunctionCallInfo fcinfo)
{
    bytea* arg = PG_GETARG_BYTEA_PP(fcinfo, 0);  // detoast-safe bytea
    return PG_RETURN_BYTEA(fcinfo, arg);
}

/**
Automatic registration of all functions
*/
mixin RegisterAllPgFunctions;