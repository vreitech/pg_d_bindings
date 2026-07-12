module pg_d.helper;

import pg_d.abi;   // Datum, FunctionCallInfo, Pg_finfo_record
import std.traits : hasUDA, Parameters, ReturnType;

/// Marker of exported function
struct PgFunction {}

/**
RegisterPgFunction generates symbol
  export extern(C) const(Pg_finfo_record)* pg_finfo_<func>()
that equivalent for PG_FUNCTION_INFO_V1(func) in C.
*/
template RegisterPgFunction(string func)
{
    static if (func.length == 0)
        static assert(false, "RegisterPgFunction: empty function name");

    enum string finfoName = "pg_finfo_" ~ func;

    mixin("export extern(C) const(Pg_finfo_record)* " ~ finfoName ~ "()\n" ~
        "{\n" ~
        "    __gshared Pg_finfo_record info = Pg_finfo_record(1);\n" ~
        "    return &info;\n" ~
        "}\n");
}

/// Checks that 'mod' with name 'name' is function marked by @PgFunction
template isExportedPgFunction(alias mod, string name)
{
    static if (__traits(compiles, __traits(getMember, mod, name)))
    {
        alias sym = __traits(getMember, mod, name);
        static if (__traits(compiles, hasUDA!(sym, PgFunction)))
            enum isExportedPgFunction = hasUDA!(sym, PgFunction);
        else
            enum isExportedPgFunction = false;
    }
    else
        enum isExportedPgFunction = false;
}

/**
Finds all module's functions marked by @PgFunction,
and generates pg_finfo_<name> for each one.
*/
mixin template RegisterAllPgFunctions()
{
    static foreach (__pgfname; __traits(allMembers, mixin(__MODULE__)))
    {
        static if (isExportedPgFunction!(mixin(__MODULE__), __pgfname))
            mixin RegisterPgFunction!(__pgfname);
    }
}