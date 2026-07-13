#ifndef clox_common_h
#define clox_common_h

#include <stdbool.h>
#include <stddef.h>
#include <stdint.h>

// Debug flags (also settable via -D on the compiler command line):
//   DEBUG_TRACE_EXECUTION  - dump the stack + disassemble each instruction as it runs
//   DEBUG_PRINT_CODE       - disassemble each function chunk right after compiling
//   DEBUG_STRESS_GC        - run the garbage collector on every allocation
//   DEBUG_LOG_GC           - log GC allocation / free / mark / sweep activity

// #define DEBUG_TRACE_EXECUTION
// #define DEBUG_PRINT_CODE
// #define DEBUG_STRESS_GC
// #define DEBUG_LOG_GC

#define UINT8_COUNT (UINT8_MAX + 1)

#endif
