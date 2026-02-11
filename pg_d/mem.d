module pg_d.mem;

/**
Minimalistic declarations to work with memory in PostgreSQL
*/

extern (C):

alias MemoryContext = void*;

// General allocators declarations
void* palloc(size_t size);
void pfree(void* ptr);

MemoryContext CurrentMemoryContext();
MemoryContext MemoryContextSwitchTo(MemoryContext newctx);