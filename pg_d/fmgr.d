module pg_d.fmgr;

import pg_d.abi;                 // Datum, FunctionCallInfo, NullableDatum, text, fcinfo_args
import core.stdc.string : memcpy; // memcpy used for low-level operations

extern (C):
/**
Return raw Datum argument from FunctionCallInfo.
*/

Datum PG_GETARG_DATUM(FunctionCallInfo fcinfo, int n)
{
    return fcinfo_args(fcinfo)[n].value;
}

/**
Check whether nth argument is NULL.
*/
bool PG_ARGISNULL(FunctionCallInfo fcinfo, int n)
{
    return fcinfo_args(fcinfo)[n].isnull;
}

/**
Get int32 argument (simple conversion).
*/
int PG_GETARG_INT32(FunctionCallInfo fcinfo, int n)
{
    return cast(int)PG_GETARG_DATUM(fcinfo, n);
}

/**
Return an int32 value to PostgreSQL.
*/
Datum PG_RETURN_INT32(FunctionCallInfo fcinfo, int x)
{
    fcinfo.isnull = false;
    return cast(Datum)x;
}

/**
Registration structure for pg_finfo_* symbols.
This structure mimics the small info-record used by PG_FUNCTION_INFO_V1.
*/

struct Pg_finfo_record
{
    int api_version;
}

/**
Convert a native pointer to Datum.
*/

Datum PointerGetDatum(void* p)
{
    return cast(Datum) p;
}

/**
Convert Datum to native pointer.
*/
void* DatumGetPointer(Datum d)
{
    return cast(void*) d;
}

/**
Get pointer argument from fcinfo (wrapper).
*/

void* PG_GETARG_POINTER(FunctionCallInfo fcinfo, int n)
{
    return DatumGetPointer(PG_GETARG_DATUM(fcinfo, n));
}

/**
Standard varlena header size used by PostgreSQL (bytes).
*/
enum int VARHDRSZ = 4;

/**
Return total size (VARSIZE) stored in varlena header.
*/
int VARSIZE_ANY(void* vp)
{
    return *cast(int*)(cast(ubyte*)vp);
}

/**
Return size of payload excluding varlena header.
*/
int VARSIZE_ANY_EXHDR(void* vp)
{
    auto vs = VARSIZE_ANY(vp);
    return vs - VARHDRSZ;
}

/**
Return pointer to payload (VARDATA) of varlena.
*/
void* VARDATA_ANY(void* vp)
{
    return cast(void*)(cast(ubyte*)vp + VARHDRSZ);
}

/**
Declare detoast helper.
The function returns a pointer to a plain/packed varlena:
 - if input is already plain, returns same pointer;
 - if input is toasted/compressed/external, returns palloc'd copy.
*/
extern (C) text* pg_detoast_datum_packed(text* datum);

/**
Convert Datum to text* (packed/plain pointer) helper.
*/
text* DatumGetTextPP(Datum d)
{
    auto ptr = cast(text*) DatumGetPointer(d);
    return pg_detoast_datum_packed(ptr);
}

/**
Get varlena/text argument without detoasting.
This is a low-level helper and unsafe for toasted values.
*/
text* PG_GETARG_VARLENA(FunctionCallInfo fcinfo, int n)
{
    return cast(text*) PG_GETARG_POINTER(fcinfo, n);
}

/**
Get text argument (packed/plain pointer) and detoast if needed.
This mirrors the C macro PG_GETARG_TEXT_PP from fmgr.h.
*/

text* PG_GETARG_TEXT_PP(FunctionCallInfo fcinfo, int n)
{
    Datum d = PG_GETARG_DATUM(fcinfo, n);
    return DatumGetTextPP(d);
}

/**
Return a varlena value to PostgreSQL.
Marks the return value as non-null and converts pointer to Datum.
*/
Datum PG_RETURN_VARLENA(FunctionCallInfo fcinfo, text* t)
{
    fcinfo.isnull = false;
    return PointerGetDatum(cast(void*)t);
}

/**
Return a bytea value to PostgreSQL.
Marks the return value as non-null and converts pointer to Datum.
*/
bytea* DatumGetByteaPP(Datum d)
{
    // Datum -> pointer, then detoast.
    auto ptr = cast(bytea*) DatumGetPointer(d);
    return pg_detoast_datum_packed(cast(text*)ptr); // reuse detoast
}

/**
Get bytea argument (packed/plain pointer).
This mirrors the C macro PG_GETARG_BYTEA_PP and is detoast-safe.
*/
bytea* PG_GETARG_BYTEA_PP(FunctionCallInfo fcinfo, int n)
{
    Datum d = PG_GETARG_DATUM(fcinfo, n);
    return DatumGetByteaPP(d);
}

/**
Get raw bytea pointer without detoast (unsafe for toasted values).
This mirrors the C macro PG_GETARG_VARLENA for binary data.
*/
bytea* PG_GETARG_VARBYTEA(FunctionCallInfo fcinfo, int n)
{
    return cast(bytea*) PG_GETARG_POINTER(fcinfo, n);
}

/**
Return bytea value to PostgreSQL (as Datum).
Marks return as non-null and converts pointer to Datum.
*/
Datum PG_RETURN_BYTEA(FunctionCallInfo fcinfo, bytea* b)
{
    fcinfo.isnull = false;
    return PointerGetDatum(cast(void*)b);
}

/**
Bytea size / data helpers (aliases to varlena helpers).
VARSIZE_ANY / VARDATA_ANY as defined earlier are used.
*/
int VARSIZE_BYTEA(bytea* b)
{
    return VARSIZE_ANY(cast(void*)b);
}

void* VARDATA_BYTEA(bytea* b)
{
    return VARDATA_ANY(cast(void*)b);
}

/**
Return text value to PostgreSQL (as Datum).
Marks return as non-null and converts pointer to Datum.
*/
Datum PG_RETURN_TEXT(FunctionCallInfo fcinfo, text* t)
{
    fcinfo.isnull = false;
    return PointerGetDatum(cast(void*)t);
}
