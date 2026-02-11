module pg_d.srf;

import pg_d.abi;
import pg_d.fmgr;
import pg_d.mem;

extern (C):

/**
Simplified structures for SRF (ReturnSetInfo etc)
Caution: real structures in PostgreSQL are reacher; here we have scaffolding for initial realisation
*/

enum ReturnMode { SFRM_ValuePerCall = 0, SFRM_Materialize = 1 }

struct ReturnSetInfo
{
    int64_t dummy; // placeholder
    int returnMode; // enum ReturnMode
    void* setResult; // tuplestore pointer in real PG
    void* setDesc; // tupledesc
}

/**
Simplified initialize for materialize SRF helper
*/

ReturnSetInfo* init_materialize_srf(FunctionCallInfo fcinfo)
{
    auto rs = cast(ReturnSetInfo*) fcinfo.resultinfo;
    if (rs is null)
    {
// Not an SRF call
        return null;
    }
// TODO: check for the type and create tuplestore/tupledesc
    return rs;
}