module pg_d.abi;

import pg_d.fmgr;

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

enum NAMEDATALEN = 64;

// not sure actually, but probably ubyte instead of char is better solution here 
struct NameData
{
    ubyte[NAMEDATALEN] data;
}

/**
Alias for name
*/

alias name = NameData;

/**
Alias for text
*/
alias text = varlena;

/**
Alias for bytea
*/
alias bytea = varlena; // bytea is the same low-level varlena layout as text
