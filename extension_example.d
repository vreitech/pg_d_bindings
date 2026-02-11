module extension_example;

import abi;     // contains Datum, FunctionCallInfo, NullableDatum, text etc.
import fmgr;    // contains PG_GETARG_* / PG_RETURN_* (minimal)
import srf;     // if SRF skeleton is needed
// import pgtext;  // if you use text helpers

extern (C):

/**
 * myfunction: doubles int
 */
export extern(C) Datum myfunction(FunctionCallInfo fcinfo)
{
    int arg = PG_GETARG_INT32(fcinfo, 0);
    return PG_RETURN_INT32(fcinfo, arg * 2);
}

/**
 * debug function: returns nargs
 */
export extern(C) Datum myfunction_debug(FunctionCallInfo fcinfo)
{
    int nargs = cast(int)fcinfo.nargs;
    return PG_RETURN_INT32(fcinfo, nargs);
}

/**
 * test_simple: test function without arguments
 */
export extern(C) Datum test_simple(FunctionCallInfo fcinfo)
{
    return cast(Datum)42;
}

/**
 * add_numbers: addition of two numbers
 */
export extern(C) Datum add_numbers(FunctionCallInfo fcinfo)
{
    int arg1 = PG_GETARG_INT32(fcinfo, 0);
    int arg2 = PG_GETARG_INT32(fcinfo, 1);
    return PG_RETURN_INT32(fcinfo, arg1 + arg2);
}

/**
 * printt: prints text
 */
export extern(C) Datum printt(FunctionCallInfo fcinfo)
{
    text* arg = PG_GETARG_VARLENA(fcinfo, 0);
    return PG_RETURN_VARLENA(fcinfo, arg);
}

/**
 * RegisterPgFunction generates in the binary symbol:
 *   export extern(C) const(Pg_finfo_record)* pg_finfo_<func>()
 * which is equivalent to PG_FUNCTION_INFO_V1(func) in C.
 *
 * Usage:
 *   mixin RegisterPgFunction!"myfunction";
 * or
 *   enum funcs = ["myfunction","myfunction_debug"];
 *   static foreach (f; funcs) mixin RegisterPgFunction!(f);
 */
template RegisterPgFunction(string func)
{
    // Simple name validation (compiler-time)
    static if (func.length == 0)
        static assert(false, "RegisterPgFunction: empty function name");

    // Assemble function body as string and insert via mixin
    enum string finfoName = "pg_finfo_" ~ func;

    // Generate code for pg_finfo_<func>
    mixin("export extern(C) const(Pg_finfo_record)* " ~ finfoName ~ "()\n" ~
          "{\n" ~
          "    __gshared Pg_finfo_record info = Pg_finfo_record(1);\n" ~
          "    return &info;\n" ~
          "}\n");
}

/**
 * Declaration of all functions that can be registered
 */
static enum string[] exportedFunctions = [
    "myfunction",
    "myfunction_debug",
    "test_simple",
    "add_numbers",
    "printt"
];

/**
 * Automatic registration of all functions
 */
static foreach (fname; exportedFunctions)
{
    mixin RegisterPgFunction!(fname);
}
