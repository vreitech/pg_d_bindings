module pg_d.abi;

extern (C):

/**
Low-level aliases and structures that depends on PostgreSQL ABI
*/

alias Datum = size_t;
alias Oid = uint;

alias int64_t = long;
alias int32_t = int;
alias uint32_t = uint;

/**
NullableDatum structure
*/

struct NullableDatum
{
    Datum value;
    bool isnull;
}

/**
Basic FunctionCallInfoBaseData structure (w/o inline args)
*/

struct FunctionCallInfoBaseData
{
    void* flinfo;
    void* context;
    void* resultinfo;
    Oid fncollation;
    bool isnull;
    short nargs;
// inline args follow immediately after this struct in memory
}

alias FunctionCallInfo = FunctionCallInfoBaseData*;

/**
fcinfo_args helper
Get pointer to the first NullableDatum after the structure
*/

NullableDatum* fcinfo_args(FunctionCallInfo fcinfo)
{
    return cast(NullableDatum*)(cast(ubyte*)fcinfo + FunctionCallInfoBaseData.sizeof);
}

/**
Simple typedefs for varlena/text
*/

struct varlena
{
    int vl_len_;
// flexible data follows
}
alias text = varlena;