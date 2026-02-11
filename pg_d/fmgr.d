module pg_d.fmgr;

import pg_d.abi;
import core.stdc.string : memcpy;

extern (C):

/**
Simple fmgr-helpers, minimalistic realisation
*/

Datum PG_GETARG_DATUM(FunctionCallInfo fcinfo, int n)
{
    return fcinfo_args(fcinfo)[n].value;
}

bool PG_ARGISNULL(FunctionCallInfo fcinfo, int n)
{
    return fcinfo_args(fcinfo)[n].isnull;
}

int PG_GETARG_INT32(FunctionCallInfo fcinfo, int n)
{
    return cast(int)PG_GETARG_DATUM(fcinfo, n);
}

Datum PG_RETURN_INT32(FunctionCallInfo fcinfo, int x)
{
    fcinfo.isnull = false;
    return cast(Datum)x;
}

/**
reg structure for pg_finfo_*
*/

struct Pg_finfo_record
{
    int api_version;
}

/**
Datum to pointer interconverters
*/

Datum PointerGetDatum(void* p)
{
    return cast(Datum) p;
}

void* DatumGetPointer(Datum d)
{
    return cast(void*) d;
}

/**
Get pointer arg from fcinfo
*/

void* PG_GETARG_POINTER(FunctionCallInfo fcinfo, int n)
{
    return DatumGetPointer(PG_GETARG_DATUM(fcinfo, n));
}

/**
Simple Varlena/text helpers
Only works when arg already detoasted
TODO: pg_detoast_datum_packed / pg_detoast_datum calls
*/

enum int VARHDRSZ = 4; // standard varlena header (4 bytes)

/// Low-level operations for varlena (VARSIZE/VARDATA)
int VARSIZE_ANY(void* vp)
{
    return *cast(int*)(cast(ubyte*)vp);
}

int VARSIZE_ANY_EXHDR(void* vp)
{
    auto vs = VARSIZE_ANY(vp);
    return vs - VARHDRSZ;
}

void* VARDATA_ANY(void* vp)
{
    return cast(void*)(cast(ubyte*)vp + VARHDRSZ);
}

/**
Get arg from varlena/text (w/o detoasting)
*/

text* PG_GETARG_VARLENA(FunctionCallInfo fcinfo, int n)
{
    // return pointer to varlena WITHOUT detoasting
    return cast(text*) PG_GETARG_POINTER(fcinfo, n);
}

/**
Useful (simplified) alias PG_GETARG_TEXT_PP (packed/plain pointer)
*/

text* PG_GETARG_TEXT_PP(FunctionCallInfo fcinfo, int n)
{
    // TODO: introduce detoast as needed
    return PG_GETARG_VARLENA(fcinfo, n);
}

/**
Return varlena
*/

Datum PG_RETURN_VARLENA(FunctionCallInfo fcinfo, text* t)
{
    fcinfo.isnull = false;
    return PointerGetDatum(cast(void*)t);
}