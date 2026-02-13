module pg_d.pgmagic;

extern (C):

/**
ABI struct
*/

struct Pg_abi_values
{
    int version_;         // PostgreSQL major / 100
    int funcmaxargs;
    int indexmaxkeys;
    int namedatalen;
    int float8byval;
    char[32] abi_extra;
}

/**
Pg_magic_struct structure
*/

struct Pg_magic_struct
{
    int len;
    Pg_abi_values abi_fields;
    const(char)* name;
    const(char)* version_;
}

/**
Constants (PostgreSQL 18)
*/

enum int PG_VERSION_NUM    = 18_00_00;
enum int FUNC_MAX_ARGS     = 100;
enum int INDEX_MAX_KEYS    = 32;
enum int NAMEDATALEN       = 64;
enum int FLOAT8PASSBYVAL   = 1;

/**
Static data
*/

__gshared char[11] pg_name_str = "PostgreSQL";

/**
pg_magic_data
*/

__gshared Pg_magic_struct pg_magic_data = {
    Pg_magic_struct.sizeof,
    Pg_abi_values(
        PG_VERSION_NUM / 100,
        FUNC_MAX_ARGS,
        INDEX_MAX_KEYS,
        NAMEDATALEN,
        FLOAT8PASSBYVAL,
        cast(char[32])("PostgreSQL")
    ),
    cast(const(char)*)pg_name_str.ptr,
    null
};

/**
Exported Pg_magic_func function
*/

export extern(C) Pg_magic_struct* Pg_magic_func()
{
    return &pg_magic_data;
}
