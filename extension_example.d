module extension_example;

import abi;   // содержит Datum, FunctionCallInfo, NullableDatum, text и т.п.
import fmgr;  // содержит PG_GETARG_* / PG_RETURN_* (минимальные)
import srf;   // если нужен SRF-скелет
// import pgtext; // если используешь текстовые помощники

extern (C):

// ----------------- Реализации функций -----------------

// myfunction: удваивает int
export extern(C) Datum myfunction(FunctionCallInfo fcinfo)
{
    int arg = PG_GETARG_INT32(fcinfo, 0);
    return PG_RETURN_INT32(fcinfo, arg * 2);
}

// отладочная функция: возвращает nargs
export extern(C) Datum myfunction_debug(FunctionCallInfo fcinfo)
{
    int nargs = cast(int)fcinfo.nargs;
    return PG_RETURN_INT32(fcinfo, nargs);
}

// test_simple: тестовая функция без аргументов
export extern(C) Datum test_simple(FunctionCallInfo fcinfo)
{
    return cast(Datum)42;
}

// add_numbers: сложение двух чисел
export extern(C) Datum add_numbers(FunctionCallInfo fcinfo)
{
    int arg1 = PG_GETARG_INT32(fcinfo, 0);
    int arg2 = PG_GETARG_INT32(fcinfo, 1);
    return PG_RETURN_INT32(fcinfo, arg1 + arg2);
}

// printt: печатает текст
export extern(C) Datum printt(FunctionCallInfo fcinfo)
{
    text* arg = PG_GETARG_VARLENA(fcinfo, 0);
    return PG_RETURN_VARLENA(fcinfo, arg);
}

// ----------------- Шаблон автогенерации pg_finfo_* -----------------

/*
  RegisterPgFunction генерирует в бинарнике символ:
    export extern(C) const(Pg_finfo_record)* pg_finfo_<func>()
  который эквивалентен PG_FUNCTION_INFO_V1(func) в C.

  Использование:
    mixin RegisterPgFunction!"myfunction";
  или
    enum funcs = ["myfunction","myfunction_debug"];
    static foreach (f; funcs) mixin RegisterPgFunction!(f);
*/
template RegisterPgFunction(string func)
{
    // Простейшая валидация имени (компиляторная)
    static if (func.length == 0)
        static assert(false, "RegisterPgFunction: empty function name");

    // Собираем тело функции как строку и вставляем через mixin
    enum string finfoName = "pg_finfo_" ~ func;

    // Генерируем код для pg_finfo_<func>
    mixin("export extern(C) const(Pg_finfo_record)* " ~ finfoName ~ "()\n" ~
          "{\n" ~
          "    __gshared Pg_finfo_record info = Pg_finfo_record(1);\n" ~
          "    return &info;\n" ~
          "}\n");
}

// ----------------- Автоматическая регистрация всех функций -----------------

static enum string[] exportedFunctions = [
    "myfunction",
    "myfunction_debug",
    "test_simple",
    "add_numbers",
    "printt"
];

static foreach (fname; exportedFunctions)
{
    mixin RegisterPgFunction!(fname);
}

