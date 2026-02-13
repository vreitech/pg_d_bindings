module extension_example;

import pg_d.abi;     // Datum, FunctionCallInfo, NullableDatum, text, bytea, etc.
import pg_d.fmgr;    // PG_GETARG_* / PG_RETURN_* helpers
import pg_d.srf;     // SRF functions
// import pg_d.pgtext;  // optional extra text helpers

extern (C):

/**
myfunction: doubles int
*/
export extern(C) Datum myfunction(FunctionCallInfo fcinfo)
{
    int arg = PG_GETARG_INT32(fcinfo, 0);
    return PG_RETURN_INT32(fcinfo, arg * 2);
}

/**
myfunction_debug: returns nargs
*/
export extern(C) Datum myfunction_debug(FunctionCallInfo fcinfo)
{
    int nargs = cast(int)fcinfo.nargs;
    return PG_RETURN_INT32(fcinfo, nargs);
}

/**
test_simple: test function without arguments
*/
export extern(C) Datum test_simple(FunctionCallInfo fcinfo)
{
    return cast(Datum)42;
}

/**
add_numbers: addition of two numbers
*/
export extern(C) Datum add_numbers(FunctionCallInfo fcinfo)
{
    int arg1 = PG_GETARG_INT32(fcinfo, 0);
    int arg2 = PG_GETARG_INT32(fcinfo, 1);
    return PG_RETURN_INT32(fcinfo, arg1 + arg2);
}

/**
print_text: prints text
*/
export extern(C) Datum print_text(FunctionCallInfo fcinfo)
{
    text* arg = PG_GETARG_TEXT_PP(fcinfo, 0);  // detoast-safe text
    return PG_RETURN_TEXT(fcinfo, arg);
}

/**
print_varchar: prints varchar
*/
export extern(C) Datum print_varchar(FunctionCallInfo fcinfo)
{
    text* arg = PG_GETARG_TEXT_PP(fcinfo, 0);  // detoast-safe text
    return PG_RETURN_VARCHAR(fcinfo, arg);
}

/**
print_name: prints name
*/
export extern(C) Datum print_name(FunctionCallInfo fcinfo)
{
    bytea* arg = PG_GETARG_BYTEA_PP(fcinfo, 0);  // detoast-safe text
    return PG_RETURN_BYTEA(fcinfo, arg);
}

/**
print_bytea: prints bytea (binary data)
*/
export extern(C) Datum print_bytea(FunctionCallInfo fcinfo)
{
    bytea* arg = PG_GETARG_BYTEA_PP(fcinfo, 0);  // detoast-safe bytea
    return PG_RETURN_BYTEA(fcinfo, arg);
}

/**
RegisterPgFunction generates in the binary symbol:
  export extern(C) const(Pg_finfo_record)* pg_finfo_<func>()
which is equivalent to PG_FUNCTION_INFO_V1(func) in C.
*/
template RegisterPgFunction(string func)
{
    // compile-time name validation
    static if (func.length == 0)
        static assert(false, "RegisterPgFunction: empty function name");

    // assemble function body as string and insert via mixin
    enum string finfoName = "pg_finfo_" ~ func;

    // generate code for pg_finfo_<func>
    mixin("export extern(C) const(Pg_finfo_record)* " ~ finfoName ~ "()\n" ~
        "{\n" ~
        "    __gshared Pg_finfo_record info = Pg_finfo_record(1);\n" ~
        "    return &info;\n" ~
        "}\n");
}

/**
Declaration of all functions that can be registered
*/
static enum string[] exportedFunctions = [
    "myfunction",
    "myfunction_debug",
    "test_simple",
    "add_numbers",
    "print_text",
    "print_varchar",
    "print_name",
    "print_bytea"
];

/**
Automatic registration of all functions
*/
static foreach (fname; exportedFunctions)
{
    mixin RegisterPgFunction!(fname);
}
