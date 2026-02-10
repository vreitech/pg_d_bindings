module pgtext;

import abi;
import mem;
import core.stdc.string : strlen, memcpy;

enum int VARHDRSZ = 4;   // standard varlena header (4 bytes)

extern (C):

/**
Convert nul-terminated C-string to text* (via palloc)
*/

text* cstring_to_text(const(char)* s)
{
    if (s is null) return null;

    size_t len = strlen(s);
    size_t total = cast(size_t)(VARHDRSZ + len);

    auto p = cast(ubyte*) palloc(total);

    // VARSIZE (vl_len_)
    *cast(int*)p = cast(int) total;

    // data after the header
    memcpy(cast(void*)(p + VARHDRSZ), cast(const void*)s, len);

    return cast(text*)p;
}

/**
Convert text* to C-string (via palloc)
*/

const(char)* text_to_cstring(text* t)
{
    if (t is null) return null;

    auto base = cast(ubyte*) t;

    // getting vl_len_
    int size = *cast(int*) base;

    size_t len;
    if (size > VARHDRSZ)
        len = cast(size_t)(size - VARHDRSZ);
    else
        len = 0;

    auto data_ptr = base + VARHDRSZ;

    auto outbuf = cast(char*) palloc(len + 1);

    if (len > 0)
        memcpy(outbuf, data_ptr, len);

    outbuf[len] = 0; // nul-terminate

    return outbuf;
}

